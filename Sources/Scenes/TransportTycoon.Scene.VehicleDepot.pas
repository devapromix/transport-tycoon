unit TransportTycoon.Scene.VehicleDepot;

interface

uses
  TransportTycoon.Scenes,
  TransportTycoon.Vehicle;

type

  { TSceneVehicleDepot }

  TSceneVehicleDepot = class(TScene)
  public
    procedure Render; override;
    procedure Update(var Key: Word); override;
    procedure DrawVehicleInfo(const AVehicleBase: array of TVehicleBase;
      const ASelVehicle: Integer);
    procedure DrawVehiclesList(const AVehicleBase: array of TVehicleBase;
      const ASelVehicle: Integer);
  end;

implementation

{ TSceneVehicleDepot }

uses
  SysUtils,
  BearLibTerminal,
  TransportTycoon.Cargo,
  TransportTycoon.Game,
  TransportTycoon.Palette;

procedure TSceneVehicleDepot.DrawVehicleInfo(const AVehicleBase
  : array of TVehicleBase; const ASelVehicle: Integer);
var
  LCargo: TCargo;
begin
  terminal_color(TPalette.Selected);
  terminal_composition(TK_ON);
  DrawText(42, 10, AVehicleBase[ASelVehicle].Name);
  DrawText(42, 10, StringOfChar('_', Length(AVehicleBase[ASelVehicle].Name)));
  terminal_composition(TK_OFF);
  terminal_color(TPalette.Default);
  TextLineY := 11;
  for LCargo := Succ(Low(TCargo)) to High(TCargo) do
    if (LCargo in AVehicleBase[ASelVehicle].CargoSet) then
      DrawTextLine(42, Format('%s: %d', [CargoStr[LCargo],
        AVehicleBase[ASelVehicle].Amount]));
  DrawTextLine(42, Format('Speed: %d km/h', [AVehicleBase[ASelVehicle].Speed]));
  DrawTextLine(42, Format('Cost: $%d', [AVehicleBase[ASelVehicle].Cost]));
  DrawTextLine(42, Format('Running Cost: $%d/y',
    [AVehicleBase[ASelVehicle].RunningCost]));
end;

procedure TSceneVehicleDepot.DrawVehiclesList(const AVehicleBase
  : array of TVehicleBase; const ASelVehicle: Integer);
var
  I: Integer;
begin
  for I := 0 to Length(AVehicleBase) - 1 do
    if AVehicleBase[I].Since <= Game.Calendar.Year then
      if I = ASelVehicle then
        DrawButton(12, I + 10, Chr(Ord('A') + I),
          AVehicleBase[I].Name, 'yellow')
      else
        DrawButton(12, I + 10, Chr(Ord('A') + I), AVehicleBase[I].Name);
end;

procedure TSceneVehicleDepot.Render;
begin
  DrawMap(Self.ScreenWidth, Self.ScreenHeight - 1);
  DrawFrame(10, 6, 60, 17);
end;

procedure TSceneVehicleDepot.Update(var Key: Word);
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
  end;
end;

end.
