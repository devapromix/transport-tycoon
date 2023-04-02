unit TransportTycoon.Scene.TruckLoadingBay;

interface

uses
  TransportTycoon.Scenes,
  TransportTycoon.Scene.Station,
  TransportTycoon.Industries;

type

  { TSceneBusStation }

  TSceneTruckLoadingBay = class(TSceneStation)
  private
    FIndustry: TIndustry;
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

{ TSceneBusStation }

procedure TSceneTruckLoadingBay.Render;
var
  I, LY: Integer;
  LCargo: TCargo;
begin
  inherited Render;

  FIndustry := Game.Map.Industry[Game.Map.CurrentIndustry];

  DrawTitle(FIndustry.Name + ' Truck Loading Bay');

  terminal_color(TPalette.Default);
  LY := 11;
  for LCargo := Succ(Low(TCargo)) to High(TCargo) do
    if (LCargo <> cgPassengers) then
    begin
      if LCargo in FIndustry.Produces then
      begin
        DrawText(7, LY, Format('%s: %d/%d', [CargoStr[LCargo],
          FIndustry.ProducesAmount[LCargo], FIndustry.MaxCargo]));
        Inc(LY);
      end;
    end;

  for I := 0 to Game.Vehicles.RoadVehicleCount - 1 do
    DrawButton(37, I + 11, Game.Vehicles.RoadVehicle[I].InLocation(FIndustry.X,
      FIndustry.Y), Chr(Ord('A') + I),
      StrLim(Game.Vehicles.RoadVehicle[I].Name, 30));

  AddButton(19, 'V', 'Road Vehicle Depot');
  AddButton(19, 'Esc', 'Close');

  DrawGameBar;
end;

procedure TSceneTruckLoadingBay.Update(var Key: Word);
var
  I: Integer;
begin
  inherited Update(Key);
  if (Key = TK_MOUSE_LEFT) then
  begin
    if (GetButtonsY = MY) then
    begin
      case MX of
        22 .. 43:
          Key := TK_V;
        47 .. 57:
          Key := TK_ESCAPE;
      end;
    end;
  end;
  case Key of
    TK_ESCAPE:
      Scenes.Back;
    TK_A .. TK_G:
      begin
        I := Key - TK_A;
        if Game.Vehicles.RoadVehicle[I].InLocation(FIndustry.X, FIndustry.Y)
        then
        begin
          Game.Vehicles.CurrentVehicle := I;
          Scenes.SetScene(scRoadVehicle, scTruckLoadingBay);
        end;
      end;
    TK_V:
      Scenes.SetScene(scRoadVehicleDepot, scTruckLoadingBay);
  end;
end;

end.
