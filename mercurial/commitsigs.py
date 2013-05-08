# commitsigs.py - sign changesets upon commit
#
# Copyright 2009, 2010 Matt Mackall <mpm@selenic.com> and others
#
# This software may be used and distributed according to the terms of the
# GNU General Public License version 2, incorporated herein by reference.

"""sign changesets upon commit

This extension will use GnuPG or OpenSSL to sign the changeset hash
upon each commit and embed the signature directly in the changelog.

Use 'hg log --debug' to see the extra meta data for each changeset,
including the signature.

You must first select the desired signature scheme::

  [commitsigs]
  scheme = gnupg

The two recognized schemes are ``gnupg`` (the default) and
``openssl``. If you use ``gnupg``, then you normally wont have to
configure other options. However, if ``gpg`` is not in your path or if
you have multiple private keys, then you may want to set the following
options::

  [commitsigs]
  gnupg.path = mygpg
  gnupg.flags = --local-user me

The ``openssl`` scheme requires a little more configuration. You need
to specify the path to your X509 certificate file and to a directory
filled with trusted certificates::

  [commitsigs]
  scheme = openssl
  openssl.certificate = my-cert.pem
  openssl.capath = trusted-certificates

You must use the ``c_rehash`` program from OpenSSL to prepare the
directoy with trusted certificates for use by OpenSSL. Otherwise
OpenSSL wont be able to lookup the certificates.
"""

import os, tempfile, subprocess, binascii, shlex

from mercurial import (util, cmdutil, extensions, revlog, error,
                       encoding, changelog)
from mercurial.node import short, hex, nullid
from mercurial.i18n import _


CONFIG = {
    'scheme': 'gnupg',
    'gnupg.path': 'gpg',
    'gnupg.flags': [],
    'openssl.path': 'openssl',
    'openssl.capath': '',
    'openssl.certificate': ''
    }


def gnupgsign(msg):
    cmd = [CONFIG["gnupg.path"], "--detach-sign"] + CONFIG["gnupg.flags"]
    p = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    sig = p.communicate(msg)[0]
    return binascii.b2a_base64(sig).strip()


def gnupgverify(msg, sig, quiet=False):
    sig = binascii.a2b_base64(sig)
    try:
        fd, filename = tempfile.mkstemp(prefix="hg-", suffix=".sig")
        fp = os.fdopen(fd, 'wb')
        fp.write(sig)
        fp.close()
        stderr = quiet and subprocess.PIPE or None

        cmd = [CONFIG["gnupg.path"]] + CONFIG["gnupg.flags"] + \
            ["--status-fd", "1", "--verify", filename, '-']
        p = subprocess.Popen(cmd, stdin=subprocess.PIPE,
                             stdout=subprocess.PIPE, stderr=stderr)
        out, err = p.communicate(msg)
        return 'GOODSIG' in out
    finally:
        try:
            os.unlink(filename)
        except OSError:
            pass


def opensslsign(msg):
    try:
        fd, filename = tempfile.mkstemp(prefix="hg-", suffix=".msg")
        fp = os.fdopen(fd, 'wb')
        fp.write(msg)
        fp.close()


        cmd = [CONFIG["openssl.path"], "smime", "-sign", "-outform", "pem",
               "-signer", CONFIG["openssl.certificate"], "-in", filename]
        p = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE)
        sig = p.communicate()[0]
        return sig
    finally:
        try:
            os.unlink(filename)
        except OSError:
            pass


def opensslverify(msg, sig, quiet=False):
    try:
        fd, filename = tempfile.mkstemp(prefix="hg-", suffix=".msg")
        fp = os.fdopen(fd, 'wb')
        fp.write(msg)
        fp.close()

        cmd = [CONFIG["openssl.path"], "smime",
               "-verify", "-CApath", CONFIG["openssl.capath"],
               "-inform", "pem", "-content", filename]
        p = subprocess.Popen(cmd, stdin=subprocess.PIPE,
                             stdout=subprocess.PIPE,
                             stderr=subprocess.PIPE)
        out, err = p.communicate(sig)
        return err.strip() == "Verification successful"
    finally:
        try:
            os.unlink(filename)
        except OSError:
            pass


