unit TransportTycoon.Scene.Company;

interface

uses
  TransportTycoon.Scenes;

type
  TSceneCompany = class(TScene)
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
  TransportTycoon.Industries,
  TransportTycoon.Company;

procedure TSceneCompany.Render;
begin
  DrawMap(Self.ScreenWidth, Self.ScreenHeight - 1);

  DrawFrame(20, 8, 40, 14);
  DrawTitle(10, Game.Company.Name);
  DrawText(22, 12, 'Inavgurated: ' + IntToStr(Game.Company.Inavgurated));

  DrawText(22, 14, 'Roads: ' + IntToStr(Game.Company.Stat.GetStat(seRoad)));
  DrawText(22, 15, 'Tunnels: ' + IntToStr(Game.Company.Stat.GetStat(seTunnel)));

  if TTownIndustry(Game.Map.Industry[Game.Company.TownID]).HQ.IsBuilding then
    DrawText(22, 17, 'Company headquarters in ' + Game.Map.Industry
      [Game.Company.TownID].Name);

  AddButton(19, 'Esc', 'Close');

  DrawBar;
end;

procedure TSceneCompany.Update(var Key: Word);
begin
  if (Key = TK_MOUSE_LEFT) then
  begin
    if (GetButtonsY = MY) then
    begin
      case MX of
        35 .. 45:
          Key := TK_ESCAPE;
      end;
    end;
  end;
  case Key of
    TK_ESCAPE:
      Scenes.Back;
  end;
end;

end.
