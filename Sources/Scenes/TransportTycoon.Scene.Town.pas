unit TransportTycoon.Scene.Town;

interface

uses
  TransportTycoon.Scenes,
  TransportTycoon.Industries;

type

  { TSceneTown }

  TSceneTown = class(TScene)
  private
    FTown: TTownIndustry;
  public
    procedure Render; override;
    procedure Update(var Key: word); override;
  end;

implementation

uses
  Math,
  SysUtils,
  BearLibTerminal,
  TransportTycoon.Game,
  TransportTycoon.Scene.Industry,
  TransportTycoon.Palette,
  TransportTycoon.Races;

{ TSceneTown }

procedure TSceneTown.Render;
var
  LAirportLevel: Integer;
  LRace: TRaceEnum;
begin
  DrawMap(Self.ScreenWidth, Self.ScreenHeight - 1);

  DrawFrame(10, 6, 60, 17);

  FTown := TTownIndustry(Game.Map.Industry[Game.Map.CurrentIndustry]);

  DrawTitle(8, FTown.Name);
  terminal_color(TPalette.Default);
  DrawText(12, 10, 'Population: ' + IntToStr(FTown.Population));
  for LRace := Low(TRaceEnum) to High(TRaceEnum) do
    DrawText(12, Ord(LRace) + 11, GameRaceStr[LRace] + ': ' +
      IntToStr(FTown.GetRacePop(LRace)) + '%');
  DrawText(12, 14, 'Houses: ' + IntToStr(FTown.Houses));
  // Airport
  LAirportLevel := Math.EnsureRange(FTown.Airport.Level, 1, 5);
  DrawButton(34, 10, 35, FTown.Airport.IsBuilding, FTown.Airport.IsBuilding,
    'A', AirportSizeStr[LAirportLevel]);
  // Dock
  DrawButton(34, 11, 35, FTown.Dock.IsBuilding, FTown.Dock.IsBuilding,
    'D', 'Dock');
  // Bus Station
  DrawButton(34, 12, 35, FTown.BusStation.IsBuilding,
    FTown.BusStation.IsBuilding, 'S', 'Bus Station');
  // Truck Loading Bay
  DrawButton(34, 13, 35, FTown.TruckLoadingBay.IsBuilding,
    FTown.TruckLoadingBay.IsBuilding, 'L', 'Truck Loading Bay');
  // Company Headquarters
  if Game.Company.IsTownHQ then
    DrawButton(34, 15, 35, FTown.HQ.IsBuilding, FTown.HQ.IsBuilding, 'G',
      'Company Headquarters');
  terminal_color(TPalette.Default);

  TSceneIndustry(Scenes.GetScene(scIndustry)).IndustryInfo(FTown, 12, 18);

  AddButton(20, 'B', 'Build');
  AddButton(20, 'ESC', 'Close');

  DrawGameBar;
end;

procedure TSceneTown.Update(var Key: word);
begin
  if (Key = TK_MOUSE_LEFT) then
  begin
    if (GetButtonsY = MY) then
    begin
      case MX of
        29 .. 37:
          Key := TK_B;
        41 .. 51:
          Key := TK_ESCAPE;
      end;
    end;
    case MX of
      34 .. 69:
        case MY of
          10:
            Key := TK_A;
          11:
            Key := TK_D;
          12:
            Key := TK_S;
          13:
            Key := TK_L;
          15:
            Key := TK_G;
        end;
    end;
  end;
  case Key of
    TK_ESCAPE:
      Scenes.SetScene(scWorld);
    TK_A:
      if FTown.Airport.IsBuilding then
        Scenes.SetScene(scAirport, scTown);
    TK_B:
      Scenes.SetScene(scBuildInTown);
    TK_D:
      if FTown.Dock.IsBuilding then
        Scenes.SetScene(scDock, scTown);
    TK_S:
      if FTown.BusStation.IsBuilding then
        Scenes.SetScene(scBusStation, scTown);
    TK_L:
      if FTown.TruckLoadingBay.IsBuilding then
        Scenes.SetScene(scTruckLoadingBay, scTown);
    TK_G:
      if Game.Company.IsTownHQ and FTown.HQ.IsBuilding then
        Scenes.SetScene(scCompany, scTown);
  end;
end;

end.
