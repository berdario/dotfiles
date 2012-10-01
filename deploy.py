#! /usr/bin/env python3

import sys
from sys import platform, argv
import os
from os import environ, path
from subprocess import check_call as call
import contextlib
import shlex

home = environ.get("HOME", ".")
home = environ.get("USERPROFILE", home)
dotfiles_dir = path.join(home, ".dotfiles")

if not hasattr(__builtins__, "WindowsError"):
	# dummy WindowsError, will never be catched
	# but without it, ignore_existing_target would fail on linux
	class WindowsError(BaseException):
		pass

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

def admin_relaunch():
	proc_args = ["-Verb", "runAs"]
	if not debug:
		proc_args += ["-WindowStyle", "Hidden"]
	this_program = ["python", '"' + " ".join(argv) + ' admin"']
	call(["powershell", "Start-Process"] + this_program + proc_args)

def ignore_existing_target (f):
	def inner(*args, **kwargs):
		try:
			f(*args, **kwargs)
		except OSError as e:
			if e.errno != 17: # 17 == file exists
				raise
		except WindowsError as e:
			if e.winerror != 183: # 183 == file already existing
				raise
	return inner

try_symlink = ignore_existing_target(os.symlink)
try_mkdir = ignore_existing_target(os.mkdir)

def main():
	try:
		if platform.startswith("linux"):
			cfg_dir = environ.get("XDG_CONFIG_HOME", path.join(home, ".config"))
			joiner = lambda x: [path.join(home, x)]
			bazaar, hgrc, gitconfig, emacsd = map(joiner, [".bazaar", ".hgrc",
				".gitconfig", ".emacs.d"])
			try_symlink(path.join(dotfiles_dir, "fish"), path.join(cfg_dir, "fish"))
		elif platform == "win32":
			appdata = environ["AppData"]
			if not admin:
				call("powershell set-executionpolicy RemoteSigned CurrentUser")

			# the True means that it's a folder, it's needed because
			# posix.symlink and windows symlink have a different signature
			bazaar = [path.join(appdata, "bazaar", "2.0"), True]
			hgrc = [path.join(home, "mercurial.ini")]
			gitconfig = [path.join(home, ".gitconfig")]
			emacsd = [path.join(appdata, ".emacs.d"), True]
			ps_profile = path.join(home, "Documents", "WindowsPowerShell", "profile.ps1")
			try_symlink(path.join(dotfiles_dir, "powershell.ps1"), ps_profile)

		joiner = lambda x: [path.join(dotfiles_dir, x)]
		# I need the argument expansion, since windows' symlink requires an extra True
		try_symlink(*(joiner("bazaar") + bazaar))
		try_symlink(*(joiner("hgrc") + hgrc))
		try_symlink(*(joiner("gitconfig") + gitconfig))
		try_symlink(*(joiner("emacs.d") + emacsd))
		if admin:
			sys.exit()
	
	except OSError as e:
		if "symbolic link" in e.args[0]:
			admin_relaunch()
		else:
			raise

	bazaar = joiner("bazaar")[0]
	bzr_plugins = path.join(bazaar, "plugins.list")
	bzr_plugin_dir = path.join(bazaar, "plugins")
	try_mkdir(bzr_plugin_dir)
	bzr_conf, bzr_bakconf = path.join(bazaar, "bazaar.conf"), path.join(bazaar, "conf.bak")
	os.rename(bzr_conf, bzr_bakconf) # move the config out of the way
	# otherwise, launchpad would ask us for auth, even only for read access
	with open(bzr_plugins, "r") as plugins, chdir(bzr_plugin_dir) as _:
		for plugin in plugins:
			if not path.exists(plugin.split()[-1]):
				call(["bzr", "branch"] + shlex.split(plugin))
	os.rename(bzr_bakconf, bzr_conf)

if __name__ == "__main__":
	main()
