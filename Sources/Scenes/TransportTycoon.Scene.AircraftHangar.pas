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
    procedure Update(var Key: Word); override;
  end;

implementation

uses
  BearLibTerminal,
  Math,
  SysUtils,
  TransportTycoon.Game,
  TransportTycoon.Aircraft,
  TransportTycoon.Vehicles;

procedure TSceneAircraftHangar.Render;
var
  SelVehicle: Integer;
begin
  inherited Render;

  FTown := TTownIndustry(Game.Map.Industry[Game.Map.CurrentIndustry]);
  DrawTitle(8, FTown.Name + ' Airport Hangar');

  SelVehicle := Math.EnsureRange(Game.Vehicles.CurrentVehicle, 0,
    Length(AircraftBase) - 1);
  DrawVehiclesList(AircraftBase, SelVehicle);
  DrawVehicleInfo(AircraftBase, SelVehicle);

  AddButton(20, Game.Vehicles.IsBuyAircraftAllowed, 'Enter', 'Buy Aircraft');
  AddButton(20, 'Esc', 'Close');

  DrawBar;
end;

procedure TSceneAircraftHangar.Update(var Key: Word);
var
  I: Integer;
  Title: string;
begin
  inherited Update(Key);
  if (Key = TK_MOUSE_LEFT) then
  begin
    if (GetButtonsY = MY) then
      case MX of
        23 .. 42:
          Key := TK_ENTER;
        46 .. 56:
          Key := TK_ESCAPE;
      end;
  end;
  case Key of
    TK_ESCAPE:
      Scenes.SetScene(scAirport);
    TK_A .. TK_I:
      begin
        I := Key - TK_A;
        if I > Length(AircraftBase) - 1 then
          Exit;
        if AircraftBase[I].Since > Game.Calendar.Year then
          Exit;
        Game.Vehicles.CurrentVehicle := I;
        Scenes.Render;
      end;
    TK_ENTER:
      begin
        if Game.Vehicles.IsBuyAircraftAllowed then
        begin
          I := Game.Vehicles.CurrentVehicle;
          if (Game.Money >= AircraftBase[I].Cost) then
          begin
            Title := Format('Aircraft #%d (%s)',
              [Game.Vehicles.AircraftCount + 1, AircraftBase[I].Name]);
            Game.Vehicles.AddAircraft(Title, Game.Map.CurrentIndustry, I);
            Scenes.SetScene(scAirport);
          end;
        end;
      end;
  end;

end;

end.
