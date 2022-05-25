program TransportTycoon;

uses
  SysUtils,
  BearLibTerminal in 'Sources\Third-Party\BearLibTerminal\BearLibTerminal.pas',
  TransportTycoon.Game in 'Game\TransportTycoon.Game.pas',
  TransportTycoon.Scenes in 'Scenes\TransportTycoon.Scenes.pas';

var
  Key: Word = 0;
  Tmp: Word = 0;

begin
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
        Inc(Turn);
      end;
    until (Key = TK_CLOSE);
    terminal_close();
  finally
    Scenes.Free;
  end;

end.
