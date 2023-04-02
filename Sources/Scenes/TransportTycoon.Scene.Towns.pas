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
  LTown: TTownIndustry;
begin
  DrawMap(Self.ScreenWidth, Self.ScreenHeight - 1);

  DrawFrame(25, 4, 30, 21);

  DrawTitle(6, 'TOWNS');

  for I := 0 to Length(Game.Map.Industry) - 1 do
    if (Game.Map.Industry[I].IndustryType = inTown) then
    begin
      LTown := TTownIndustry(Game.Map.Industry[I]);
      if (Game.Company.TownID = I) then
        DrawButton(27, I + 8, Chr(Ord('A') + I),
          Format('%s (%d)', [LTown.Name, LTown.Population]), 'yellow')
      else
        DrawButton(27, I + 8, Chr(Ord('A') + I),
          Format('%s (%d)', [LTown.Name, LTown.Population]));
    end;

  DrawText(20, Format('World population: %d', [Game.Map.WorldPop]));

  AddButton(22, 'Esc', 'Close');

  DrawGameBar;
end;

procedure TSceneTowns.Update(var Key: Word);
var
  I: Integer;
begin
  if (Key = TK_MOUSE_LEFT) then
  begin
    case MX of
      27 .. 51:
        case MY of
          8 .. 18:
            Key := TK_A + (MY - 8);
        end;
    end;
    if (GetButtonsY = MY) then
      case MX of
        35 .. 45:
          Key := TK_ESCAPE;
      end;
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
          CurrentIndustry := I;
          ScrollTo(Industry[I].X, Industry[I].Y);
          Scenes.SetScene(scTown);
        end;
      end;
  end;
end;

end.
