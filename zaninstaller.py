#!/usr/bin/env python3
# Copyright (c) Chris K, Torr Samaho, Zandronum development team; 2015

import argparse
import os
import sys

INSTRUCTIONS_FILE = ".instructions.txt"

class InstallerGenError (Exception):
	pass

def getInstallFilePaths(base):
	'''Returns a dictionary of files to install. The function is supplied the base path to walk
	through. The dictionary has two elements:
		- basepath: i.e. the base parameter itself
		- files: another dict that contains the files contained in each directory recursively.
	'''
	oldpath = os.getcwd()
	try:
		os.chdir(base)
		filedict = {'basepath': base + '\\', 'files': {}}
		for (dirpath, dirnames, filenames) in os.walk('.'):
			# Append slash if missing, rework to all one slash type
			dirpath = '\\'.join(dirpath.split(os.path.sep)[1:]) + '\\'
			filedict['files'][dirpath] = []
			for filename in filenames:
				if filename != INSTRUCTIONS_FILE:
					filedict['files'][dirpath].append(filename)

		# We should have at least one file.
		if not filedict['files']:
			raise InstallerGenError("No files detected in the " + base + " folder, are you sure you set this up correctly?")

		return filedict
	finally:
		os.chdir(oldpath)

def readFragment(filename, args):
	'''Reads a file from the fragmens directory'''
	fragmentPath = os.path.join (args.fragments_path, filename)

	try:
		with open (fragmentPath, 'r') as fp:
			return fp.read()
	except FileNotFoundError:
		raise InstallerGenError("You are missing a core NSIS text file:", fragmentPath)

def getFileinfoPaths (fileinfo):
	'''Gets the directory names from the fileinfo. Paths aree sorted case-insensitively.'''
	return sorted(list(fileinfo['files'].keys()), key=str.lower)

def generateInstaller (fileinfo):
	'''Generates the installer NSIS script'''
	outlines = []
	for installpath in getFileinfoPaths (fileinfo):
		outlines.append(("    SetOutPath $INSTDIR\\" + installpath))
		for filepath in fileinfo['files'][installpath]:
			outlines.append("        File " + fileinfo['basepath'] + installpath + filepath)
	return '\n'.join(outlines)

def generateUninstaller (fileinfo):
	'''Generates the uninstaller NSIS script'''
	paths = getFileinfoPaths (fileinfo)
	outlines = []
	for installpath in paths:
		outlines.append(("    SetOutPath $INSTDIR\\" + installpath))
		for filepath in fileinfo['files'][installpath]:
			outlines.append("        Delete /REBOOTOK " + filepath)
	outlines.append("    SetOutPath $TEMP")
	for installpath in paths[::-1]:
		outlines.append(("        RmDir /REBOOTOK $INSTDIR\\" + installpath))
	return '\n'.join(outlines)

def main():
	'''The main installer routine'''
	try:
		parser = argparse.ArgumentParser (description='Generates an NSIS installer script for Zandronum')
		parser.add_argument ('version')
		parser.add_argument ('-o', '--output', default='ZanInstaller.nsi')
		parser.add_argument ('--fragments-path', default='fragments')
		parser.add_argument ('--files-path', default='files')
		args = parser.parse_args()

		# No spaces should be in the version number.
		if ' ' in args.version:
			raise InstallerGenError("You should not have spaces in the argument (try underscores or hyphens).")

		filePaths = getInstallFilePaths(args.files_path)

		# 1) Write the header
		textoutput = ""
		textoutput += readFragment('header.txt', args=args)

		# 2) Define the build based on the version.
		textoutput += "!define RELEASEBUILD\n"
		textoutput += "!define VERSION_NUM " + args.version + "\n"
		textoutput += "!define VERSION " + args.version + "\n"
		textoutput += "\n"

		# 3) Append the core functions that will be called
		textoutput += readFragment('corefunctions.txt', args=args)

		# 4) Add the commands for the files.
		textoutput += generateInstaller(filePaths)

		# 5) Do the post-install functions/commands.
		textoutput += readFragment('postinstall.txt', args=args)

		# 6) Write the uninstaller.
		textoutput += generateUninstaller(filePaths)

		# 7) Append the footer.
		textoutput += readFragment ('footer.txt', args=args)

		# Write it to the installer file.
		with open(args.output, "w") as f:
			f.write(textoutput)
			print(args.output, "written")
	except InstallerGenError as e:
		print ('Error:', e, file=sys.stderr)

if __name__ == '__main__':
	main()
