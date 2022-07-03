unit TransportTycoon.Scene.Aircraft;

interface

uses
  TransportTycoon.Scenes;

type
  TSceneAircraft = class(TScene)
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
  TransportTycoon.Aircraft;

procedure TSceneAircraft.Render;
var
  I: Integer;
  S: string;
  C: Char;
begin
  DrawMap(Self.Width, Self.Height - 1);

  DrawFrame(10, 7, 60, 15);
  with Game.Vehicles do
  begin
    DrawTitle(UpperCase(Aircraft[CurrentVehicle].Name));

    with Aircraft[CurrentVehicle] do
    begin
      terminal_color('yellow');
      terminal_composition(TK_ON);
      DrawText(12, 11, AircraftBase[VehicleID].Name);
      S := '';
      for I := 1 to Length(AircraftBase[VehicleID].Name) do
        S := S + '_';
      DrawText(12, 11, S);
      terminal_composition(TK_OFF);
      terminal_color('white');
      DrawText(12, 12, Format('Passengers: %d/%d',
        [Passengers, MaxPassengers]));
      DrawText(12, 13, Format('Mail: %d/%d',
        [Mail, MaxMail]));

      DrawText(12, 17, Format('State: %s', [State]));

      for I := 0 to Length(Order) - 1 do
      begin
        if (OrderIndex = I) then
          C := '>'
        else
          C := #32;
        DrawText(32, I + 11, C);
        DrawButton(34, I + 11, Length(Order) > 1, Chr(Ord('A') + I),
          'Go to ' + Order[I].Name + ' Airport');
      end;
    end;
  end;

  AddButton(19, 'O', 'Orders');
  AddButton(19, 'Esc', 'Close');

  DrawBar;
end;

procedure TSceneAircraft.Update(var Key: Word);
var
  I: Integer;
begin
  if (Key = TK_MOUSE_LEFT) then
  begin
    if (MX >= 28) and (MX <= 37) then
      case MY of
        19:
          Key := TK_O;
      end;
    if (MX >= 41) and (MX <= 51) then
      case MY of
        19:
          Key := TK_ESCAPE;
      end;
  end;
  case Key of
    TK_A .. TK_G:
      with Game.Vehicles do
      begin
        I := Key - TK_A;
        with Aircraft[CurrentVehicle] do
        begin
          if (I > Length(Order) - 1) then
            Exit;
          DelOrder(I);
          Scenes.Render;
        end;
      end;
    TK_ESCAPE:
      Scenes.Back;
    TK_O:
      Scenes.SetScene(scAircraftOrders);
  end;
end;

end.
