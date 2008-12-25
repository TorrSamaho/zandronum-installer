#=================================================
#
# Skulltag Installer v3
# Copyright (c) 2009 Rivecoder
#
# To add new files to the installer, go to [Section "Installer"] and [Section "Uninstall"].
#
#=================================================

# Build options
!define RELEASEBUILD        # Always define this when doing a final build.
!define VERSION_NUM 97
!define VERSION 97d

# Compression (lzma = god)
!ifdef RELEASEBUILD
    SetCompressor /SOLID lzma
!endif

# Included files
!include MUI2.nsh
!include include\fileAssociate.nsh

Name Skulltag

# Add/Remove Programs entry  
!define REGKEY "SOFTWARE\$(^Name)"
!define COMPANY Skulltag
!define URL http://skulltag.com

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

    !define MUI_FINISHPAGE_NOAUTOCLOSE
    !define MUI_UNFINISHPAGE_NOAUTOCLOSE

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
OutFile skulltagSetup.exe
InstallDir $PROGRAMFILES\Skulltag
CRCCheck on
XPStyle on
ShowInstDetails show
VIAddVersionKey ProductName Skulltag
VIAddVersionKey ProductVersion "${VERSION}"
VIAddVersionKey CompanyName "${COMPANY}"
VIAddVersionKey CompanyWebsite "${URL}"
VIAddVersionKey FileVersion "${VERSION}"
VIAddVersionKey FileDescription ""
VIAddVersionKey LegalCopyright ""
InstallDirRegKey HKLM "${REGKEY}" Path
ShowUninstDetails show

# Variables
Var shouldCreateShortcuts
Var shouldAssociate
Var shouldRemoveShortcuts
Var shouldRemoveAllFiles
Var shouldRemoveAssociations

# Form elements
Var textbox_Path
Var button_Browse
Var check_Shortcuts
Var check_Associate
Var check_RemoveShortcuts
Var check_RemoveAllFiles
Var check_RemoveAssociations
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
    ${NSD_CreateLabel} 8u 0u 100% 10u "This will uninstall Skulltag."
    ${NSD_CreateGroupBox} 8u 20u 95% 76u "Uninstall from"    
    
    ${NSD_CreateText} 16u 34u 90% 12u $INSTDIR
        Pop $0
        EnableWindow $0 0
    ${NSD_CreateCheckbox} 24u 54u -28u 10u "Remove shortcuts"
        Pop $check_RemoveShortcuts
    ${NSD_CreateCheckbox} 24u 66u -28u 10u "Remove PWAD associations"
        Pop $check_RemoveAssociations
    ${NSD_CreateCheckbox} 24u 78u -28u 10u "Remove all files in the Skulltag folder"
        Pop $check_RemoveAllFiles
    ${NSD_SETCHECK} $check_RemoveShortcuts 1
    ${NSD_SETCHECK} $check_RemoveAssociations 1    
    ${NSD_SETCHECK} $check_RemoveAllFiles 0
    
    nsDialogs::Show
FunctionEnd

Function un.nsUninstaller_exit
    ${NSD_GetState} $check_RemoveShortcuts $shouldRemoveShortcuts
    ${NSD_GetState} $check_RemoveAllFiles $shouldRemoveAllFiles
    ${NSD_GetState} $check_RemoveAssociations $shouldRemoveAssociations
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
    ${NSD_CreateLabel} 140u 30u -140u 12u "Welcome to Skulltag setup!"
        Pop $0
        SetCtlColors $0 "" "${MUI_BGCOLOR}"
        CreateFont $mui.WelcomePage.Title.Font "Tahoma" "8" "700"
        SendMessage $0 ${WM_SETFONT} $mui.WelcomePage.Title.Font 0
    ${NSD_CreateLabel} 140u 42u -140u 10u "Skulltag adds fresh ideas to Doom's classic gameplay."
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
    ${NSD_CreateCheckbox} 144u 168u 86u 10u "Associate PWAD files"
        Pop $check_Associate
        SetCtlColors $check_Associate "" "${MUI_BGCOLOR}"
    ${NSD_CreateCheckbox} -90u 168u 82u 10u "Create shortcuts"
        Pop $check_Shortcuts
        SetCtlColors $check_Shortcuts "" "${MUI_BGCOLOR}"
    ${NSD_SETCHECK} $check_Shortcuts 1
    ${NSD_SETCHECK} $check_Associate 1       

    
    nsDialogs::Show
    
    # Delete the image from memory.
    System::Call gdi32::DeleteObject(i$mui.WelcomePage.Image.Bitmap)   
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
    ${NSD_GetState} $check_Shortcuts $shouldCreateShortcuts
    ${NSD_GetState} $check_Associate $shouldAssociate
    
