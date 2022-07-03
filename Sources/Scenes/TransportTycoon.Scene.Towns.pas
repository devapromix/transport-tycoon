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
  TransportTycoon.Map,
  TransportTycoon.Industries;

procedure TSceneTowns.Render;
var
  I: Integer;
  Town: TTownIndustry;
begin
  DrawMap(Self.Width, Self.Height - 1);

  DrawFrame(25, 4, 30, 21);

  DrawTitle(6, 'TOWNS');

  for I := 0 to Length(Game.Map.Industry) - 1 do
    if (Game.Map.Industry[I].IndustryType = inTown) then
    begin
      Town := TTownIndustry(Game.Map.Industry[I]);
      if (Game.Company.TownID = I) then
        DrawButton(27, I + 8, Chr(Ord('A') + I),
          Format('%s (%d)', [Town.Name, Town.Population]), 'yellow')
      else
        DrawButton(27, I + 8, Chr(Ord('A') + I),
          Format('%s (%d)', [Town.Name, Town.Population]));
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
        if (I < TownCount) then
        begin
          CurrentTown := I;
          ScrollTo(Industry[I].X, Industry[I].Y);
          Scenes.SetScene(scTown2);
        end;
      end;
  end;
end;

end.
