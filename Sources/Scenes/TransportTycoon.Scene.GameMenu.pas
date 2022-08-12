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
  TransportTycoon.Game,
  TransportTycoon.Scene.World;

{ TSceneGameMenu }

procedure TSceneGameMenu.Render;
begin
  DrawMap(Self.ScreenWidth, Self.ScreenHeight - 1);

  DrawFrame(10, 7, 60, 15);
  DrawTitle(9, Game.Company.Name);

  DrawButton(12, 11, 'F', 'COMPANY FINANCES INFO');
  DrawButton(42, 11, 'G', 'GENERAL COMPANY INFO');

  DrawButton(12, 12, 'N', 'TOWN DIRECTORY');
  DrawButton(42, 12, 'I', 'LIST OF INDUSTRIES');

  DrawButton(12, 14, Game.Vehicles.GotRoadVehicles, 'R',
    'LIST OF ROAD VEHICLES');
  DrawButton(12, 15, False, 'T', 'LIST OF TRAINS');
  DrawButton(12, 16, Game.Vehicles.GotShips, 'S', 'LIST OF SHIPS');
  DrawButton(12, 17, Game.Vehicles.GotAircrafts, 'A', 'LIST OF AIRCRAFTS');

  DrawButton(42, 14, 'D', 'Settings menu');
  DrawButton(42, 15, 'B', 'Build menu');
  DrawButton(42, 16, 'P', 'Pause game');
  DrawButton(42, 17, 'X', 'Clear land');

  AddButton(19, 'Q', 'Quit');
  AddButton(19, 'ESC', 'Close');

  DrawBar;
end;

procedure TSceneGameMenu.Update(var Key: word);
begin
  if (Key = TK_MOUSE_LEFT) then
  begin
    case MX of
      12 .. 38:
        case MY of
          11:
            Key := TK_F;
          12:
            Key := TK_N;
          16:
            Key := TK_S;
          17:
            Key := TK_A;
        end;
      42 .. 68:
        case MY of
          11:
            Key := TK_G;
          12:
            Key := TK_I;
          14:
            Key := TK_D;
          15:
            Key := TK_B;
          16:
            Key := TK_P;
          17:
            Key := TK_X;
        end;
    end;
    if (GetButtonsY = MY) then
    begin
      case MX of
        29 .. 36:
          Key := TK_Q;
        40 .. 50:
          Key := TK_ESCAPE;
      end;
    end;
  end;
  case Key of
    TK_ESCAPE:
      begin
        Scenes.SetScene(scWorld);
      end;
    TK_Q:
      begin
        Game.IsPause := True;
        Scenes.SetScene(scMainMenu);
      end;
  end;
  TSceneWorld.GlobalKeys(Key);
end;

end.
