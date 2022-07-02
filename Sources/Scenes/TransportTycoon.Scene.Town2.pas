unit TransportTycoon.Scene.Town2;

interface

uses
  TransportTycoon.Scenes;

type

  { TSceneTown2 }

  TSceneTown2 = class(TScene)
  private

  public
    procedure Render; override;
    procedure Update(var Key: word); override;
  end;

implementation

uses
  SysUtils,
  BearLibTerminal,
  TransportTycoon.Game,
  TransportTycoon.Town,
  TransportTycoon.Industries;

{ TSceneTown2 }

var
  Town: TTownIndustry;

procedure TSceneTown2.Render;
begin
  DrawMap(Self.Width, Self.Height - 1);

  DrawFrame(10, 8, 60, 13);

  Town := TTownIndustry(Game.Map.Industry[Game.Map.CurrentTown]);

  DrawTitle(10, Town.Name + '***');
  terminal_color('white');
  DrawText(12, 12, 'Population: ' + IntToStr(Town.Population));
  DrawText(12, 13, 'Houses: ' + IntToStr(Town.Houses));
  DrawButton(34, 12, Town.Airport.HasBuilding, 'A',
    'Airport: ' + AirportSizeStr[Town.Airport.Level]);
  DrawButton(34, 13, Town.Dock.HasBuilding, 'D',
    'Dock: ' + DockSizeStr[Town.Dock.Level]);
  if (Game.Map.CurrentTown = Game.Company.TownID) then
    DrawButton(34, 16, Game.Map.Town[Game.Map.CurrentTown].HQ.HasBuilding, 'G',
      'Company Headquarters');
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
      if Town.Airport.HasBuilding then
        Scenes.SetScene(scAirport, scTown2);
    TK_B:
      Scenes.SetScene(scBuildInTown2);
    TK_D:
      if Town.Dock.HasBuilding then
        Scenes.SetScene(scDock, scTown2);
    TK_G:
      if (Game.Map.CurrentTown = Game.Company.TownID) and
        Game.Map.Town[Game.Map.CurrentTown].HQ.HasBuilding then
        Scenes.SetScene(scCompany, scTown2);
  end;
end;

end.
