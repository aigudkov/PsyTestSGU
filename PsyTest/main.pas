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
    ButtonBackAdmin: TButton;
    ButtonBackUser: TButton;
    ButtonNextAdmin: TButton;
    ButtonNextUser: TButton;
    ButtonUser: TButton;
    EditFamily: TEdit;
    EditFirstName: TEdit;
    EditGroup: TEdit;
    EditLastName: TEdit;
    EditPassword: TEdit;
    LabelAuthorizationAdmin: TLabel;
    LabelAuthorizationUser: TLabel;
    LabelFamily: TLabel;
    LabelFirstName: TLabel;
    LabelGroup: TLabel;
    LabelLastName: TLabel;
    LabelPassword: TLabel;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    PanelAuthorizationAdmin: TPanel;
    PanelAuthorizationUser: TPanel;
    PanelMain: TPanel;
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
            ShowMessage('???????????????? ????????????!');
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
     ShowMessage('?????????????? ????????????')
  else
    if (EditFamily.Text = '') then
       ShowMessage('?????????????? ??????????????')
    else
      if (EditFirstName.Text = '') then
         ShowMessage('?????????????? ??????')
      else
        if (EditLastName.Text = '') then
           ShowMessage('?????????????? ????????????????')
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

