unit TransportTycoon.Scene.Industry;

interface

uses
  TransportTycoon.Scenes,
  TransportTycoon.Industries;

type

  { TSceneIndustry }

  TSceneIndustry = class(TScene)
  private
    FIndustry: TIndustry;
  public
    procedure Render; override;
    procedure Update(var AKey: Word); override;
    procedure IndustryInfo(const AIndustry: TIndustry; const AX, AY: Integer);
  end;

implementation

uses
  BearLibTerminal,
  SysUtils,
  TransportTycoon.Game;

{ TSceneIndustry }

procedure TSceneIndustry.IndustryInfo(const AIndustry: TIndustry;
  const AX, AY: Integer);
var
  LY: Integer;
begin
  LY := AY;
  if AIndustry.Produces <> [] then
  begin
    DrawText(AX, LY, 'Produces: ' + AIndustry.GetCargoStr(AIndustry.Produces));
    Dec(LY);
  end;
  if AIndustry.Accepts <> [] then
    DrawText(AX, LY, 'Accepts: ' + AIndustry.GetCargoStr(AIndustry.Accepts));
end;

procedure TSceneIndustry.Render;
begin
  DrawMap(Self.ScreenWidth, Self.ScreenHeight - 1);

  FIndustry := Game.Map.Industry[Game.Map.CurrentIndustry];

  DrawFrame(10, 8, 60, 13);

  with FIndustry do
  begin
    DrawTitle(10, Name);

    DrawButton(34, 12, 35, Dock.IsBuilding, Dock.IsBuilding, 'D', 'Dock');
    DrawButton(34, 13, 35, TruckLoadingBay.IsBuilding,
      TruckLoadingBay.IsBuilding, 'L', 'Truck Loading Bay');
  end;

  IndustryInfo(FIndustry, 12, 16);

  AddButton(18, 'B', 'Build');
  AddButton(18, 'ESC', 'Close');

  DrawGameBar;
end;

procedure TSceneIndustry.Update(var AKey: Word);
begin
  if (AKey = TK_MOUSE_LEFT) then
  begin
    if (GetButtonsY = MY) then
    begin
      case MX of
        29 .. 37:
          AKey := TK_B;
        41 .. 51:
          AKey := TK_ESCAPE;
      end;
    end;
    case MX of
      34 .. 56:
        case MY of
          12:
            AKey := TK_D;
          13:
            AKey := TK_L;
        end;
    end;
  end;
  case AKey of
    TK_ESCAPE:
      Scenes.SetScene(scWorld);
    TK_B:
      Scenes.SetScene(scBuildNearIndustry);
    TK_D:
      if FIndustry.Dock.IsBuilding then
        Scenes.SetScene(scDock, scIndustry);
    TK_L:
      if FIndustry.TruckLoadingBay.IsBuilding then
        Scenes.SetScene(scTruckLoadingBay, scIndustry);
  end;
end;

end.
