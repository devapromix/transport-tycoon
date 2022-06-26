﻿program TransportTycoon;

uses
  SysUtils,
  BearLibTerminal in 'Third-Party\BearLibTerminal\BearLibTerminal.pas',
  TransportTycoon.Map in 'Game\TransportTycoon.Map.pas',
  TransportTycoon.Game in 'Game\TransportTycoon.Game.pas',
  TransportTycoon.Town in 'Game\TransportTycoon.Town.pas',
  TransportTycoon.Company in 'Game\TransportTycoon.Company.pas',
  TransportTycoon.Finances in 'Game\TransportTycoon.Finances.pas',
  TransportTycoon.Order in 'Game\TransportTycoon.Order.pas',
  TransportTycoon.Vehicle in 'Game\TransportTycoon.Vehicle.pas',
  TransportTycoon.Vehicles in 'Game\TransportTycoon.Vehicles.pas',
  TransportTycoon.Aircraft in 'Game\TransportTycoon.Aircraft.pas',
  TransportTycoon.Scenes in 'Scenes\TransportTycoon.Scenes.pas',
  TransportTycoon.Scene.Town in 'Scenes\TransportTycoon.Scene.Town.pas',
  TransportTycoon.Scene.BuildInTown
    in 'Scenes\TransportTycoon.Scene.BuildInTown.pas',
  TransportTycoon.Scene.World in 'Scenes\TransportTycoon.Scene.World.pas',
  TransportTycoon.Scene.Airport in 'Scenes\TransportTycoon.Scene.Airport.pas',
  TransportTycoon.Scene.MainMenu in 'Scenes\TransportTycoon.Scene.MainMenu.pas',
  TransportTycoon.Scene.GenMenu in 'Scenes\TransportTycoon.Scene.GenMenu.pas',
  TransportTycoon.Scene.GameMenu in 'Scenes\TransportTycoon.Scene.GameMenu.pas',
  TransportTycoon.Scene.Hangar in 'Scenes\TransportTycoon.Scene.Hangar.pas',
  TransportTycoon.Scene.Aircraft in 'Scenes\TransportTycoon.Scene.Aircraft.pas',
  TransportTycoon.Scene.Orders in 'Scenes\TransportTycoon.Scene.Orders.pas',
  TransportTycoon.Scene.Aircrafts
    in 'Scenes\TransportTycoon.Scene.Aircrafts.pas',
  TransportTycoon.Scene.Finances in 'Scenes\TransportTycoon.Scene.Finances.pas',
  TransportTycoon.Scene.Towns in 'Scenes\TransportTycoon.Scene.Towns.pas',
  TransportTycoon.Scene.Company in 'Scenes\TransportTycoon.Scene.Company.pas',
  TransportTycoon.Calendar in 'Game\TransportTycoon.Calendar.pas',
  TransportTycoon.MapObject in 'Game\TransportTycoon.MapObject.pas',
  TransportTycoon.PathFind in 'Game\TransportTycoon.PathFind.pas',
  TransportTycoon.Industries in 'Game\TransportTycoon.Industries.pas',
  TransportTycoon.Scene.Industry in 'Scenes\TransportTycoon.Scene.Industry.pas',
  TransportTycoon.Scene.BuildNearIndustry
    in 'Scenes\TransportTycoon.Scene.BuildNearIndustry.pas',
  TransportTycoon.Scene.Dock in 'Scenes\TransportTycoon.Scene.Dock.pas',
  TransportTycoon.Ship in 'Game\TransportTycoon.Ship.pas',
  TransportTycoon.Stations in 'Game\TransportTycoon.Stations.pas';

var
  Key: Word = 0;
  Tmp: Word = 0;

begin
  Randomize();
  terminal_open();
  terminal_set('window: size=80x30, title="Transport Tycoon v.' +
    Game.Version + '";');
  terminal_set('input: filter={keyboard, mouse+}');
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
      if (Tmp > 25) then
      begin
        Tmp := 0;
        Game.Step;
      end;
    until (Key = TK_CLOSE);
    terminal_close();
  finally
    Scenes.Free;
  end;

end.
