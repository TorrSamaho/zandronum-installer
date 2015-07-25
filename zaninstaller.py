#!/usr/bin/env python3
# Copyright (c) Chris K, Torr Samaho, Zandronum development team; 2015

import argparse
import os

FILES_PATH = 'files'
FRAGMENTS_PATH = 'fragments'
INSTRUCTIONS_FILE = ".instructions.txt"

parser = argparse.ArgumentParser (description='Generates an NSIS installer script for Zandronum')
parser.add_argument ('version')
parser.add_argument ('-o', '--output', default='ZanInstaller.nsi')
args = parser.parse_args()

###############################################################################
# Retrieve the version number and ensure it's valid.                          #
###############################################################################

# No spaces should be in the version number.
if ' ' in args.version:
	print("You should not have spaces in the argument (try underscores or hyphens).")
	quit(1)

###############################################################################
# Collect all the files we want to add into a list.                           #
###############################################################################

# Get all the files to install.
def getInstallFilePaths(base):
	if base[-1] != '\\':
		base += '\\'

	filedict = {'basepath': base, 'files': {}}
	for (dirpath, dirnames, filenames) in os.walk(base):
		# Append slash if missing, rework to all one slash type
		dirpath = dirpath.replace ('/', '\\')
		if dirpath[-1] != '\\':
			dirpath += '\\'
		dirpath = dirpath[len(base):]
		filedict['files'][dirpath] = []
		for filename in filenames:
			if filename != INSTRUCTIONS_FILE:
				filedict['files'][dirpath].append(filename)

	# We should have at least one file.
	if not filedict:
		print("No files detected in the " + base + " folder, are you sure you set this up correctly?")
		quit(1)

	return filedict

###############################################################################
# Write our information into the installer file.                              #
###############################################################################

def readFragment(filename):
	fragmentPath = os.path.join (FRAGMENTS_PATH, filename)

	try:
		with open (fragmentPath, 'r') as fp:
			return fp.read()
	except FileNotFoundError:
		print("You are missing a core NSIS text file:", fragmentPath)
		quit(1)

# Sort the keys alphabetically and case-insensitive.
def getFileinfoPaths (fileinfo):
	return sorted(list(fileinfo['files'].keys()), key=str.lower)

def generateInstaller (fileinfo):
	outlines = []
	for installpath in getFileinfoPaths (fileinfo):
		path = "    SetOutPath $INSTDIR\\" + installpath
		path = path[:-1]
		outlines.append(path)
		for filepath in fileinfo['files'][installpath]:
			outlines.append("        File " + fileinfo['basepath'] + installpath + filepath)
	return '\n'.join(outlines)

def generateUninstaller (fileinfo):
	paths = getFileinfoPaths (fileinfo)
	outlines = []
	for installpath in paths:
		path = "    SetOutPath $INSTDIR\\" + installpath
		path = path[:-1]
		outlines.append(path)
		for filepath in fileinfo['files'][installpath]:
			outlines.append("        Delete /REBOOTOK " + filepath)
	outlines.append("    SetOutPath $TEMP")
	endpaths = []
	for installpath in paths:
		dirpath = "        RmDir /REBOOTOK $INSTDIR\\" + installpath
		dirpath = dirpath[:-1]
		endpaths.append(dirpath)
	endpaths.reverse()
	for endpath in endpaths:
		outlines.append(endpath)
	return '\n'.join(outlines)

filePaths = getInstallFilePaths('files')

# 1) Write the header
textoutput = ""
textoutput += readFragment('header.txt')

# 2) Define the build based on the version.
textoutput += "!define RELEASEBUILD\n"
textoutput += "!define VERSION_NUM " + args.version + "\n"
textoutput += "!define VERSION " + args.version + "\n"
textoutput += "\n"

# 3) Append the core functions that will be called
textoutput += readFragment('corefunctions.txt')

# 4) Add the commands for the files.
textoutput += generateInstaller(filePaths)

# 5) Do the post-install functions/commands.
textoutput += readFragment('postinstall.txt')

# 6) Write the uninstaller.
textoutput += generateUninstaller(filePaths)

# 7) Append the footer.
textoutput += readFragment ('footer.txt')

# Write it to the installer file.
with open(args.output, "w") as f:
	f.write(textoutput)
	print(args.output, "written")
