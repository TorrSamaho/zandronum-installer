#=================================================
#
# Zandronum Installer v4
# Copyright (c) 2010 Rivecoder, Eruanna
# Copyright (c) 2013 Zandronum development team, Torr Samaho
#
# To add new files to the installer, go to [Section "Installer"] and [Section "Uninstall"].
#
#=================================================

# Build options
!define RELEASEBUILD        # Comment out this line while testing to speed things up.
!define VERSION_NUM 1.1
#!define VERSION 98xSET_VERSION 			# 97d3, 97d42, etc
!define VERSION 1.1

# Compression (lzma = god)
!ifdef RELEASEBUILD
    SetCompressor /SOLID lzma
!endif

# Included files
!include MUI2.nsh
!include include\fileAssociate.nsh

Name Zandronum

# Add/Remove Programs entry  
!define REGKEY "SOFTWARE\$(^Name)"
!define COMPANY Zandronum
!define URL http://zandronum.com

# Installer graphics settings
    ; Installer EXE icon.
    !define MUI_ICON "res\icon_install.ico"
    
    ; Uninstaller EXE icon.
    !define MUI_UNICON "res\icon_uninstall.ico"
    
    ; The large side image shown at start / finish.
    !define MUI_WELCOMEFINISHPAGE_BITMAP "res\graphics_side.bmp"
    !define MUI_UNWELCOMEFINISHPAGE_BITMAP "res\graphics_sideun.bmp"
    
    ; The small icon shown at the top during setup.
    !define MUI_HEADERIMAGE
    !define MUI_HEADERIMAGE_BITMAP "res\graphics_top.bmp"
    
    ; The grayed text at the bottom.
    BrandingText " "
    
    Caption "Zandronum ${VERSION} Setup"

    ; While debugging, pause to show the install log.
    !ifndef RELEASEBUILD
      !define MUI_FINISHPAGE_NOAUTOCLOSE
      !define MUI_UNFINISHPAGE_NOAUTOCLOSE
    !endif

# Insert the installer pages
;Page custom nsUninstaller_create nsUninstaller_exit
Page custom nsAllInOne_create nsAllInOne_exit
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

# Insert uninstaller pages
UnInstPage custom un.nsUninstaller_create un.nsUninstaller_exit
!insertmacro MUI_UNPAGE_INSTFILES

# Languages
!insertmacro MUI_LANGUAGE English

# EXE attributes
VIProductVersion ${VERSION_NUM}.0.0.1
OutFile zandronum${VERSION}.exe
InstallDir $PROGRAMFILES\Zandronum
CRCCheck on
XPStyle on
ShowInstDetails show
VIAddVersionKey ProductName Zandronum
VIAddVersionKey ProductVersion "${VERSION}"
VIAddVersionKey CompanyName "${COMPANY}"
VIAddVersionKey CompanyWebsite "${URL}"
VIAddVersionKey FileVersion "${VERSION}"
VIAddVersionKey FileDescription ""
VIAddVersionKey LegalCopyright ""
InstallDirRegKey HKLM "${REGKEY}" Path
ShowUninstDetails show

# Variables
Var portableInstallation
Var shouldAssociate
Var shouldRemoveShortcuts
Var shouldRemoveAllFiles
Var shouldRemoveAssociations
Var shouldRemoveDSConfig

# Form elements
Var textbox_Path
Var button_Browse
Var check_PortableInstall
Var check_Associate
Var check_RemoveShortcuts
Var check_RemoveAllFiles
Var check_RemoveAssociations
Var check_RemoveConfig
!define NSD_SETCHECK `!insertmacro _NSD_SETCHECK`
!macro _NSD_SETCHECK NAME TOGGLE
    ${If} ${TOGGLE} == 1
        SendMessage ${NAME} ${BM_SETCHECK} ${BST_CHECKED} 0
    ${Else}
        SendMessage ${NAME} ${BM_SETCHECK} ${BST_UNCHECKED} 0
    ${EndIf}
!macroend

