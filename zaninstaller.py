#!/usr/bin/env python3
# Copyright (c) Chris K, Torr Samaho, Zandronum development team; 2015

import sys
import os

FILES_PATH = 'files/'
FRAGMENTS_PATH = 'fragments'
INSTRUCTIONS_FILE = ".instructions.txt"


###############################################################################
# Retrieve the version number and ensure it's valid.                          #
###############################################################################

# Make sure a version was supplied.
if len(sys.argv) <= 1:
	print("Please provide a version number as an argument.")
	sys.exit(1)

# No spaces should be in the version number.
if ' ' in sys.argv[1]:
	print("You should not have spaces in the argument (try underscores or hyphens).")
	sys.exit(1)

versionnum = sys.argv[1]


###############################################################################
# Ensure that we have all the NSIS installer files.                           #
###############################################################################

required_nsis_files = ["corefunctions.txt", "footer.txt", "header.txt", "postinstall.txt"]

for reqfile in required_nsis_files:
	pathreqfile = os.path.join (FRAGMENTS_PATH, reqfile)
	if not os.path.isfile(pathreqfile):
		print("You are missing a core NSIS text file:", pathreqfile)
		sys.exit(1)


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
	sys.exit(1)


###############################################################################
# Write our information into the installer file.                              #
###############################################################################

textoutput = ""

def readFragment(filename):
	with open (os.path.join (FRAGMENTS_PATH, filename), 'r') as fp:
		return fp.read()

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
textoutput += "!define VERSION_NUM " + versionnum + "\n"
textoutput += "!define VERSION " + versionnum + "\n"
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
with open("ZanInstaller.nsi", "w") as f:
	f.write(textoutput)
