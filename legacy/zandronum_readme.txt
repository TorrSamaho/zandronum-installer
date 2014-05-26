=====================
 ZANDRONUM INSTALLER 
=====================
v 1.2.1
NSIS 3.0b0 (May 11, 2014)

1) To compile the installer, put the following in the zandronum_files directory,
If the folder does not exist, create it in the directory where the pull was made:

Example: If I hg clone'd this to /home/installer/, then i'd want to put the files
below in the /home/installer/zandronum_files/ folder

If you can't find some of these files, they should come with previous installers.

/fmodex.dll
/licenses.zip
/Readme.txt
/skulltag_actors.pk3
/Zandronum Version History.txt
/zandronum.exe
/zandronum.pk3
/announcer/ZanACG.pk3
/announcer/ZanGeneric.pk3
/skins/about.txt
/Doomseeker/doomseeker.exe
/Doomseeker/doomseeker.ico
/Doomseeker/doomseeker-portable.bat
/Doomseeker/libwadseeker.dll
/Doomseeker/LICENSE.json.txt
/Doomseeker/LICENSE.txt
/Doomseeker/LICENSE.wadseeker.txt
/Doomseeker/Microsoft.VC90.CRT.manifest
/Doomseeker/msvcm90.dll
/Doomseeker/msvcp90.dll
/Doomseeker/msvcr90.dll
/Doomseeker/QtCore4.dll
/Doomseeker/QtGui4.dll
/Doomseeker/QtNetwork4.dll
/Doomseeker/QtXml4.dll
/Doomseeker/updater.exe
/Doomseeker/engines/libzandronum.dll
/Doomseeker/engines/Microsoft.VC90.CRT.manifest
/Doomseeker/translations/pl_PL.qm
/Doomseeker/translations/qt_pl.qm
/Doomseeker/translations/translations.def

2) Compile with NSIS (compiled with 3.0 release on July 14th 2013)
* Should compile with earlier versions
* May need to investigate firewall exceptions