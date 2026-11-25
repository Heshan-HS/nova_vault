#define MyAppName "NovaVault"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "NovaGen Software Solutions"
#define MyAppURL "https://novagen.local"
#define MyAppExeName "novavault_flutter.exe"
#define SourceDir "D:\passwrdmanger\novavault_flutter\build\windows\x64\runner\Release"
#define IconFile "D:\passwrdmanger\novavault_flutter\windows\runner\resources\app_icon.ico"

[Setup]
AppId={{5D7E0B08-7A91-4876-BE05-BF3C1B7892CA}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
UninstallDisplayIcon={app}\{#MyAppExeName}
SetupIconFile={#IconFile}

OutputDir=D:\passwrdmanger\dist
OutputBaseFilename=NovaVault-v1.0.0-Setup
SolidCompression=yes
Compression=lzma2/ultra64
WizardStyle=modern

ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog

DisableProgramGroupPage=yes
DefaultGroupName={#MyAppName}
CloseApplications=yes
RestartApplications=no

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"

[Files]
Source: "{#SourceDir}\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceDir}\flutter_windows.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceDir}\dartjni.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceDir}\url_launcher_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion

Source: "{#SourceDir}\msvcp140.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceDir}\vcruntime140.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceDir}\vcruntime140_1.dll"; DestDir: "{app}"; Flags: ignoreversion

Source: "{#SourceDir}\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent
