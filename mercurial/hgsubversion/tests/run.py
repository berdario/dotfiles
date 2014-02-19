#!/usr/bin/env python

import optparse
import os
import sys
import unittest

import test_util
test_util.SkipTest = None

def tests():
    import test_binaryfiles
    import test_diff
    import test_externals
    import test_fetch_branches
    import test_fetch_command
    import test_fetch_command_regexes
    import test_fetch_exec
    import test_fetch_mappings
    import test_fetch_renames
    import test_fetch_symlinks
    import test_fetch_truncated
    import test_hooks
    import test_svn_pre_commit_hooks
    import test_pull
    import test_pull_fallback
    import test_push_command
    import test_push_renames
    import test_push_dirs
    import test_push_eol
    import test_push_autoprops
    import test_single_dir_clone
    import test_single_dir_push
    import test_svnwrap
    import test_tags
    import test_template_keywords
    import test_utility_commands
    import test_unaffected_core
    import test_urls

    sys.path.append(os.path.dirname(__file__))
    sys.path.append(os.path.join(os.path.dirname(__file__), 'comprehensive'))

    import test_rebuildmeta
    import test_stupid_pull
    import test_updatemeta
    import test_verify_and_startrev

    return locals()

def comprehensive(mod):
    dir = os.path.basename(os.path.dirname(mod.__file__))
    return dir == 'comprehensive'

if __name__ == '__main__':
    description = ("This script runs the hgsubversion tests. If no tests are "
                   "specified, all known tests are implied.")
    parser = optparse.OptionParser(usage="%prog [options] [TESTS ...]",
                                   description=description)
    parser.add_option("-A", "--all",
                      dest="comprehensive", action="store_true", default=False,
                      help="include slow, but comprehensive tests")
    parser.add_option("-v", "--verbose",
                      dest="verbose", action="store_true", default=False,
                      help="enable verbose output")
    parser.add_option("", "--no-demandimport",
                      dest="demandimport", action="store_false", default=True,
                      help="disable Mercurial demandimport loading")
    parser.add_option("", "--bindings",
                      dest="bindings", action="store", default=None,
                      choices=["swig", "subvertpy"],
                      help="test using the specified bindings (swig or "
                      "subvertpy)")
    parser.add_option("", "--show-stdout",
                      dest="showstdout", action="store_true", default=False,
                      help="show stdout (hidden by default)")

    (options, args) = parser.parse_args()

    if options.verbose:
        testargs = { 'descriptions': 3, 'verbosity': 2 }
    else:
        testargs = {'descriptions': 2}

    sys.path.append(os.path.dirname(os.path.dirname(__file__)))

    if options.demandimport:
        from mercurial import demandimport
        demandimport.enable()

    if options.bindings:
        os.environ['HGSUBVERSION_BINDINGS'] = options.bindings

    # make sure our copy of hgsubversion gets imported by loading test_util
    import test_util
    test_util.TestBase

    # silence output when running outside nose
    if not options.showstdout:
        import tempfile
        sys.stdout = tempfile.TemporaryFile()

    all_tests = tests()

    args = [i.split('.py')[0].replace('-', '_') for i in args]

    loader = unittest.TestLoader()
    suite = unittest.TestSuite()

    if not args:
        check = lambda x: options.comprehensive or not comprehensive(x)
        suite.addTests(loader.loadTestsFromModule(m)
                       for (n, m) in sorted(all_tests.iteritems())
                       if check(m))
    else:
        for arg in args:
            if arg == 'test_util':
                continue
            elif arg not in all_tests:
                print >> sys.stderr, 'test module %s not available' % arg
            else:
                suite.addTest(loader.loadTestsFromModule(all_tests[arg]))

    runner = unittest.TextTestRunner(**testargs)
    result = runner.run(suite)
    if not result.wasSuccessful():
        sys.exit(1)
