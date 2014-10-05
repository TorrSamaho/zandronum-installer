/==============================================================================\
|                          Zandronum Installer Readme                     v1.0 |
--------------------------------------------------------------------------------
| Requirements:                                                                |
|    - NSIS (for creating the installer)                                       |
|        http://nsis.sourceforge.net/Main_Page                                 |
|    - Perl (synthesizing and running the installer)                           |
|        http://www.perl.org/get.html                                          |
|    - Ability to add perl.exe and makensis.exe to the PATH variable so Perl   |
|      can call makensis.exe from the command prompt.                          |
|------------------------------------------------------------------------------|
| How to run:                                                                  |
|    1) Put all the files you want to bundle into the installer in the 'files/'|
|       directory. Any files that begin with a period will be ignored. There   |
|       is a file in the 'files/' folder called instructions.txt, which will be|
|       ignored upon preparing the compilation. You may delete.                |
|       If no files/ folder exists in the top directory, create it and then put|
|       your desired files inside.                                             |
|                                                                              |
|    2) Add perl.exe and makensis.exe to the PATH variable (use the makensis   |
|       executable in the main directory, not the bin folder one)              |
|       You can do this from the command line with the cmd shell as follows:   |
|          set PATH=%PATH%;C:\Your\nsis\folder\                                |
|                                                                              |
|                                                                              |
|    3) Run the Perl script with a single argument of what the version number  |
|       should be. It must be a number release, no letters now are allowed.    |
|       The version must start and end with a number, and there may not be     |
|       back to back periods. Version number must match: ^[0-9]+(\.[0-9]+)*\$  |
|                                                                              |
|       Good examples: 0.1                                                     |
|                      12.2                                                    |
|                      4.3.1                                                   |
|                      01.02.030                                               |
|                                                                              |
|       Bad examples:  .1    // Starts with a period                           |
|                      0..1  // Two back to back periods                       |
|                      1.1.  // Ends with a period                             |
|                      a.1   // No letters allowed (for now)                   |
|                                                                              |
|       Command line example (if we want to compile zandronum version w/ 1.3)  |
|           perl zaninstaller.pl 1.3                                           |
|                                                                              |
|    Important:                                                                |
|           * All folders must have at least one file in them, or else the     | 
|             install script will not have proper removal for the folder at    |
|             the uninstaller section. So far this is not an issue, but a note |
|             for any future installations.                                    |
|------------------------------------------------------------------------------|
| Current included files:                                               (v1.3) |
|     - files/announcer/ZanACG.pk3                                             |
|     - files/announcer/ZanGeneric.pk3                                         |
|     - files/Doomseeker/engines/libodamex.dll                                 |
|     - files/Doomseeker/engines/libzandronum.dll                              |
|     - files/Doomseeker/engines/Microsoft.VC90.CRT.manifest                   |
|     - files/Doomseeker/translations/pl_PL.qm                                 |
|     - files/Doomseeker/translations/qt_pl.qm                                 |
|     - files/Doomseeker/translations/translations.def                         |
|     - files/Doomseeker/doomseeker.exe                                        |
|     - files/Doomseeker/doomseeker.ico                                        |
|     - files/Doomseeker/doomseeker-portable.bat                               |
|     - files/Doomseeker/libwadseeker.dll                                      |
|     - files/Doomseeker/LICENSE.json.txt                                      |
|     - files/Doomseeker/LICENSE.txt                                           |
|     - files/Doomseeker/LICENSE.wadseeker.txt                                 |
|     - files/Doomseeker/Microsoft.VC90.CRT.manifest                           |
|     - files/Doomseeker/msvcm90.dll                                           |
|     - files/Doomseeker/msvcp90.dll                                           |
|     - files/Doomseeker/msvcr90.dll                                           |
|     - files/Doomseeker/QtCore4.dll                                           |
|     - files/Doomseeker/QtGui4.dll                                            |
|     - files/Doomseeker/QtNetwork4.dll                                        |
|     - files/Doomseeker/QtXml4.dll                                            |
|     - files/Doomseeker/updater.exe                                           |
|     - files/skins/about.txt                                                  |
|     - files/fmodex.dll                                                       |
|     - files/skulltag_actors.pk3                                              |
|     - files/zandronum.exe                                                    |
|     - files/zandronum.pk3                                                    |
|                                                                              |
\==============================================================================/

