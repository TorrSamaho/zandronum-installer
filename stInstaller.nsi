;==================================;
; 		Skulltag Installer         ;
;==================================;

;--------------------------------
; NSIS IMPORTS

	; Modern UI
	!include "MUI.nsh"
	; Zip Extraction
	!include "ZipDLL.nsh"
	; Loops and logic
	!include LogicLib.nsh

;--------------------------------
; VARIABLES

	; The text on the 'Finished' page varies on whether the setup worked.
	Var g_FinishPage_BodyText				; The main paragraph.
	Var g_FinishPage_Title					; The title.
	Var g_FinishPage_RunLink				; ('Run' checkbox) Path.
	Var g_FinishPage_RunLink_Label			; ('Run' checkbox) Label.
	Var g_FinishPage_RunLink_Parameters		; ('Run' checkbox) Parameters.
	Var g_FinishPage_SetupLink				; URL to the 'online configuration guide'.

	; Random server we use for the download.
	var RandomSeed
	Var Mirror_count
	
	; Start menu folder is saved in the registry.
	Var STARTMENU_FOLDER


;--------------------------------
; GENERAL SETTINGS

	; Name and file
	Name "Skulltag"
	OutFile "St-Installer.exe"
	
	; Default installation folder
	InstallDir "$PROGRAMFILES\Skulltag"
	
	; Get installation folder from registry if available
	InstallDirRegKey HKCU "Software\Skulltag" ""

;--------------------------------
; INTERFACE SETTINGS
 
	; Prompt the user before quitting early.
	!define MUI_ABORTWARNING
	
	; Installer EXE icon.
	!define MUI_ICON "res\graphics_icon.ico" ;main program icon
	
	; Uninstaller EXE icon.
	!define MUI_UNICON "C:\Program Files\NSIS\Contrib\Graphics\Icons\orange-uninstall-nsis.ico" ;uninstaller icon
	
	; The large side image shown at start / finish.
	!define MUI_WELCOMEFINISHPAGE_BITMAP "res\graphics_side.bmp"
	!define MUI_UNWELCOMEFINISHPAGE_BITMAP "res\graphics_sideun.bmp"
	
	; The small icon shown at the top during setup.
	!define MUI_HEADERIMAGE
	!define MUI_HEADERIMAGE_BITMAP "res\graphics_top.bmp"
	
	; The grayed text at the bottom.
	BrandingText "Skulltag"
	
;--------------------------------
; SETUP PAGES

	; Welcome.
		!define MUI_WELCOMEPAGE_TITLE "Welcome to Skulltag!"
		!define MUI_WELCOMEPAGE_TEXT "This wizard will download and install the latest version of Skulltag.\n\nPlease make sure that you're connected to the internet before continuing."
	!insertmacro MUI_PAGE_WELCOME

	; Directory select.
		!define MUI_DIRECTORYPAGE_TEXT_TOP "Setup will install Skulltag in the following folder. To install into a different folder, click Browse. Try to avoid installing into another sourceport's directory."
	!insertmacro MUI_PAGE_DIRECTORY

	; Start menu.
		!define MUI_STARTMENUPAGE_TEXT_TOP "Select or type in the Start Menu folder that you'd like shortcuts to Skulltag made. There will be links to play, browse / host servers, troubleshoot, as well as community links."
		!define MUI_STARTMENUPAGE_REGISTRY_ROOT "HKCU" 
		!define MUI_STARTMENUPAGE_REGISTRY_KEY "Software\Skulltag" 
		!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "Start Menu Folder"  
	!insertmacro MUI_PAGE_STARTMENU Application $STARTMENU_FOLDER
	
	; Installation progress.
		!define MUI_TEXT_INSTALLING_SUBTITLE "Please wait while Skultag is downloaded and installed."
		;---------------------------------------------------------------------------------------
		; When commented, Setup goes straight to the finish page after installing (recommended).
		; Uncomment the next line during testing to help troubleshoot.
		; !define MUI_FINISHPAGE_NOAUTOCLOSE
		;----------------------------------------------------------------------------------------
	!insertmacro MUI_PAGE_INSTFILES
  
	; Finished.
		!define MUI_FINISHPAGE_TITLE "$g_FinishPage_Title"
		!define MUI_FINISHPAGE_TEXT "$g_FinishPage_BodyText"
		!define MUI_FINISHPAGE_RUN_PARAMETERS "$g_FinishPage_RunLink_Parameters"
		!define MUI_FINISHPAGE_RUN "$g_FinishPage_RunLink"
		!define MUI_FINISHPAGE_RUN_TEXT "$g_FinishPage_RunLink_Label"
		!define MUI_FINISHPAGE_LINK "Online configuration guide"
		!define MUI_FINISHPAGE_LINK_LOCATION "$g_FinishPage_SetupLink"
		!define MUI_FINISHPAGE_RUN_NOTCHECKED
	!insertmacro MUI_PAGE_FINISH

	; Uninstaller.
	!insertmacro MUI_UNPAGE_WELCOME
	!insertmacro MUI_UNPAGE_CONFIRM
	!insertmacro MUI_UNPAGE_INSTFILES
	!insertmacro MUI_UNPAGE_FINISH

