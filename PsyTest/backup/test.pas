unit test;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Fpjson, jsonparser, FileUtil;

type

  { TTestWindow }

  TTestWindow = class(TForm)
    NextButton: TButton;
    PanelResult: TPanel;
    Panel: TPanel;
    PanelForAnswers: TPanel;
    QuestionLabel: TLabel;
    NumberQuestionLabel: TLabel;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure NextButtonClick(Sender: TObject);
  private

  public

  end;

var
  TestWindow: TTestWindow;
  currentQuestionCount: integer;
  currentAnswerCount: integer;
  userCorrectAnswer: integer=0;
  lbl: array of TLabel;
  RB: array of TRadioButton;

implementation
  uses user, main;

{$R *.lfm}

{ TTestWindow }

procedure CreateLabel (position: integer);
var
  left: integer=24;
  top: integer=24;
  width: integer=648;
  height: integer=27;
begin
  lbl[position]:=TLabel.Create(TestWindow.PanelForAnswers);
  lbl[position].Parent:=TestWindow.PanelForAnswers;
  lbl[position].Left:=left;
  lbl[position].Top:=top + 70 * (position);
  lbl[position].Width:=width;
  lbl[position].Height:=height;
  lbl[position].Caption:=user.currentTest.questions[currentQuestionCount].answers[position].answer;
  lbl[position].Font.Name:='Times New Roman';
  lbl[position].WordWrap:=true;
  lbl[position].AutoSize:=false;
  lbl[position].Width:=915;
  lbl[position].Height:=57;
end;

procedure CreateRB (position: integer);
var
  left: integer=955;
  top: integer=25;
  width: integer=23;
  height: integer=23;
begin
  RB[position]:=TRadioButton.Create(TestWindow.PanelForAnswers);
  RB[position].Parent:=TestWindow.PanelForAnswers;
  RB[position].Left:=left;
  RB[position].Top:=top + 70 * (position);
  RB[position].Width:=width;
  RB[position].Height:=height;
  RB[position].Caption:='';
  RB[position].Checked:=false;
end;

procedure AddAnswer;
begin
   begin
      currentAnswerCount:=currentAnswerCount + 1;
      SetLength(lbl,currentAnswerCount);
      SetLength(RB,currentAnswerCount);
      CreateLabel(currentAnswerCount-1);
      CreateRB(currentAnswerCount-1);
   end;
end;

procedure DeleteAnswers;
var
  i:integer;
begin
  for i:=0 to currentAnswerCount-1 do
  begin
     FreeAndNil(lbl[i]);
     FreeAndNil(RB[i]);
  end;
  currentAnswerCount:=0;
  SetLength(lbl,currentAnswerCount);
  SetLength(RB,currentAnswerCount);
end;

procedure TTestWindow.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  FreeAndNil(user.currentTest);
  DeleteAnswers;
  User.UserWindow.Visible:=true;
  userCorrectAnswer:=0;
end;

procedure CheckUserAnswer;
var
  i:integer;
Begin
   for i:=0 to (Length(user.currentTest.questions[currentQuestionCount].answers) - 1) do
    begin
       if ((user.currentTest.questions[currentQuestionCount].answers[i].correct = RB[i].Checked) and (RB[i].Checked = true)) then
          begin
              userCorrectAnswer:=userCorrectAnswer+1;
          end;
    end;
end;

procedure SaveToFileTestResult(testName:string; correctAnswer:string; AllAnswer:string);
var
  jDocument: TJSONObject;
  strList: TStringList;
begin
  jDocument:= TJSONObject.Create(['group',main.currentStudent.group,
                                  'surname',main.currentStudent.familyName,
                                  'firstname',main.currentStudent.firstName,
                                  'lastname',main.currentStudent.lastName,
                                  'testname',testName,
                                  'result',correctAnswer + ' из ' + AllAnswer + ' (' + FloatToStrF(StrToInt(correctAnswer)/StrToInt(AllAnswer)*100,ffFixed,5,2)+ '%)']);
  strList := TStringList.Create;
  strList.Text:=jDocument.FormatJSON();
  strList.SaveToFile('PsyTest/results/' + main.currentStudent.group + ' ' + user.currentTest.name + ' ' + main.currentStudent.familyName + ' ' + main.currentStudent.firstName + ' ' + main.currentStudent.lastName + '.json');
  FreeAndNil(jDocument);
  FreeAndNil(strList);
end;

procedure TTestWindow.FormShow(Sender: TObject);
var
  i:integer;
begin
  Panel.Left:=1;
  Panel.Top:=1;
  Panel.Height:=100;
  Panel.Width:=1022;
  PanelForAnswers.Left:=1;
  PanelForAnswers.Top:=102;
  PanelForAnswers.Height:=606;
  PanelForAnswers.Width:=1022;
  PanelResult.Left:=1;
  PanelResult.Top:=709;
  PanelResult.Height:=58;
  PanelResult.Width:=1022;
  NextButton.Caption:='Дальше';
  Caption:=user.currentTest.name;
  currentQuestionCount:=0;
  currentAnswerCount:=0;
  QuestionLabel.Caption:=user.currentTest.questions[currentQuestionCount].question;
  for i:=0 to (Length(user.currentTest.questions[currentQuestionCount].answers) - 1) do
    begin
       AddAnswer;
    end;
  NumberQuestionLabel.Caption:='Вопрос номер ' + IntToStr(currentQuestionCount+1) + ' из ' + IntToStr(Length(user.currentTest.questions));
end;

procedure TTestWindow.NextButtonClick(Sender: TObject);
var
  i:integer;
begin
   if (Length(user.currentTest.questions) > (currentQuestionCount+1)) then
     begin
       CheckUserAnswer;
       DeleteAnswers;
       currentQuestionCount:=currentQuestionCount+1;
       QuestionLabel.Caption:=user.currentTest.questions[currentQuestionCount].question;
       for i:=0 to (Length(user.currentTest.questions[currentQuestionCount].answers) - 1) do
         begin
           AddAnswer;
         end;
       NumberQuestionLabel.Caption:='Вопрос номер ' + IntToStr(currentQuestionCount+1) + ' из ' + IntToStr(Length(user.currentTest.questions));
       if (Length(user.currentTest.questions) = (currentQuestionCount+1)) then
         NextButton.Caption:='Завершить';
     end
   else
     Begin
        CheckUserAnswer;
        SaveToFileTestResult(user.currentTest.name, IntToStr(userCorrectAnswer), IntToStr(Length(user.currentTest.questions)));
        if QuestionDlg('Тест завершен',
                       'Результат: '  + IntToStr(userCorrectAnswer) + ' из ' +  IntToStr(Length(user.currentTest.questions)) + ' (' + FloatToStrF(userCorrectAnswer/Length(user.currentTest.questions)*100,ffFixed,5,2)+ '%)'
                       ,mtCustom,
                       [mrYes,'Ок',
                       'IsDefault'],
                       '') = mrYes then
          close
        else
          close;
     end;
end;

end.

