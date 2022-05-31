program TransportTycoon;

uses
  SysUtils,
  BearLibTerminal in 'Third-Party\BearLibTerminal\BearLibTerminal.pas',
  TransportTycoon.Map in 'Game\TransportTycoon.Map.pas',
  TransportTycoon.Game in 'Game\TransportTycoon.Game.pas',
  TransportTycoon.Scenes in 'Scenes\TransportTycoon.Scenes.pas',
  TransportTycoon.Scene.City in 'Scenes\TransportTycoon.Scene.City.pas',
  TransportTycoon.Scene.BuildInCity in 'Scenes\TransportTycoon.Scene.BuildInCity.pas',
  TransportTycoon.Scene.World in 'Scenes\TransportTycoon.Scene.World.pas',
  TransportTycoon.City in 'Game\TransportTycoon.City.pas',
  TransportTycoon.Scene.Airport in 'Scenes\TransportTycoon.Scene.Airport.pas',
  TransportTycoon.Scene.Menu in 'Scenes\TransportTycoon.Scene.Menu.pas',
  TransportTycoon.Scene.Gen in 'Scenes\TransportTycoon.Scene.Gen.pas';

var
  Key: Word = 0;
  Tmp: Word = 0;

begin
  Randomize;
  terminal_open();
  terminal_set('window: size=80x25, title="Transport Tycoon";');
  terminal_set('input: filter={keyboard, mouse+}');
  Scenes := TScenes.Create;
  Scenes.SetScene(scMenu);
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
