unit editor;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Fpjson, jsonparser, FileUtil;

type

  { TEditorWindow }

  TEditorWindow = class(TForm)
    AddAnswerButton: TButton;
    Button1: TButton;
    DeleteAnswerButton: TButton;
    CreateQuestion: TButton;
    DeleteQuestion: TButton;
    CompletedButton: TButton;
    SaveButton: TButton;
    QuestionName: TEdit;
    SaveDialog1: TSaveDialog;
    TestName: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    AnswerVariantLabel: TLabel;
    CorrectVariantLabel: TLabel;
    ListBox1: TListBox;
    Panel1: TPanel;
    Panel2: TPanel;
    procedure AddAnswerButtonClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure CompletedButtonClick(Sender: TObject);
    procedure CreateQuestionClick(Sender: TObject);
    procedure DeleteAnswerButtonClick(Sender: TObject);
    procedure DeleteQuestionClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure SaveButtonClick(Sender: TObject);
  private

  public

  end;

var
  EditorWindow: TEditorWindow;
  currentAnswerCount: integer = 2;
  currentQuestionsCount: integer = 0;
  edit: array of TEdit;
  RB: array of TRadioButton;

implementation
uses admin;
{$R *.lfm}

{ TEditorWindow }

procedure CreateEdit (position: integer);
var
  left: integer=8;
  top: integer=104;
  width: integer=648;
  height: integer=27;
begin
  edit[position]:=TEdit.Create(EditorWindow.Panel1);
  edit[position].Parent:=EditorWindow.Panel1;
  edit[position].Left:=left;
  edit[position].Top:=top + 32 * (position);
  edit[position].Width:=width;
  edit[position].Height:=height;
  edit[position].Caption:='';
  edit[position].Font.Name:='Times New Roman';
end;

procedure CreateRB (position: integer);
var
  left: integer=665;
  top: integer=108;
  width: integer=23;
  height: integer=23;
begin
  RB[position]:=TRadioButton.Create(EditorWindow.Panel1);
  RB[position].Parent:=EditorWindow.Panel1;
  RB[position].Left:=left;
  RB[position].Top:=top + 32 * (position);
  RB[position].Width:=width;
  RB[position].Height:=height;
  RB[position].Caption:='';
end;

procedure ReverseVisible(vision : boolean);
begin
    EditorWindow.AnswerVariantLabel.Visible:=vision;
    EditorWindow.CorrectVariantLabel.Visible:=vision;
    EditorWindow.QuestionName.ReadOnly:= not vision;
    edit[0].Visible:=vision;
    edit[1].Visible:=vision;
    edit[0].ReadOnly:=not vision;
    edit[1].ReadOnly:=not vision;
    RB[0].Visible:=vision;
    RB[1].Visible:=vision;
    EditorWindow.AddAnswerButton.Visible:=vision;
    EditorWindow.DeleteAnswerButton.Visible:=vision;
    EditorWindow.SaveButton.Visible:=vision;
end;

procedure CorrectingAnswerCount(correctLength:integer);
var
  j: integer;
begin
  ReverseVisible(true);
  if (currentAnswerCount > correctLength) then
       for j:=correctLength to currentAnswerCount do
           Begin
                EditorWindow.DeleteAnswerButtonClick(nil);
           end;
  If (currentAnswerCount < correctLength) then
       for j:=currentAnswerCount to correctLength-1  do
           Begin
                EditorWindow.AddAnswerButtonClick(nil);
           end;
end;

procedure TEditorWindow.AddAnswerButtonClick(Sender: TObject);
begin
  if (currentAnswerCount < 8) then
     begin
        currentAnswerCount:=currentAnswerCount + 1;
        SetLength(edit,currentAnswerCount);
        SetLength(RB,currentAnswerCount);
        CreateEdit(currentAnswerCount-1);
        CreateRB(currentAnswerCount-1);
     end;
end;

procedure TEditorWindow.Button1Click(Sender: TObject);
begin
  EditorWindow.Close;
end;

procedure TEditorWindow.CompletedButtonClick(Sender: TObject);
var
  jDocument: TJSONObject;
  jArrayQuestions:TJSONArray;
  jArrayAnswers:TJSONArray;
  strList: TStringList;
  i, j: integer;
begin
  admin.currentTest.name:=EditorWindow.TestName.Text;
  jDocument:= TJSONObject.Create;
  jArrayQuestions:=TJSONArray.Create;
  strList := TStringList.Create;
  try
    for i:=0 to Length(admin.currentTest.questions)-1 do
        begin
             jArrayAnswers:=TJSONArray.Create;
               for j:=0 to Length(admin.currentTest.questions[i].answers)-1 do
                   begin
                        jArrayAnswers.Add(TJSONObject.Create(['name',admin.currentTest.questions[i].answers[j].answer,
                                                              'correctAnswer',admin.currentTest.questions[i].answers[j].correct]));
                   end;
             jArrayQuestions.Add(TJSONObject.Create(['title',admin.currentTest.questions[i].question,
                                                     'answers',jArrayAnswers]));
        end;
    jDocument.Add('test',admin.currentTest.name);
    jDocument.Add('questions',jArrayQuestions);
    strList.Text:=jDocument.FormatJSON();

    SaveDialog1.FileName:=admin.currentTest.name + '.json';
    if SaveDialog1.Execute then
       begin
          strList.SaveToFile(SaveDialog1.FileName);
          AdminWindow.ListBox1.Clear;
          AdminWindow.FormCreate(nil);
       end;
  finally
    EditorWindow.Close;
    FreeAndNil(strList);
    FreeAndNil(jDocument);
  end;
