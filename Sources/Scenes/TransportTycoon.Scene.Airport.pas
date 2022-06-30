﻿unit TransportTycoon.Scene.Airport;

interface

uses
  TransportTycoon.Scenes;

type
  TSceneAirport = class(TScene)
  private

  public
    procedure Render; override;
    procedure Update(var Key: Word); override;
  end;

implementation

uses
  BearLibTerminal,
  SysUtils,
  TransportTycoon.Game,
  TransportTycoon.Town,
  TransportTycoon.Industries;

var
  Town: TTown;

procedure TSceneAirport.Render;
var
  I: Integer;
begin
  DrawMap(Self.Width, Self.Height - 1);

  DrawFrame(5, 7, 70, 15);

  Town := Game.Map.Town[Game.Map.CurrentTown];
  DrawTitle(Town.Name + ' Airport');

  terminal_color('white');
  DrawText(7, 11, 'Size: ' + AirportSizeStr[Town.Airport.Level]);
  DrawText(7, 12, 'Passengers: ' + IntToStr(Town.ProducesAmount[cgPassengers]));
  DrawText(7, 13, 'Bags of mail: ' + IntToStr(Town.ProducesAmount
    [cgBagsOfMail]));

  for I := 0 to Length(Game.Vehicles.Aircraft) - 1 do
    DrawButton(37, I + 11, Game.Vehicles.Aircraft[I].InLocation(Town.X, Town.Y),
      Chr(Ord('A') + I), Game.Vehicles.Aircraft[I].Name);

  AddButton(19, 'H', 'Hangar');
  AddButton(19, 'Esc', 'Close');

  DrawBar;
end;

procedure TSceneAirport.Update(var Key: Word);
var
  I: Integer;
begin
  if (Key = TK_MOUSE_LEFT) then
  begin
    if (MX >= 37) and (MX <= 71) then
    begin
      I := MY - 11;
      case MY of
        11 .. 17:
          Key := TK_A + I;
      end;
    end;
    if (GetButtonsY = MY) then
    begin
      if (MX >= 28) and (MX <= 37) then
        Key := TK_H;
      if (MX >= 41) and (MX <= 51) then
        Key := TK_ESCAPE;
    end;
  end;
  case Key of
    TK_ESCAPE:
      Scenes.SetScene(scTown);
    TK_A .. TK_G:
      begin
        I := Key - TK_A;
        if Game.Vehicles.Aircraft[I].InLocation(Town.X, Town.Y) then
        begin
          Game.Vehicles.CurrentVehicle := I;
          Scenes.SetScene(scAircraft, scAirport);
        end;
      end;
    TK_H:
      Scenes.SetScene(scAircraftHangar);
  end;
end;

end.
