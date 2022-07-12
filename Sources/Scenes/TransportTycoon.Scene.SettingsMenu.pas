unit TransportTycoon.Scene.SettingsMenu;

interface

uses
  TransportTycoon.Scenes;

type
  TSceneSettingsMenu = class(TScene)
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

procedure TSceneSettingsMenu.Render;
begin
  if Game.IsGame then
    Game.Map.Draw(Self.Width, Self.Height - 1)
  else
    Game.Map.Draw(Self.Width, Self.Height);

  DrawFrame(25, 9, 30, 11);
  DrawTitle(11, 'GAME SETTINGS');

  DrawButton(27, 13, 'S', Format('Game Speed: %s', [GameSpeedStr[Game.Speed]]));

  AddButton(17, 'Esc', 'Close');

  if Game.IsGame then
    DrawBar;
end;

procedure TSceneSettingsMenu.Update(var Key: Word);
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
    case MX of
      27 .. 52:
        case MY of
          13:
            Key := TK_S;
        end;
    end;
  end;
  if (Key = TK_MOUSE_RIGHT) then
  begin
    case MX of
      27 .. 52:
        case MY of
          13:
            Game.PrevSpeed;
        end;
    end;
  end;
  case Key of
    TK_ESCAPE:
      Scenes.Back;
    TK_S:
      Game.NextSpeed;
  end;
end;

end.
