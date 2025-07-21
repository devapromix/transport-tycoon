unit TransportTycoon.Scene.Menu.About;

interface

uses
  TransportTycoon.Scenes;

type

  { TSceneAboutMenu }

  TSceneAboutMenu = class(TScene)
  private
  public
    procedure Render; override;
    procedure Update(var AKey: Word); override;
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
  Game.Map.Draw(Self.ScreenWidth, Self.ScreenHeight);

  DrawFrame('ABOUT', 30, 10, True);

  DrawText(14, 'Version ' + Game.Version);
  DrawText(15, 'Apromix (C) 2022-2025');
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
  end;
  case AKey of
    TK_ESCAPE:
      Scenes.Back;
  end;
end;

end.
