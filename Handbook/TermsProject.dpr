program TermsProject;

uses
  Vcl.Forms,
  uMainWindow in 'uMainWindow.pas' {fMain},
  Procedures in 'Procedures.pas',
  SharedData in 'SharedData.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfMain, fMain);
  Application.Run;
end.
