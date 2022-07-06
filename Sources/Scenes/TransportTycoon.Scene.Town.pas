unit TransportTycoon.Scene.Town;

interface

uses
  TransportTycoon.Scenes,
  TransportTycoon.Industries;

type

  { TSceneTown }

  TSceneTown = class(TScene)
  private
    FTown: TTownIndustry;
  public
    procedure Render; override;
    procedure Update(var Key: word); override;
  end;

implementation

uses
  SysUtils,
  BearLibTerminal,
  TransportTycoon.Game,
  TransportTycoon.Scene.Industry;

{ TSceneTown }

procedure TSceneTown.Render;
begin
  DrawMap(Self.Width, Self.Height - 1);

  DrawFrame(10, 6, 60, 17);

  FTown := TTownIndustry(Game.Map.Industry[Game.Map.CurrentIndustry]);

  DrawTitle(8, FTown.Name);
  terminal_color('white');
  DrawText(12, 10, 'Population: ' + IntToStr(FTown.Population));
  DrawText(12, 11, 'Houses: ' + IntToStr(FTown.Houses));
  DrawButton(34, 10, FTown.Airport.IsBuilding, 'A',
    'Airport: ' + AirportSizeStr[FTown.Airport.Level]);
  DrawButton(34, 11, FTown.Dock.IsBuilding, 'D',
    'Dock: ' + DockSizeStr[FTown.Dock.Level]);
  if (Game.Map.CurrentIndustry = Game.Company.TownID) then
    DrawButton(34, 15, FTown.HQ.IsBuilding, 'G', 'Company Headquarters');
  terminal_color('white');

  TSceneIndustry(Scenes.GetScene(scIndustry)).IndustryInfo(FTown, 12, 18);

  AddButton(20, 'B', 'Build');
  AddButton(20, 'ESC', 'Close');

  DrawBar;
end;

procedure TSceneTown.Update(var Key: word);
begin
  if (Key = TK_MOUSE_LEFT) then
  begin
    if (MX >= 29) and (MX <= 37) then
      case MY of
        20:
          Key := TK_B;
      end;
    if (MX >= 41) and (MX <= 51) then
      case MY of
        20:
          Key := TK_ESCAPE;
      end;
    if (MX >= 34) and (MX <= 69) then
      case MY of
        10:
          Key := TK_A;
        11:
          Key := TK_D;
        15:
          Key := TK_G;
      end;
  end;
  case Key of
    TK_ESCAPE:
      Scenes.SetScene(scWorld);
    TK_A:
      if FTown.Airport.IsBuilding then
        Scenes.SetScene(scAirport, scTown);
    TK_B:
      Scenes.SetScene(scBuildInTown);
    TK_D:
      if FTown.Dock.IsBuilding then
        Scenes.SetScene(scDock, scTown);
    TK_G:
      if (Game.Map.CurrentIndustry = Game.Company.TownID) and FTown.HQ.IsBuilding
      then
        Scenes.SetScene(scCompany, scTown);
  end;
end;

end.
