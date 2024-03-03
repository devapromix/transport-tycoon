unit TransportTycoon.Scene.Dialog;

interface

uses
  TransportTycoon.Scenes;

type
  TVoidMethod = procedure of object;

type

  { TSceneDialog }

  TSceneDialogPrompt = class(TScene)
  private
  public
    procedure Render; override;
    procedure Update(var AKey: Word); override;
    class function Ask(const ACaption, AMessage: string;
      const ASceneBack: TSceneEnum; AHandler: TVoidMethod = nil): Boolean;
  end;

implementation

uses
  SysUtils,
  BearLibTerminal;

var
  LHandler: TVoidMethod = nil;
  LSceneBack: TSceneEnum;
  LCaption: string;
  LMessage: string;

  { TSceneDialog }

class function TSceneDialogPrompt.Ask(const ACaption, AMessage: string;
  const ASceneBack: TSceneEnum; AHandler: TVoidMethod = nil): Boolean;
begin
  LCaption := ACaption;
  LSceneBack := ASceneBack;
  LMessage := AMessage;
  Result := True;
  LHandler := AHandler;
  Scenes.SetScene(scDialog);
end;

procedure TSceneDialogPrompt.Render;
begin
  DrawMap(Self.ScreenWidth, Self.ScreenHeight);

  DrawFrame(LCaption, 40, 10);
  DrawText(14, LMessage);
  AddButton(17, 'ENTER', 'Yes');
  AddButton(17, 'ESC', 'Cancel');

  DrawGameBar;
end;

procedure TSceneDialogPrompt.Update(var AKey: Word);
begin
  if (AKey = TK_MOUSE_LEFT) then
  begin
    if (GetButtonsY = MY) then
    begin
      case MX of
        27 .. 37:
          AKey := TK_ENTER;
        41 .. 52:
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
      Scenes.SetScene(LSceneBack);
  end;
end;

end.
