import test_util

import os
import subprocess
import tempfile
import unittest

from hgsubversion import svnwrap

class TestBasicRepoLayout(unittest.TestCase):
    def setUp(self):
        self.tmpdir = tempfile.mkdtemp('svnwrap_test')
        self.repo_path = '%s/testrepo' % self.tmpdir
        subprocess.call(['svnadmin', 'create', self.repo_path, ])
        inp = open(os.path.join(os.path.dirname(__file__), 'fixtures',
                                'project_root_at_repo_root.svndump'))
        proc = subprocess.call(['svnadmin', 'load', self.repo_path, ],
                                stdin=inp,
                                close_fds=test_util.canCloseFds,
                                stdout=subprocess.PIPE,
                                stderr=subprocess.STDOUT)
        assert proc == 0
        self.repo = svnwrap.SubversionRepo(test_util.fileurl(self.repo_path))

    def tearDown(self):
        del self.repo
        test_util.rmtree(self.tmpdir)

    def test_num_revs(self):
        revs = list(self.repo.revisions())
        self.assertEqual(len(revs), 7)
        r = revs[1]
        self.assertEqual(r.revnum, 2)
        self.assertEqual(sorted(r.paths.keys()),
                  ['trunk/alpha', 'trunk/beta', 'trunk/delta'])
        for r in revs:
            for p in r.paths:
                # make sure these paths are always non-absolute for sanity
                if p:
                    assert p[0] != '/'
        revs = list(self.repo.revisions(start=3))
        self.assertEqual(len(revs), 4)

class TestRootAsSubdirOfRepo(TestBasicRepoLayout):
    def setUp(self):
        self.tmpdir = tempfile.mkdtemp('svnwrap_test')
        self.repo_path = '%s/testrepo' % self.tmpdir
        subprocess.call(['svnadmin', 'create', self.repo_path, ])
        inp = open(os.path.join(os.path.dirname(__file__), 'fixtures',
                                'project_root_not_repo_root.svndump'))
        ret = subprocess.call(['svnadmin', 'load', self.repo_path, ],
                              stdin=inp,
                              close_fds=test_util.canCloseFds,
                              stdout=subprocess.PIPE,
                              stderr=subprocess.STDOUT)
        assert ret == 0
        self.repo = svnwrap.SubversionRepo(test_util.fileurl(
            self.repo_path + '/dummyproj'
        ))