FunctionEnd

# Nicely adds a firewall exception.
!macro ADD_FIREWALL_EXCEPTION PATH NAME

    # Check if windows firewall service is running.
    SimpleFC::IsFirewallServiceRunning
        Pop $0 ; return error(1)/success(0)
        Pop $1 ; return 1=IsRunning/0=Not Running
    ${If} $0 == 1
    ${OrIf} $1 == 0
        DetailPrint "${NAME}: firewall not running."
    ${Else}   
        SimpleFC::IsApplicationAdded ${PATH}
            Pop $0 ; return error(1)/success(0)
            Pop $1 ; return 1=Added/0=Not added
            
        ${If} $0 == 1       # Error check
            DetailPrint "${NAME}: Couldn't connect to firewall."
        ${Else}        
            ${If} $1 == 1       # Not added already?
                DetailPrint "${NAME}: An exception already exists."
            ${Else}            
                SimpleFC::AddApplication ${NAME} ${PATH} 0 2 "" 1
                    Pop $0  ; return error(1)/success(0)
                ${If} $0 == 0
                    DetailPrint "${NAME}: Added exception."
                ${Else}
                    DetailPrint "${NAME}: Couldn't add an exception."
                ${EndIf}
            ${EndIf}
        ${EndIf}
    ${EndIf}
!macroend

# Nicely removes a firewall exception.
!macro REMOVE_FIREWALL_EXCEPTION PATH NAME

    # Check if windows firewall service is running.
    SimpleFC::IsFirewallServiceRunning
        Pop $0 ; return error(1)/success(0)
        Pop $1 ; return 1=IsRunning/0=Not Running
    ${If} $0 == 1
    ${OrIf} $1 == 0
        DetailPrint "${NAME}: firewall not running."
    ${Else}   
        SimpleFC::IsApplicationAdded ${PATH}
            Pop $0 ; return error(1)/success(0)
            Pop $1 ; return 1=Added/0=Not added
            
        ${If} $0 == 1       # Error check
            DetailPrint "${NAME}: Couldn't connect to firewall."
        ${Else}        
            ${If} $1 == 1       # Added already?           
                SimpleFC::RemoveApplication ${PATH}
                    Pop $0  ; return error(1)/success(0)
                ${If} $0 == 0
                    DetailPrint "${NAME}: Removed exception."
                ${Else}
                    DetailPrint "${NAME}: Couldn't remove exception."
                ${EndIf}
            ${EndIf}
        ${EndIf}
    ${EndIf}
!macroend


