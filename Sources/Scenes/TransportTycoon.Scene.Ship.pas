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
    procedure Update(var Key: Word); override;
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
  I: Integer;
  S: string;
  C: Char;
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
      S := '';
      for I := 1 to Length(ShipBase[VehicleID].Name) do
        S := S + '_';
      DrawText(7, 11, S);
      terminal_composition(TK_OFF);
      terminal_color(TPalette.Default);

      if (CargoType <> cgNone) then
        DrawText(7, 12, Format('%s: %d/%d', [CargoStr[CargoType], CargoAmount,
          CargoMaxAmount]));

      DrawText(7, 15, Format('State: %s', [State]));
      DrawText(7, 17, Format('[color=yellow][[L]][/c] Full Load: [[%s]]',
        [Check(FullLoad)]));

      for I := 0 to Length(Order) - 1 do
      begin
        if (OrderIndex = I) then
          C := '>'
        else
          C := #32;
        DrawText(27, I + 11, C);
        DrawButton(29, I + 11, Length(Order) > 1, Chr(Ord('A') + I),
          StrLim('Go to ' + Order[I].Name + ' Dock', 40));
      end;
    end;
  end;
end;

procedure TSceneShip.Update(var Key: Word);
var
  I: Integer;
begin
  inherited Update(Key);
  case Key of
    TK_A .. TK_G:
      with Game.Vehicles do
      begin
        I := Key - TK_A;
        with Ship[CurrentVehicle] do
        begin
          if (I > Length(Order) - 1) then
            Exit;
          DelOrder(I);
          Scenes.Render;
        end;
      end;
    TK_ESCAPE:
      Scenes.Back;
    TK_L:
      with Game.Vehicles do
        with Ship[CurrentVehicle] do
        begin
          FullLoad := not FullLoad;
          Scenes.Render;
        end;
    TK_O:
      begin
        Game.IsOrder := True;
        Scenes.CurrentVehicleScene := scShip;
        Scenes.ClearQScenes;
        Scenes.SetScene(scWorld);
      end;
  end;
end;

end.
