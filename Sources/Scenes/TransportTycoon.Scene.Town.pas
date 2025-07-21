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
    procedure PrevTown;
    procedure NextTown;
  public
    procedure Render; override;
    procedure Update(var AKey: word); override;
  end;

implementation

uses
  Math,
  SysUtils,
  BearLibTerminal,
  TransportTycoon.Game,
  TransportTycoon.Scene.Industry,
  TransportTycoon.Palette,
  TransportTycoon.Races,
  TransportTycoon.Log;

{ TSceneTown }

procedure TSceneTown.NextTown;
begin
  try
    with Game.Map do
    begin
      repeat
        CurrentIndustry := CurrentIndustry + 1;
        if CurrentIndustry > MapTownCount() then
          CurrentIndustry := 0;
      until (Industry[CurrentIndustry].IndustryType = inTown);
      ScrollTo(Industry[CurrentIndustry].X, Industry[CurrentIndustry].Y);
    end;
  except
    on E: Exception do
      Log.Add('TSceneTown.NextTown', E.Message);
  end;
end;

procedure TSceneTown.PrevTown;
begin
  try
    with Game.Map do
    begin
      repeat
        CurrentIndustry := CurrentIndustry - 1;
        if CurrentIndustry < 0 then
          CurrentIndustry := MapTownCount();
      until (Industry[CurrentIndustry].IndustryType = inTown);
      ScrollTo(Industry[CurrentIndustry].X, Industry[CurrentIndustry].Y);
    end;
  except
    on E: Exception do
      Log.Add('TSceneTown.PrevTown', E.Message);
  end;
end;

procedure TSceneTown.Render;
var
  LAirportLevel: Integer;
  LRace: TRaceEnum;
begin
  DrawMap(Self.ScreenWidth, Self.ScreenHeight - 1);

  DrawFrame(6, 6, 68, 17);

  FTown := TTownIndustry(Game.Map.Industry[Game.Map.CurrentIndustry]);

  DrawTitle(8, FTown.Name);
  terminal_color(TPalette.Default);
  DrawText(8, 10, 'Population: ' + IntToStr(FTown.Population));
  DrawText(8, 11, 'Houses: ' + IntToStr(FTown.Houses));
  for LRace := Low(TRaceEnum) to High(TRaceEnum) do
    DrawText(8, Ord(LRace) + 13, GameRaceStr[LRace] + ': ' +
      IntToStr(FTown.GetRacePop(LRace)) + '%');
  // Airport
  LAirportLevel := Math.EnsureRange(FTown.Airport.Level, 1, 5);
  DrawButton(33, 10, 40, FTown.Airport.IsBuilding, FTown.Airport.IsBuilding,
    'A', AirportSizeStr[LAirportLevel]);
  // Dock
  DrawButton(33, 11, 40, FTown.Dock.IsBuilding, FTown.Dock.IsBuilding,
    'D', 'Dock');
  // Bus Station
  DrawButton(33, 12, 40, FTown.BusStation.IsBuilding,
    FTown.BusStation.IsBuilding, 'S', 'Bus Station');
  // Truck Loading Bay
  DrawButton(33, 13, 40, FTown.TruckLoadingBay.IsBuilding,
    FTown.TruckLoadingBay.IsBuilding, 'L', 'Truck Loading Bay');
  // Train Station
  DrawButton(33, 14, 40, FTown.TrainStation.IsBuilding,
    FTown.TrainStation.IsBuilding, 'T', 'Train Station');
  // Company Headquarters
  if Game.Company.IsTownHQ then
    DrawButton(33, 15, 40, FTown.HQ.IsBuilding, FTown.HQ.IsBuilding, 'G',
      'Company Headquarters');
  terminal_color(TPalette.Default);

  TSceneIndustry(Scenes.GetScene(scIndustry)).IndustryInfo(FTown, 8, 18);

  AddButton(20, '<', 'Prev');
  AddButton(20, 'N', 'Towns');
  AddButton(20, 'ESC', 'Close');
  AddButton(20, 'B', 'Build');
  AddButton(20, '>', 'Next');

  DrawGameBar;
end;

procedure TSceneTown.Update(var AKey: word);
begin
  if (AKey = TK_MOUSE_LEFT) then
  begin
    if (GetButtonsY = MY) then
    begin
      case MX of
        12 .. 19:
          AKey := TK_LEFT;
        23 .. 31:
          AKey := TK_N;
        35 .. 45:
          AKey := TK_ESCAPE;
        49 .. 57:
          AKey := TK_B;
        61 .. 68:
          AKey := TK_RIGHT;
      end;
    end;
    case MX of
      34 .. 69:
        case MY of
          10:
            AKey := TK_A;
          11:
            AKey := TK_D;
          12:
            AKey := TK_S;
          13:
            AKey := TK_L;
          14:
            AKey := TK_T;
          15:
            AKey := TK_G;
        end;
    end;
  end;
  case AKey of
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
    TK_T:
      if FTown.TrainStation.IsBuilding then
        Scenes.SetScene(scTrainStation, scTown);
    TK_G:
      if Game.Company.IsTownHQ and FTown.HQ.IsBuilding then
        Scenes.SetScene(scCompany, scTown);
    TK_N:
      Scenes.SetScene(scTowns);
    TK_LEFT:
      PrevTown;
    TK_RIGHT:
      NextTown;
  end;
end;

end.
