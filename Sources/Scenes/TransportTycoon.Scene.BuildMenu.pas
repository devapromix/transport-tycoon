unit TransportTycoon.Scene.BuildMenu;

interface

uses
  TransportTycoon.Scenes;

type

  { TSceneBuildMenu }

  TSceneBuildMenu = class(TScene)
  private
    StartYLine: Integer;
    procedure DrawLine(const Button, Text: string; const AMoney: Integer);
  public
    procedure Render; override;
    procedure Update(var Key: Word); override;
  end;

implementation

uses
  SysUtils,
  BearLibTerminal,
  TransportTycoon.Game,
  TransportTycoon.Construct;

{ TSceneBuildMenu }

procedure TSceneBuildMenu.DrawLine(const Button, Text: string;
  const AMoney: Integer);
begin
  DrawButton(22, StartYLine, Button, Text);
  terminal_print(57, StartYLine, TK_ALIGN_RIGHT, Format('[c=light gray]$%d[/c]',
    [AMoney]));
  Inc(StartYLine);
end;

procedure TSceneBuildMenu.Render;
begin
  DrawMap(Self.ScreenWidth, Self.ScreenHeight - 1);

  DrawFrame(20, 8, 40, 13);
  DrawTitle(10, Game.Company.Name);

  StartYLine := 12;

  DrawLine('C', 'Build Canal', Game.Map.BuildCanalCost);
  DrawLine('R', 'Build Road', Game.Map.BuildRoadCost);
  DrawLine('B', 'Build Road Bridge', Game.Map.BuildRoadBridgeCost);
  DrawLine('T', 'Build Road Tunnel', Game.Map.BuildRoadTunnelCost);
  DrawLine('X', 'Clear land', Game.Map.ClearLandCost);

  AddButton(18, 'Esc', 'Close');

  DrawBar;
end;

procedure TSceneBuildMenu.Update(var Key: Word);
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
      22 .. 56:
        case MY of
          12:
            Key := TK_C;
          13:
            Key := TK_R;
          14:
            Key := TK_B;
          15:
            Key := TK_T;
          16:
            Key := TK_X;
        end;
    end;
  end;
  case Key of
    TK_ESCAPE:
      Scenes.Back;
    TK_C:
      begin
        Game.Construct.Build(ceBuildCanal);
        Scenes.SetScene(scWorld);
      end;
    TK_R:
      begin
        Game.Construct.Build(ceBuildRoad);
        Scenes.SetScene(scWorld);
      end;
    TK_B:
      begin
        Game.Construct.Build(ceBuildRoadBridge);
        Scenes.SetScene(scWorld);
      end;
    TK_T:
      begin
        Game.Construct.Build(ceBuildRoadTunnel);
        Scenes.SetScene(scWorld);
      end;
    TK_X:
      begin
        Game.Construct.Build(ceClearLand);
        Scenes.SetScene(scWorld);
      end;
  end;
end;

end.