;--------------------------------
; LANGUAGES

	!insertmacro MUI_LANGUAGE "English"
  
;--------------------------------
; WEB SHORTCUT CREATOR

	!macro CreateInternetShortcut FILENAME URL ICONFILE ICONINDEX
		WriteINIStr "${FILENAME}.url" "InternetShortcut" "URL" "${URL}"
		WriteINIStr "${FILENAME}.url" "InternetShortcut" "IconFile" "${ICONFILE}"
		WriteINIStr "${FILENAME}.url" "InternetShortcut" "IconIndex" "${ICONINDEX}"
	!macroend

;--------------------------------
; INSTALLER


Section "Core Files" stCore
	
	; We can't judge the size of the files yet (they're still sitting on a server at this point).
	; Simply pad the size to 50 mb which should give a rough idea.
	AddSize 51196
	SetOutPath "$INSTDIR"
	
	;============================
	; Get the download index file
	;============================
				DetailPrint "Downloading the index file..."
				Push "http://www.skulltag.com/download/installpaths.txt"
				Push 1 													
				Push "$TEMP\installpaths.txt"
				Call DownloadFromRandomMirror
				Pop $0
				
	;===========================
	; Crunch results of download
	;===========================
				${Switch} $0
					${Case} 'cancel'
							DetailPrint "Cancelled by user."
							StrCpy $g_FinishPage_BodyText "Setup was cancelled (stage 1). Re-run the program to install Skulltag or download the zip of the latest version."
							StrCpy $g_FinishPage_Title "Cancelled."
							StrCpy $g_FinishPage_RunLink "$WINDIR\explorer.exe"
							StrCpy $g_FinishPage_RunLink_Label "Browse Skulltag folder"
							StrCpy $g_FinishPage_RunLink_Parameters "$INSTDIR"
							Goto End
							${Break}
					${Case} 'success'
							; Don't goto end.
							${Break}
					${Default}
							StrCpy $g_FinishPage_BodyText "There was an error ($0) during setup (stage 1). Re-run the program to install Skulltag or download the zip of the latest version."
							StrCpy $g_FinishPage_Title "Failure."
							StrCpy $g_FinishPage_RunLink "$WINDIR\explorer.exe"
							StrCpy $g_FinishPage_RunLink_Label "Browse Skulltag folder"
							StrCpy $g_FinishPage_RunLink_Parameters "$INSTDIR"
							Goto End
							${Break}
				${EndSwitch}

	;=======================
	; Analyze the index file
	;========================
	
				FileOpen $4 "$TEMP\installpaths.txt" r
				
				; Read the first line (mirror count).
				FileSeek $4 0;
				FileRead $4 $R7
				;DetailPrint "Read in: $R7"
					
				; Remove the linebreak.
				StrLen $R3 $R7					; Get length of line.
				IntOp $R4 $R3 - 1  				; Subtract the \n.
				StrCpy $Mirror_count $R7 $R4 	; Copy, using the shortened length.
				DetailPrint "Mirror count: $Mirror_count"
				
				; Read in the second line (setup URL).
				FileRead $4 $g_FinishPage_SetupLink
				
				; Now read in the rest of the mirrors, and add the URLs to the stack.
				${For} $R1 1 $Mirror_count
					FileRead $4 $R2					
					; Remove the linebreak.
					StrLen $R3 $R2
					IntOp $R4 $R3 - 1
					StrCpy $R5 $R2 $R4
					Push $R5
					DetailPrint "Found mirror $R1 / $Mirror_count: $R5"
				${Next}
					
				; Close the index file.
					FileClose $4
	 			
	;========================================
	; Download the files from a random mirror
	;========================================			
				Push $Mirror_count 					; Number of mirrors (10 max).
				Push "$TEMP\Skulltag-latest.zip"	; Filename to save as.
				Call DownloadFromRandomMirror
				Pop $0								; Get the result.
	
	;===========================
	; Crunch results of download
	;===========================
				${Switch} $0
					${Case} 'cancel'
							DetailPrint "Cancelled by user."
							StrCpy $g_FinishPage_BodyText "Setup was cancelled  (stage 2). Re-run the program to install Skulltag or download the zip of the latest version."
							StrCpy $g_FinishPage_Title "Cancelled."
							StrCpy $g_FinishPage_RunLink "$WINDIR\explorer.exe"
							StrCpy $g_FinishPage_RunLink_Label "Browse Skulltag folder"
							StrCpy $g_FinishPage_RunLink_Parameters "$INSTDIR"
							Goto End
							${Break}
					${Case} 'success'
							StrCpy $g_FinishPage_BodyText "The latest version of Skulltag has been installed. Remember that Skulltag is a sourceport so you'll need to have an IWAD from Doom, Doom II, or FreeDoom. For more help consult the Getting Started guide availible from the start menu."
							StrCpy $g_FinishPage_Title "Installation Complete!"
							StrCpy $g_FinishPage_RunLink "$INSTDIR\Skulltag.exe"
							StrCpy $g_FinishPage_RunLink_Label "Play Skulltag now!"
							${Break}
					${Default}
							StrCpy $g_FinishPage_BodyText "There was an error ($0) during setup (stage 2). Re-run the program to install Skulltag or download the zip of the latest version."
							StrCpy $g_FinishPage_Title "Failure."
							StrCpy $g_FinishPage_RunLink "$WINDIR\explorer.exe"
							StrCpy $g_FinishPage_RunLink_Label "Browse Skulltag folder"
							StrCpy $g_FinishPage_RunLink_Parameters "$INSTDIR"
							Goto End
						${Break}

				${EndSwitch}
					
	;==================
	; Extract the files
	;==================
					!insertmacro ZIPDLL_EXTRACT "$TEMP\Skulltag-latest.zip" "$INSTDIR" "<ALL>"
	
					;Store installation folder in the registry
					WriteRegStr HKCU "Software\Skulltag" "" $INSTDIR

	;==========================
	; Create start menu entries
	;==========================
				!insertmacro MUI_STARTMENU_WRITE_BEGIN Application  
					CreateDirectory "$SMPROGRAMS\$STARTMENU_FOLDER"
					CreateDirectory "$SMPROGRAMS\$STARTMENU_FOLDER\Community"
					 !insertmacro "CreateInternetShortcut" "$SMPROGRAMS\$STARTMENU_FOLDER\Community\Forums" "http://www.skulltag.com/forum" "" ""
					 !insertmacro "CreateInternetShortcut" "$SMPROGRAMS\$STARTMENU_FOLDER\Community\Friday Night Fragfest" "http://www.skulltag.com/download" "" ""
					 !insertmacro "CreateInternetShortcut" "$SMPROGRAMS\$STARTMENU_FOLDER\Community\IRC Chat" "irc://irc.oftc.net/skulltag" "" ""
	
					CreateShortCut "$SMPROGRAMS\$STARTMENU_FOLDER\Play Skulltag!.lnk" "$INSTDIR\Skulltag.exe" "" "$INSTDIR\Skulltag.exe" 0 "" "" "Run the Skulltag client."
					CreateShortCut "$SMPROGRAMS\$STARTMENU_FOLDER\Browse Servers.lnk" "$INSTDIR\IdeSE.exe" "" "$INSTDIR\IDESE.exe" 0 "" "" "Browse availible servers to play on."
					CreateShortCut "$SMPROGRAMS\$STARTMENU_FOLDER\Host Server.lnk" "$INSTDIR\Skulltag.exe" "-host" "$INSTDIR\Skulltag.exe" 0 "" "" "Starts a multiplayer server that others can play on."
					CreateShortCut "$DESKTOP\Skulltag.lnk" "$INSTDIR\Skulltag.exe" "" "" 0 "" "" "Play Skulltag!"
					 !insertmacro "CreateInternetShortcut" "$SMPROGRAMS\$STARTMENU_FOLDER\Setup guide" "$g_FinishPage_SetupLink" "" ""
					 !insertmacro "CreateInternetShortcut" "$SMPROGRAMS\$STARTMENU_FOLDER\Website" "http://www.skulltag.com/forum" "" ""
					 CreateShortCut "$SMPROGRAMS\$STARTMENU_FOLDER\Uninstall.lnk" "$INSTDIR\Uninstall.exe"
					 
				!insertmacro MUI_STARTMENU_WRITE_END
				
	End:
				;Store start menu folder in the registry
				WriteRegStr HKCU "Software\Skulltag" "Startmenu" "$SMPROGRAMS\$STARTMENU_FOLDER\"
				
				;Create uninstaller
				WriteUninstaller "$INSTDIR\Uninstall.exe"
