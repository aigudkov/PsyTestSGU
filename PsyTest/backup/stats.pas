unit stats;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, StdCtrls,
  Fpjson, jsonparser, FileUtil;

type
  TResult = class
    Name: string;
    Result: string;
    User: string;
  end;

type

  { TStatsTestWindow }

  TStatsTestWindow = class(TForm)
    BackButton: TButton;
    TestListDescription: TLabel;
    UserName: TLabel;
    UserSelectorLabel: TLabel;
    UserText: TLabel;
    TestName: TLabel;
    TestText: TLabel;
    ResultDesc: TLabel;
    ResultText: TLabel;
    TestList: TListBox;
    UserSelector: TComboBox;
    procedure BackButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure StudentSelectorOnSelect(Sender: TObject);
    procedure TestListSelectionChange(Sender: TObject; User: boolean);
  private

  public

  end;

var
  StatsTestWindow: TStatsTestWindow;

implementation
uses results;

{$R *.lfm}

{ TStatsTestWindow }

procedure TStatsTestWindow.StudentSelectorOnSelect(Sender: TObject);
var
  JResult:TJSONData;
  resultFiles: TStringList;
  Result: TResult;
  resultUserName: string;
  i:integer;
begin
     TestList.Items.Clear;
     TestText.Visible:=false;
     TestName.Visible:=false;
     ResultText.Visible:=false;
     ResultDesc.Visible:=false;
     UserText.Visible:=false;
     UserName.Visible:=false;

     resultFiles := FindAllFiles('PsyTest/results/', '*.json', true);
     for i:=0 to (resultFiles.Count-1)do begin
         JResult:=GetJSON(ReadFileToString(resultFiles[i]));
         resultUserName := JResult.FindPath('group').AsString+' '+JResult.FindPath('surname').AsString+' '+JResult.FindPath('firstname').AsString+' '+JResult.FindPath('lastname').AsString;
         if (UserSelector.Text = resultUserName) then begin
             Result := TResult.Create;
             Result.Name := JResult.FindPath('testname').AsString;
             Result.Result := JResult.FindPath('result').AsString;
             Result.User := resultUserName;
             TestList.Items.AddObject(Result.Name,Result);
         end;
     end;
end;

procedure TStatsTestWindow.BackButtonClick(Sender: TObject);
begin
     UserSelector.Clear;
     TestList.Items.Clear;
     TestText.Visible:=false;
     TestName.Visible:=false;
     ResultText.Visible:=false;
     ResultDesc.Visible:=false;
     UserText.Visible:=false;
     UserName.Visible:=false;
     FormResult.Visible:=true;
     StatsTestWindow.close;
end;

procedure TStatsTestWindow.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
     UserSelector.Clear;
     TestList.Items.Clear;
     TestText.Visible:=false;
     TestName.Visible:=false;
     ResultText.Visible:=false;
     ResultDesc.Visible:=false;
     UserText.Visible:=false;
     UserName.Visible:=false;
     FormResult.Visible:=true;
     StatsTestWindow.close;
end;

procedure TStatsTestWindow.TestListSelectionChange(Sender: TObject;
  User: boolean);
var
  Result: TResult;
begin
     Result:= TestList.Items.Objects[TestList.ItemIndex] as TResult;
     TestName.Caption:= Result.Name;
     ResultDesc.Caption:= Result.Result;
     UserName.Caption:= Result.User;
     TestText.Visible:=true;
     TestName.Visible:=true;
     ResultText.Visible:=true;
     ResultDesc.Visible:=true;
     UserText.Visible:=true;
     UserName.Visible:=true;
end;

end.

