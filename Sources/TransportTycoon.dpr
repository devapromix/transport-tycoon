program TransportTycoon;

uses
  SysUtils,
  BearLibTerminal in 'Third-Party\BearLibTerminal\BearLibTerminal.pas',
  TransportTycoon.Map in 'Game\TransportTycoon.Map.pas',
  TransportTycoon.Game in 'Game\TransportTycoon.Game.pas',
  TransportTycoon.City in 'Game\TransportTycoon.City.pas',
  TransportTycoon.Company in 'Game\TransportTycoon.Company.pas',
  TransportTycoon.Finances in 'Game\TransportTycoon.Finances.pas',
  TransportTycoon.Order in 'Game\TransportTycoon.Order.pas',
  TransportTycoon.Vehicle in 'Game\TransportTycoon.Vehicle.pas',
  TransportTycoon.Vehicles in 'Game\TransportTycoon.Vehicles.pas',
  TransportTycoon.Aircraft in 'Game\TransportTycoon.Aircraft.pas',
  TransportTycoon.Scenes in 'Scenes\TransportTycoon.Scenes.pas',
  TransportTycoon.Scene.City in 'Scenes\TransportTycoon.Scene.City.pas',
  TransportTycoon.Scene.BuildInCity in 'Scenes\TransportTycoon.Scene.BuildInCity.pas',
  TransportTycoon.Scene.World in 'Scenes\TransportTycoon.Scene.World.pas',
  TransportTycoon.Scene.Airport in 'Scenes\TransportTycoon.Scene.Airport.pas',
  TransportTycoon.Scene.MainMenu in 'Scenes\TransportTycoon.Scene.MainMenu.pas',
  TransportTycoon.Scene.Gen in 'Scenes\TransportTycoon.Scene.Gen.pas',
  TransportTycoon.Scene.GameMenu in 'Scenes\TransportTycoon.Scene.GameMenu.pas',
  TransportTycoon.Scene.Hangar in 'Scenes\TransportTycoon.Scene.Hangar.pas',
  TransportTycoon.Scene.Aircraft in 'Scenes\TransportTycoon.Scene.Aircraft.pas',
  TransportTycoon.Scene.Orders in 'Scenes\TransportTycoon.Scene.Orders.pas',
  TransportTycoon.Scene.Aircrafts in 'Scenes\TransportTycoon.Scene.Aircrafts.pas',
  TransportTycoon.Scene.Finances in 'Scenes\TransportTycoon.Scene.Finances.pas',
  TransportTycoon.Scene.Towns in 'Scenes\TransportTycoon.Scene.Towns.pas',
  TransportTycoon.Scene.Company in 'Scenes\TransportTycoon.Scene.Company.pas';

var
  Key: Word = 0;
  Tmp: Word = 0;

begin
  Randomize;
  terminal_open();
  terminal_set('window: size=80x30, title="Transport Tycoon";');
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
