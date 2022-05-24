unit user;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, LazFileUtils,
  admin, Fpjson, jsonparser, FileUtil;

type

  { TUserWindow }

  TUserWindow = class(TForm)
    ChoiseTestLabel: TLabel;
    StartButton: TButton;
    ListBox1: TListBox;
    BackButton: TButton;
    procedure BackButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure StartButtonClick(Sender: TObject);
  private

  public

  end;

var
  UserWindow: TUserWindow;
  gPath : String = 'PsyTest/test/'; //Путь к папке..
  currentTest: admin.Test;

implementation
  uses main, test;

{$R *.lfm}

{ TUserWindow }

procedure TUserWindow.FormCreate(Sender: TObject);

begin

end;

procedure TUserWindow.FormShow(Sender: TObject);
var
  Sr : TSearchRec;
  Attr : Integer;
begin
  UserWindow.ListBox1.Clear;
  UserWindow.Caption:='Окно пользователя - ' + main.currentStudent.familyName + ' ' + main.currentStudent.firstName + ' ' + main.currentStudent.lastName;
  gPath := IncludeTrailingPathDelimiter(gPath); //Если конечный слеш отсутствует, то добавляем его.
  Attr := faAnyFile - faDirectory;    //Все файлы, исключая папки.
  try
    if FindFirst(gPath + '*', Attr, Sr) = 0 then
      repeat
        ListBox1.Items.Add(ExtractFileNameWithoutExt(Sr.Name));
      until FindNext(Sr) <> 0;
  finally
    FindClose(Sr);
  end;
end;

procedure TUserWindow.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  main.MainForm.Visible:=true;
  FreeAndNil(main.currentStudent);
end;

procedure TUserWindow.BackButtonClick(Sender: TObject);
begin
  close;
end;

procedure TUserWindow.StartButtonClick(Sender: TObject);
var
  JRoot:TJSONData;
  jArrayQuestions:TJSONArray;
  jArrayAnswers:TJSONArray;
  i,j:integer;
begin
  if (ListBox1.SelCount > 0) then
  Begin
     JRoot:=GetJSON(ReadFileToString('PsyTest/test/'+ListBox1.Items[ListBox1.ItemIndex]+'.json'));
     try
       UserWindow.Visible:=false;
       currentTest:=admin.Test.Create;
       currentTest.name:=JRoot.FindPath('test').AsString;
       jArrayQuestions:=TJSONArray.Create;
       jArrayQuestions:=TJSONArray(JRoot.FindPath('questions'));
       SetLength(currentTest.questions, jArrayQuestions.Count);
       for i:=0 to (jArrayQuestions.Count-1) do
         begin
           currentTest.questions[i]:=admin.QuestionClass.Create;
           currentTest.questions[i].question:=jArrayQuestions.Items[i].FindPath('title').AsString;
           jArrayAnswers:=TJSONArray.Create;
           jArrayAnswers:=TJSONArray(jArrayQuestions.Items[i].FindPath('answers'));
           SetLength(currentTest.questions[i].answers, jArrayAnswers.Count);
           for j:=0 to (jArrayAnswers.Count-1) do
             begin
               currentTest.questions[i].answers[j]:=admin.AnswerClass.Create;
               currentTest.questions[i].answers[j].answer:=jArrayAnswers.Items[j].FindPath('name').AsString;
               currentTest.questions[i].answers[j].correct:=jArrayAnswers.Items[j].FindPath('correctAnswer').AsBoolean;
             end;
         end;
         test.TestWindow.ShowModal;
     finally
       FreeAndNil(JRoot);
     end;
  end;
end;
end.

