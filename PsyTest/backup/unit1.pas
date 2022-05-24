unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls;

type

  { TEditorWindow }

  TEditorWindow = class(TForm)
    AddAnswerButton: TButton;
    DeleteAnswerButton: TButton;
    CreateButton: TButton;
    DeleteButton: TButton;
    CompletedButton: TButton;
    SaveButton: TButton;
    QuestionName: TEdit;
    Answer1: TEdit;
    Answer2: TEdit;
    TestName: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    ListBox1: TListBox;
    Panel1: TPanel;
    Panel2: TPanel;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    procedure AddAnswerButtonClick(Sender: TObject);
    procedure DeleteAnswerButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
  private

  public

  end;

var
  EditorWindow: TEditorWindow;
  currentAnswerCount: integer = 2;
  edit: array[1..10] of TEdit;
  RB: array[1..10] of TRadioButton;

implementation
uses admin;
{$R *.lfm}

{ TEditorWindow }

procedure TEditorWindow.AddAnswerButtonClick(Sender: TObject);
begin
  if (currentAnswerCount < 8) then
     begin
        currentAnswerCount:=currentAnswerCount + 1;

        edit[currentAnswerCount]:=TEdit.Create(Panel1);
        edit[currentAnswerCount].Parent:=Panel1;
        edit[currentAnswerCount].Left:=Answer1.Left;
        edit[currentAnswerCount].Top:=Answer1.Top + 32 * (currentAnswerCount-1);
        edit[currentAnswerCount].Width:=Answer1.Width;
        edit[currentAnswerCount].Height:=Answer1.Height;
        edit[currentAnswerCount].Caption:='';

        RB[currentAnswerCount]:=TRadioButton.Create(Panel1);
        RB[currentAnswerCount].Parent:=Panel1;
        RB[currentAnswerCount].Left:=RadioButton1.Left;
        RB[currentAnswerCount].Top:=RadioButton1.Top + 32 * (currentAnswerCount-1);
        RB[currentAnswerCount].Width:=RadioButton1.Width;
        RB[currentAnswerCount].Height:=RadioButton1.Height;
        RB[currentAnswerCount].Caption:='';
     end;
end;

procedure TEditorWindow.DeleteAnswerButtonClick(Sender: TObject);
begin
  if (currentAnswerCount > 2) then
     begin
        FreeAndNil(edit[currentAnswerCount]);
        FreeAndNil(RB[currentAnswerCount]);
        currentAnswerCount:=currentAnswerCount - 1;
     end;
end;

procedure TEditorWindow.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
begin
  //admin.currentTest.Free;
  //admin.AdminWindow.Visible:=true;
end;

end.

