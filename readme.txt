/==============================================================================\
|                          Zandronum Installer Readme                     v1.1 |
--------------------------------------------------------------------------------
| Requirements:                                                                |
|    - NSIS v3.04 (should work with older versions)                            |
|    - Python 3 (tested with 3.7.4)                                            |
|------------------------------------------------------------------------------|
| How to run:                                                                  |
|    Put all the files you want to bundle into the installer in the 'files/'   |
|    directory. Any files that begin with a period will be ignored.            |
|                                                                              |
|    If no files/ folder exists in the top directory, create it and then put   |
|    your desired files inside.                                                |
|                                                                              |
|                                                                              |
|    When running on the command line, run it with the version number.         |
|    Ex:                                                                       |
|        python3 zaninstaller.py 2.0                                           |
|                                                                              |
|    The python script generates an .nsi file, which has to be compiled with   |
|    NSIS.                                                                     |
\==============================================================================/

