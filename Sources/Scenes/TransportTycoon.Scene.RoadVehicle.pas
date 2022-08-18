unit TransportTycoon.Scene.RoadVehicle;

interface

uses
  TransportTycoon.Scenes;

type
  TSceneRoadVehicle = class(TScene)
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
  TransportTycoon.Vehicle;

procedure TSceneRoadVehicle.Render;
var
  I: Integer;
  S: string;
  C: Char;
begin
  DrawMap(Self.ScreenWidth, Self.ScreenHeight - 1);

  DrawFrame(10, 7, 60, 15);
  with Game.Vehicles do
  begin
    DrawTitle(UpperCase(RoadVehicle[CurrentVehicle].Name));

    with RoadVehicle[CurrentVehicle] do
    begin
      terminal_color('yellow');
      terminal_composition(TK_ON);
      DrawText(12, 11, RoadVehicleBase[VehicleID].Name);
      S := '';
      for I := 1 to Length(RoadVehicleBase[VehicleID].Name) do
        S := S + '_';
      DrawText(12, 11, S);
      terminal_composition(TK_OFF);
      terminal_color('white');

      if (CargoType <> cgNone) then
        DrawText(12, 12, Format('%s: %d/%d', [CargoStr[CargoType], CargoAmount,
          CargoMaxAmount]));

      DrawText(12, 15, Format('State: %s', [State]));
      DrawText(12, 17, Format('[color=yellow][[L]][/c] Full Load: [[%s]]',
        [Check(FullLoad)]));

      for I := 0 to Length(Order) - 1 do
      begin
        if (OrderIndex = I) then
          C := '>'
        else
          C := #32;
        DrawText(32, I + 11, C);
        if RoadVehicleBase[VehicleID].VehicleType = vtBus then
          DrawButton(34, I + 11, Length(Order) > 1, Chr(Ord('A') + I),
            'Go to ' + Order[I].Name + ' Bus Station')
        else
          DrawButton(34, I + 11, Length(Order) > 1, Chr(Ord('A') + I),
            'Go to ' + Order[I].Name + ' Truck Loading Bay');
      end;
    end;
  end;

  AddButton(19, 'O', 'Add Order');
  AddButton(19, 'Esc', 'Close');

  DrawBar;
end;

procedure TSceneRoadVehicle.Update(var Key: Word);
var
  I: Integer;
begin
  if (Key = TK_MOUSE_LEFT) then
  begin
    case MX of
      32 .. 51:
        case MY of
          11 .. 17:
            Key := TK_A + (MY - 11);
        end;
    end;
    case MX of
      27 .. 39:
        case MY of
          19:
            Key := TK_O;
        end;
      43 .. 53:
        case MY of
          19:
            Key := TK_ESCAPE;
        end;
    end;
    case MX of
      12 .. 30:
        case MY of
          17:
            Key := TK_L;
        end;
    end;
  end;
  case Key of
    TK_A .. TK_G:
      with Game.Vehicles do
      begin
        I := Key - TK_A;
        with RoadVehicle[CurrentVehicle] do
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
        with RoadVehicle[CurrentVehicle] do
        begin
          FullLoad := not FullLoad;
          Scenes.Render;
        end;
    TK_O:
      begin
        Game.IsOrder := True;
        Scenes.CurrentVehicleScene := scRoadVehicle;
        Scenes.ClearQScenes;
        Scenes.SetScene(scWorld);
      end;
  end;
end;

end.
