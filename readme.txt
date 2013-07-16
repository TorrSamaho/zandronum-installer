=====================
 ZANDRONUM INSTALLER 
=====================

1) To compile the installer, put the following in the zandronum_files directory:

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
/Doomseeker/engines/libskulltag.dll
/Doomseeker/engines/Microsoft.VC90.CRT.manifest
/Doomseeker/translations/pl_PL.qm
/Doomseeker/translations/qt_pl.qm
/Doomseeker/translations/translations.def

2) Compile with NSIS (compiled with 3.0 release on July 14th 2013)
* Should compile with earlier versions
* May need to investigate firewall exceptions

================================================================================
Legacy readme:

-----------------------
 SKULLTAG INSTALLER v3
-----------------------

To make the installer:
	1) Open SkulltagInstaller.nsi in notepad. Find "!define VERSION" and put in the appropiate version there.
  	2) Unzip the windows zip into \skulltag_files
	3) Run build.bat.

To add more files to the installer:
  See the header of SkulltagInstaller.nsi.

-Rivecoder


