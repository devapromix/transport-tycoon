unit TransportTycoon.Scene.Hangar;

interface

uses
  TransportTycoon.Scenes;

type
  TSceneHangar = class(TScene)
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
  TransportTycoon.City,
  TransportTycoon.Aircraft;

procedure TSceneHangar.Render;
var
  C: TCity;
  I: Integer;
begin
  DrawMap(Self.Width, Self.Height - 1);

  DrawFrame(10, 7, 60, 15);

  C := Game.Map.City[Game.Map.CurrentCity];

  DrawTitle(C.Name + ' Airport Hangar');

  for I := 0 to Length(AircraftBase) - 1 do
    DrawButton(12, I + 11, Chr(Ord('A') + I), AircraftBase[I].Name);

  I := Math.EnsureRange(Game.Vehicles.CurrentVehicle, 0,
    Length(AircraftBase) - 1);
  DrawText(42, 11, AircraftBase[I].Name);
  DrawText(42, 12, Format('Max. Passengers: %d',
    [AircraftBase[I].MaxPassengers]));
  DrawText(42, 13, Format('Speed: %d', [AircraftBase[I].Speed]));

  AddButton(19, Length(Game.Vehicles.Aircraft) < 7, 'Enter', 'Buy Aircraft');
  AddButton(19, 'Esc', 'Close');

  DrawBar;
end;

procedure TSceneHangar.Update(var Key: Word);
var
  I: Integer;
begin
  if (Key = TK_MOUSE_LEFT) then
  begin
    if (MX >= 12) and (MX <= 38) then
      case MY of
        11 .. 17:
          Key := TK_A + (MY - 11);
      end;
    if (GetButtonsY = MY) then
    begin
      case MX of
        23 .. 42:
          Key := TK_ENTER;
        46 .. 56:
          Key := TK_ESCAPE;
      end;
    end;
  end;
  case Key of
    TK_ESCAPE:
      Scenes.SetScene(scAirport);
    TK_A .. TK_G:
      begin
        if Key - TK_A > Length(AircraftBase) - 1 then
          Exit;
        Game.Vehicles.CurrentVehicle := Key - TK_A;
        Scenes.Render;
      end;
    TK_ENTER:
      begin
        if Length(Game.Vehicles.Aircraft) < 7 then
        begin
          I := Game.Vehicles.CurrentVehicle;
          Game.Vehicles.AddAircraft(Format('Aircraft #%d (%s)',
            [Length(Game.Vehicles.Aircraft) + 1, AircraftBase[I].Name]),
            Game.Map.CurrentCity, AircraftBase[I].MaxPassengers);
          Scenes.SetScene(scAirport);
        end;
      end;
  end;

end;

end.
