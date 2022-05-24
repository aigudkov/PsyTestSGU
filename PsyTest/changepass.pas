unit changepass;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Fpjson, jsonparser, FileUtil;

type

  { TFormChangePassword }

  TFormChangePassword = class(TForm)
    ButtonConfirm: TButton;
    ButtonBack: TButton;
    EditOldPassword: TEdit;
    EditNewPassword: TEdit;
    EditRepeatNewPassword: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    procedure ButtonBackClick(Sender: TObject);
    procedure ButtonConfirmClick(Sender: TObject);
  private

  public

  end;

var
  FormChangePassword: TFormChangePassword;

implementation
uses admin;

{$R *.lfm}

{ TFormChangePassword }

procedure TFormChangePassword.ButtonBackClick(Sender: TObject);
begin
  EditOldPassword.Clear;
  EditNewPassword.Clear;
  EditRepeatNewPassword.Clear;
  close;
end;

procedure TFormChangePassword.ButtonConfirmClick(Sender: TObject);
var
  JOpen:TJSONData;
  JSave:TJSONObject;
  strList: TStringList;
begin
  JOpen:=GetJSON(ReadFileToString('PsyTest/utils/technicalfile.json'));
  JSave:=TJSONObject.Create;
  strList := TStringList.Create;
  try
    if (EditOldPassword.Text <> JOpen.FindPath('password').AsString) then
       begin
         ShowMessage('Исходный пароль введен неверно!');
       end
    else
        if (Length(EditNewPassword.Text) < 4) then
           begin
             ShowMessage('Пароль должен состоять минимум из 4 символов.');
           end
        else
            if (EditNewPassword.Text <> EditRepeatNewPassword.Text) then
              begin
                ShowMessage('Пароли не совпадают.');
              end
            else
              begin
                JSave.Add('password', EditRepeatNewPassword.Text);
                strList.Text:=JSave.FormatJSON();
                strList.SaveToFile('PsyTest/utils/technicalfile.json');
                ButtonBackClick(nil);
                admin.AdminWindow.Close;
              end;
  finally
    FreeAndNil(JOpen);
    FreeAndNil(JSave);
    FreeAndNil(strList);
  end;
end;

end.

