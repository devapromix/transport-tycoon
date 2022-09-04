unit TransportTycoon.Scene.RoadVehicle;

interface

uses
  TransportTycoon.Scenes,
  TransportTycoon.Scene.Vehicle;

type
  TSceneRoadVehicle = class(TSceneVehicle)
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
  TransportTycoon.RoadVehicle,
  TransportTycoon.Cargo,
  TransportTycoon.Vehicle,
  TransportTycoon.Palette;

procedure TSceneRoadVehicle.Render;
var
  I: Integer;
begin
  inherited Render;

  with Game.Vehicles do
  begin
    DrawTitle(UpperCase(RoadVehicle[CurrentVehicle].Name));

    with RoadVehicle[CurrentVehicle] do
    begin
      terminal_color(TPalette.Selected);
      terminal_composition(TK_ON);
      DrawText(7, 11, RoadVehicleBase[VehicleID].Name);
      DrawText(7, 11, StringOfChar('_',
        Length(RoadVehicleBase[VehicleID].Name)));
      terminal_composition(TK_OFF);
      terminal_color(TPalette.Default);

      if (CargoType <> cgNone) then
        DrawText(7, 12, Format('%s: %d/%d', [CargoStr[CargoType], CargoAmount,
          CargoMaxAmount]));

      DrawText(7, 15, Format('State: %s', [State]));
      DrawText(25, 19, '|');
      DrawButton(7, 19, 18, True, FullLoad, 'L', 'Full Load');
      DrawText(55, 19, '|');
      DrawButton(57, 19, 17, True, IsDetails, 'V', 'Details');

      if IsDetails then
      begin
        DrawText(27, 11, 'Profit this year:');
        DrawMoney(45, 11, Profit, TK_ALIGN_LEFT);
        DrawText(27, 12, 'Profit last year:');
        DrawMoney(45, 12, LastProfit, TK_ALIGN_LEFT);
      end
      else
      begin
        for I := 0 to Orders.Count - 1 do
        begin
          if (Orders.OrderIndex = I) then
            DrawText(27, I + 11, '>');
          if RoadVehicleBase[VehicleID].VehicleType = vtBus then
            DrawButton(29, I + 11, Orders.Count > 1, Chr(Ord('A') + I),
              StrLim('Go to ' + Orders.Order[I].Name + ' Bus Station', 40))
          else
            DrawButton(29, I + 11, Orders.Count > 1, Chr(Ord('A') + I),
              StrLim('Go to ' + Orders.Order[I].Name +
              ' Truck Loading Bay', 40));
        end;
      end;
    end;
  end;
end;

procedure TSceneRoadVehicle.Update(var Key: Word);
var
  I: Integer;
begin
  inherited Update(Key);
  case Key of
    TK_A .. TK_G:
      with Game.Vehicles do
      begin
        I := Key - TK_A;
        with RoadVehicle[CurrentVehicle] do
        begin
          if (I > Orders.Count - 1) then
            Exit;
          Orders.DelOrder(I);
          Scenes.Render;
        end;
      end;
    TK_ESCAPE:
      Scenes.Back;
    TK_V:
      IsDetails := not IsDetails;
    TK_L:
      with Game.Vehicles do
        with RoadVehicle[CurrentVehicle] do
        begin
          FullLoad := not FullLoad;
          Scenes.Render;
        end;
    TK_O:
      begin
        IsDetails := False;
        Game.IsOrder := True;
        Scenes.CurrentVehicleScene := scRoadVehicle;
        Scenes.ClearQScenes;
        Scenes.SetScene(scWorld);
      end;
  end;
end;

end.