Function un.nsUninstaller_create

    # Create the dialog.
    nsDialogs::Create /NOUNLOAD 1018
    Pop $0

    ${If} $0 == error
        Abort
    ${EndIf}
    nsDialogs::SetRTL /NOUNLOAD $(^RTL)
    
    # Create the "Welcome!" labels.
    ${NSD_CreateLabel} 8u 0u 100% 10u "This will uninstall Zandronum."
    ${NSD_CreateGroupBox} 8u 20u 95% 90u "Uninstall from"    
    
    ${NSD_CreateText} 16u 34u 90% 12u $INSTDIR
        Pop $0
        EnableWindow $0 0
    ${NSD_CreateCheckbox} 24u 54u -28u 10u "Remove shortcuts"
        Pop $check_RemoveShortcuts
    ${NSD_CreateCheckbox} 24u 66u -28u 10u "Remove PWAD associations"
        Pop $check_RemoveAssociations
    ${NSD_CreateCheckbox} 24u 78u -28u 10u "Remove static Doomseeker configuration"
        Pop $check_RemoveConfig
    ${NSD_CreateCheckbox} 24u 90u -28u 10u "Remove all files in the Zandronum folder"
        Pop $check_RemoveAllFiles
    ${NSD_SETCHECK} $check_RemoveShortcuts 1
    ${NSD_SETCHECK} $check_RemoveAssociations 1    
    ${NSD_SETCHECK} $check_RemoveAllFiles 0
	${NSD_SETCHECK} $check_RemoveConfig 0
    
    nsDialogs::Show
FunctionEnd

Function un.nsUninstaller_exit
    ${NSD_GetState} $check_RemoveShortcuts $shouldRemoveShortcuts
    ${NSD_GetState} $check_RemoveAllFiles $shouldRemoveAllFiles
    ${NSD_GetState} $check_RemoveAssociations $shouldRemoveAssociations
    ${NSD_GetState} $check_RemoveConfig $shouldRemoveDSConfig
FunctionEnd

Var mui.WelcomePage.Image
Var mui.WelcomePage.Image.Bitmap
Var mui.WelcomePage.Title.Font
Function nsAllInOne_create

    # Create the dialog (a special, full size type).
    nsDialogs::Create /NOUNLOAD 1044
    Pop $0

    ${If} $0 == error
        Abort
    ${EndIf}
    nsDialogs::SetRTL /NOUNLOAD $(^RTL)
    
    # Make the background white.
    SetCtlColors $0 "" "${MUI_BGCOLOR}"
    
    # Create the banner on the left.
    ${NSD_CreateBitmap} 0u 0u 109u 193u ""
    Pop $mui.WelcomePage.Image
    System::Call 'user32::LoadImage(i 0, t "$PLUGINSDIR\modern-wizard.bmp", i ${IMAGE_BITMAP}, i 0, i 0, i ${LR_LOADFROMFILE}) i.s'
    Pop $mui.WelcomePage.Image.Bitmap
    SendMessage $mui.WelcomePage.Image ${STM_SETIMAGE} ${IMAGE_BITMAP} $mui.WelcomePage.Image.Bitmap
    
    # Create the "Welcome!" labels.
    ${NSD_CreateLabel} 140u 30u -140u 12u "Welcome to Zandronum setup!"
        Pop $0
        SetCtlColors $0 "" "${MUI_BGCOLOR}"
        CreateFont $mui.WelcomePage.Title.Font "Tahoma" "8" "700"
        SendMessage $0 ${WM_SETFONT} $mui.WelcomePage.Title.Font 0
    ${NSD_CreateLabel} 140u 42u -140u 10u "Zandronum continues where Skulltag left off." # [JZ] i'm so original.
        Pop $0
        SetCtlColors $0 "" "${MUI_BGCOLOR}"
    
    # Create the install directory group.
    ${NSD_CreateGroupBox} 140u 128u -155u 32u "Install into"
        Pop $0
        SetCtlColors $0 "" "${MUI_BGCOLOR}"
        ${NSD_CreateDirRequest} 148u 140u -222u 12u $INSTDIR
            Pop $textbox_Path
            SetCtlColors $textbox_Path "" "${MUI_BGCOLOR}"
        ${NSD_CreateBrowseButton} -68u 139u 48u 14u "Browse..."
            Pop $button_Browse
            SetCtlColors $button_Browse "" "${MUI_BGCOLOR}"
            GetFunctionAddress $0 OfflineFileBrowseButton
            nsDialogs::OnClick /NOUNLOAD $button_Browse $0
            
    # Create the check boxes for extra settings.
    ${NSD_CreateCheckbox} 144u 168u 86u 10u "Portable installation"
        Pop $check_PortableInstall
        SetCtlColors $check_PortableInstall "" "${MUI_BGCOLOR}"
        ${NSD_OnClick} $check_PortableInstall nsAllInOne_checkPortable
		${NSD_SETCHECK} $check_PortableInstall 0
    ${NSD_CreateCheckbox} -100u 168u 86u 10u "Associate PWAD files"
        Pop $check_Associate
        SetCtlColors $check_Associate "" "${MUI_BGCOLOR}"  
        ${NSD_OnClick} $check_Associate nsAllInOne_checkPortable
		${NSD_SETCHECK} $check_Associate 1
		
    nsDialogs::Show
    
    # Delete the image from memory.
    System::Call gdi32::DeleteObject(i$mui.WelcomePage.Image.Bitmap)   
