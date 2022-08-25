unit TransportTycoon.Scene.Aircraft;

interface

uses
  TransportTycoon.Scenes,
  TransportTycoon.Scene.Vehicle;

type
  TSceneAircraft = class(TSceneVehicle)
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
  TransportTycoon.Aircraft,
  TransportTycoon.Cargo,
  TransportTycoon.Palette;

procedure TSceneAircraft.Render;
var
  I: Integer;
  S: string;
  C: Char;
begin
  inherited Render;

  with Game.Vehicles do
  begin
    DrawTitle(UpperCase(Aircraft[CurrentVehicle].Name));

    with Aircraft[CurrentVehicle] do
    begin
      terminal_color(TPalette.Selected);
      terminal_composition(TK_ON);
      DrawText(7, 11, AircraftBase[VehicleID].Name);
      S := '';
      for I := 1 to Length(AircraftBase[VehicleID].Name) do
        S := S + '_';
      DrawText(7, 11, S);
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
        for I := 0 to OrderLength - 1 do
        begin
          if (OrderIndex = I) then
            C := '>'
          else
            C := #32;
          DrawText(27, I + 11, C);
          DrawButton(29, I + 11, OrderLength > 1, Chr(Ord('A') + I),
            StrLim('Go to ' + Order[I].Name + ' Airport', 40));
        end;
      end;
    end;
  end;
end;

procedure TSceneAircraft.Update(var Key: Word);
var
  I: Integer;
begin
  inherited Update(Key);
  case Key of
    TK_A .. TK_G:
      with Game.Vehicles do
      begin
        I := Key - TK_A;
        with Aircraft[CurrentVehicle] do
        begin
          if (I > OrderLength - 1) then
            Exit;
          DelOrder(I);
          Scenes.Render;
        end;
      end;
    TK_ESCAPE:
      Scenes.Back;
    TK_V:
      IsDetails := not IsDetails;
    TK_L:
      with Game.Vehicles do
        with Aircraft[CurrentVehicle] do
        begin
          FullLoad := not FullLoad;
          Scenes.Render;
        end;
    TK_O:
      begin
        IsDetails := False;
        Game.IsOrder := True;
        Scenes.CurrentVehicleScene := scAircraft;
        Scenes.ClearQScenes;
        Scenes.SetScene(scWorld);
      end;
  end;
end;

end.
