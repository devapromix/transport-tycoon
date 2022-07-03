unit TransportTycoon.Scene.Town2;

interface

uses
  TransportTycoon.Scenes,
  TransportTycoon.Industries;

type

  { TSceneTown2 }

  TSceneTown2 = class(TScene)
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
  TransportTycoon.Town;

{ TSceneTown2 }

procedure TSceneTown2.Render;
begin
  DrawMap(Self.Width, Self.Height - 1);

  DrawFrame(10, 8, 60, 13);

  FTown := TTownIndustry(Game.Map.Industry[Game.Map.CurrentIndustry]);

  DrawTitle(10, FTown.Name + '***');
  terminal_color('white');
  DrawText(12, 12, 'Population: ' + IntToStr(FTown.Population));
  DrawText(12, 13, 'Houses: ' + IntToStr(FTown.Houses));
  DrawButton(34, 12, FTown.Airport.HasBuilding, 'A',
    'Airport: ' + AirportSizeStr[FTown.Airport.Level]);
  DrawButton(34, 13, FTown.Dock.HasBuilding, 'D',
    'Dock: ' + DockSizeStr[FTown.Dock.Level]);
  if (Game.Map.CurrentIndustry = Game.Company.TownID) then
    DrawButton(34, 16, FTown.HQ.HasBuilding, 'G', 'Company Headquarters');
  terminal_color('white');

  AddButton(18, 'B', 'Build');
  AddButton(18, 'ESC', 'Close');

  DrawBar;
end;

procedure TSceneTown2.Update(var Key: word);
begin
  if (Key = TK_MOUSE_LEFT) then
  begin
    if (MX >= 29) and (MX <= 37) then
      case MY of
        18:
          Key := TK_B;
      end;
    if (MX >= 41) and (MX <= 51) then
      case MY of
        18:
          Key := TK_ESCAPE;
      end;
    if (MX >= 34) and (MX <= 69) then
      case MY of
        12:
          Key := TK_A;
        13:
          Key := TK_D;
        16:
          Key := TK_G;
      end;
  end;
  case Key of
    TK_ESCAPE:
      Scenes.SetScene(scWorld);
    TK_A:
      if FTown.Airport.HasBuilding then
        Scenes.SetScene(scAirport, scTown);
    TK_B:
      Scenes.SetScene(scBuildInTown);
    TK_D:
      if FTown.Dock.HasBuilding then
        Scenes.SetScene(scDock, scTown);
    TK_G:
      if (Game.Map.CurrentIndustry = Game.Company.TownID) and FTown.HQ.HasBuilding
      then
        Scenes.SetScene(scCompany, scTown);
  end;
end;

end.