FunctionEnd

Function nsAllInOne_checkPortable		
	${NSD_GetState} $check_PortableInstall $portableInstallation    

	GetDlgItem $0 $HWNDPARENT 1 ; Next button
    ${If} $portableInstallation == 1
		${NSD_SetText} $0 "Extract"
		${NSD_SETCHECK} $check_Associate 0
		EnableWindow $check_Associate 0
	${Else}
		${NSD_SetText} $0 "Install"
		EnableWindow $check_Associate 1
	${EndIf}
FunctionEnd

Function OfflineFileBrowseButton
      ${NSD_GetText} $textbox_Path $INSTDIR
      nsDialogs::SelectFolderDialog /NOUNLOAD "Select the folder." $INSTDIR 
      Pop $2
      ${If} $2 != "error"
      ${AndIf} $2 != ""
          SendMessage $textbox_Path ${WM_SETTEXT} 0 STR:$2
     ${EndIf}
FunctionEnd

Function nsAllInOne_exit
    ${NSD_GetText} $textbox_Path $INSTDIR
    ${NSD_GetState} $check_PortableInstall $portableInstallation    
    ${NSD_GetState} $check_Associate $shouldAssociate
FunctionEnd

#===================================================
#
# Creates internet shortcuts.
#   Acquired 12/25/08 from http://nsis.sourceforge.net/CreateInternetShortcut_macro_&_function
#
#===================================================

!macro CreateInternetShortcut FILENAME URL
WriteINIStr "${FILENAME}.url" "InternetShortcut" "URL" "${URL}"
!macroend