#--------------------------
# The installation process.
Section "Installer"
    SetOutPath $INSTDIR
    SetOverwrite on   
    
    # Write the game files.
    !ifdef RELEASEBUILD
        File skulltag_files\fmod.dll
        File skulltag_files\getwad.dll
        File skulltag_files\IdeSE.exe
        File skulltag_files\ip2c.dll
        File skulltag_files\Readme.txt
        File skulltag_files\rcon_utility.exe               
        File skulltag_files\skulltag.exe
        File skulltag_files\skulltag.pk3
        File skulltag_files\skulltag.wad
        File "skulltag_files\Skulltag Version History.txt"
    !endif

    # Create the uninstaller.
    WriteUninstaller $INSTDIR\uninstall.exe
    
    # Create start menu shortcuts.
    ${If} $shouldCreateShortcuts == 1
        SetOutPath $SMPROGRAMS\Skulltag
        CreateShortcut "Play Singleplayer.lnk" $INSTDIR\skulltag.exe
        CreateShortcut "Play Online.lnk" $INSTDIR\IdeSE.exe
        CreateShortcut "Tools\Manage server.lnk" $INSTDIR\rcon_utility.exe        
        CreateShortcut "Tools\Uninstall.lnk" $INSTDIR\uninstall.exe
        
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
    ${If} $shouldAssociate == 1
        DetailPrint "Associating .WAD and .PK3 files..."
        !insertmacro APP_ASSOCIATE "wad" "Doom.wadfile" "Doom data file "$INSTDIR\skulltag.exe,0" "Play with Skulltag" "$INSTDIR\skulltag.exe $\"%1$\""
        !insertmacro APP_ASSOCIATE "pk3" "ZDoom.wadfile" "ZDoom data file "$INSTDIR\skulltag.exe,0" "Play with Skulltag" "$INSTDIR\skulltag.exe $\"%1$\""
    ${EndIf}
    
    # Create exceptions in Windows Firewall. (All Networks - All IP Version - Enabled)
    DetailPrint "Creating exceptions in Windows Firewall..."    
    !insertmacro ADD_FIREWALL_EXCEPTION "$INSTDIR\skulltag.exe"       "Skulltag"
    !insertmacro ADD_FIREWALL_EXCEPTION "$INSTDIR\IdeSE.exe"          "IdeSE"
    !insertmacro ADD_FIREWALL_EXCEPTION "$INSTDIR\rcon_utility.exe"   "RCON utility"       
    
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
        DetailPrint "Removing stock Skulltag files..."
        SetOutPath $INSTDIR
        Delete /REBOOTOK fmod.dll
        Delete /REBOOTOK getwad.dll
        Delete /REBOOTOK IdeSE.exe
        Delete /REBOOTOK ip2c.dll
        Delete /REBOOTOK Readme.txt
        Delete /REBOOTOK rcon_utility.exe
        Delete /REBOOTOK skulltag.exe
        Delete /REBOOTOK skulltag.pk3    
        Delete /REBOOTOK skulltag.wad
        Delete /REBOOTOK "Skulltag Version History.txt"
        Delete /REBOOTOK uninstall.exe
    ${EndIf}
    
    # Delete shortcuts and the Add/Remove entry.
    ${If} $shouldRemoveShortcuts == 1
        Delete /REBOOTOK "$SMPROGRAMS\Skulltag\Uninstall $(^Name).lnk"
        Delete /REBOOTOK "$SMPROGRAMS\Skulltag\Play Singleplayer.lnk"
        Delete /REBOOTOK "$SMPROGRAMS\Skulltag\Play Online.lnk"        
        DeleteRegKey HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)"
    ${EndIf}
    
    # Remove .WAD/.PK3 associations.
    ${If} $shouldRemoveAssociations == 1
        !insertmacro APP_UNASSOCIATE "wad" "Doom.wadfile"
        !insertmacro APP_UNASSOCIATE "pk3" "ZDoom.wadfile"
    ${EndIf}
    
    # Remove firewall exceptions.
    !insertmacro REMOVE_FIREWALL_EXCEPTION "$INSTDIR\skulltag.exe"        "Skulltag"
    !insertmacro REMOVE_FIREWALL_EXCEPTION "$INSTDIR\IdeSE.exe"           "IdeSE"
    !insertmacro REMOVE_FIREWALL_EXCEPTION "$INSTDIR\rcon_utility.exe"    "RCON utiliy"    
    
    
    # Remove the folders if they're completely empty.
    RmDir /REBOOTOK $SMPROGRAMS\Skulltag
    RmDir /REBOOTOK $INSTDIR
SectionEnd

