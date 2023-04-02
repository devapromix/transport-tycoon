﻿unit TransportTycoon.Scene.BusStation;

interface

uses
  TransportTycoon.Scenes,
  TransportTycoon.Scene.Station,
  TransportTycoon.Industries;

type

  { TSceneBusStation }

  TSceneBusStation = class(TSceneStation)
  private
    FIndustry: TIndustry;
  public
    procedure Render; override;
    procedure Update(var AKey: Word); override;
  end;

implementation

uses
  BearLibTerminal,
  SysUtils,
  TransportTycoon.Game,
  TransportTycoon.Cargo,
  TransportTycoon.Palette;

{ TSceneBusStation }

procedure TSceneBusStation.Render;
var
  LRoadVehicle, LY: Integer;
  LCargo: TCargo;
begin
  inherited Render;

  FIndustry := Game.Map.Industry[Game.Map.CurrentIndustry];

  DrawTitle(FIndustry.Name + ' Bus Station');

  terminal_color(TPalette.Default);
  LY := 11;
  for LCargo := Succ(Low(TCargo)) to High(TCargo) do
  begin
    if LCargo in [cgPassengers] then
    begin
      DrawText(7, LY, Format('%s: %d/%d', [CargoStr[LCargo],
        FIndustry.ProducesAmount[LCargo], FIndustry.MaxCargo]));
      Inc(LY);
    end;
  end;

  for LRoadVehicle := 0 to Game.Vehicles.RoadVehicleCount - 1 do
    DrawButton(37, LRoadVehicle + 11, Game.Vehicles.RoadVehicle[LRoadVehicle]
      .InLocation(FIndustry.X, FIndustry.Y), Chr(Ord('A') + LRoadVehicle),
      StrLim(Game.Vehicles.RoadVehicle[LRoadVehicle].Name, 30));

  AddButton(19, 'V', 'Road Vehicle Depot');
  AddButton(19, 'Esc', 'Close');

  DrawGameBar;
end;

procedure TSceneBusStation.Update(var AKey: Word);
var
  LCurrentVehicle: Integer;
begin
  inherited Update(AKey);
  if (AKey = TK_MOUSE_LEFT) then
  begin
    if (GetButtonsY = MY) then
    begin
      case MX of
        22 .. 43:
          AKey := TK_V;
        47 .. 57:
          AKey := TK_ESCAPE;
      end;
    end;
  end;
  case AKey of
    TK_ESCAPE:
      Scenes.Back;
    TK_A .. TK_G:
      begin
        LCurrentVehicle := AKey - TK_A;
        if Game.Vehicles.RoadVehicle[LCurrentVehicle].InLocation(FIndustry.X,
          FIndustry.Y) then
        begin
          Game.Vehicles.CurrentVehicle := LCurrentVehicle;
          Scenes.SetScene(scRoadVehicle, scBusStation);
        end;
      end;
    TK_V:
      Scenes.SetScene(scRoadVehicleDepot, scBusStation);
  end;
end;

end.
