unit TransportTycoon.Scene.BuildInTown;

interface

uses
  TransportTycoon.Scenes;

type

  { TSceneBuildInTown }

  TSceneBuildInTown = class(TScene)
  private

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
  TransportTycoon.Town;

{ TSceneBuildInTown }

var
  Town: TTown;

procedure TSceneBuildInTown.Render;
var
  N: Integer;
  S: string;
begin
  DrawMap(Self.Width, Self.Height - 1);

  DrawFrame(15, 7, 50, 15);

  Town := Game.Map.Town[Game.Map.CurrentTown];
  DrawTitle('BUILD IN ' + Town.Name);

  S := '';
  N := Math.EnsureRange(Town.Airport.Level + 1, 0, 5);
  if Town.Airport.Level < Town.Airport.MaxLevel then
    S := ' ($' + IntToStr(Town.Airport.Cost) + ')';
  DrawButton(17, 11, Town.Airport.CanBuild, 'A',
    'Build ' + AirportSizeStr[N] + S);

  S := '';
  if Town.Dock.Level = 0 then
    S := ' ($' + IntToStr(Town.Dock.Cost) + ')';
  DrawButton(17, 12, Town.Dock.CanBuild, 'B', 'Build Dock' + S);

  if (Game.Map.CurrentTown = Game.Company.TownID) then
    DrawButton(17, 17, Town.HQ.CanBuild, 'G', 'Build Company Headquarters ($' +
      IntToStr(Town.HQ.Cost) + ')');

  AddButton(19, 'Esc', 'Close');

  DrawBar;
end;

procedure TSceneBuildInTown.Update(var Key: Word);
begin
  if (Key = TK_MOUSE_LEFT) then
  begin
    if (MX >= 35) and (MX <= 45) then
      case MY of
        19:
          Key := TK_ESCAPE;
      end;
    if (MX >= 17) and (MX <= 62) then
      case MY of
        11:
          Key := TK_A;
        12:
          Key := TK_B;
        17:
          Key := TK_G;
      end;
  end;
  case Key of
    TK_ESCAPE:
      Scenes.SetScene(scTown);
    TK_A:
      begin
        if Town.Airport.CanBuild then
        begin
          Town.Airport.Build;
          Scenes.SetScene(scAirport, scTown);
        end;
      end;
    TK_B:
      begin
        if Town.Dock.CanBuild then
        begin
          Town.Dock.Build;
          Scenes.SetScene(scDock, scTown);
        end;
      end;
    TK_G:
      begin
        if Town.HQ.CanBuild and (Game.Map.CurrentTown = Game.Company.TownID)
        then
        begin
          Town.HQ.Build;
          Scenes.SetScene(scCompany, scTown);
        end;
      end;
  end;
end;

end.
