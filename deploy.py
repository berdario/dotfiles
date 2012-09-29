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
			pass
			#fish = path.join(home, ".config", "fish")
			#try_symlink(path.join(dotfiles_dir, "fish"), fish)
		elif platform == "win32":
			appdata = environ["AppData"]
			if not admin:
				call("powershell set-executionpolicy RemoteSigned CurrentUser")
			bazaar = path.join(appdata, "bazaar", "2.0")
			hgrc = path.join(home, "mercurial.ini")
			gitconfig = path.join(home, ".gitconfig")
			emacsd = path.join(appdata, ".emacs.d")
			ps_profile = path.join(home, "Documents", "WindowsPowerShell", "profile.ps1")
			try_symlink(path.join(dotfiles_dir, "powershell.ps1"), ps_profile)

		try_symlink(path.join(dotfiles_dir, "bazaar"), bazaar, True)
		try_symlink(path.join(dotfiles_dir, "hgrc"), hgrc)
		try_symlink(path.join(dotfiles_dir, "gitconfig"), gitconfig)
		try_symlink(path.join(dotfiles_dir, "emacs.d"), emacsd, True)
		if admin:
			sys.exit()
	
	except OSError as e:
		if "symbolic link" in e.args[0]:
			admin_relaunch()
		else:
			raise

	bzr_plugins = path.join(bazaar, "plugins.list")
	bzr_plugin_dir = path.join(bazaar, "plugins")
	try_mkdir(bzr_plugin_dir)
	bzr_conf, bzr_bakconf = path.join(bazaar, "bazaar.conf"), path.join(bazaar, "conf.bak")
	os.rename(bzr_conf, bzr_bakconf) # move the config out of the way
	# otherwise, launchpad would ask us for auth, even only for read access
	with open(bzr_plugins, "r") as plugins, chdir(bzr_plugin_dir) as _:
		for plugin in plugins:
			call(["bzr", "branch"] + shlex.split(plugin))
	os.rename(bzr_bakconf, bzr_conf)

if __name__ == "__main__":
	main()
