unit TransportTycoon.Scene.Menu.Game;

interface

uses
  TransportTycoon.Scenes;

type
  TSceneGameMenu = class(TScene)
  private

  public
    procedure Render; override;
    procedure Update(var AKey: word); override;
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
  DrawTitle(9, Game.Company.GetName);

  DrawButton(12, 11, 'F', 'COMPANY FINANCES INFO');
  DrawButton(42, 11, 'G', 'GENERAL COMPANY INFO');

  DrawButton(12, 12, 'N', 'TOWN DIRECTORY');
  DrawButton(42, 12, 'I', 'LIST OF INDUSTRIES');

  DrawButton(42, 13, 'U', 'SAVE GAME');

  DrawButton(12, 14, Game.Vehicles.GotRoadVehicles, 'R',
    'LIST OF ROAD VEHICLES');
  DrawButton(12, 15, False, 'T', 'LIST OF TRAINS');
  DrawButton(12, 16, Game.Vehicles.GotShips, 'S', 'LIST OF SHIPS');
  DrawButton(12, 17, Game.Vehicles.GotAircrafts, 'A', 'LIST OF AIRCRAFTS');

  DrawButton(42, 14, 'D', 'Settings menu');
  DrawButton(42, 15, 'B', 'Build menu');
  if Game.IsPause then
    DrawButton(42, 16, 'P', 'Paused game')
  else
    DrawButton(42, 16, 'P', 'Pause game');
  DrawButton(42, 17, 'X', 'Clear land');

  AddButton(19, 'Q', 'Quit');
  AddButton(19, 'ESC', 'Close');

  DrawGameBar;
end;

procedure TSceneGameMenu.Update(var AKey: word);
begin
  if (AKey = TK_MOUSE_LEFT) then
  begin
    case MX of
      12 .. 38:
        case MY of
          11:
            AKey := TK_F;
          12:
            AKey := TK_N;
          14:
            AKey := TK_R;
          15:
            AKey := TK_T;
          16:
            AKey := TK_S;
          17:
            AKey := TK_A;
        end;
      42 .. 68:
        case MY of
          11:
            AKey := TK_G;
          12:
            AKey := TK_I;
          13:
            AKey := TK_U;
          14:
            AKey := TK_D;
          15:
            AKey := TK_B;
          16:
            AKey := TK_P;
          17:
            AKey := TK_X;
        end;
    end;
    if (GetButtonsY = MY) then
    begin
      case MX of
        29 .. 36:
          AKey := TK_Q;
        40 .. 50:
          AKey := TK_ESCAPE;
      end;
    end;
  end;
  case AKey of
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
  TSceneWorld.GlobalKeys(AKey);
end;

end.
