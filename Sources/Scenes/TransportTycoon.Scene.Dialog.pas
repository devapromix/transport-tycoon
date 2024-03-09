unit TransportTycoon.Scene.Dialog;

interface

uses
  TransportTycoon.Scenes;

type
  TVoidMethod = procedure;

type

  { TSceneDialog }

  TSceneDialog = class(TScene)
  private
  public
    procedure Render; override;
    procedure Update(var AKey: Word); override;
    class function Ask(const ACaption, AMessage: string;
      const AIsDrawBar: Boolean; const ASceneBack: TSceneEnum;
      AHandler: TVoidMethod = nil): Boolean;
  end;

implementation

uses
  SysUtils,
  BearLibTerminal;

var
  LHandler: TVoidMethod = nil;
  LIsDrawBar: Boolean = False;
  LCaption: string;
  LMessage: string;

  { TSceneDialog }

class function TSceneDialog.Ask(const ACaption, AMessage: string;
  const AIsDrawBar: Boolean; const ASceneBack: TSceneEnum;
  AHandler: TVoidMethod = nil): Boolean;
begin
  LCaption := ACaption;
  LMessage := AMessage;
  Result := True;
  LHandler := AHandler;
  LIsDrawBar := AIsDrawBar;
  Scenes.SetScene(scDialog, ASceneBack);
end;

procedure TSceneDialog.Render;
begin
  DrawMap(Self.ScreenWidth, Self.ScreenHeight);

  DrawFrame(LCaption, 40, 9);
  DrawText(15, LMessage);
  AddButton(17, 'ENTER', 'Leave');
  AddButton(17, 'ESC', 'Cancel');

  if LIsDrawBar then
    DrawGameBar;
end;

procedure TSceneDialog.Update(var AKey: Word);
begin
  if (AKey = TK_MOUSE_LEFT) then
  begin
    if (GetButtonsY = MY) then
    begin
      case MX of
        26 .. 38:
          AKey := TK_ENTER;
        42 .. 53:
          AKey := TK_ESCAPE;
      end;
    end;
  end;
  case AKey of
    TK_ENTER:
      if Assigned(LHandler) then
      begin
        LHandler();
        LHandler := nil;
      end;
    TK_ESCAPE:
      Scenes.Back;
  end;
end;

end.
