unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Menus, Fpjson, jsonparser, FileUtil;

type

  { TMainForm }

  TMainForm = class(TForm)
    ButtonAdmin: TButton;
    ButtonBackUser: TButton;
    ButtonBackAdmin: TButton;
    ButtonNextAdmin: TButton;
    ButtonUser: TButton;
    ButtonNextUser: TButton;
    EditGroup: TEdit;
    EditFamily: TEdit;
    EditFirstName: TEdit;
    EditPassword: TEdit;
    EditLastName: TEdit;
    LabelAuthorizationUser: TLabel;
    LabelAuthorizationAdmin: TLabel;
    LabelFamily: TLabel;
    LabelFirstName: TLabel;
    LabelPassword: TLabel;
    LabelLastName: TLabel;
    LabelGroup: TLabel;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    PanelAuthorizationAdmin: TPanel;
    PanelMain: TPanel;
    PanelAuthorizationUser: TPanel;
    procedure ButtonAdminClick(Sender: TObject);
    procedure ButtonBackAdminClick(Sender: TObject);
    procedure ButtonBackUserClick(Sender: TObject);
    procedure ButtonNextAdminClick(Sender: TObject);
    procedure ButtonNextUserClick(Sender: TObject);
    procedure ButtonUserClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
  private

  public

  end;

Type StudentClass=class
  group: string;
  familyName: string;
  firstName: string;
  lastName: string;
end;

var
  MainForm: TMainForm;
  currentStudent: StudentClass;

implementation
  uses user, admin;

{$R *.lfm}

{ TMainForm }

procedure TMainForm.FormCreate(Sender: TObject);
begin
  PanelMain.Top:=200;
  PanelMain.Left:=300;
  PanelAuthorizationUser.Top:=200;
  PanelAuthorizationUser.Left:=300;
  PanelAuthorizationAdmin.Top:=200;
  PanelAuthorizationAdmin.Left:=300;
end;

procedure TMainForm.MenuItem2Click(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.ButtonUserClick(Sender: TObject);
begin
  PanelMain.Visible:=false;
  PanelAuthorizationUser.Visible:=true;
end;

procedure TMainForm.ButtonBackUserClick(Sender: TObject);
begin
  PanelMain.Visible:=true;
  PanelAuthorizationUser.Visible:=false;
  EditGroup.Clear;
  EditFamily.Clear;
  EditFirstName.Clear;
  EditLastName.Clear;
end;

procedure TMainForm.ButtonNextAdminClick(Sender: TObject);
var
  JRoot:TJSONData;
begin
  JRoot:=GetJSON(ReadFileToString('PsyTest/utils/technicalfile.json'));
  try
    if (EditPassword.Text = '') or (EditPassword.Text <> JRoot.FindPath('password').AsString) then
       begin
            ShowMessage('Неверный пароль!');
            EditPassword.Clear;
       end
    else
      begin
        MainForm.Visible:=false;
        admin.AdminWindow.ShowModal;
      end;
  finally
    FreeAndNil(JRoot);
  end;
end;

procedure TMainForm.ButtonAdminClick(Sender: TObject);
begin
  PanelMain.Visible:=false;
  PanelAuthorizationAdmin.Visible:=true;
end;

procedure TMainForm.ButtonBackAdminClick(Sender: TObject);
begin
  PanelMain.Visible:=true;
  PanelAuthorizationAdmin.Visible:=false;
  EditPassword.Clear;
end;

procedure TMainForm.ButtonNextUserClick(Sender: TObject);
begin
  if (EditGroup.Text = '') then
     ShowMessage('Введите группу')
  else
    if (EditFamily.Text = '') then
       ShowMessage('Введите фамилию')
    else
      if (EditFirstName.Text = '') then
         ShowMessage('Введите имя')
      else
        if (EditLastName.Text = '') then
           ShowMessage('Введите отчество')
        else
          begin
            currentStudent:=StudentClass.Create;
            currentStudent.group:=EditGroup.Text;
            currentStudent.familyName:=EditFamily.Text;
            currentStudent.firstName:=EditFirstName.Text;
            currentStudent.lastName:=EditLastName.Text;
            MainForm.Visible:=false;
            user.UserWindow.ShowModal;
          end;
end;

end.