SectionEnd

;--------------------------------
; DESCRIPTIONS

  ;Language strings
  LangString DESC_stCore ${LANG_ENGLISH} "A test section."

  ;Assign language strings to sections
  !insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${stCore} $(DESC_stCore)
  !insertmacro MUI_FUNCTION_DESCRIPTION_END

;--------------------------------
; UNINSTALLER

Section "Uninstall"

	ReadRegStr $0 HKCU Software\Skulltag "Startmenu"
  Delete "$INSTDIR\*.*"
  Delete "$DESKTOP\Skulltag.lnk"
  RMDir "$INSTDIR"
  Delete "$0\*.*"
  Delete "$0\Community\*.*"
  RMDir  "$0\Community"
  RMDir  "$0"
  DeleteRegKey /ifempty HKCU "Software\Skulltag"

SectionEnd


;--------------------------------
; OTHER FUNCTIONS


# 
# Downloads a file from a list of mirrors
# (the fist mirror is selected at random)
#
# Usage:
# 	Push Mirror1
# 	Push [Mirror2]
# 	...
# 	Push [Mirror10]
#	Push NumMirrors		# 10 Max
#	Push FileName
#	Call DownloadFromRandomMirror
#	Pop Return
#
#	Returns the NSISdl result
Function DownloadFromRandomMirror
	Exch $R1 #File name
	Exch
	Exch $R0 #Number of Mirros
	Push $0
	Exch 3
	Pop $0	#Mirror 1
	IntCmpU "2" $R0 0 0 +4
		Push $1
		Exch 4
		Pop $1	#Mirror 2
	IntCmpU "3" $R0 0 0 +4
		Push $2
		Exch 5
		Pop $2	#Mirror 3
	IntCmpU "4" $R0 0 0 +4
		Push $3
		Exch 6
		Pop $3	#Mirror 4
	IntCmpU "5" $R0 0 0 +4
		Push $4
		Exch 7
		Pop $4	#Mirror 5
	IntCmpU "6" $R0 0 0 +4
		Push $5
		Exch 8
		Pop $5	#Mirror 6
	IntCmpU "7" $R0 0 0 +4
		Push $6
		Exch 9
		Pop $6	#Mirror 7
	IntCmpU "8" $R0 0 0 +4
		Push $7
		Exch 10
		Pop $7	#Mirror 8
	IntCmpU "9" $R0 0 0 +4
		Push $8
		Exch 11
		Pop $8	#Mirror 9
	IntCmpU "10" $R0 0 0 +4
		Push $9
		Exch 12
		Pop $9	#Mirror 10
	Push $R4
	Push $R2
	Push $R3
	Push $R5
	Push $R6
	
	# If you don't want a random mirror, replace this block with:
	# StrCpy $R3 "0"
	# -----------------------------------------------------------
	StrCmp $RandomSeed "" 0 +2
		StrCpy $RandomSeed $HWNDPARENT  #init RandomSeed
	
	Push $RandomSeed
	Push $R0
	Call LimitedRandomNumber
	Pop $R3
	Pop $RandomSeed
	# -----------------------------------------------------------
	
	StrCpy $R5 "0"
