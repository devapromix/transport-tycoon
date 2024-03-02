unit TransportTycoon.Scene.Towns;

interface

uses
  TransportTycoon.Scenes;

type
  TSceneTowns = class(TScene)
  private

  public
    procedure Render; override;
    procedure Update(var AKey: Word); override;
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
  LIndustryIndex: Integer;
  LTown: TTownIndustry;
  LTownName: string;
begin
  DrawMap(Self.ScreenWidth, Self.ScreenHeight - 1);

  DrawFrame('TOWNS', 30, 22, True);

  for LIndustryIndex := 0 to Length(Game.Map.Industry) - 1 do
    if (Game.Map.Industry[LIndustryIndex].IndustryType = inTown) then
    begin
      LTown := TTownIndustry(Game.Map.Industry[LIndustryIndex]);
      LTownName := StrLim(LTown.Name, 15);
      if (Game.Company.TownIndex = LIndustryIndex) then
        DrawButton(27, LIndustryIndex + 8, Chr(Ord('A') + LIndustryIndex),
          Format('%s (%d)', [LTownName, LTown.Population]), 'yellow')
      else
        DrawButton(27, LIndustryIndex + 8, Chr(Ord('A') + LIndustryIndex),
          Format('%s (%d)', [LTownName, LTown.Population]));
    end;

  DrawText(21, Format('World population: %d', [Game.Map.WorldPop]));

  DrawGameBar;
end;

procedure TSceneTowns.Update(var AKey: Word);
var
  LIndustryIndex: Integer;
begin
  if (AKey = TK_MOUSE_LEFT) then
  begin
    case MX of
      27 .. 51:
        case MY of
          8 .. 18:
            AKey := TK_A + (MY - 8);
        end;
    end;
    if (GetButtonsY = MY) then
      case MX of
        35 .. 45:
          AKey := TK_ESCAPE;
      end;
  end;
  case AKey of
    TK_ESCAPE:
      Scenes.SetScene(scWorld);
    TK_A .. TK_K:
      with Game.Map do
      begin
        LIndustryIndex := AKey - TK_A;
        if (LIndustryIndex < TownCount) then
        begin
          CurrentIndustry := LIndustryIndex;
          ScrollTo(Industry[CurrentIndustry].X, Industry[CurrentIndustry].Y);
          Scenes.SetScene(scTown);
        end;
      end;
  end;
end;

end.