#--------------------------
# The installation process.
Section "Installer"
    SetOutPath $INSTDIR
    SetOverwrite on   
    
    # Write the game files.
    !ifdef RELEASEBUILD
        # File zandronum_files\Rcon_utility.exe  [NW] Doomseeker supports this already. We no longer need to maintain this utility.
        File zandronum_files\Readme.txt
        File zandronum_files\zandronum.exe
        File zandronum_files\zandronum.pk3
        File "zandronum_files\Zandronum Version History.txt"
        File zandronum_files\fmodex.dll
        File zandronum_files\skulltag_actors.pk3
	# Doomseeker files.
        SetOutPath $INSTDIR\Doomseeker
        File zandronum_files\Doomseeker\doomseeker.exe
        File zandronum_files\Doomseeker\doomseeker.ico
        File zandronum_files\Doomseeker\doomseeker-portable.bat
        File zandronum_files\Doomseeker\libwadseeker.dll
        File zandronum_files\Doomseeker\Microsoft.VC90.CRT.manifest
        File zandronum_files\Doomseeker\msvcm90.dll
        File zandronum_files\Doomseeker\msvcp90.dll
        File zandronum_files\Doomseeker\msvcr90.dll
        File zandronum_files\Doomseeker\QtCore4.dll
        File zandronum_files\Doomseeker\QtGui4.dll
        File zandronum_files\Doomseeker\QtNetwork4.dll
        File zandronum_files\Doomseeker\QtXml4.dll
        File zandronum_files\Doomseeker\updater.exe
        # Preconfigure paths for Doomseeker. [NW] todo: figure out how to break up and read line 364, 366, 361, 362
        #SetOutPath $APPDATA\.doomseeker
        #FileOpen $9 doomseeker.ini w 
        #FileWrite $9 "[Zandronum]$\r$\n"
        #FileWrite $9 "Masterserver=master.zandronum.com:15300$\r$\n"
        #FileWrite $9 "BinaryPath=$\"$INSTDIR\zandronum.exe$\"$\r$\n"
        #FileWrite $9 "ServerBinaryPath=$INSTDIR\zandronum.exe$\r$\n"
        #FileWrite $9 "[Doomseeker]$\r$\n"
        #FileWrite $9 "WadPaths=$\"$INSTDIR\\wads\\;$INSTDIR\\$\"$\r$\n"
        #FileWrite $9 "[Wadseeker]$\r$\n"
        #FileWrite $9 "TargetDirectory=$INSTDIR\wads"
        #FileClose $9
        # Copy the chat directory [NW] Doomseeker supports this too.
        # SetOutPath $INSTDIR\skulltalk
        # File /r skulltag_files\skulltalk\*.*
		
        SetOutPath $INSTDIR\skins
        File /r zandronum_files\skins\*.*
        SetOutPath $INSTDIR\Doomseeker\engines
        File /r zandronum_files\Doomseeker\engines\*.*
        # [CK] Support new Doomseeker folder
        SetOutPath $INSTDIR\Doomseeker\translations
        File /r zandronum_files\Doomseeker\translations\*.*
        SetOutPath $INSTDIR\announcer
        File /r zandronum_files\announcer\*.*                       
        
        SetOutPath $INSTDIR
    !endif    

    # Create the uninstaller.
    ${If} $portableInstallation == 0    
		WriteUninstaller $INSTDIR\uninstall.exe
    ${EndIf}
    
    # Create start menu shortcuts.
    ${If} $portableInstallation == 0
        SetOutPath $INSTDIR
		# Start menu stuff
        CreateShortcut "$SMPROGRAMS\Zandronum\Play Zandronum (Singleplayer).lnk" $INSTDIR\zandronum.exe
        CreateShortcut "$SMPROGRAMS\Zandronum\Play Zandronum (Online).lnk" $INSTDIR\Doomseeker\doomseeker.exe
        CreateShortcut "$DESKTOP\Play Zandronum (Online).lnk" $INSTDIR\Doomseeker\doomseeker.exe
        #SetOutPath $INSTDIR\skulltalk
        #CreateShortcut "$SMPROGRAMS\Skulltag\Chat with Skulltaggers.lnk" $INSTDIR\skulltalk\Skulltalk.exe
        
        SetOutPath $SMPROGRAMS\Zandronum
        !insertmacro CreateInternetShortcut "$SMPROGRAMS\Zandronum\Forum" "http://zandronum.com/forum/"
                      
        CreateDirectory $SMPROGRAMS\Zandronum\Tools
        SetOutPath $SMPROGRAMS\Zandronum\Tools        
		# [NW] Merge these two into a single tracker link instead of splitting them up. They go to the same place anyway. I may create splash pages later and change out this code to reflect it.
        #!insertmacro CreateInternetShortcut "$SMPROGRAMS\Zandronum\Tools\Report a bug" "http://skulltag.com/bugs/"
        #!insertmacro CreateInternetShortcut "$SMPROGRAMS\Zandronum\Tools\Request a feature" "http://skulltag.com/featurerequests/"
        !insertmacro CreateInternetShortcut "$SMPROGRAMS\Zandronum\Tools\Development Tracker" "http://zandronum.com/tracker"
        #CreateShortcut "Manage server.lnk" $INSTDIR\rcon_utility.exe
        CreateShortcut "Uninstall.lnk" $INSTDIR\uninstall.exe
        
        # Add/Remove programs entry.
        WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" DisplayName "$(^Name)"
        WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" DisplayVersion "${VERSION}"
        WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" Publisher "${COMPANY}"
        WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" URLInfoAbout "${URL}"
        WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" DisplayIcon $INSTDIR\uninstall.exe
        WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" UninstallString $INSTDIR\uninstall.exe
        WriteRegDWORD HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" NoModify 1
        WriteRegDWORD HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" NoRepair 1
    ${EndIf}
    
    # Associate .WAD and .PK3 files.
    ${If} $portableInstallation == 0
		${If} $shouldAssociate == 1
			DetailPrint "Associating .WAD and .PK3 files..."
			!insertmacro APP_ASSOCIATE "wad" "Doom.wadfile" "Doom data file "$INSTDIR\zandronum.exe,0" "Play with Zandronum" "$INSTDIR\zandronum.exe $\"%1$\""
			!insertmacro APP_ASSOCIATE "pk3" "ZDoom.wadfile" "ZDoom data file "$INSTDIR\zandronum.exe,0" "Play with Zandronum" "$INSTDIR\zandronum.exe $\"%1$\""
		${EndIf}
    ${EndIf}
    
    # Create exceptions in Windows Firewall. (All Networks - All IP Version - Enabled)
    ${If} $portableInstallation == 0
		DetailPrint "Creating exceptions in Windows Firewall..."    
		# !insertmacro ADD_FIREWALL_EXCEPTION "$INSTDIR\zandronum.exe" "Zandronum"
		# !insertmacro ADD_FIREWALL_EXCEPTION "$INSTDIR\Doomseeker\doomseeker.exe" "Doomseeker"
