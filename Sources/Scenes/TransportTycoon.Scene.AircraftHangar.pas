﻿unit TransportTycoon.Scene.AircraftHangar;

interface

uses
  TransportTycoon.Scenes,
  TransportTycoon.Industries,
  TransportTycoon.Scene.VehicleDepot;

type
  TSceneAircraftHangar = class(TSceneVehicleDepot)
  private
    FTown: TTownIndustry;
  public
    procedure Render; override;
    procedure Update(var AKey: Word); override;
  end;

implementation

uses
  Math,
  SysUtils,
  BearLibTerminal,
  TransportTycoon.Game,
  TransportTycoon.Aircraft,
  TransportTycoon.Vehicles;

procedure TSceneAircraftHangar.Render;
var
  LSelVehicle: Integer;
begin
  inherited Render;

  FTown := TTownIndustry(Game.Map.Industry[Game.Map.CurrentIndustry]);
  DrawTitle(8, FTown.Name + ' Airport Hangar');

  LSelVehicle := Math.EnsureRange(Game.Vehicles.CurrentVehicle, 0,
    Length(AircraftBase) - 1);
  DrawVehiclesList(AircraftBase, LSelVehicle);
  DrawVehicleInfo(AircraftBase, LSelVehicle);

  AddButton(20, Game.Vehicles.IsBuyAircraftAllowed, 'Enter', 'Buy Aircraft');
  AddButton(20, 'Esc', 'Close');

  DrawGameBar;
end;

procedure TSceneAircraftHangar.Update(var AKey: Word);
var
  LCurrentVehicle: Integer;
  LTitle: string;
begin
  inherited Update(AKey);
  if (AKey = TK_MOUSE_LEFT) then
  begin
    if (GetButtonsY = MY) then
      case MX of
        23 .. 42:
          AKey := TK_ENTER;
        46 .. 56:
          AKey := TK_ESCAPE;
      end;
  end;
  case AKey of
    TK_ESCAPE:
      Scenes.SetScene(scAirport);
    TK_A .. TK_I:
      begin
        LCurrentVehicle := AKey - TK_A;
        if LCurrentVehicle > Length(AircraftBase) - 1 then
          Exit;
        if AircraftBase[LCurrentVehicle].Since > Game.Calendar.Year then
          Exit;
        Game.Vehicles.CurrentVehicle := LCurrentVehicle;
        Scenes.Render;
      end;
    TK_ENTER:
      begin
        if Game.Vehicles.IsBuyAircraftAllowed then
        begin
          LCurrentVehicle := Game.Vehicles.CurrentVehicle;
          if (Game.Money >= AircraftBase[LCurrentVehicle].Cost) then
          begin
            LTitle := Format('Aircraft #%d (%s)',
              [Game.Vehicles.AircraftCount + 1,
              AircraftBase[LCurrentVehicle].Name]);
            Game.Vehicles.AddAircraft(LTitle, Game.Map.CurrentIndustry,
              LCurrentVehicle);
            Scenes.SetScene(scAirport);
          end;
        end;
      end;
  end;

end;

end.
