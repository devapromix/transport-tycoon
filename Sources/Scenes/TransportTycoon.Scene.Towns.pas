unit TransportTycoon.Scene.Towns;

interface

uses
  TransportTycoon.Scenes;

type
  TSceneTowns = class(TScene)
  private

  public
    procedure Render; override;
    procedure Update(var Key: Word); override;
  end;

implementation

uses
  BearLibTerminal,
  SysUtils,
  TransportTycoon.Game,
  TransportTycoon.Map;

procedure TSceneTowns.Render;
var
  I: Integer;
begin
  DrawMap(Self.Width, Self.Height - 1);

  DrawFrame(25, 4, 30, 21);

  DrawTitle(6, 'TOWNS');

  for I := 0 to Length(Game.Map.City) - 1 do
    DrawButton(27, I + 8, Chr(Ord('A') + I),
      Format('%s (%d)', [Game.Map.City[I].Name, Game.Map.City[I].Population]));

  DrawText(20, Format('World population: %d', [Game.Map.WorldPop]));

  AddButton(22, 'Esc', 'Close');

  DrawBar;
end;

procedure TSceneTowns.Update(var Key: Word);
begin
  if (Key = TK_MOUSE_LEFT) then
  begin
    if (MX >= 27) and (MX <= 51) then
      case MY of
        8 .. 18:
          Key := TK_A + (MY - 8);
      end;
    if (GetButtonsY = MY) then
      if (MX >= 35) and (MX <= 45) then
        Key := TK_ESCAPE;
  end;
  case Key of
    TK_ESCAPE:
      Scenes.SetScene(scWorld);
    TK_A .. TK_K:
      begin
        if (Key - TK_A < Length(Game.Map.City)) then
        begin
          Game.Map.CurrentCity := Key - TK_A;
          Scenes.SetScene(scCity);
        end;
      end;
  end;
end;

end.
