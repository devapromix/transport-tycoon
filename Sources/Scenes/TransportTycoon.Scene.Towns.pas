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
  SysUtils,
  BearLibTerminal,
  TransportTycoon.Game,
  TransportTycoon.Map;

procedure TSceneTowns.Render;
var
  I: Integer;
begin
  DrawMap(Self.Width, Self.Height - 1);

  DrawFrame(25, 4, 30, 21);

  DrawTitle(6, 'TOWNS');

  for I := 0 to Length(Game.Map.Town) - 1 do
  begin
    if (Game.Company.TownID = I) then
      DrawButton(27, I + 8, Chr(Ord('A') + I),
        Format('%s (%d)', [Game.Map.Town[I].Name, Game.Map.Town[I].Population]
        ), 'yellow')
    else
      DrawButton(27, I + 8, Chr(Ord('A') + I),
        Format('%s (%d)', [Game.Map.Town[I].Name,
        Game.Map.Town[I].Population]));
  end;

  DrawText(20, Format('World population: %d', [Game.Map.WorldPop]));

  AddButton(22, 'Esc', 'Close');

  DrawBar;
end;

procedure TSceneTowns.Update(var Key: Word);
var
  I: Integer;
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
      with Game.Map do
      begin
        I := Key - TK_A;
        if (I < Length(Town)) then
        begin
          CurrentCity := I;
          ScrollTo(Town[I].X, Town[I].Y);
          Scenes.SetScene(scCity);
        end;
      end;
  end;
end;

end.
