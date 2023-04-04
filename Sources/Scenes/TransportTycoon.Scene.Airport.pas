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
    procedure Update(var AKey: Word); override;
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
  LCurrentAircraft, LY: Integer;
  LCargo: TCargo;
begin
  inherited Render;

  FTown := TTownIndustry(Game.Map.Industry[Game.Map.CurrentIndustry]);

  DrawTitle(FTown.Name + ' Airport');

  terminal_color(TPalette.Default);
  DrawText(7, 11, 'Size: ' + AirportSizeStr[FTown.Airport.Level]);
  LY := 12;
  for LCargo := Succ(Low(TCargo)) to High(TCargo) do
  begin
    if LCargo in [cgPassengers] then
    begin
      DrawText(7, LY, Format('%s: %d/%d', [CargoStr[LCargo],
        FTown.ProducesAmount[LCargo], FTown.MaxCargo]));
      Inc(LY);
    end;
  end;

  for LCurrentAircraft := 0 to Game.Vehicles.AircraftCount - 1 do
    DrawButton(37, LCurrentAircraft + 11,
      Game.Vehicles.Aircraft[LCurrentAircraft].InLocation(FTown.X, FTown.Y),
      Chr(Ord('A') + LCurrentAircraft),
      StrLim(Game.Vehicles.Aircraft[LCurrentAircraft].Name, 30));

  AddButton(19, 'H', 'Hangar');
  AddButton(19, 'Esc', 'Close');

  DrawGameBar;
end;

procedure TSceneAirport.Update(var AKey: Word);
var
  LCurrentAircraft: Integer;
begin
  inherited Update(AKey);
  if (AKey = TK_MOUSE_LEFT) then
  begin
    if (GetButtonsY = MY) then
      case MX of
        28 .. 37:
          AKey := TK_H;
        41 .. 51:
          AKey := TK_ESCAPE;
      end;
  end;
  case AKey of
    TK_ESCAPE:
      Scenes.Back;
    TK_A .. TK_G:
      begin
        LCurrentAircraft := AKey - TK_A;
        if Game.Vehicles.Aircraft[LCurrentAircraft].InLocation(FTown.X, FTown.Y)
        then
        begin
          Game.Vehicles.CurrentVehicle := LCurrentAircraft;
          Scenes.SetScene(scAircraft, scAirport);
        end;
      end;
    TK_H:
      Scenes.SetScene(scAircraftHangar);
  end;
end;

end.
