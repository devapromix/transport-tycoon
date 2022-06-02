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
  Math,
  SysUtils,
  TransportTycoon.Game;

procedure TSceneAircraft.Render;
var
  I: Integer;
begin
  DrawMap(Self.Width, Self.Height - 1);

  DrawFrame(10, 5, 60, 15);
  with Game.Vehicles do
  begin
    DrawTitle(UpperCase(Aircraft[CurrentVehicle].Name));

    terminal_color('white');
    with Aircraft[CurrentVehicle] do
    begin
      DrawText(12, 9, Format('Passengers: %d/%d', [Passengers, MaxPassengers]));

      DrawText(12, 15, Format('State: %s', [State]));

      for I := 0 to Length(Order) - 1 do
      begin
        if (OrderIndex = I) then
          terminal_color('white')
        else
          terminal_color('gray');
        DrawText(34, I + 9, 'Go to ' + Order[I].Name + ' Airport');
      end;
    end;
  end;

  DrawButton(28, 17, 'O', 'ORDERS');
  DrawText(39, 17, '|');
  DrawButton(41, 17, 'ESC', 'CLOSE');

  DrawBar;
end;

procedure TSceneAircraft.Update(var Key: Word);
begin
  if (Key = TK_MOUSE_LEFT) then
  begin
    if (MX >= 28) and (MX <= 37) then
      case MY of
        17:
          Key := TK_O;
      end;
    if (MX >= 41) and (MX <= 51) then
      case MY of
        17:
          Key := TK_ESCAPE;
      end;
  end;
  case Key of
    TK_ESCAPE:
      Scenes.SetScene(scWorld);
    TK_O:
      Scenes.SetScene(scOrders);
  end;
end;

end.
