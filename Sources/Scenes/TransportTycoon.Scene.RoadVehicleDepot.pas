unit TransportTycoon.Scene.RoadVehicleDepot;

interface

uses
  TransportTycoon.Scenes,
  TransportTycoon.Industries;

type
  TSceneRoadVehicleDepot = class(TScene)
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
  TransportTycoon.RoadVehicle,
  TransportTycoon.Vehicles,
  TransportTycoon.Cargo;

procedure TSceneRoadVehicleDepot.Render;
var
  I, J: Integer;
  S: string;
  Cargo: TCargo;
begin
  DrawMap(Self.ScreenWidth, Self.ScreenHeight - 1);

  DrawFrame(10, 6, 60, 17);

  FIndustry := Game.Map.Industry[Game.Map.CurrentIndustry];

  DrawTitle(8, FIndustry.Name + ' Road Vehicle Depot');

  for I := 0 to Length(RoadVehicleBase) - 1 do
    if RoadVehicleBase[I].Since <= Game.Calendar.Year then
      DrawButton(12, I + 10, Chr(Ord('A') + I), RoadVehicleBase[I].Name);

  I := Math.EnsureRange(Game.Vehicles.CurrentVehicle, 0,
    Length(RoadVehicleBase) - 1);

  terminal_color('yellow');
  terminal_composition(TK_ON);
  DrawText(42, 10, RoadVehicleBase[I].Name);
  S := '';
  for J := 1 to Length(RoadVehicleBase[I].Name) do
    S := S + '_';
  DrawText(42, 10, S);
  terminal_composition(TK_OFF);

  terminal_color('white');
  J := 11;
  for Cargo := Succ(Low(TCargo)) to High(TCargo) do
    if (Cargo in RoadVehicleBase[I].Cargo) then
    begin
      DrawText(42, J, Format('%s: %d', [CargoStr[Cargo],
        RoadVehicleBase[I].Amount]));
      Inc(J);
    end;
  DrawText(42, J, Format('Speed: %d km/h', [RoadVehicleBase[I].Speed]));
  Inc(J);
  DrawText(42, J, Format('Cost: $%d', [RoadVehicleBase[I].Cost]));
  Inc(J);
  DrawText(42, J, Format('Running Cost: $%d/y',
    [RoadVehicleBase[I].RunningCost]));

  AddButton(20, Game.Vehicles.IsBuyRoadVehicleAllowed, 'Enter',
    'Buy Road Vehicle');
  AddButton(20, 'Esc', 'Close');

  DrawBar;
end;

procedure TSceneRoadVehicleDepot.Update(var Key: Word);
var
  I: Integer;
  Title: string;
begin
  if (Key = TK_MOUSE_LEFT) then
  begin
    case MX of
      12 .. 38:
        case MY of
          10 .. 18:
            Key := TK_A + (MY - 10);
        end;
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
      Scenes.Back;
    TK_A .. TK_I:
      begin
        I := Key - TK_A;
        if I > Length(RoadVehicleBase) - 1 then
          Exit;
        if RoadVehicleBase[I].Since > Game.Calendar.Year then
          Exit;
        Game.Vehicles.CurrentVehicle := I;
        Scenes.Render;
      end;
    TK_ENTER:
      begin
        if Game.Vehicles.IsBuyRoadVehicleAllowed then
        begin
          I := Game.Vehicles.CurrentVehicle;
          if (Game.Money >= RoadVehicleBase[I].Cost) then
          begin
            Title := Format('Road Vehicle #%d (%s)',
              [Game.Vehicles.RoadVehicleCount + 1, RoadVehicleBase[I].Name]);
            Game.Vehicles.AddRoadVehicle(Title, Game.Map.CurrentIndustry, I);
            Scenes.Back;
          end;
        end;
      end;
  end;

end;

end.
