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
    procedure Update(var Key: Word); override;
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
  SelVehicle: Integer;
begin
  inherited Render;

  FIndustry := Game.Map.Industry[Game.Map.CurrentIndustry];
  DrawTitle(8, FIndustry.Name + ' Ship Depot');

  SelVehicle := Math.EnsureRange(Game.Vehicles.CurrentVehicle, 0,
    Length(ShipBase) - 1);
  DrawVehiclesList(ShipBase, SelVehicle);
  DrawVehicleInfo(ShipBase, SelVehicle);

  AddButton(20, Game.Vehicles.IsBuyShipAllowed, 'Enter', 'Buy Ship');
  AddButton(20, 'Esc', 'Close');

  DrawBar;
end;

procedure TSceneShipDepot.Update(var Key: Word);
var
  I: Integer;
  Title: string;
begin
  inherited Update(Key);
  if (Key = TK_MOUSE_LEFT) then
  begin
    if (GetButtonsY = MY) then
    begin
      case MX of
        25 .. 40:
          Key := TK_ENTER;
        44 .. 54:
          Key := TK_ESCAPE;
      end;
    end;
  end;
  case Key of
    TK_ESCAPE:
      Scenes.SetScene(scDock);
    TK_A .. TK_I:
      begin
        I := Key - TK_A;
        if I > Length(ShipBase) - 1 then
          Exit;
        if ShipBase[I].Since > Game.Calendar.Year then
          Exit;
        Game.Vehicles.CurrentVehicle := I;
        Scenes.Render;
      end;
    TK_ENTER:
      begin
        if Game.Vehicles.IsBuyShipAllowed then
        begin
          I := Game.Vehicles.CurrentVehicle;
          if (Game.Money >= ShipBase[I].Cost) then
          begin
            Title := Format('Ship #%d (%s)', [Game.Vehicles.ShipCount + 1,
              ShipBase[I].Name]);
            Game.Vehicles.AddShip(Title, Game.Map.CurrentIndustry, I);
            Scenes.SetScene(scDock);
          end;
        end;
      end;
  end;

end;

end.
