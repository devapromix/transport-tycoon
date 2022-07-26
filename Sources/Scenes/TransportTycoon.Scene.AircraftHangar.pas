unit TransportTycoon.Scene.AircraftHangar;

interface

uses
  TransportTycoon.Scenes,
  TransportTycoon.Industries;

type
  TSceneAircraftHangar = class(TScene)
  private
    FTown: TTownIndustry;
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
  TransportTycoon.Aircraft,
  TransportTycoon.Vehicles;

procedure TSceneAircraftHangar.Render;
var
  I, J: Integer;
  S: string;
begin
  DrawMap(Self.ScreenWidth, Self.ScreenHeight - 1);

  DrawFrame(10, 6, 60, 17);

  FTown := TTownIndustry(Game.Map.Industry[Game.Map.CurrentIndustry]);

  DrawTitle(8, FTown.Name + ' Airport Hangar');

  for I := 0 to Length(AircraftBase) - 1 do
    if AircraftBase[I].Since <= Game.Calendar.Year then
      DrawButton(12, I + 10, Chr(Ord('A') + I), AircraftBase[I].Name);

  I := Math.EnsureRange(Game.Vehicles.CurrentVehicle, 0,
    Length(AircraftBase) - 1);
  terminal_color('yellow');
  terminal_composition(TK_ON);
  DrawText(42, 10, AircraftBase[I].Name);
  S := '';
  for J := 1 to Length(AircraftBase[I].Name) do
    S := S + '_';
  DrawText(42, 10, S);
  terminal_composition(TK_OFF);
  terminal_color('white');
  DrawText(42, 11, Format('Passengers: %d', [AircraftBase[I].Passengers]));
  DrawText(42, 12, Format('Mail: %d', [AircraftBase[I].Mail]));
  DrawText(42, 13, Format('Speed: %d km/h', [AircraftBase[I].Speed]));
  DrawText(42, 14, Format('Cost: $%d', [AircraftBase[I].Cost]));
  DrawText(42, 15, Format('Running Cost: $%d/y',
    [AircraftBase[I].RunningCost]));

  AddButton(20, Game.Vehicles.IsBuyAircraftAllowed, 'Enter', 'Buy Aircraft');
  AddButton(20, 'Esc', 'Close');

  DrawBar;
end;

procedure TSceneAircraftHangar.Update(var Key: Word);
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
      case MX of
        23 .. 42:
          Key := TK_ENTER;
        46 .. 56:
          Key := TK_ESCAPE;
      end;
  end;
  case Key of
    TK_ESCAPE:
      Scenes.SetScene(scAirport);
    TK_A .. TK_I:
      begin
        I := Key - TK_A;
        if I > Length(AircraftBase) - 1 then
          Exit;
        if AircraftBase[I].Since > Game.Calendar.Year then
          Exit;
        Game.Vehicles.CurrentVehicle := I;
        Scenes.Render;
      end;
    TK_ENTER:
      begin
        if Game.Vehicles.IsBuyAircraftAllowed then
        begin
          I := Game.Vehicles.CurrentVehicle;
          if (Game.Money >= AircraftBase[I].Cost) then
          begin
            Title := Format('Aircraft #%d (%s)',
              [Game.Vehicles.AircraftCount + 1, AircraftBase[I].Name]);
            Game.Vehicles.AddAircraft(Title, Game.Map.CurrentIndustry, I);
            Scenes.SetScene(scAirport);
          end;
        end;
      end;
  end;

end;

end.