#		# !insertmacro ADD_FIREWALL_EXCEPTION "$INSTDIR\rcon_utility.exe"   "RCON_utility"       
    ${EndIf}
    
SectionEnd

#---------------------------
# The uninstaller's process.
Section "Uninstall"
    # $INSTDIR is the folder in which the uninstaller resides.
    
    # Delete game files.
    ${If} $shouldRemoveAllFiles == 1
        DetailPrint "Removing all files in $INSTDIR..."
        RmDir /r /REBOOTOK $INSTDIR
    ${Else}
        DetailPrint "Removing stock Zandronum files..."
        # zan
        SetOutPath $INSTDIR
        Delete /REBOOTOK Readme.txt
        Delete /REBOOTOK fmodex.dll    		
        Delete /REBOOTOK zandronum.exe
        Delete /REBOOTOK zandronum.pk3
        Delete /REBOOTOK skulltag_actors.pk3
        Delete /REBOOTOK "Zandronum Version History.txt"
        Delete /REBOOTOK fmodex.dll
	# Remove Doomseeker
        SetOutPath $INSTDIR\Doomseeker
	Delete /REBOOTOK doomseeker.exe
        Delete /REBOOTOK doomseeker-portable.bat
        Delete /REBOOTOK libwadseeker.dll
        Delete /REBOOTOK Microsoft.VC90.CRT.manifest
	Delete /REBOOTOK QtCore4.dll
        Delete /REBOOTOK QtGui4.dll
        Delete /REBOOTOK QtNetwork4.dll
        Delete /REBOOTOK msvcm90.dll
        Delete /REBOOTOK msvcp90.dll
        Delete /REBOOTOK msvcr90.dll
        SetOutPath $INSTDIR\Doomseeker\engines
        Delete /REBOOTOK libzandronum.dll
        Delete /REBOOTOK Microsoft.VC90.CRT.manifest

        
        # Some old files that might be around from a past upgrade.
        Delete /REBOOTOK skulltag.wad
        Delete /REBOOTOK IdeSe.exe
        Delete /REBOOTOK fmod.dll
        Delete /REBOOTOK getwad.dll
        Delete /REBOOTOK ip2c.dll
        Delete /REBOOTOK devil.dll
        Delete /REBOOTOK ilu.dll
        Delete /REBOOTOK skulltag_data.pk3
        Delete /REBOOTOK Rcon_utility.exe

        
        SetOutPath $INSTDIR\announcer
        Delete /REBOOTOK Skulltag_98a_announcer.pk3
        Delete /REBOOTOK ZanGeneric.pk3
        Delete /REBOOTOK ZanACG.pk3
        # About all of these are largely uncredited.
	SetOutPath $INSTDIR\skins
        Delete /REBOOTOK ST_BASEII.pk3
        Delete /REBOOTOK ST_BASEIII.pk3
        Delete /REBOOTOK ST_Chaingun_Marine.pk3
        Delete /REBOOTOK ST_Chubbs.pk3
        Delete /REBOOTOK ST_Crash.pk3
        Delete /REBOOTOK ST_Doom64Guy.pk3
        Delete /REBOOTOK ST_Illucia.pk3
        Delete /REBOOTOK ST_Orion.pk3
        Delete /REBOOTOK ST_Phobos.pk3
        Delete /REBOOTOK ST_Procyon.pk3
        Delete /REBOOTOK ST_Seenas.pk3
        Delete /REBOOTOK ST_Strife_Guy.pk3
        Delete /REBOOTOK ST_Synas.pk3            
        Delete /REBOOTOK about.txt
        
        # Uninstall chat...
        SetOutPath $INSTDIR\skulltalk
        Delete /REBOOTOK Skulltalk.exe
        Delete /REBOOTOK Nettalk.ini        
        SetOutPath $INSTDIR\skulltalk\Preferences
        Delete /REBOOTOK BgSkinPicture.dat
        Delete /REBOOTOK Dark.jpg
        Delete /REBOOTOK Language.ini
        Delete /REBOOTOK Nettalk.ini
        Delete /REBOOTOK Servers.srv
        Delete /REBOOTOK "Skulltag Dark.skn"
        Delete /REBOOTOK "Skulltag Light.skn"
        
        # Delete empty directories.
        SetOutPath $TEMP
        RmDir /REBOOTOK $INSTDIR\announcer
        RmDir /REBOOTOK $INSTDIR\engines
        RmDir /REBOOTOK $INSTDIR\skins
        RmDir /REBOOTOK $INSTDIR\skulltalk\Preferences
        RmDir /REBOOTOK $INSTDIR\skulltalk 
        RmDir /REBOOTOK $INSTDIR\Doomseeker\engines		
	RmDir /REBOOTOK $INSTDIR\Doomseeker
        
    ${EndIf}

	# Remove the static configuration inside of AppData.
    ${If} $shouldRemoveDSConfig == 1
        Delete /REBOOTOK $APPDATA\.doomseeker\demos\*.*
        RmDir /r /REBOOTOK $APPDATA\.doomseeker\demos
        Delete /REBOOTOK doomseeker.ini
        Delete /REBOOTOK doomseeker-irc.ini
        Delete /REBOOTOK IpToCountry.csv
        Delete /REBOOTOK Odamex
        Delete /REBOOTOK Skulltag
        Delete /REBOOTOK Vavoom
        Delete /REBOOTOK Zandronum
        Delete /REBOOTOK ZDaemon
        Delete /REBOOTOK ChocolateDoom
        Delete /REBOOTOK $APPDATA\.doomseeker\*.*
        RmDir /r /REBOOTOK $APPDATA\.doomseeker
    ${EndIf}

    # Delete shortcuts and the Add/Remove entry.
    ${If} $shouldRemoveShortcuts == 1		
        Delete /REBOOTOK "$DESKTOP\Play Zandronum (Online).lnk"
        RmDir /r /REBOOTOK "$SMPROGRAMS\Zandronum\"
        SetShellVarContext all
        RmDir /r /REBOOTOK "$SMPROGRAMS\Zandronum\"
        DeleteRegKey HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)"
    ${EndIf}
    
    
    # Remove .WAD/.PK3 associations.
    ${If} $shouldRemoveAssociations == 1
        !insertmacro APP_UNASSOCIATE "wad" "Doom.wadfile"
        !insertmacro APP_UNASSOCIATE "pk3" "ZDoom.wadfile"
    ${EndIf}
	
    # Remove firewall exceptions.
    # !insertmacro REMOVE_FIREWALL_EXCEPTION "$INSTDIR\zandronum.exe" "Zandronum"
    # !insertmacro REMOVE_FIREWALL_EXCEPTION "$INSTDIR\Doomseeker\doomseeker.exe" "Doomseeker"
    # !insertmacro REMOVE_FIREWALL_EXCEPTION "$INSTDIR\rcon_utility.exe" "RCON utiliy"    
SectionEnd