end;

procedure TEditorWindow.CreateQuestionClick(Sender: TObject);
var
  i: integer;
begin
  //увеличение счетчика числа вопросов
  currentQuestionsCount := currentQuestionsCount + 1;
  //выделение памяти под массив вопросов
  setLength(currentTest.questions,currentQuestionsCount);
  //инициализация вопроса и добавление в массив
  currentTest.questions[currentQuestionsCount-1]:= QuestionClass.Create;
  currentTest.questions[currentQuestionsCount-1].question:='Новый вопрос';
  QuestionName.Text:='Новый вопрос';
  //инициализируем default список ответов для вопросов
  SetLength(currentTest.questions[currentQuestionsCount-1].answers, 2);
  for i:=0 to 1 do
      Begin
         currentTest.questions[currentQuestionsCount-1].answers[i]:=AnswerClass.Create;
         currentTest.questions[currentQuestionsCount-1].answers[i].answer:='';
      end;
  currentTest.questions[currentQuestionsCount-1].answers[0].correct:=true;
  currentTest.questions[currentQuestionsCount-1].answers[1].correct:=false;

  ListBox1.Items.Add(currentTest.questions[currentQuestionsCount-1].question);
  ListBox1.ItemIndex:=currentQuestionsCount-1;
  EditorWindow.ListBox1Click(nil);
end;

procedure TEditorWindow.DeleteAnswerButtonClick(Sender: TObject);
begin
  if (currentAnswerCount > 2) then
     begin
        currentAnswerCount:=currentAnswerCount - 1;
        FreeAndNil(edit[currentAnswerCount]);
        FreeAndNil(RB[currentAnswerCount]);
        SetLength(edit,currentAnswerCount);
        SetLength(RB,currentAnswerCount);
     end;
end;

procedure TEditorWindow.DeleteQuestionClick(Sender: TObject);
var
  i: integer;
begin
  //если существует элемент и он выделен то удалем его
  if (currentQuestionsCount > 0) and (ListBox1.SelCount >= 0) then
     Begin
        currentQuestionsCount:= currentQuestionsCount - 1;
        for i:=ListBox1.ItemIndex+1 to currentQuestionsCount do
            currentTest.questions[i-1] := currentTest.questions[i];
        //выделяем память
        SetLength(currentTest.questions, currentQuestionsCount);
        ListBox1.Items.Delete(ListBox1.ItemIndex);
        ListBox1.ItemIndex:=currentQuestionsCount-1;
        if (ListBox1.ItemIndex >= 0) then
           EditorWindow.ListBox1Click(nil)
        else
           CorrectingAnswerCount(2);
     end;
  if (currentQuestionsCount = 0)  then
     Begin
        QuestionName.Text:='Добавьте или выберите вопрос для редактирования.';
        ReverseVisible(false);
     end;
end;

procedure TEditorWindow.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CorrectingAnswerCount(2);
  currentAnswerCount:=2;
  currentQuestionsCount:=0;
  EditorWindow.DeleteQuestionClick(nil);
  FreeAndNil(admin.currentTest);
  ListBox1.Clear;
  AdminWindow.Visible:=true;
end;

procedure TEditorWindow.FormCreate(Sender: TObject);
var
  i: integer;
begin
  SetLength(edit,2);
  SetLength(RB,2);
  for i:=0 to 1 do
      begin
         CreateEdit(i);
         CreateRB(i);
      end;
  ReverseVisible(false);
end;

procedure TEditorWindow.ListBox1Click(Sender: TObject);
var
  i: integer;
begin
  if ListBox1.SelCount > 0 then
     Begin
      CorrectingAnswerCount(Length(currentTest.questions[EditorWindow.ListBox1.ItemIndex].answers));
      QuestionName.Text:=currentTest.questions[ListBox1.ItemIndex].question;
      for i:=0 to (Length(currentTest.questions[ListBox1.ItemIndex].answers)-1) do
          Begin
             edit[i].Text:=currentTest.questions[ListBox1.ItemIndex].answers[i].answer;
             RB[i].Checked:=currentTest.questions[ListBox1.ItemIndex].answers[i].correct;
          end;
     end;
end;

procedure TEditorWindow.SaveButtonClick(Sender: TObject);
var
  i: integer;
begin
  currentTest.questions[ListBox1.ItemIndex].question:=QuestionName.Text;
  ListBox1.Items[ListBox1.ItemIndex]:=QuestionName.Text;
  if currentAnswerCount < Length(currentTest.questions[ListBox1.ItemIndex].answers) then
     SetLength(currentTest.questions[ListBox1.ItemIndex].answers, currentAnswerCount);
  if currentAnswerCount > 2 then
     Begin
       SetLength(currentTest.questions[ListBox1.ItemIndex].answers, currentAnswerCount);
       for i:= 2 to currentAnswerCount-1 do
           currentTest.questions[ListBox1.ItemIndex].answers[i]:=AnswerClass.Create;
     end;
  for i:=0 to currentAnswerCount-1 do
      Begin
         currentTest.questions[ListBox1.ItemIndex].answers[i].answer:=edit[i].Text;
         currentTest.questions[ListBox1.ItemIndex].answers[i].correct:=RB[i].Checked;
      end;
end;

end.

