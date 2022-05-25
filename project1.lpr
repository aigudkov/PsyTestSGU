program project1;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, editor, admin, user, test, main, results, changepass, stats
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Title:='PsyTestSGU';
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TAdminWindow, AdminWindow);
  Application.CreateForm(TEditorWindow, EditorWindow);
  Application.CreateForm(TFormResult, FormResult);
  Application.CreateForm(TUserWindow, UserWindow);
  Application.CreateForm(TTestWindow, TestWindow);
  Application.CreateForm(TFormChangePassword, FormChangePassword);
  Application.CreateForm(TStatsTestWindow, StatsTestWindow);
  Application.Run;
end.

