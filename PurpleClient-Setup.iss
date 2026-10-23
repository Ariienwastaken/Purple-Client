; Inno Setup Script fuer den Purple Client (Deutsch + English)
; Installiert den Launcher und auf Wunsch Java 21 und Java 26 (falls noch nicht vorhanden).

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
ShowLanguageDialog=yes
UsePreviousLanguage=no

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "german";  MessagesFile: "compiler:Languages\German.isl"

[CustomMessages]
english.JavaGroup=Java
german.JavaGroup=Java
english.JavaTask=Also install Java 21 and Java 26 (only if not already installed)
german.JavaTask=Java 21 und Java 26 mitinstallieren (nur falls noch nicht vorhanden)
english.JavaDownloading=Downloading Java %1 ...
german.JavaDownloading=Java %1 wird heruntergeladen ...
english.JavaFailed=Java %1 could not be installed. The launcher will download it by itself when needed.
german.JavaFailed=Java %1 konnte nicht installiert werden. Der Launcher lädt es bei Bedarf selbst nach.

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "installjava"; Description: "{cm:JavaTask}"; GroupDescription: "{cm:JavaGroup}"

[Files]
Source: "{#SourceDir}\*"; DestDir: "{app}"; Excludes: "START-DEBUG.bat"; Flags: recursesubdirs createallsubdirs ignoreversion
; Bei English wird die englische Programmdatei darueber installiert (mc-launcher-en.jar liegt neben dieser .iss-Datei)
Source: "mc-launcher-en.jar"; DestDir: "{app}\app"; DestName: "mc-launcher-1.0.5.jar"; Flags: ignoreversion; Check: IsEnglish

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExe}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExe}"; Description: "{cm:LaunchProgram,{#MyAppName}}"; Flags: nowait postinstall skipifsilent

[Code]
function IsEnglish: Boolean;
begin
  Result := ActiveLanguage = 'english';
end;

var
  DownloadPage: TDownloadWizardPage;

function OnDownloadProgress(const Url, FileName: String; const Progress, ProgressMax: Int64): Boolean;
begin
  Result := True;
end;

procedure InitializeWizard;
begin
  DownloadPage := CreateDownloadPage(SetupMessage(msgWizardPreparing), SetupMessage(msgPreparingDesc), @OnDownloadProgress);
end;

function FolderMatches(const Pattern: String): Boolean;
var
  FindRec: TFindRec;
begin
  Result := FindFirst(Pattern, FindRec);
  if Result then
    FindClose(FindRec);
end;

function JavaTarget(Major: Integer): String;
begin
  Result := ExpandConstant('{%USERPROFILE}') + '\.mylauncher\java\jdk-' + IntToStr(Major);
end;

function JavaAlreadyThere(Major: Integer): Boolean;
var
  M: String;
begin
  M := IntToStr(Major);
  Result := FileExists(JavaTarget(Major) + '\bin\java.exe')
    or FolderMatches(ExpandConstant('{commonpf64}') + '\Eclipse Adoptium\jdk-' + M + '*')
    or FolderMatches(ExpandConstant('{commonpf64}') + '\Eclipse Adoptium\jre-' + M + '*')
    or FolderMatches(ExpandConstant('{commonpf64}') + '\Java\jdk-' + M + '*')
    or FolderMatches(ExpandConstant('{commonpf64}') + '\Java\jre-' + M + '*');
end;

procedure InstallJava(Major: Integer);
var
  M, Target, Zip: String;
  ResultCode: Integer;
begin
  if JavaAlreadyThere(Major) then
    Exit;
  M := IntToStr(Major);
  Target := JavaTarget(Major);
  Zip := ExpandConstant('{tmp}\java' + M + '.zip');
  DownloadPage.Clear;
  DownloadPage.Add('https://api.adoptium.net/v3/binary/latest/' + M + '/ga/windows/x64/jre/hotspot/normal/eclipse', 'java' + M + '.zip', '');
  DownloadPage.SetText(FmtMessage(CustomMessage('JavaDownloading'), [M]), '');
  DownloadPage.Show;
  try
    try
      DownloadPage.Download;
      ForceDirectories(Target);
      if not Exec(ExpandConstant('{sys}\tar.exe'), '-xf "' + Zip + '" -C "' + Target + '" --strip-components=1', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) or (ResultCode <> 0) then
        RaiseException('Extraction failed');
      if not FileExists(Target + '\bin\java.exe') then
        RaiseException('java.exe missing');
    except
      DelTree(Target, True, True, True);
      MsgBox(FmtMessage(CustomMessage('JavaFailed'), [M]), mbInformation, MB_OK);
    end;
  finally
    DownloadPage.Hide;
  end;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;
  if (CurPageID = wpReady) and WizardIsTaskSelected('installjava') then
  begin
    InstallJava(21);
    InstallJava(26);
  end;
end;
