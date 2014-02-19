import difflib
import posixpath

from mercurial import util as hgutil
from mercurial import error
from mercurial import worker

import svnwrap
import svnrepo
import util
import editor

def verify(ui, repo, args=None, **opts):
    '''verify current revision against Subversion repository
    '''

    if repo is None:
        raise error.RepoError("There is no Mercurial repository"
                              " here (.hg not found)")

    ctx = repo[opts.get('rev', '.')]
    if 'close' in ctx.extra():
        ui.write('cannot verify closed branch')
        return 0
    convert_revision = ctx.extra().get('convert_revision')
    if convert_revision is None or not convert_revision.startswith('svn:'):
        raise hgutil.Abort('revision %s not from SVN' % ctx)

    if args:
        url = repo.ui.expandpath(args[0])
    else:
        url = repo.ui.expandpath('default')

    svn = svnrepo.svnremoterepo(ui, url).svn
    meta = repo.svnmeta(svn.uuid, svn.subdir)
    srev, branch, branchpath = meta.get_source_rev(ctx=ctx)

    branchpath = branchpath[len(svn.subdir.lstrip('/')):]
    branchurl = ('%s/%s' % (url, branchpath)).strip('/')

    ui.write('verifying %s against %s@%i\n' % (ctx, branchurl, srev))

    def diff_file(path, svndata):
        fctx = ctx[path]

        if ui.verbose and not fctx.isbinary():
            svndesc = '%s/%s/%s@%d' % (svn.svn_url, branchpath, path, srev)
            hgdesc = '%s@%s' % (path, ctx)

            for c in difflib.unified_diff(svndata.splitlines(True),
                                          fctx.data().splitlines(True),
                                          svndesc, hgdesc):
                ui.note(c)

    if opts.get('stupid', ui.configbool('hgsubversion', 'stupid')):
        svnfiles = set()
        result = 0

        hgfiles = set(ctx) - util.ignoredfiles

        def verifydata(svndata):
            svnworker = svnrepo.svnremoterepo(ui, url).svn

            i = 0
            res = True
            for fn, type in svndata:
                i += 1
                if type != 'f':
                    continue

                fp = fn
                if branchpath:
                    fp = branchpath + '/' + fn
                data, mode = svnworker.get_file(posixpath.normpath(fp), srev)
                try:
                    fctx = ctx[fn]
                except error.LookupError:
                    yield i, "%s\0%r" % (fn, res)
                    continue

                if not fctx.data() == data:
                    ui.write('difference in: %s\n' % fn)
                    diff_file(fn, data)
                    res = False
                if not fctx.flags() == mode:
                    ui.write('wrong flags for: %s\n' % fn)
                    res = False
                yield i, "%s\0%r" % (fn, res)

        if url.startswith('file://'):
            perarg = 0.00001
        else:
            perarg = 0.000001

        svndata = svn.list_files(branchpath, srev)
        w = worker.worker(repo.ui, perarg, verifydata, (), tuple(svndata))
        i = 0
        for _, t in w:
            ui.progress('verify', i, total=len(hgfiles))
            i += 1
            fn, ok = t.split('\0', 2)
            if not bool(ok):
                result = 1
            svnfiles.add(fn)

        if hgfiles != svnfiles:
            unexpected = hgfiles - svnfiles
            for f in sorted(unexpected):
                ui.write('unexpected file: %s\n' % f)
            missing = svnfiles - hgfiles
            for f in sorted(missing):
                ui.write('missing file: %s\n' % f)
            result = 1

        ui.progress('verify', None, total=len(hgfiles))

    else:
        class VerifyEditor(svnwrap.Editor):
            """editor that verifies a repository against the given context."""
            def __init__(self, ui, ctx):
                self.ui = ui
                self.ctx = ctx
                self.unexpected = set(ctx) - util.ignoredfiles
                self.missing = set()
                self.failed = False

                self.total = len(self.unexpected)
                self.seen = 0

            def open_root(self, base_revnum, pool=None):
                pass

            def add_directory(self, path, parent_baton, copyfrom_path,
                              copyfrom_revision, pool=None):
                self.file = None
                self.props = None

            def open_directory(self, path, parent_baton, base_revision, pool=None):
                self.file = None
                self.props = None

            def add_file(self, path, parent_baton=None, copyfrom_path=None,
                         copyfrom_revision=None, file_pool=None):

                if path in self.unexpected:
                    self.unexpected.remove(path)
                    self.file = path
                    self.props = {}
                else:
                    self.total += 1
                    self.missing.add(path)
                    self.failed = True
                    self.file = None
                    self.props = None

                self.seen += 1
                self.ui.progress('verify', self.seen, total=self.total)

            def open_file(self, path, base_revnum):
                raise NotImplementedError()

            def apply_textdelta(self, file_baton, base_checksum, pool=None):
                stream = svnwrap.SimpleStringIO(closing=False)
                handler = svnwrap.apply_txdelta('', stream)
                if not callable(handler):
                    raise hgutil.Abort('Error in Subversion bindings: '
                                       'cannot call handler!')
                def txdelt_window(window):
                    handler(window)
                    # window being None means we're done
                    if window:
                        return

                    fctx = self.ctx[self.file]
                    hgdata = fctx.data()
                    svndata = stream.getvalue()

                    if 'svn:executable' in self.props:
                        if fctx.flags() != 'x':
                            self.ui.warn('wrong flags for: %s\n' % self.file)
                            self.failed = True
                    elif 'svn:special' in self.props:
                        hgdata = 'link ' + hgdata
                        if fctx.flags() != 'l':
                            self.ui.warn('wrong flags for: %s\n' % self.file)
                            self.failed = True
                    elif fctx.flags():
                        self.ui.warn('wrong flags for: %s\n' % self.file)
                        self.failed = True

                    if hgdata != svndata:
                        self.ui.warn('difference in: %s\n' % self.file)
                        diff_file(self.file, svndata)
                        self.failed = True

                if self.file is not None:
                    return txdelt_window

            def change_dir_prop(self, dir_baton, name, value, pool=None):
                pass

            def change_file_prop(self, file_baton, name, value, pool=None):
                if self.props is not None:
                    self.props[name] = value

            def close_file(self, file_baton, checksum, pool=None):
                pass

            def close_directory(self, dir_baton, pool=None):
                pass

            def delete_entry(self, path, revnum, pool=None):
                raise NotImplementedError()

            def check(self):
                self.ui.progress('verify', None, total=self.total)

                for f in self.unexpected:
                    self.ui.warn('unexpected file: %s\n' % f)
                    self.failed = True
                for f in self.missing:
                    self.ui.warn('missing file: %s\n' % f)
                    self.failed = True
                return not self.failed

        v = VerifyEditor(ui, ctx)
        svnrepo.svnremoterepo(ui, branchurl).svn.get_revision(srev, v)
        if v.check():
            result = 0
        else:
            result = 1

    return result
