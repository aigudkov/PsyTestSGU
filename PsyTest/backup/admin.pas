unit admin;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Menus, Fpjson, jsonparser, FileUtil;

type

  { TAdminWindow }

  TAdminWindow = class(TForm)
    CreateTestButton: TButton;
    DeleteTestButton: TButton;
    EditTestButton: TButton;
    BackButton: TButton;
    ItemDelete: TMenuItem;
    ItemEditor: TMenuItem;
    ListBox1: TListBox;
    //Menu: TMainMenu;
    ItemFile: TMenuItem;
    ItemBack: TMenuItem;
    ItemEdit: TMenuItem;
    ItemAdd: TMenuItem;
    ItemResults: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    ItemChangePassword: TMenuItem;
    MenuItems: TMainMenu;
    Panel1: TPanel;
    procedure BackButtonClick(Sender: TObject);
    procedure CreateTestButtonClick(Sender: TObject);
    procedure DeleteTestButtonClick(Sender: TObject);
    procedure EditTestButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure ItemBackClick(Sender: TObject);
    procedure ItemChangePasswordClick(Sender: TObject);
    procedure ItemResultsClick(Sender: TObject);
  private

  public

  end;

Type AnswerClass=class
  answer: string;
  correct: Boolean;
end;

Type QuestionClass=class
  question: string;
  answers: array of AnswerClass;
end;

Type Test=class
  name: string;
  questions: array of QuestionClass;
end;

var
  AdminWindow: TAdminWindow;
  gPath : String = 'PsyTest/test/'; //Путь к папке..
  currentTest: Test;

implementation
uses editor, main, results, changepass;
{$R *.lfm}

{ TAdminWindow }
procedure TAdminWindow.CreateTestButtonClick(Sender: TObject);
begin
  editor.EditorWindow.Show;
  AdminWindow.Visible:=false;
  currentTest:=Test.Create;
  currentTest.name:='Введите название теста';
  editor.EditorWindow.TestName.Text:=currentTest.name;
end;

procedure TAdminWindow.BackButtonClick(Sender: TObject);
begin
  close;
end;

procedure TAdminWindow.DeleteTestButtonClick(Sender: TObject);
begin
   if (ListBox1.SelCount > 0) then
     Begin
        case QuestionDlg('Подстверждение операции',
                 'Вы действительно хотите удалить тест ' + ListBox1.Items[ListBox1.ItemIndex] + '?',
                 mtConfirmation,
                 [mrNo, '&Нет','IsDefault',
                 mrYes,'&Да'],0)
        of
         mrYes :
            begin
              DeleteFile(gPath + ListBox1.Items[ListBox1.ItemIndex]);
              ListBox1.Items.Delete(ListBox1.ItemIndex);
            end;
        end;
     end;
end;

procedure TAdminWindow.EditTestButtonClick(Sender: TObject);
var
  JRoot:TJSONData;
  jArrayQuestions:TJSONArray;
  jArrayAnswers:TJSONArray;
  i,j:integer;
begin
   if (ListBox1.SelCount > 0) then
     Begin
         JRoot:=GetJSON(ReadFileToString('PsyTest/test/'+ListBox1.Items[ListBox1.ItemIndex]));
         try
           editor.EditorWindow.Show;
           AdminWindow.Visible:=false;
           currentTest:=Test.Create;

           currentTest.name:=JRoot.FindPath('test').AsString;
           editor.EditorWindow.TestName.Text:=currentTest.name;
           jArrayQuestions:=TJSONArray.Create;
           jArrayQuestions:=TJSONArray(JRoot.FindPath('questions'));
           for i:=0 to (jArrayQuestions.Count-1) do
             begin
               editor.EditorWindow.CreateQuestionClick(nil);
               currentTest.questions[i].question:=jArrayQuestions.Items[i].FindPath('title').AsString;
               editor.EditorWindow.ListBox1.Items[i]:=currentTest.questions[i].question;
               jArrayAnswers:=TJSONArray.Create;
               jArrayAnswers:=TJSONArray(jArrayQuestions.Items[i].FindPath('answers'));
               for j:=0 to (jArrayAnswers.Count-1) do
                 begin
                   if j > 1 then
                      begin
                          SetLength(currentTest.questions[i].answers, j + 1);
                          currentTest.questions[i].answers[j]:=AnswerClass.Create;
                      end;
                   currentTest.questions[i].answers[j].answer:=jArrayAnswers.Items[j].FindPath('name').AsString;
                   currentTest.questions[i].answers[j].correct:=jArrayAnswers.Items[j].FindPath('correctAnswer').AsBoolean;
                   editor.EditorWindow.ListBox1Click(nil);
                 end;
             end;
         finally
           FreeAndNil(JRoot);
         end;
     end;
end;

procedure TAdminWindow.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
begin
  main.MainForm.Visible:=true;
  main.MainForm.ButtonBackAdminClick(nil);
end;

procedure TAdminWindow.FormCreate(Sender: TObject);
var
  Sr : TSearchRec;
  Attr : Integer;
begin
  gPath := IncludeTrailingPathDelimiter(gPath); //Если конечный слеш отсутствует, то добавляем его.
  Attr := faAnyFile - faDirectory;    //Все файлы, исключая папки.
  try
    if FindFirst(gPath + '*', Attr, Sr) = 0 then
      repeat
        ListBox1.Items.Add(Sr.Name);
      until FindNext(Sr) <> 0;
  finally
    FindClose(Sr);
  end;
end;

procedure TAdminWindow.ItemBackClick(Sender: TObject);
begin

end;

procedure TAdminWindow.ItemChangePasswordClick(Sender: TObject);
begin
  changepass.FormChangePassword.ShowModal;
end;

procedure TAdminWindow.ItemResultsClick(Sender: TObject);
begin
  AdminWindow.Visible:=false;
  results.FormResult.ShowModal;
end;

end.

