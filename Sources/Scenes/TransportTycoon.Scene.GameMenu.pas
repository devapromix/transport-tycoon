unit TransportTycoon.Scene.GameMenu;

interface

uses
  TransportTycoon.Scenes;

type
  TSceneGameMenu = class(TScene)
  private

  public
    procedure Render; override;
    procedure Update(var Key: word); override;
  end;

implementation

uses
  BearLibTerminal,
  Math,
  SysUtils,
  TransportTycoon.Game,
  TransportTycoon.Scene.World;

{ TSceneGameMenu }

procedure TSceneGameMenu.Render;
begin
  DrawMap(Self.Width, Self.Height - 1);

  DrawFrame(10, 5, 60, 15);
  DrawTitle(Game.CompanyName);

  DrawButton(12, 9, False, 'F', 'COMPANY FINANCES INFO');
  DrawButton(42, 9, False, 'G', 'GENERAL COMPANY INFO');

  DrawButton(12, 10, False, 'N', 'TOWN DIRECTORY');

  DrawButton(12, 12, False, 'C', 'LIST OF ROAD VEHICLES');
  DrawButton(12, 13, False, 'T', 'LIST OF TRAINS');
  DrawButton(12, 14, False, 'S', 'LIST OF SHIPS');
  DrawButton(12, 15, 'A', 'LIST OF AIRCRAFTS');

  DrawButton(42, 14, False, 'B', 'BUILD');
  DrawButton(42, 15, 'X', 'CLEAR LAND');

  DrawButton(29, 17, 'Q', 'QUIT');
  DrawText(38, 17, '|');
  DrawButton(40, 17, 'ESC', 'CLOSE');

  DrawBar;
end;

procedure TSceneGameMenu.Update(var Key: word);
begin
  if (Key = TK_MOUSE_LEFT) then
  begin
    if (MX >= 12) and (MX <= 38) then
      case MY of
        15:
          Key := TK_A;
      end;
    if (MX >= 42) and (MX <= 68) then
      case MY of
        15:
          Key := TK_X;
      end;
    if (MX >= 29) and (MX <= 36) then
      case MY of
        17:
          Key := TK_Q;
      end;
    if (MX >= 40) and (MX <= 50) then
      case MY of
        17:
          Key := TK_ESCAPE;
      end;
  end;
  case Key of
    TK_ESCAPE:
      begin
        Scenes.SetScene(scWorld);
      end;
    TK_A:
      Scenes.SetScene(scAircrafts);
    TK_Q:
      begin
        Game.IsPause := True;
        Scenes.SetScene(scMainMenu);
      end;
    TK_X:
      begin
        Game.IsClearLand := True;
        Scenes.SetScene(scWorld);
      end;
  end;
end;

end.
