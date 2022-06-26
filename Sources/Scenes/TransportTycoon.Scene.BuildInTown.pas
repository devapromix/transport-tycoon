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

procedure TSceneBuildInTown.Render;
var
  Town: TTown;
  N: Integer;
  S: string;
  F: Boolean;
begin
  DrawMap(Self.Width, Self.Height - 1);

  DrawFrame(15, 7, 50, 15);

  Town := Game.Map.Town[Game.Map.CurrentTown];
  DrawTitle('BUILD IN ' + Town.Name);

  S := '';
  N := Math.EnsureRange(Town.Airport.Level + 1, 0, 5);
  if Town.Airport.Level < 5 then
    S := ' ($' + IntToStr(Town.Airport.Cost) + ')';
  DrawButton(17, 11, Town.Airport.CanBuild, 'A',
    'Build ' + AirportSizeStr[N] + S);

  S := '';
  F := (Game.Money >= Town.DockCost) and (Town.Dock = 0);
  if Town.Dock = 0 then
    S := ' ($' + IntToStr(Town.DockCost) + ')';
  DrawButton(17, 12, F, 'B', 'Build Dock' + S);

  if (Game.Money >= TTown.HQCost) and (Town.CompanyHeadquarters = 0) and
    (Game.Map.CurrentTown = Game.Company.TownID) then
    DrawButton(17, 17, 'G', 'Build Company Headquarters ($' +
      IntToStr(TTown.HQCost) + ')');

  AddButton(19, 'Esc', 'Close');

  DrawBar;
end;

procedure TSceneBuildInTown.Update(var Key: Word);
var
  Town: TTown;
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
        Town := Game.Map.Town[Game.Map.CurrentTown];
        if Town.Airport.CanBuild then
        begin
          Town.Airport.Build;
          Scenes.SetScene(scAirport);
        end;
      end;
    TK_B:
      begin
        Town := Game.Map.Town[Game.Map.CurrentTown];
        if (Game.Money >= Town.DockCost) and (Town.Dock = 0) then
        begin
          Town.BuildDock;
          Scenes.SetScene(scDock);
        end;
      end;
    TK_G:
      begin
        Town := Game.Map.Town[Game.Map.CurrentTown];
        if (Game.Map.CurrentTown = Game.Company.TownID) and
          (Game.Money >= TTown.HQCost) and (Town.CompanyHeadquarters = 0) then
        begin
          Town.BuildCompanyHeadquarters;
          Scenes.SetScene(scCompany);
        end;
      end;
  end;
end;

end.
