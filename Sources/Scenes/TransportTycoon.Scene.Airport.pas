unit TransportTycoon.Scene.Airport;

interface

uses
  TransportTycoon.Scenes,
  TransportTycoon.Scene.Station,
  TransportTycoon.Industries;

type

  { TSceneAirport }

  TSceneAirport = class(TSceneStation)
  private
    FTown: TTownIndustry;
  public
    procedure Render; override;
    procedure Update(var Key: Word); override;
  end;

implementation

uses
  BearLibTerminal,
  SysUtils,
  TransportTycoon.Game,
  TransportTycoon.Cargo,
  TransportTycoon.Palette;

{ TSceneAirport }

procedure TSceneAirport.Render;
var
  I, J: Integer;
  Cargo: TCargo;
begin
  inherited Render;

  FTown := TTownIndustry(Game.Map.Industry[Game.Map.CurrentIndustry]);

  DrawTitle(FTown.Name + ' Airport');

  terminal_color(TPalette.Default);
  DrawText(7, 11, 'Size: ' + AirportSizeStr[FTown.Airport.Level]);
  J := 12;
  for Cargo := Succ(Low(TCargo)) to High(TCargo) do
  begin
    if Cargo in [cgPassengers] then
    begin
      DrawText(7, J, Format('%s: %d/%d', [CargoStr[Cargo],
        FTown.ProducesAmount[Cargo], FTown.MaxCargo]));
      Inc(J);
    end;
  end;

  for I := 0 to Game.Vehicles.AircraftCount - 1 do
    DrawButton(37, I + 11, Game.Vehicles.Aircraft[I].InLocation(FTown.X,
      FTown.Y), Chr(Ord('A') + I), StrLim(Game.Vehicles.Aircraft[I].Name, 30));

  AddButton(19, 'H', 'Hangar');
  AddButton(19, 'Esc', 'Close');

  DrawBar;
end;

procedure TSceneAirport.Update(var Key: Word);
var
  I: Integer;
begin
  inherited Update(Key);
  if (Key = TK_MOUSE_LEFT) then
  begin
    if (GetButtonsY = MY) then
      case MX of
        28 .. 37:
          Key := TK_H;
        41 .. 51:
          Key := TK_ESCAPE;
      end;
  end;
  case Key of
    TK_ESCAPE:
      Scenes.Back;
    TK_A .. TK_G:
      begin
        I := Key - TK_A;
        if Game.Vehicles.Aircraft[I].InLocation(FTown.X, FTown.Y) then
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
