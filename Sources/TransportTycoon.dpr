program TransportTycoon;

uses
  SysUtils,
  BearLibTerminal in 'Third-Party\BearLibTerminal\BearLibTerminal.pas',
  TransportTycoon.Map in 'Game\TransportTycoon.Map.pas',
  TransportTycoon.Game in 'Game\TransportTycoon.Game.pas',
  TransportTycoon.Cargo in 'Game\TransportTycoon.Cargo.pas',
  TransportTycoon.Company in 'Game\TransportTycoon.Company.pas',
  TransportTycoon.Finances in 'Game\TransportTycoon.Finances.pas',
  TransportTycoon.Order in 'Game\TransportTycoon.Order.pas',
  TransportTycoon.Vehicle in 'Game\TransportTycoon.Vehicle.pas',
  TransportTycoon.Vehicles in 'Game\TransportTycoon.Vehicles.pas',
  TransportTycoon.Aircraft in 'Game\TransportTycoon.Aircraft.pas',
  TransportTycoon.Ship in 'Game\TransportTycoon.Ship.pas',
  TransportTycoon.Construct in 'Game\TransportTycoon.Construct.pas',
  TransportTycoon.Calendar in 'Game\TransportTycoon.Calendar.pas',
  TransportTycoon.MapObject in 'Game\TransportTycoon.MapObject.pas',
  TransportTycoon.PathFind in 'Game\TransportTycoon.PathFind.pas',
  TransportTycoon.Stations in 'Game\TransportTycoon.Stations.pas',
  TransportTycoon.Industries in 'Game\TransportTycoon.Industries.pas',
  TransportTycoon.Scenes in 'Scenes\TransportTycoon.Scenes.pas',
  TransportTycoon.Scene.Menu.Build in 'Scenes\TransportTycoon.Scene.Menu.Build.pas',
  TransportTycoon.Scene.BuildInTown in 'Scenes\TransportTycoon.Scene.BuildInTown.pas',
  TransportTycoon.Scene.World in 'Scenes\TransportTycoon.Scene.World.pas',
  TransportTycoon.Scene.Airport in 'Scenes\TransportTycoon.Scene.Airport.pas',
  TransportTycoon.Scene.Menu.Main in 'Scenes\TransportTycoon.Scene.Menu.Main.pas',
  TransportTycoon.Scene.Menu.Game in 'Scenes\TransportTycoon.Scene.Menu.Game.pas',
  TransportTycoon.Scene.AircraftHangar in 'Scenes\TransportTycoon.Scene.AircraftHangar.pas',
  TransportTycoon.Scene.Aircraft in 'Scenes\TransportTycoon.Scene.Aircraft.pas',
  TransportTycoon.Scene.Aircrafts in 'Scenes\TransportTycoon.Scene.Aircrafts.pas',
  TransportTycoon.Scene.Finances in 'Scenes\TransportTycoon.Scene.Finances.pas',
  TransportTycoon.Scene.Towns in 'Scenes\TransportTycoon.Scene.Towns.pas',
  TransportTycoon.Scene.Company in 'Scenes\TransportTycoon.Scene.Company.pas',
  TransportTycoon.Scene.Industry in 'Scenes\TransportTycoon.Scene.Industry.pas',
  TransportTycoon.Scene.BuildNearIndustry in 'Scenes\TransportTycoon.Scene.BuildNearIndustry.pas',
  TransportTycoon.Scene.Dock in 'Scenes\TransportTycoon.Scene.Dock.pas',
  TransportTycoon.Scene.Ships in 'Scenes\TransportTycoon.Scene.Ships.pas',
  TransportTycoon.Scene.Ship in 'Scenes\TransportTycoon.Scene.Ship.pas',
  TransportTycoon.Scene.Vehicles in 'Scenes\TransportTycoon.Scene.Vehicles.pas',
  TransportTycoon.Scene.ShipDepot in 'Scenes\TransportTycoon.Scene.ShipDepot.pas',
  TransportTycoon.Scene.Town in 'Scenes\TransportTycoon.Scene.Town.pas',
  TransportTycoon.Scene.Industries in 'Scenes\TransportTycoon.Scene.Industries.pas',
  TransportTycoon.Scene.Menu.Gen in 'Scenes\TransportTycoon.Scene.Menu.Gen.pas',
  TransportTycoon.Scene.Menu.Settings in 'Scenes\TransportTycoon.Scene.Menu.Settings.pas',
  TransportTycoon.Scene.Menu.OpenGame in 'Scenes\TransportTycoon.Scene.Menu.OpenGame.pas',
  TransportTycoon.RoadVehicle in 'Game\TransportTycoon.RoadVehicle.pas',
  TransportTycoon.Scene.BusStation in 'Scenes\TransportTycoon.Scene.BusStation.pas',
  TransportTycoon.Scene.RoadVehicle in 'Scenes\TransportTycoon.Scene.RoadVehicle.pas',
  TransportTycoon.Scene.RoadVehicleDepot in 'Scenes\TransportTycoon.Scene.RoadVehicleDepot.pas',
  TransportTycoon.Scene.TruckLoadingBay in 'Scenes\TransportTycoon.Scene.TruckLoadingBay.pas',
  TransportTycoon.Scene.RoadVehicles in 'Scenes\TransportTycoon.Scene.RoadVehicles.pas',
  TransportTycoon.Scene.VehicleDepot in 'Scenes\TransportTycoon.Scene.VehicleDepot.pas',
  TransportTycoon.Palette in 'Game\TransportTycoon.Palette.pas',
  TransportTycoon.Scene.Vehicle in 'Scenes\TransportTycoon.Scene.Vehicle.pas',
  TransportTycoon.Scene.Station in 'Scenes\TransportTycoon.Scene.Station.pas',
  TransportTycoon.Log in 'Game\TransportTycoon.Log.pas',
  TransportTycoon.Scene.Menu.SaveGame in 'Scenes\TransportTycoon.Scene.Menu.SaveGame.pas';

var
  Key: Word = 0;
  Tmp: Word = 0;

begin
{$IFDEF DEBUG}
{$IF CompilerVersion > 16}
{$WARN SYMBOL_PLATFORM OFF}
  ReportMemoryLeaksOnShutdown := DebugHook <> 0;
{$IFEND}
{$ENDIF}
  Randomize();
  terminal_open();
  terminal_set('window: size=80x30, title="Transport Tycoon v.' +
    Game.Version + '";');
  terminal_set('input: filter={keyboard, mouse+}');
  Game := TGame.Create;
  Scenes := TScenes.Create;
  Scenes.SetScene(scMainMenu);
  try
    Scenes.Render;
    terminal_refresh();
    repeat
      Scenes.Render;
      Key := 0;
      if terminal_has_input() then
      begin
        Key := terminal_read();
        Scenes.Update(Key);
        Continue;
      end;
      terminal_refresh();
      terminal_delay(25);
      Inc(Tmp);
      if (Tmp > GameSpeedValue[Game.Speed]) then
      begin
        Tmp := 0;
        Game.Step;
      end;
    until (Key = TK_CLOSE);
    terminal_close();
  finally
    FreeAndNil(Scenes);
    FreeAndNil(Game);
  end;

end.
