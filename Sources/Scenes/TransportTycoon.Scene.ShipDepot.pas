unit TransportTycoon.Scene.ShipDepot;

interface

uses
  TransportTycoon.Scenes,
  TransportTycoon.Industries,
  TransportTycoon.Scene.VehicleDepot;

type
  TSceneShipDepot = class(TSceneVehicleDepot)
  private
    FIndustry: TIndustry;
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
  TransportTycoon.Ship,
  TransportTycoon.Vehicles,
  TransportTycoon.Cargo;

procedure TSceneShipDepot.Render;
var
  LVehicle: Integer;
begin
  inherited Render;

  FIndustry := Game.Map.Industry[Game.Map.CurrentIndustry];
  DrawTitle(8, FIndustry.Name + ' Ship Depot');

  LVehicle := Math.EnsureRange(Game.Vehicles.CurrentVehicle, 0,
    Length(ShipBase) - 1);
  DrawVehiclesList(ShipBase, LVehicle);
  DrawVehicleInfo(ShipBase, LVehicle);

  AddButton(20, Game.Vehicles.IsBuyShipAllowed, 'Enter', 'Buy Ship');
  AddButton(20, 'Esc', 'Close');

  DrawGameBar;
end;

procedure TSceneShipDepot.Update(var AKey: Word);
var
  LVehicle: Integer;
  LTitle: string;
begin
  inherited Update(AKey);
  if (AKey = TK_MOUSE_LEFT) then
  begin
    if (GetButtonsY = MY) then
    begin
      case MX of
        25 .. 40:
          AKey := TK_ENTER;
        44 .. 54:
          AKey := TK_ESCAPE;
      end;
    end;
  end;
  case AKey of
    TK_ESCAPE:
      Scenes.SetScene(scDock);
    TK_A .. TK_I:
      begin
        LVehicle := AKey - TK_A;
        if LVehicle > Length(ShipBase) - 1 then
          Exit;
        if ShipBase[LVehicle].Since > Game.Calendar.Year then
          Exit;
        Game.Vehicles.CurrentVehicle := LVehicle;
        Scenes.Render;
      end;
    TK_ENTER:
      begin
        if Game.Vehicles.IsBuyShipAllowed then
        begin
          LVehicle := Game.Vehicles.CurrentVehicle;
          if (Game.Money >= ShipBase[LVehicle].Cost) then
          begin
            LTitle := Format('Ship #%d (%s)', [Game.Vehicles.ShipCount + 1,
              ShipBase[LVehicle].Name]);
            Game.Vehicles.AddShip(LTitle, Game.Map.CurrentIndustry, LVehicle);
            Scenes.SetScene(scDock);
          end;
        end;
      end;
  end;

end;

end.
