unit TransportTycoon.Scene.Menu.Build;

interface

uses
  TransportTycoon.Map,
  TransportTycoon.Scenes,
  TransportTycoon.Construct;

type

  { TSceneBuildMenu }

  TSceneBuildMenu = class(TScene)
  private
    FX, FY: Integer;
    procedure DrawCategory(const AInfrastructureCategory
      : TInfrastructureCategory);
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
  TransportTycoon.Palette;

{ TSceneBuildMenu }

procedure TSceneBuildMenu.DrawCategory(const AInfrastructureCategory
  : TInfrastructureCategory);
begin
  FX := 7;
  if (AInfrastructureCategory <> icNone) and
    (AInfrastructureCategory <> icLandscaping) then
    Inc(FY);
  terminal_color(TPalette.Selected);
  terminal_composition(TK_ON);
  DrawText(FX, FY, InfrastructureCategotyName[AInfrastructureCategory] + ':');
  DrawText(FX, FY, StringOfChar('_',
    Length(InfrastructureCategotyName[AInfrastructureCategory] + ':')));
  terminal_composition(TK_OFF);
  terminal_color(TPalette.Default);
  Inc(FY);
end;

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
  LInfrastructureCategory: TInfrastructureCategory;
begin
  DrawMap(Self.ScreenWidth, Self.ScreenHeight - 1);

  DrawFrame(5, 3, 70, 23);
  DrawTitle(5, Game.Company.Name);

  FX := 7;
  FY := 7;

  LInfrastructureCategory := icNone;

  for LConstructEnum := Low(TConstructEnum) to High(TConstructEnum) do
  begin
    if LInfrastructureCategory <> Construct[LConstructEnum].InfrastructureCategory
    then
    begin
      LInfrastructureCategory := Construct[LConstructEnum]
        .InfrastructureCategory;
      DrawCategory(LInfrastructureCategory);
    end;
    DrawLine(Construct[LConstructEnum]);
  end;

  AddButton(23, 'Esc', 'Close');

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
          8:
            AKey := TK_X;
          11:
            AKey := TK_C;
          14:
            AKey := TK_R;
          15:
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
          8:
            AKey := TK_L;
          11:
            AKey := TK_A;
          14:
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
