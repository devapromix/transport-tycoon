﻿unit TransportTycoon.Scene.Menu.Settings;

interface

uses
  TransportTycoon.Scenes;

type

  { TSceneSettingsMenu }

  TSceneSettingsMenu = class(TScene)
  private
    FIsGame: Boolean;
    FIsShowBar: Boolean;
  public
    property IsGame: Boolean read FIsGame write FIsGame;
    procedure Render; override;
    procedure Update(var AKey: Word); override;
    property IsShowBar: Boolean read FIsShowBar write FIsShowBar;
  end;

implementation

uses
  SysUtils,
  BearLibTerminal,
  TransportTycoon.Game,
  TransportTycoon.Palette;

{ TSceneSettingsMenu }

procedure TSceneSettingsMenu.Render;
begin
  if IsShowBar then
    Game.Map.Draw(Self.ScreenWidth, Self.ScreenHeight - 1)
  else
    Game.Map.Draw(Self.ScreenWidth, Self.ScreenHeight);

  DrawFrame(25, 9, 30, 11);
  DrawTitle(11, 'GAME SETTINGS');

  // Game Speed
  DrawButton(27, 13, 'S', Format('Game Speed: %s', [GameSpeedStr[Game.Speed]]));
  // Fullscreen
  DrawButton(27, 15, 27, True, terminal_check(TK_FULLSCREEN), 'ALT+ENTER',
    'Fullscreen', TPalette.Unused);
  // DrawText(39, 15, 'FULLSCREEN', False);
  AddButton(17, 'Esc', 'Close');

  if IsShowBar then
    DrawGameBar;
end;

procedure TSceneSettingsMenu.Update(var AKey: Word);
begin
  if (AKey = TK_MOUSE_LEFT) then
  begin
    if (GetButtonsY = MY) then
    begin
      case MX of
        35 .. 45:
          AKey := TK_ESCAPE;
      end;
    end;
    case MX of
      27 .. 52:
        case MY of
          13:
            AKey := TK_S;
        end;
    end;
  end;
  if (AKey = TK_MOUSE_RIGHT) then
  begin
    case MX of
      27 .. 52:
        case MY of
          13:
            Game.PrevSpeed;
        end;
    end;
  end;
  case AKey of
    TK_ESCAPE:
      Scenes.Back;
    TK_S:
      Game.NextSpeed;
  end;
end;

end.
