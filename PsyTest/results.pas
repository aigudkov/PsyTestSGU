unit results;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Grids, Fpjson, jsonparser, FileUtil;

type

  { TFormResult }

  TFormResult = class(TForm)
    BackButton: TButton;
    DeleteButton: TButton;
    StringGrid1: TStringGrid;
    procedure BackButtonClick(Sender: TObject);
    procedure DeleteButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  FormResult: TFormResult;
  gPath : String = 'PsyTest/results/'; //Путь к папке..

implementation
uses admin;

{$R *.lfm}

{ TFormResult }

procedure ParseJson(pathToFile: string);
var
  JRoot:TJSONData;
begin
  JRoot:=GetJSON(ReadFileToString(pathToFile));
  try
    FormResult.StringGrid1.RowCount:=FormResult.StringGrid1.RowCount+1;
    FormResult.StringGrid1.Cells[0,FormResult.StringGrid1.RowCount-1]:=JRoot.FindPath('group').AsString;
    FormResult.StringGrid1.Cells[1,FormResult.StringGrid1.RowCount-1]:=JRoot.FindPath('testname').AsString;
    FormResult.StringGrid1.Cells[2,FormResult.StringGrid1.RowCount-1]:=JRoot.FindPath('surname').AsString + ' ' +
                                                                       JRoot.FindPath('firstname').AsString + ' ' +
                                                                       JRoot.FindPath('lastname').AsString;
    FormResult.StringGrid1.Cells[3,FormResult.StringGrid1.RowCount-1]:=JRoot.FindPath('result').AsString;
  finally
    FreeAndNil(JRoot);
  end;
end;

procedure CheckResultsUsers;
var
  Sr : TSearchRec;
  Attr : Integer;
Begin
  Attr := faAnyFile - faDirectory;    //Все файлы, исключая папки.
  try
    if FindFirst(gPath + '*', Attr, Sr) = 0 then
      repeat
        ParseJson(gPath + Sr.Name)
      until FindNext(Sr) <> 0;
  finally
    FindClose(Sr);
  end;
end;

procedure TFormResult.FormCreate(Sender: TObject);
begin
  StringGrid1.ColWidths[0]:=58;
  StringGrid1.ColWidths[1]:=490;
  StringGrid1.ColWidths[2]:=292;
  StringGrid1.ColWidths[3]:=150;
  StringGrid1.Cells[0,0]:='Группа';
  StringGrid1.Cells[1,0]:='Название теста';
  StringGrid1.Cells[2,0]:='ФИО';
  StringGrid1.Cells[3,0]:='Результат';
end;

procedure TFormResult.DeleteButtonClick(Sender: TObject);
begin
  case QuestionDlg('Подстверждение операции',
                   'Вы действительно хотите удалить результат теста ' + StringGrid1.Cells[1,StringGrid1.Row] + ' пользователя ' + StringGrid1.Cells[2,StringGrid1.Row] + '?',
                   mtConfirmation,
                   [mrNo, '&Нет','IsDefault',
                   mrYes,'&Да'],0)
  of
   mrYes :
     if (StringGrid1.Row >= 1) then
      begin
        DeleteFile(gPath + StringGrid1.Cells[0,StringGrid1.Row] + ' ' +
                           StringGrid1.Cells[1,StringGrid1.Row] + ' ' +
                           StringGrid1.Cells[2,StringGrid1.Row] + '.json');
       StringGrid1.DeleteRow(StringGrid1.Row);
      end;
  end;
end;

procedure TFormResult.BackButtonClick(Sender: TObject);
begin
  close;
end;

procedure TFormResult.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  StringGrid1.RowCount:=1;
  admin.AdminWindow.Visible:=true;
end;

procedure TFormResult.FormShow(Sender: TObject);
begin
  CheckResultsUsers;
end;

end.

