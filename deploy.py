#!/usr/bin/env python3

import sys
from sys import platform, argv
import os
from os import environ, path
from subprocess import check_call as call
import contextlib
import shlex
import shutil
from operator import itemgetter

home = environ.get("HOME", ".")
home = os.path.abspath(environ.get("USERPROFILE", home))
dotfiles_dir = path.dirname(path.abspath(__file__))
cfg_dir = os.path.abspath(environ.get("XDG_CONFIG_HOME", path.join(home, ".config")))
appsupport = os.path.abspath(path.join(home, 'Library', 'Application Support')) if platform == 'darwin' else None
appdata = os.path.abspath(environ.get('AppData', ''))

admin = "admin" in argv
debug = "debug" in argv
if debug:
    import pdb; pdb.set_trace()

@contextlib.contextmanager
def chdir(dirname):
    curdir = os.getcwd()
    try:
        os.chdir(dirname)
        yield
    finally:
        os.chdir(curdir)


@contextlib.contextmanager
def rename_away(dirname):
    if not path.exists(dirname):
        yield
    else:
        bak = dirname + '.bak'
        os.rename(dirname, bak)
        yield
        os.rename(bak, dirname)


def admin_relaunch():
    proc_args = ["-Verb", "runAs"]
    if not debug:
        proc_args += ["-WindowStyle", "Hidden"]
    this_program = ["python", '"' + " ".join(argv) + ' admin"']
    call(["powershell", "Start-Process"] + this_program + proc_args)

def ask_to_overwrite(src, target):
    if '--dont-prompt' in sys.argv:
        sys.exit(target + ' already exists')
    choice = None
    while choice not in {'y', 'n', ''}:
        choice = input(target + ' already exists, do you want to overwrite it? [Y/n] ').lower()
    if choice in 'y':
        delete = shutil.rmtree if os.path.isdir(target) else os.remove
        delete(target)
    return choice in 'y'

def ignore_existing_target (f):
    def inner(*args, **kwargs):
        try:
            f(*args, **kwargs)
            print(args[1], 'deployed')
        except OSError as e:
            # 17 == file exists
            # WTF?: cannot use e.filename, because on win32 it's the src... not the target
            if e.errno != 17:
                raise
            if not path.islink(args[1]):
                if ask_to_overwrite(*args):
                    f(*args, **kwargs)
    return inner

@ignore_existing_target
def symlink(src, target):
    parent = path.dirname(target)
    if not path.exists(parent):
        os.makedirs(parent)
    os.symlink(src, target, path.isdir(src))

def copy_ghciconf(src, target):
    "ghci refuses to load the file if it is writable by others, and git doesn't preserve permissions"
    shutil.copy2(src, target)
    os.chmod(target, 0o644)

dotfiles = [ # src, unixdest, windest, method
['bazaar', '.bazaar', path.join(appdata, "bazaar", "2.0"), symlink],
['hgrc', '.hgrc', 'mercurial.ini', symlink],
['mercurial', '.hgextensions', '.hgextensions', symlink],
['gitconfig', None, '.gitconfig', symlink],
['global_gitignore', '.gitignore', None, symlink],
['emacs.d', '.emacs.d', path.join(appdata, ".emacs.d"), symlink],
['fish', path.join(cfg_dir, 'fish'), None, symlink],
['ackrc', '.ackrc', '_ackrc', symlink],
['ghci.conf', '.ghci', path.join(appdata, 'ghc', 'ghci.conf'), copy_ghciconf],
['lighttable', path.join(appsupport or cfg_dir, 'LightTable', 'settings'), None, symlink],
['lein-profile.clj', path.join('.lein', 'profiles.clj'), None, symlink],
['powershell.ps1', None, path.join(home, "Documents", "WindowsPowerShell", "profile.ps1"), symlink],
['nixpkgs', '.nixpkgs', None, symlink],
['atom', '.atom', None, symlink],
['stack.yaml', path.join('.stack', 'config.yaml'), None, symlink],
['npmrc', '.npmrc', None, symlink],
['vscode', path.join(appsupport or cfg_dir, 'Code', 'User'), None, symlink],
]

dotfiles = map(
    lambda dotfile: dict(zip(['src', 'unixdest', 'windest', 'method'], dotfile)),
    dotfiles)

def deploy_symlinks():
    try:
        if platform.startswith('linux') or platform == 'darwin':
            dest = itemgetter('unixdest')
        elif platform == 'win32':
            dest = itemgetter('windest')
            if not admin:
                call("powershell set-executionpolicy RemoteSigned CurrentUser")

        for dotfile in filter(dest, dotfiles):
            target = dest(dotfile)
            if not path.isabs(target):
                target = path.join(home, target)

            # actually apply symlink() or copy2()
            dotfile['method'](path.join(dotfiles_dir, dotfile['src']), target)

        if admin:
            sys.exit()

    except OSError as e:
        if "symbolic link" in str(e.args[0]):
            admin_relaunch()
        elif admin:
            # unfortunately, "powershell -verb runAs" creates a new
            # window, and thus our stdout/err might not be visible
            import traceback
            import tkinter
            t = tkinter.Text(bg='lightgrey')
            t.insert(tkinter.END, traceback.format_exc())
            t.config(state=tkinter.DISABLED)
            t.pack()
            tkinter.mainloop()
        else:
            raise


def deploy_bazaar_plugins():
    bazaar = path.join(dotfiles_dir, "bazaar")
    bzr_plugins = path.join(bazaar, "plugins.list")
    bzr_plugin_dir = path.join(bazaar, "plugins")
    try:
        os.mkdir(bzr_plugin_dir)
    except OSError:
        pass
    with rename_away(path.join(bazaar, "bazaar.conf")):
        # move the config out of the way otherwise, launchpad would ask us for
        # auth, even only for read access
        with open(bzr_plugins, "r") as plugins, chdir(bzr_plugin_dir):
            for plugin in plugins:
                if not path.exists(plugin.split()[-1]):
                    call(["bzr", "branch"] + shlex.split(plugin))


if __name__ == "__main__":
    deploy_symlinks()
    if shutil.which('bzr'):
        deploy_bazaar_plugins()
