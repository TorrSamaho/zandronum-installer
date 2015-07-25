#!/usr/bin/env python3
# Copyright (c) Chris K, Torr Samaho, Zandronum development team; 2015

import argparse
import os

FILES_PATH = 'files/'
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
	filedict = {}
	for (dirpath, dirnames, filenames) in os.walk(base):
		# Append slash if missing, rework to all one slash type
		dirpath = dirpath.replace ('/', '\\')
		if dirpath[-1] != '\\':
			dirpath += '\\'
		filedict[dirpath] = []
		for filename in filenames:
			if filename != INSTRUCTIONS_FILE:
				filedict[dirpath].append(filename)
	return filedict

installFilePathsDict = getInstallFilePaths(FILES_PATH)

# Sort the keys alphabetically and case-insensitive.
installFilePathKeys = list(installFilePathsDict.keys())
installFilePathKeys.sort(key=str.lower)

# We should have at least one file.
if not installFilePathsDict.keys():
	print("No files detected in the " + FILES_PATH + " folder, are you sure you set this up correctly?")
	quit(1)


###############################################################################
# Write our information into the installer file.                              #
###############################################################################

textoutput = ""

def readFragment(filename):
	fragmentPath = os.path.join (FRAGMENTS_PATH, filename)

	try:
		with open (fragmentPath, 'r') as fp:
			return fp.read()
	except FileNotFoundError:
		print("You are missing a core NSIS text file:", fragmentPath)
		quit(1)

def generateInstallLines():
	global textoutput
	global FILES_PATH
	global installFilePathsDict
	global installFilePathKeys
	outlines = []
	for installpath in installFilePathKeys:
		path = "    SetOutPath $INSTDIR\\" + installpath[len(FILES_PATH):]
		path = path[:-1]
		outlines.append(path + "\n")
		for filepath in installFilePathsDict[installpath]:
			outlines.append("        File " + installpath + filepath + "\n")
	return outlines

def generateUnInstallLines():
	global textoutput
	global FILES_PATH
	global installFilePathsDict
	global installFilePathKeys
	outlines = []
	for installpath in installFilePathKeys:
		path = "    SetOutPath $INSTDIR\\" + installpath[len(FILES_PATH):]
		path = path[:-1]
		outlines.append(path + "\n")
		for filepath in installFilePathsDict[installpath]:
			outlines.append("        Delete /REBOOTOK " + filepath + "\n")
	outlines.append("    SetOutPath $TEMP\n")
	endpaths = []
	for installpath in installFilePathKeys:
		dirpath = "        RmDir /REBOOTOK $INSTDIR\\" + installpath[len(FILES_PATH):]
		dirpath = dirpath[:-1]
		endpaths.append(dirpath + "\n")
	endpaths.reverse()
	for endpath in endpaths:
		outlines.append(endpath)
	return outlines

# 1) Write the header
textoutput += readFragment('header.txt')

# 2) Define the build based on the version.
textoutput += "!define RELEASEBUILD\n"
textoutput += "!define VERSION_NUM " + args.version + "\n"
textoutput += "!define VERSION " + args.version + "\n"
textoutput += "\n"

# 3) Append the core functions that will be called
textoutput += readFragment('corefunctions.txt')

# 4) Add the commands for the files.
instlines = generateInstallLines()
for instline in instlines:
	textoutput += instline

# 5) Do the post-install functions/commands.
textoutput += readFragment('postinstall.txt')

# 6) Write the uninstaller.
uninstlines = generateUnInstallLines()
for uninstline in uninstlines:
	textoutput += uninstline

# 7) Append the footer.
textoutput += readFragment ('footer.txt')

# Write it to the installer file.
with open(args.output, "w") as f:
	f.write(textoutput)
	print(args.output, "written")
