unit TransportTycoon.Scene.Menu.Build;

interface

uses
  TransportTycoon.Scenes;

type

  { TSceneBuildMenu }

  TSceneBuildMenu = class(TScene)
  private
    FX, FY: Integer;
    procedure DrawLine(const AButton, AText: string; const AMoney: Integer);
  public
    procedure Render; override;
    procedure Update(var AKey: Word); override;
  end;

implementation

uses
  SysUtils,
  BearLibTerminal,
  TransportTycoon.Game,
  TransportTycoon.Construct,
  TransportTycoon.Palette,
  TransportTycoon.Map;

{ TSceneBuildMenu }

procedure TSceneBuildMenu.DrawLine(const AButton, AText: string;
  const AMoney: Integer);
begin
  DrawButton(FX, FY, AButton, AText);
  terminal_print(FX + 31, FY, TK_ALIGN_RIGHT, Format('[c=%s]$%d[/c]',
    [TPalette.Unused, AMoney]));
  Inc(FX, 34);
  if (FX > 66) then
  begin
    FX := 7;
    Inc(FY);
  end;
end;

procedure TSceneBuildMenu.Render;
begin
  DrawMap(Self.ScreenWidth, Self.ScreenHeight - 1);

  DrawFrame(5, 8, 70, 13);
  DrawTitle(10, Game.Company.Name);

  FX := 7;
  FY := 12;

  DrawLine('C', 'Build Canal', ConstructCost[ceBuildCanal]);
  DrawLine('R', 'Build Road', ConstructCost[ceBuildRoad]);
  DrawLine('B', 'Build Road Bridge', ConstructCost[ceBuildRoadBridge]);
  DrawLine('T', 'Build Road Tunnel', ConstructCost[ceBuildRoadTunnel]);

  FX := 7;
  FY := 16;
  DrawLine('X', 'Clear land', ConstructCost[ceClearLand]);

  AddButton(18, 'Esc', 'Close');

  DrawGameBar;
end;

procedure TSceneBuildMenu.Update(var AKey: Word);
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
      7 .. 38:
        case MY of
          12:
            AKey := TK_C;
          13:
            AKey := TK_B;
          { 14:
            AKey := TK_;
            15:
            AKey := TK_; }
          16:
            AKey := TK_X;
        end;
      41 .. 72:
        case MY of
          12:
            AKey := TK_R;
          13:
            AKey := TK_T;
          { 14:
            AKey := TK_;
            15:
            AKey := TK_;
            16:
            AKey := TK_; }
        end;
    end;
  end;
  case AKey of
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