def chash(manifest, files, desc, p1, p2, user, date, extra):
    """Compute changeset hash from the changeset pieces."""
    user = user.strip()
    if "\n" in user:
        raise error.RevlogError(_("username %s contains a newline")
                                % repr(user))

    # strip trailing whitespace and leading and trailing empty lines
    desc = '\n'.join([l.rstrip() for l in desc.splitlines()]).strip('\n')

    user, desc = encoding.fromlocal(user), encoding.fromlocal(desc)

    if date:
        parseddate = "%d %d" % util.parsedate(date)
    else:
        parseddate = "%d %d" % util.makedate()
    extra = extra.copy()
    if 'signature' in extra:
        del extra['signature']
    if extra.get("branch") in ("default", ""):
        del extra["branch"]
    if extra:
        extra = changelog.encodeextra(extra)
        parseddate = "%s %s" % (parseddate, extra)
    l = [hex(manifest), user, parseddate] + sorted(files) + ["", desc]
    text = "\n".join(l)
    return revlog.hash(text, p1, p2)


def ctxhash(ctx):
    """Compute changeset hash from a ``changectx``."""
    manifest, user, date, files, desc, extra = ctx.changeset()
    p1, p2 = ([p.node() for p in ctx.parents()] + [nullid, nullid])[:2]
    date = (int(date[0]), date[1])
    return chash(manifest, files, desc, p1, p2, user, date, extra)


def verifysigs(ui, repo, *revrange, **opts):
    """verify manifest signatures

    Verify repository heads, the revision range specified or all
    changesets. The return code is one of:

    - 0 if all changesets had valid signatures
    - 1 if there were a changeset without a signature
    - 2 if an exception was raised while verifying a changeset
    - 3 if there were a changeset with a bad signature

    The final return code is the highest of the above.
    """
    if opts.get('only_heads'):
        revs = repo.heads()
    elif not revrange:
        revs = xrange(len(repo))
    else:
        revs = cmdutil.revrange(repo, revrange)

    retcode = 0
    for rev in revs:
        ctx = repo[rev]
        h = ctxhash(ctx)
        extra = ctx.extra()
        sig = extra.get('signature')
        if not sig:
            msg = _("** no signature")
            retcode = max(retcode, 1)
        else:
            ui.debug(_("signature: %s\n") % sig)
            try:
                scheme, sig = sig.split(":", 1)
                verifyfunc = sigschemes[scheme][1]
                if verifyfunc(hex(h), sig, quiet=True):
                    msg = _("good %s signature") % scheme
                else:
                    msg = _("** bad %s signature on %s") % (scheme, short(h))
                    retcode = max(retcode, 3)
            except Exception, e:
                msg = _("** exception while verifying %s signature: %s") \
                    % (scheme, e)
                retcode = max(retcode, 2)
        ui.write("%d:%s: %s\n" % (ctx.rev(), ctx, msg))
    return retcode


def verifyallhook(ui, repo, node, **kwargs):
    """verify changeset signatures

    This hook is suitable for use as a ``pretxnchangegroup`` hook. It
    will verify that all pushed changesets carry a good signature. If
    one or more changesets lack a good signature, the push is aborted.
    """
    ctx = repo[node]
    if verifysigs(ui, repo, "%s:" % node) > 0:
        raise error.Abort(_("could not verify all new changesets"))

def verifyheadshook(ui, repo, node, **kwargs):
    """verify signatures in repository heads

    This hook is suitable for use as a ``pretxnchangegroup`` hook. It
    will verify that all heads carry a good signature after push. If
    one or more changesets lack a good signature, the push is aborted.
    """
    ctx = repo[node]
    if verifysigs(ui, repo, True, "%s:" % node, only_heads=True) > 0:
        raise error.Abort(_("could not verify all new changesets"))

sigschemes = {'gnupg': (gnupgsign, gnupgverify),
              'openssl': (opensslsign, opensslverify)}

def uisetup(ui):
    for key in CONFIG:
        val = CONFIG[key]
        uival = ui.config('commitsigs', key, val)
        if isinstance(val, list) and not isinstance(uival, list):
            CONFIG[key] = shlex.split(uival)
        else:
            CONFIG[key] = uival
    if CONFIG['scheme'] not in sigschemes:
        raise util.Abort(_("unknown signature scheme: %s")
                         % CONFIG['scheme'])

def extsetup():

    def add(orig, self, manifest, files, desc, transaction,
            p1=None, p2=None, user=None, date=None, extra={}):
        h = chash(manifest, files, desc, p1, p2, user, date, extra)
        scheme = CONFIG['scheme']
        signfunc = sigschemes[scheme][0]
        extra['signature'] = "%s:%s" % (scheme, signfunc(hex(h)))
        return orig(self, manifest, files, desc, transaction,
                    p1, p2, user, date, extra)

    extensions.wrapfunction(changelog.changelog, 'add', add)

cmdtable = {
    "verifysigs": (verifysigs,
                   [('', 'only-heads', None, _('only verify heads'))], 
                   "[REV...]")
}
