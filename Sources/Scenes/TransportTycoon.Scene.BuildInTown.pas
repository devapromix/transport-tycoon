unit TransportTycoon.Scene.BuildInTown;

interface

uses
  TransportTycoon.Scenes,
  TransportTycoon.Industries;

type

  { TSceneBuildInTown }

  TSceneBuildInTown = class(TScene)
  private
    FTown: TTownIndustry;
  public
    procedure Render; override;
    procedure Update(var AKey: Word); override;
  end;

implementation

uses
  Math,
  SysUtils,
  BearLibTerminal,
  TransportTycoon.Game;

{ TSceneBuildInTown }

procedure TSceneBuildInTown.Render;
var
  LAirportLevel: Integer;
begin
  DrawMap(Self.ScreenWidth, Self.ScreenHeight - 1);

  DrawFrame(15, 7, 50, 15);

  FTown := TTownIndustry(Game.Map.Industry[Game.Map.CurrentIndustry]);
  DrawTitle('BUILD IN ' + FTown.Name);
  // Airport
  LAirportLevel := Math.EnsureRange(FTown.Airport.Level + 1, 0, 5);
  DrawBuildingTitle(AirportSizeStr[LAirportLevel], 'A', 11,
    FTown.Airport.CanBuild, FTown.Airport.Cost, FTown.Airport.Level <
    FTown.Airport.MaxLevel);
  // Dock
  DrawBuildingTitle('Dock', 'D', 12, FTown.Dock.CanBuild(FTown.X, FTown.Y),
    FTown.Dock.Cost, FTown.Dock.Level = 0);
  // Bus Station
  DrawBuildingTitle('Bus Station', 'S', 13, FTown.BusStation.CanBuild,
    FTown.BusStation.Cost, not FTown.BusStation.IsBuilding);
  // Truck Loading Bay
  DrawBuildingTitle('Truck Loading Bay', 'L', 14,
    FTown.TruckLoadingBay.CanBuild, FTown.TruckLoadingBay.Cost,
    not FTown.TruckLoadingBay.IsBuilding);

  // Company Headquarters
  DrawBuildingTitle('Company Headquarters', 'G', 17, FTown.HQ.CanBuild and
    Game.Company.IsTownHQ, FTown.HQ.Cost, Game.Company.IsTownHQ and
    not FTown.HQ.IsBuilding);

  AddButton(19, 'Esc', 'Close');

  DrawGameBar;
end;

procedure TSceneBuildInTown.Update(var AKey: Word);
begin
  if (AKey = TK_MOUSE_LEFT) then
  begin
    if (GetButtonsY = MY) then
      case MX of
        35 .. 45:
          AKey := TK_ESCAPE;
      end;
    case MX of
      17 .. 62:
        case MY of
          11:
            AKey := TK_A;
          12:
            AKey := TK_D;
          13:
            AKey := TK_S;
          14:
            AKey := TK_L;
          17:
            AKey := TK_G;
        end;
    end;
  end;
  case AKey of
    TK_ESCAPE:
      Scenes.SetScene(scTown);
    TK_A:
      begin
        if FTown.Airport.CanBuild then
        begin
          FTown.Airport.Build;
          Scenes.SetScene(scAirport, scTown);
        end;
      end;
    TK_D:
      begin
        if FTown.Dock.CanBuild(FTown.X, FTown.Y) then
        begin
          FTown.Dock.Build;
          Scenes.SetScene(scDock, scTown);
        end;
      end;
    TK_S:
      begin
        if FTown.BusStation.CanBuild then
        begin
          FTown.BusStation.Build;
          Scenes.SetScene(scBusStation, scTown);
        end;
      end;
    TK_L:
      begin
        if FTown.TruckLoadingBay.CanBuild then
        begin
          FTown.TruckLoadingBay.Build;
          Scenes.SetScene(scTruckLoadingBay, scTown);
        end;
      end;
    TK_G:
      begin
        if FTown.HQ.CanBuild and
          (Game.Map.CurrentIndustry = Game.Company.TownIndex) then
        begin
          FTown.HQ.Build;
          Scenes.SetScene(scCompany, scTown);
        end;
      end;
  end;
end;

end.
