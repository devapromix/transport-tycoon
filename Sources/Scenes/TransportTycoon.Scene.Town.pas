unit TransportTycoon.Scene.Town;

interface

uses
  TransportTycoon.Scenes;

type
  TSceneTown = class(TScene)
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
  TransportTycoon.Town;

procedure TSceneTown.Render;
var
  C: TTown;
begin
  DrawMap(Self.Width, Self.Height - 1);

  DrawFrame(10, 8, 60, 13);

  C := Game.Map.Town[Game.Map.CurrentTown];
  DrawTitle(10, C.Name);
  terminal_color('white');
  DrawText(12, 12, 'Population: ' + IntToStr(C.Population));
  DrawText(12, 13, 'Houses: ' + IntToStr(C.Houses));
  DrawButton(34, 12, C.Airport.HasBuilding, 'A',
    'Airport: ' + AirportSizeStr[C.Airport.Level]);
  DrawButton(34, 13, C.Dock.HasBuilding, 'D',
    'Dock: ' + DockSizeStr[C.Dock.Level]);
  if (Game.Map.CurrentTown = Game.Company.TownID) then
    DrawButton(34, 16, Game.Map.Town[Game.Map.CurrentTown].HQ.HasBuilding, 'G',
      'Company Headquarters');
  terminal_color('white');

  AddButton(18, 'B', 'Build');
  AddButton(18, 'ESC', 'Close');

  DrawBar;
end;

procedure TSceneTown.Update(var Key: word);
var
  C: TTown;
begin
  C := Game.Map.Town[Game.Map.CurrentTown];
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
      if C.Airport.HasBuilding then
        Scenes.SetScene(scAirport, scTown);
    TK_B:
      Scenes.SetScene(scBuildInTown);
    TK_D:
      if C.Dock.HasBuilding then
        Scenes.SetScene(scDock, scTown);
    TK_G:
      if (Game.Map.CurrentTown = Game.Company.TownID) and
        Game.Map.Town[Game.Map.CurrentTown].HQ.HasBuilding then
        Scenes.SetScene(scCompany, scTown);
  end;
end;

end.
