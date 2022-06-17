unit TransportTycoon.Scene.BuildInCity;

interface

uses
  TransportTycoon.Scenes;

type
  TSceneBuildInCity = class(TScene)
  private

  public
    procedure Render; override;
    procedure Update(var Key: Word); override;
  end;

implementation

uses
  BearLibTerminal,
  Math,
  SysUtils,
  TransportTycoon.Game,
  TransportTycoon.City;

procedure TSceneBuildInCity.Render;
var
  C: TCity;
  N: Integer;
  S: string;
  F: Boolean;
begin
  DrawMap(Self.Width, Self.Height - 1);

  DrawFrame(15, 7, 50, 15);

  C := Game.Map.City[Game.Map.CurrentCity];
  DrawTitle('BUILD IN ' + C.Name);

  S := '';
  F := (Game.Money >= C.AirportCost) and (C.Airport < 5);
  N := Math.EnsureRange(C.Airport + 1, 0, 5);
  if C.Airport < 5 then
    S := ' ($' + IntToStr(C.AirportCost) + ')';
  DrawButton(17, 11, F, 'A', 'Build ' + AirportSizeStr[N] + S);

  F := (Game.Money >= TCity.HQCost) and (C.CompanyHeadquarters = 0);
  if C.CompanyHeadquarters = 0 then
    DrawButton(17, 17, F, 'G', 'Build Company Headquarters ($' +
      IntToStr(TCity.HQCost) + ')');

  AddButton(19, 'Esc', 'Close');

  DrawBar;
end;

procedure TSceneBuildInCity.Update(var Key: Word);
var
  C: TCity;
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
        17:
          Key := TK_G;
      end;
  end;
  case Key of
    TK_ESCAPE:
      Scenes.SetScene(scCity);
    TK_A:
      begin
        C := Game.Map.City[Game.Map.CurrentCity];
        if (Game.Money >= C.AirportCost) and (C.Airport < 5) then
        begin
          C.BuildAirport;
          Scenes.SetScene(scAirport);
        end;
      end;
    TK_G:
      begin
        C := Game.Map.City[Game.Map.CurrentCity];
        if (Game.Money >= TCity.HQCost) and (C.CompanyHeadquarters = 0) then
        begin
          C.BuildCompanyHeadquarters;
          Scenes.SetScene(scCompany);
        end;
      end;
  end;
end;

end.
