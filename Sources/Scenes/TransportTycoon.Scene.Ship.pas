﻿unit TransportTycoon.Scene.Ship;

interface

uses
  TransportTycoon.Scenes,
  TransportTycoon.Scene.Vehicle;

type
  TSceneShip = class(TSceneVehicle)
  private

  public
    procedure Render; override;
    procedure Update(var AKey: Word); override;
  end;

implementation

uses
  BearLibTerminal,
  SysUtils,
  TransportTycoon.Game,
  TransportTycoon.Ship,
  TransportTycoon.Cargo,
  TransportTycoon.Palette;

procedure TSceneShip.Render;
var
  LOrder: Integer;
begin
  inherited Render;

  with Game.Vehicles do
  begin
    DrawTitle(UpperCase(Ship[CurrentVehicle].Name));

    with Ship[CurrentVehicle] do
    begin
      terminal_color(TPalette.Selected);
      terminal_composition(TK_ON);
      DrawText(7, 11, ShipBase[VehicleID].Name);
      DrawText(7, 11, StringOfChar('_', Length(ShipBase[VehicleID].Name)));
      terminal_composition(TK_OFF);
      terminal_color(TPalette.Default);

      if (CargoType <> cgNone) then
        DrawText(7, 12, Format('%s: %d/%d', [CargoStr[CargoType], CargoAmount,
          MaxCargoAmount]));

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
        for LOrder := 0 to Orders.Count - 1 do
        begin
          if (Orders.OrderIndex = LOrder) then
            DrawText(27, LOrder + 11, '>');
          DrawButton(29, LOrder + 11, Orders.Count > 1, Chr(Ord('A') + LOrder),
            StrLim('Go to ' + Orders.Order[LOrder].Name + ' Dock', 40));
        end;
      end;
    end;
  end;
end;

procedure TSceneShip.Update(var AKey: Word);
var
  LOrder: Integer;
begin
  inherited Update(AKey);
  case AKey of
    TK_A .. TK_G:
      with Game.Vehicles do
      begin
        LOrder := AKey - TK_A;
        with Ship[CurrentVehicle] do
        begin
          if (LOrder > Orders.Count - 1) then
            Exit;
          Orders.DelOrder(LOrder);
          Scenes.Render;
        end;
      end;
    TK_ESCAPE:
      Scenes.Back;
    TK_V:
      IsDetails := not IsDetails;
    TK_L:
      with Game.Vehicles do
        with Ship[CurrentVehicle] do
        begin
          FullLoad := not FullLoad;
          Scenes.Render;
        end;
    TK_O:
      begin
        IsDetails := False;
        Game.IsOrder := True;
        Scenes.CurrentVehicleScene := scShip;
        Scenes.ClearQScenes;
        Scenes.SetScene(scWorld);
      end;
  end;
end;

end.