MirrorsStart:
	IntOp $R5 $R5 + "1"
	StrCmp $R3 "0" 0 +3
		StrCpy $R2 $0
		Goto MirrorsEnd
	StrCmp $R3 "1" 0 +3
		StrCpy $R2 $1
		Goto MirrorsEnd
	StrCmp $R3 "2" 0 +3
		StrCpy $R2 $2
		Goto MirrorsEnd
	StrCmp $R3 "3" 0 +3
		StrCpy $R2 $3
		Goto MirrorsEnd
	StrCmp $R3 "4" 0 +3
		StrCpy $R2 $4
		Goto MirrorsEnd
	StrCmp $R3 "5" 0 +3
		StrCpy $R2 $5
		Goto MirrorsEnd
	StrCmp $R3 "6" 0 +3
		StrCpy $R2 $6
		Goto MirrorsEnd
	StrCmp $R3 "7" 0 +3
		StrCpy $R2 $7
		Goto MirrorsEnd
	StrCmp $R3 "8" 0 +3
		StrCpy $R2 $8
		Goto MirrorsEnd
	StrCmp $R3 "9" 0 +3
		StrCpy $R2 $9
		Goto MirrorsEnd
	StrCmp $R3 "10" 0 +3
		StrCpy $R2 $10
		Goto MirrorsEnd
 
