import test_util

import unittest

from mercurial import ui

from hgsubversion import wrappers

expected_diff_output = '''Index: alpha
===================================================================
--- alpha\t(revision 3)
+++ alpha\t(working copy)
@@ -1,1 +1,3 @@
-file: alpha
+alpha
+
+added line
Index: foo
===================================================================
new file mode 100644
--- foo\t(revision 0)
+++ foo\t(working copy)
@@ -0,0 +1,1 @@
+This is missing a newline.
\ No newline at end of file
'''

class DiffTests(test_util.TestBase):
    def test_diff_output(self):
        self._load_fixture_and_fetch('two_revs.svndump')
        self.commitchanges([('foo', 'foo', 'This is missing a newline.'),
                            ('alpha', 'alpha', 'alpha\n\nadded line\n'),
                            ])
        u = ui.ui()
        u.pushbuffer()
        wrappers.diff(lambda x, y, z: None, u, self.repo, svn=True)
        self.assertEqual(u.popbuffer(), expected_diff_output)
