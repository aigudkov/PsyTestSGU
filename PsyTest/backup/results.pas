unit results;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Grids, Fpjson, jsonparser, FileUtil;

type

  { TFormResult }

  TFormResult = class(TForm)
    BackButton: TButton;
    StatsTestButton: TButton;
    ExportButton: TButton;
    DeleteButton: TButton;
    SaveDialog1: TSaveDialog;
    StringGrid1: TStringGrid;
    procedure BackButtonClick(Sender: TObject);
    procedure DeleteButtonClick(Sender: TObject);
    procedure ExportButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure StatsTestButtonClick(Sender: TObject);
  private

  public

  end;

var
  FormResult: TFormResult;
  gPath : String = 'PsyTest/results/'; //Путь к папке..

implementation
uses admin,stats;

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
  StringGrid1.ColWidths[0]:=53;
  StringGrid1.ColWidths[1]:=505;
  StringGrid1.ColWidths[2]:=292;
  StringGrid1.ColWidths[3]:=140;
  StringGrid1.Cells[0,0]:='Группа';
  StringGrid1.Cells[1,0]:='Название теста';
  StringGrid1.Cells[2,0]:='ФИО';
  StringGrid1.Cells[3,0]:='Результат';
end;

procedure TFormResult.DeleteButtonClick(Sender: TObject);
begin
  case QuestionDlg('Подстверждение операции',
                   'Вы действительно хотите удалить результат пользователя ' + StringGrid1.Cells[2,StringGrid1.Row] + '?',
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

procedure TFormResult.ExportButtonClick(Sender: TObject);
var
  exportData: TStringList;
  tempString: string;
  i,j:        integer;
begin
  exportData := TStringList.Create;
  for i:= 0 to StringGrid1.RowCount-1 do begin
    tempString:='';
    for j:= 0 to StringGrid1.ColCount-1 do begin
      tempString:= tempString + '"' + StringGrid1.Cells[j,i] + '";'
    end;
    exportData.Add(tempString);
  end;

  SaveDialog1.FileName:='PsyTestExport.csv';
  if SaveDialog1.Execute then
  begin
       exportData.WriteBOM:=true;
       exportData.SaveToFile(SaveDialog1.FileName, TEncoding.UTF8);
       AdminWindow.ListBox1.Clear;
       AdminWindow.FormCreate(nil);
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

procedure TFormResult.StatsTestButtonClick(Sender: TObject);
var
  JResult:TJSONData;
  studentList: TStringList;
  resultFiles: TStringList;
  i,j:integer;
begin
     try
        stats.StatsTestWindow.Show;
        FormResult.Visible:=false;
        studentList := TStringList.create;
        studentList.Sorted:= true;
        studentList.Duplicates:= dupIgnore;
        resultFiles := FindAllFiles('PsyTest/results/', '*.json', true);
        for i:=0 to (resultFiles.Count-1)do
          begin
            JResult:=GetJSON(ReadFileToString(resultFiles[i]));
            studentList.add(JResult.FindPath('group').AsString+' '+JResult.FindPath('surname').AsString+' '+JResult.FindPath('firstname').AsString+' '+JResult.FindPath('lastname').AsString);
          end;
        for j:=0 to (studentList.Count-1)do
          begin
            stats.StatsTestWindow.UserSelector.Items.Add(studentList[j]);
          end;
     finally
        resultFiles.Free;
        FreeAndNil(JResult);
     end;
end;

end.

