unit TransportTycoon.Scene.Menu.SaveGame;

interface

uses
  TransportTycoon.Scenes;

type

  { TSceneSaveGameMenu }

  TSceneSaveGameMenu = class(TScene)
  private

  public
    procedure Render; override;
    procedure Update(var Key: Word); override;
  end;

implementation

uses
  SysUtils,
  BearLibTerminal,
  TransportTycoon.Game;

{ TSceneSaveGameMenu }

procedure TSceneSaveGameMenu.Render;
var
  I: Integer;
begin
  Game.Map.Draw(Self.ScreenWidth, Self.ScreenHeight);

  DrawFrame(10, 6, 60, 18);
  DrawTitle(8, 'SAVE CURRENT GAME');

  for I := 0 to 9 do
    DrawButton(12, I + 10, False, Chr(Ord('A') + I),
      'DRINNINGBRIDGETOWN TRANSPORT / 1965 / 23.07.2022');

  AddButton(21, 'Esc', 'Close');
end;

procedure TSceneSaveGameMenu.Update(var Key: Word);
begin
  if (Key = TK_MOUSE_LEFT) then
  begin
    if (GetButtonsY = MY) then
    begin
      case MX of
        35 .. 45:
          Key := TK_ESCAPE;
      end;
    end;
  end;
  case Key of
    TK_ESCAPE:
      Scenes.SetScene(scWorld);
  end;
end;

end.
