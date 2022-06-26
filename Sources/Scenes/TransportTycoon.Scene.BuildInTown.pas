﻿unit TransportTycoon.Scene.BuildInTown;

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
  C: TTown;
  N: Integer;
  S: string;
  F: Boolean;
begin
  DrawMap(Self.Width, Self.Height - 1);

  DrawFrame(15, 7, 50, 15);

  C := Game.Map.Town[Game.Map.CurrentTown];
  DrawTitle('BUILD IN ' + C.Name);

  S := '';
  N := Math.EnsureRange(C.Airport + 1, 0, 5);
  if C.Airport < 5 then
    S := ' ($' + IntToStr(C.AirportCost) + ')';
  DrawButton(17, 11, C.CanBuildAirport, 'A', 'Build ' + AirportSizeStr[N] + S);

  S := '';
  F := (Game.Money >= C.DockCost) and (C.Dock = 0);
  if C.Dock = 0 then
    S := ' ($' + IntToStr(C.DockCost) + ')';
  DrawButton(17, 12, F, 'B', 'Build Dock' + S);

  if (Game.Money >= TTown.HQCost) and (C.CompanyHeadquarters = 0) and
    (Game.Map.CurrentTown = Game.Company.TownID) then
    DrawButton(17, 17, 'G', 'Build Company Headquarters ($' +
      IntToStr(TTown.HQCost) + ')');

  AddButton(19, 'Esc', 'Close');

  DrawBar;
end;

procedure TSceneBuildInTown.Update(var Key: Word);
var
  C: TTown;
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
        C := Game.Map.Town[Game.Map.CurrentTown];
        if C.CanBuildAirport then
        begin
          C.BuildAirport;
          Scenes.SetScene(scAirport);
        end;
      end;
    TK_B:
      begin
        C := Game.Map.Town[Game.Map.CurrentTown];
        if (Game.Money >= C.DockCost) and (C.Dock = 0) then
        begin
          C.BuildDock;
          Scenes.SetScene(scDock);
        end;
      end;
    TK_G:
      begin
        C := Game.Map.Town[Game.Map.CurrentTown];
        if (Game.Map.CurrentTown = Game.Company.TownID) and
          (Game.Money >= TTown.HQCost) and (C.CompanyHeadquarters = 0) then
        begin
          C.BuildCompanyHeadquarters;
          Scenes.SetScene(scCompany);
        end;
      end;
  end;
end;

end.
