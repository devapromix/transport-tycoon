unit TransportTycoon.Scene.Airport;

interface

uses
  TransportTycoon.Scenes;

type
  TSceneAirport = class(TScene)
  private

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
  TransportTycoon.Scene.World,
  TransportTycoon.City;

procedure TSceneAirport.Render;
var
  C: TCity;
  I: Integer;
begin
  DrawMap(Self.Width, Self.Height - 1);

  DrawFrame(10, 7, 60, 15);

  C := Game.Map.City[Game.Map.CurrentCity];
  DrawTitle(C.Name + ' Airport');

  terminal_color('white');
  DrawText(12, 11, 'Size: ' + AirportSizeStr[C.Airport]);
  DrawText(12, 12, 'Passengers: ' + IntToStr(C.Passengers.Airport));
  DrawText(12, 13, 'Bags of mail: ' + IntToStr(C.Mail.Airport));

  for I := 0 to Length(Game.Vehicles.Aircraft) - 1 do
    DrawButton(42, I + 11, (Game.Vehicles.Aircraft[I].X = C.X) and
      (Game.Vehicles.Aircraft[I].Y = C.Y), Chr(Ord('A') + I),
      Game.Vehicles.Aircraft[I].Name);

  AddButton(19, 'H', 'Hangar');
  AddButton(19, 'Esc', 'Close');

  DrawBar;
end;

procedure TSceneAirport.Update(var Key: Word);
var
  C: TCity;
  I: Integer;
begin
  if (Key = TK_MOUSE_LEFT) then
  begin
    if (MX >= 42) and (MX <= 66) then
    begin
      C := Game.Map.City[Game.Map.CurrentCity];
      I := MY - 11;
      case MY of
        11 .. 17:
          if (Game.Vehicles.Aircraft[I].X = C.X) and
            (Game.Vehicles.Aircraft[I].Y = C.Y) then
            Key := TK_A + I;
      end;
    end;
    if (GetButtonsY = MY) then
    begin
      if (MX >= 28) and (MX <= 37) then
        Key := TK_H;
      if (MX >= 41) and (MX <= 51) then
        Key := TK_ESCAPE;
    end;
  end;
  case Key of
    TK_ESCAPE:
      Scenes.SetScene(scCity);
    TK_A .. TK_G:
      begin
        Game.Vehicles.CurrentVehicle := Key - TK_A;
        Scenes.SetScene(scAircraft);
      end;
    TK_H:
      Scenes.SetScene(scHangar);
  end;
end;

end.
