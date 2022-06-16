unit TransportTycoon.Scene.Towns;

interface

uses
  TransportTycoon.Scenes;

type
  TSceneTowns = class(TScene)
  private
    procedure ScrollTo(const X, Y: Integer);
  public
    procedure Render; override;
    procedure Update(var Key: Word); override;
  end;

implementation

uses
  Math,
  SysUtils,
  BearLibTerminal,
  TransportTycoon.Game,
  TransportTycoon.Map;

procedure TSceneTowns.ScrollTo(const X, Y: Integer);
begin
  Game.Map.Left := EnsureRange(X - (Width div 2), 0, Game.Map.Width - Width);
  Game.Map.Top := EnsureRange(Y - (Height div 2), 0, Game.Map.Height - Height);
end;

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
        if (I < Length(City)) then
        begin
          CurrentCity := I;
          ScrollTo(City[I].X, City[I].Y);
          Scenes.SetScene(scCity);
        end;
      end;
  end;
end;

end.
