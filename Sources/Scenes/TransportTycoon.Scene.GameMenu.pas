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
  SysUtils,
  TransportTycoon.Game;

{ TSceneGameMenu }

procedure TSceneGameMenu.Render;
begin
  DrawMap(Self.Width, Self.Height - 1);

  DrawFrame(10, 7, 60, 15);
  DrawTitle(9, Game.Company.Name);

  DrawButton(12, 11, 'F', 'COMPANY FINANCES INFO');
  DrawButton(42, 11, False, 'G', 'GENERAL COMPANY INFO');

  DrawButton(12, 12, 'N', 'TOWN DIRECTORY');

  DrawButton(12, 14, False, 'C', 'LIST OF ROAD VEHICLES');
  DrawButton(12, 15, False, 'T', 'LIST OF TRAINS');
  DrawButton(12, 16, False, 'S', 'LIST OF SHIPS');
  DrawButton(12, 17, Length(Game.Vehicles.Aircraft) > 0, 'A',
    'LIST OF AIRCRAFTS');

  DrawButton(42, 16, False, 'B', 'BUILD');
  DrawButton(42, 17, 'X', 'CLEAR LAND');

  AddButton(19, 'Q', 'QUIT');
  AddButton(19, 'ESC', 'CLOSE');

  DrawBar;
end;

procedure TSceneGameMenu.Update(var Key: word);
begin
  if (Key = TK_MOUSE_LEFT) then
  begin
    if (MX >= 12) and (MX <= 38) then
      case MY of
        11:
          Key := TK_F;
        12:
          Key := TK_N;
        17:
          Key := TK_A;
      end;
    if (MX >= 42) and (MX <= 68) then
      case MY of
        17:
          Key := TK_X;
      end;
    if (MX >= 29) and (MX <= 36) then
      case MY of
        19:
          Key := TK_Q;
      end;
    if (MX >= 40) and (MX <= 50) then
      case MY of
        19:
          Key := TK_ESCAPE;
      end;
  end;
  case Key of
    TK_ESCAPE:
      begin
        Scenes.SetScene(scWorld);
      end;
    TK_A:
      if Length(Game.Vehicles.Aircraft) > 0 then
        Scenes.SetScene(scAircrafts);
    TK_F:
      Scenes.SetScene(scFinances);
    TK_N:
      Scenes.SetScene(scTowns);
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