MirrorsEnd:
	IntOp $R6 $R3 + "1"
	DetailPrint "Downloading from mirror $R6: $R2"
	
	NSISdl::download "$R2" "$R1"
	Pop $R4
	StrCmp $R4 "success" Success
	StrCmp $R4 "cancel" DownloadCanceled
	IntCmp $R5 $R0 NoSuccess
	DetailPrint "Download failed (error $R4), trying with other mirror"
	IntOp $R3 $R3 + "1"
	IntCmp $R3 $R0 0 MirrorsStart
	StrCpy $R3 "0"
	Goto MirrorsStart
 
DownloadCanceled:
	DetailPrint "Download Canceled: $R2"
	Goto End
NoSuccess:		
	DetailPrint "Download Failed: $R1"
	Goto End
Success:
	DetailPrint "Download completed."
End:
	Pop $R6
	Pop $R5
	Pop $R3
	Pop $R2
	Push $R4
	Exch
	Pop $R4
	Exch 2
	Pop $R1
	Exch 2
	Pop $0
	Exch
	
	IntCmpU "2" $R0 0 0 +4
		Exch 2	
		Pop $1
		Exch
	IntCmpU "3" $R0 0 0 +4
		Exch 2	
		Pop $2
		Exch
	IntCmpU "4" $R0 0 0 +4
		Exch 2	
		Pop $3
		Exch
	IntCmpU "5" $R0 0 0 +4
		Exch 2	
		Pop $4
		Exch
	IntCmpU "6" $R0 0 0 +4
		Exch 2	
		Pop $5
		Exch
	IntCmpU "7" $R0 0 0 +4
		Exch 2	
		Pop $6
		Exch
	IntCmpU "8" $R0 0 0 +4
		Exch 2	
		Pop $7
		Exch
	IntCmpU "9" $R0 0 0 +4
		Exch 2	
		Pop $8
		Exch
	IntCmpU "10" $R0 0 0 +4
		Exch 2	
		Pop $9
		Exch
	Pop $R0
FunctionEnd
 
###############################################################
#
# NOTE: If you don't want a random mirror, remove this Function
#
# Returns a random number
#
# Usage:
# 	Push Seed (or previously generated number)
#	Call RandomNumber
#	Pop Generated Random Number
Function RandomNumber
	Exch $R0
	
	IntOp $R0 $R0 * "13"
	IntOp $R0 $R0 + "3"
	IntOp $R0 $R0 % "1048576" # Values goes from 0 to 1048576 (2^20)
 
	Exch $R0
FunctionEnd
 
####################################################
#
# NOTE: If you don't want a random mirror, remove this Function
#
# Returns a random number between 0 and Max-1
#
# Usage:
# 	Push Seed (or previously generated number)
#	Push MaxValue
#	Call RandomNumber
#	Pop Generated Random Number
#	Pop NewSeed
Function LimitedRandomNumber
	Exch $R0
	Exch
	Exch $R1
	Push $R2
	Push $R3
 
	StrLen $R2 $R0
	Push $R1
RandLoop:
	Call RandomNumber
	Pop $R1	#Random Number
	IntCmp $R1 $R0 0 NewRnd
	StrLen $R3 $R1	
	IntOp $R3 $R3 - $R2
	IntOp $R3 $R3 / "2"
	StrCpy $R3 $R1 $R2 $R3
	IntCmp $R3 $R0 0 RndEnd
NewRnd:
	Push $R1
	Goto RandLoop
RndEnd:
	StrCpy $R0 $R3
	IntOp $R0 $R0 + "0" #removes initial 0's
	Pop $R3
	Pop $R2
	Exch $R1
	Exch
	Exch $R0
FunctionEnd