unit TransportTycoon.Scene.ShipDepot;

interface

uses
  TransportTycoon.Scenes,
  TransportTycoon.Industries;

type
  TSceneShipDepot = class(TScene)
  private
    FIndustry: TIndustry;
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
  TransportTycoon.Ship,
  TransportTycoon.Vehicles;

procedure TSceneShipDepot.Render;
var
  I, J: Integer;
  S: string;
begin
  DrawMap(Self.Width, Self.Height - 1);

  DrawFrame(10, 6, 60, 17);

  FIndustry := Game.Map.Industry[Game.Map.CurrentIndustry];

  DrawTitle(8, FIndustry.Name + ' Ship Depot');

  for I := 0 to Length(ShipBase) - 1 do
    if ShipBase[I].Since <= Game.Calendar.Year then
      DrawButton(12, I + 10, Chr(Ord('A') + I), ShipBase[I].Name);

  I := Math.EnsureRange(Game.Vehicles.CurrentVehicle, 0, Length(ShipBase) - 1);
  terminal_color('yellow');
  terminal_composition(TK_ON);
  DrawText(42, 10, ShipBase[I].Name);
  S := '';
  for J := 1 to Length(ShipBase[I].Name) do
    S := S + '_';
  DrawText(42, 10, S);
  terminal_composition(TK_OFF);
  terminal_color('white');
  DrawText(42, 11, Format('Passengers: %d', [ShipBase[I].Passengers]));
  DrawText(42, 12, Format('Bags of mail: %d', [ShipBase[I].Mail]));
  DrawText(42, 13, Format('Speed: %d km/h', [ShipBase[I].Speed]));
  DrawText(42, 14, Format('Cost: $%d', [ShipBase[I].Cost]));
  DrawText(42, 15, Format('Running Cost: $%d/y', [ShipBase[I].RunningCost]));

  AddButton(20, Game.Vehicles.IsBuyShipAllowed, 'Enter', 'Buy Ship');
  AddButton(20, 'Esc', 'Close');

  DrawBar;
end;

procedure TSceneShipDepot.Update(var Key: Word);
var
  I: Integer;
  Title: string;
begin
  if (Key = TK_MOUSE_LEFT) then
  begin
    if (MX >= 12) and (MX <= 38) then
      case MY of
        10 .. 18:
          Key := TK_A + (MY - 10);
      end;
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
