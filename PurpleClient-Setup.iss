; Inno Setup Script fuer den Purple Client (Deutsch + English)
; Anleitung: Den entpackten Launcher-Ordner neben diese Datei legen und
; unten bei SourceDir den Ordnernamen eintragen. Dann in Inno Setup mit F9 kompilieren.

#define MyAppName    "Purple Client"
#define MyAppVersion "1.0.5"
#define MyAppExe     "Purple Client.exe"
#define SourceDir    "purple_client"

[Setup]
AppId={{B7E2D1A4-5C3F-4E8B-9A61-2F4D8C7E1B35}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppName}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
; Installation ohne Administrator-Rechte (nach %LOCALAPPDATA%\Programs), weniger Warnungen
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
OutputDir=output
OutputBaseFilename=PurpleClient-Setup-{#MyAppVersion}
UninstallDisplayIcon={app}\{#MyAppExe}
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
; Sprachauswahl beim Start des Installers immer anzeigen
ShowLanguageDialog=yes
UsePreviousLanguage=no

[Languages]
Name: "german";  MessagesFile: "compiler:Languages\German.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#SourceDir}\*"; DestDir: "{app}"; Excludes: "START-DEBUG.bat"; Flags: recursesubdirs createallsubdirs ignoreversion

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExe}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExe}"; Description: "{cm:LaunchProgram,{#MyAppName}}"; Flags: nowait postinstall skipifsilent

; Hinweis: Accounts, Profile und Spielordner liegen unter %USERPROFILE%\.mylauncher
; und bleiben beim Deinstallieren absichtlich erhalten.
