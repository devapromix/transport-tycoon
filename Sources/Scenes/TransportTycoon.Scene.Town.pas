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
  BearLibTerminal,
  SysUtils,
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
  DrawButton(34, 12, C.Airport > 0, 'A', 'Airport: ' + AirportSizeStr
    [C.Airport]);
  if (Game.Map.CurrentTown = Game.Company.TownID) and
    (Game.Map.Town[Game.Map.CurrentTown].CompanyHeadquarters > 0) then
    DrawButton(34, 16, 'G', 'Company Headquarters');
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
        16:
          Key := TK_G;
      end;
  end;
  case Key of
    TK_ESCAPE:
      Scenes.SetScene(scWorld);
    TK_A:
      if (C.Airport > 0) then
        Scenes.SetScene(scAirport);
    TK_B:
      Scenes.SetScene(scBuildInTown);
    TK_G:
      if (Game.Map.CurrentTown = Game.Company.TownID) and
        (Game.Map.Town[Game.Map.CurrentTown].CompanyHeadquarters > 0) then
        Scenes.SetScene(scCompany);
  end;
end;

end.
