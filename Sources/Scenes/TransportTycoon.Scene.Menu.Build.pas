﻿unit TransportTycoon.Scene.Menu.Build;

interface

uses
  TransportTycoon.Map,
  TransportTycoon.Scenes;

type

  { TSceneBuildMenu }

  TSceneBuildMenu = class(TScene)
  private
    FX, FY: Integer;
    procedure DrawLine(const AConstruct: TConstructRec);
  public
    procedure Render; override;
    procedure Update(var AKey: Word); override;
  end;

implementation

uses
  SysUtils,
  BearLibTerminal,
  TransportTycoon.Game,
  TransportTycoon.Palette,
  TransportTycoon.Construct;

{ TSceneBuildMenu }

procedure TSceneBuildMenu.DrawLine(const AConstruct: TConstructRec);
begin
  DrawButton(FX, FY, AConstruct.HotKey, AConstruct.Name);
  terminal_print(FX + 31, FY, TK_ALIGN_RIGHT, Format('[c=%s]$%d[/c]',
    [TPalette.Unused, AConstruct.Cost]));
  Inc(FX, 34);
  if (FX > 66) then
  begin
    FX := 7;
    Inc(FY);
  end;
end;

procedure TSceneBuildMenu.Render;
var
  LConstructEnum: TConstructEnum;
begin
  DrawMap(Self.ScreenWidth, Self.ScreenHeight - 1);

  DrawFrame(5, 7, 70, 15);
  DrawTitle(9, Game.Company.Name);

  FX := 7;
  FY := 11;

  for LConstructEnum := Low(TConstructEnum) to High(TConstructEnum) do
    DrawLine(Construct[LConstructEnum]);

  AddButton(19, 'Esc', 'Close');

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
          11:
            AKey := TK_X;
          12:
            AKey := TK_C;
          13:
            AKey := TK_R;
          14:
            AKey := TK_B;
          { 15:
            AKey := TK_;
            16:
            AKey := TK_X;
            17:
            AKey := TK_X; }
        end;
      41 .. 72:
        case MY of
          11:
            AKey := TK_L;
          12:
            AKey := TK_A;
          13:
            AKey := TK_T;
          { 14:
            AKey := TK_;
            15:
            AKey := TK_;
            16:
            AKey := TK_;
            17:
            AKey := TK_; }
        end;
    end;
  end;
  case AKey of
    TK_ESCAPE:
      Scenes.Back;
    TK_L:
      begin
        Game.Construct.Build(ceLoweringLand);
        Scenes.SetScene(scWorld);
      end;
    TK_U:
      begin
      end;
    TK_A:
      begin
        Game.Construct.Build(ceBuildAqueduct);
        Scenes.SetScene(scWorld);
      end;
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
