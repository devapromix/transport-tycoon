unit TransportTycoon.Scene.Menu.About;

interface

uses
  TransportTycoon.Scenes;

type

  { TSceneAboutMenu }

  TSceneAboutMenu = class(TScene)
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

{ TSceneAboutMenu }

procedure TSceneAboutMenu.Render;
begin
  if IsShowBar then
    Game.Map.Draw(Self.ScreenWidth, Self.ScreenHeight - 1)
  else
    Game.Map.Draw(Self.ScreenWidth, Self.ScreenHeight);

  DrawFrame('GAME SETTINGS', 30, 10, True);

  // Game Speed
  DrawButton(27, 14, 'S', Format('Game Speed: %s', [GameSpeedStr[Game.Speed]]));
  // Fullscreen
  DrawButton(27, 15, 27, True, Game.Fullscreen, 'F', 'Fullscreen');

  if IsShowBar then
    DrawGameBar;
end;

procedure TSceneAboutMenu.Update(var AKey: Word);
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
          14:
            AKey := TK_S;
          15:
            AKey := TK_F;
        end;
    end;
  end;
  if (AKey = TK_MOUSE_RIGHT) then
  begin
    case MX of
      27 .. 52:
        case MY of
          14:
            Game.PrevSpeed;
        end;
    end;
  end;
  case AKey of
    TK_ESCAPE:
      begin
        Game.SaveSettings;
        Scenes.Back;
      end;
    TK_S:
      Game.NextSpeed;
    TK_F:
      begin
        Game.Fullscreen := not Game.Fullscreen;
        Game.Refresh;
      end;
  end;
end;

end.
