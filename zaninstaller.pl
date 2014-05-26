#!/usr/bin/perl
# Copyright (c) Water, Torr Samaho, Zandronum development team; 2014 

use 5.010;
use Cwd;
use File::Next;

###############################################################################
# Variables                                                                   #
###############################################################################

my $currentdir = getcwd; # The current diretory
my $filesdir = "$currentdir/files/"; # The files directory to read from
my @files; # A list of all the files (including their directory path from the /files/ folder)
my $versionString = ""; # The parsed version string from the first program argument
my @outputLines; # The final lines we will write to our file


###############################################################################
# Subroutines                                                                 #
###############################################################################

# Reads a file and outputs it into @outputLines
sub readFileIntoOutputLines
{
	# Takes one argument
	die "readFileIntoOutputLines only takes one argument (file path)" if $#_ != 0;
	
	# Read the file in
	open(my $handle, '<', $_[0]) or die "Unable to open file: $_[0]";
	while (<$handle>) {
		push(@outputLines, $_);
	}
	close($handle);
}

# Goes through the list of files we have and creates install lines from it
sub createInstallLines
{
	# This will count when our directory level changes
	my $prevDirPrefix = "";
	my $dirPrefix = "";
	my $file;
	
	# Go through each file and assess it
	foreach (@files) {
		$file = $_;

		# Push back our previous results		
		$prevDirPrefix = $dirPrefix;
		
		# Get our new directory name (or set it to empty if there's no directory)
		if ($file =~ m/(.*)\\.+/) {
			$dirPrefix = $1;
		} else {
			$dirPrefix = "";
		}
		
		# If the dir has changed, update our out path
		if ($prevDirPrefix ne $dirPrefix) {
			if ($dirPrefix eq "") {
				push(@outputLines, "    SetOutPath \$INSTDIR\n");
			} else {
				push(@outputLines, "    SetOutPath \$INSTDIR\\$dirPrefix\n");
			}
		} 
		
		# Add the file now
		push(@outputLines, "        File \"files\\$_\"\n");
	}
}

# Creates the uninstall and deletion for folders/files
sub createUninstallLines
{
	# This will count when our directory level changes
	my $prevDirPrefix = "";
	my $dirPrefix = "";
	my $file;
	my $targetDir;
	my @dirsToRemove;
	my %hashmapDirsToRemove;
	
	# Go through each file and assess it
	foreach (@files) {
		$file = $_;

		# Push back our previous results		
		$prevDirPrefix = $dirPrefix;
		
		# Get our new directory name (or set it to empty if there's no directory)
		if ($file =~ m/(.*)\\.+/) {
			$dirPrefix = $1;
		} else {
			$dirPrefix = "";
		}
		
		# If the dir has changed, update our out path
		if ($prevDirPrefix ne $dirPrefix) {
			if ($dirPrefix eq "") {
				push(@outputLines, "    SetOutPath \$INSTDIR\n");
			} else {
				push(@outputLines, "    SetOutPath \$INSTDIR\\$dirPrefix\n");
				$hashmapDirsToRemove{$dirPrefix} = $dirPrefix;
			}
		} 
		
		# Add the file now
		push(@outputLines, "        Delete /REBOOTOK \"$file\"\n");
	}
	
	# Now that all the files have been set to be removed, remove the directories
	push(@outputLines, "    SetOutPath \$TEMP\n");
	foreach (keys %hashmapDirsToRemove) {
		push(@outputLines, "        RmDir /REBOOTOK $_\n");
	}
}

###############################################################################
# Get version number from args                                                #
###############################################################################

# Make sure our first argument is not blank and is the version number we want
die "Requires version number for the first argument, no arguments specified ($#ARGV)." if $#ARGV < 0; 

# Assign the version string for later usage
$versionString = $ARGV[0];

# Make sure the version number is just numbers and periods (don't allow .0 or 0..0, or 0. or things like that)
die "Invalid version number ($ARGV[0]), must match this regex: ^[0-9]+(\.[0-9]+)*\$" if $versionString !~ m/^[0-9]+(\.[0-9]+)*$/;


###############################################################################
# Index files that we want to install                                         #
###############################################################################

# Go through each file and add the files we want to add to our list
my $iterator = File::Next::files("$filesdir"); # Iterator
while (defined(my $file = $iterator->())) {
	# Remove the prefixing directory
	$file =~ s/.*files\\//;
	
	# If it starts with a period, skip it
	next if ($file =~ m/^\./);
	
	# If the file is 'instructions.txt' then ignore it (because thats left in that folder by us)
	next if ($file =~ m/^instructions.txt$/);
	
    # Add it to our list of files
    push(@files, $file);
}

# If we have no files, something is wrong...
die "No files found from directory: '$filesdir', cannot continue." if $#files <= 0;

# Sort the files so directories are together
@files = sort @files;


###############################################################################
# Compose the installer file before we add our files                          #
###############################################################################

# This will contain all the lines we will eventually write

# 1) Read the header in
&readFileIntoOutputLines("$currentdir/fragments/header.txt");

# 2) Add in the version number
push(@outputLines, "!define RELEASEBUILD\n");
push(@outputLines, "!define VERSION_NUM $versionString\n");
push(@outputLines, "!define VERSION $versionString\n");
push(@outputLines, "\n");

# 3) Read the core functions in in
&readFileIntoOutputLines("$currentdir/fragments/corefunctions.txt");

# 4) Write our files that we want to install
&createInstallLines();

# 5) Read in the stuff between the 'install' and 'uninstall' section
&readFileIntoOutputLines("$currentdir/fragments/postinstall.txt");

# 6) Add in uninstaller lines for files to remove
&createUninstallLines();

# 7) Write last parts
&readFileIntoOutputLines("$currentdir/fragments/footer.txt");

# 8) Save the data finally to our installer file
open(MYFILE, '>', 'ZanInstaller.nsi');
foreach (@outputLines) {
	print MYFILE "$_";
}
close(MYFILE);

# Execute NSIS to make our installer
system("makensis ZanInstaller.nsi");

# Exit cleanly stating we're done
exit 0;
