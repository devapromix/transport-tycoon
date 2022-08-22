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
    procedure DrawVehicleInfo(const V: array of TVehicleBase;
      const SelVehicle: Integer);
    procedure DrawVehiclesList(const V: array of TVehicleBase;
      const SelVehicle: Integer);
  end;

implementation

{ TSceneVehicleDepot }

uses
  SysUtils,
  BearLibTerminal,
  TransportTycoon.Cargo,
  TransportTycoon.Game,
  TransportTycoon.Palette;

procedure TSceneVehicleDepot.DrawVehicleInfo(const V: array of TVehicleBase;
  const SelVehicle: Integer);
var
  C: TCargo;
  S: string;
  I: Integer;
begin
  terminal_color(TPalette.Selected);
  terminal_composition(TK_ON);
  DrawText(42, 10, V[SelVehicle].Name);
  S := '';
  for I := 1 to Length(V[SelVehicle].Name) do
    S := S + '_';
  DrawText(42, 10, S);
  terminal_composition(TK_OFF);
  terminal_color(TPalette.Default);
  TextLineY := 11;
  for C := Succ(Low(TCargo)) to High(TCargo) do
    if (C in V[SelVehicle].Cargo) then
      DrawTextLine(42, Format('%s: %d', [CargoStr[C], V[SelVehicle].Amount]));
  DrawTextLine(42, Format('Speed: %d km/h', [V[SelVehicle].Speed]));
  DrawTextLine(42, Format('Cost: $%d', [V[SelVehicle].Cost]));
  DrawTextLine(42, Format('Running Cost: $%d/y', [V[SelVehicle].RunningCost]));
end;

procedure TSceneVehicleDepot.DrawVehiclesList(const V: array of TVehicleBase;
  const SelVehicle: Integer);
var
  I: Integer;
begin
  for I := 0 to Length(V) - 1 do
    if V[I].Since <= Game.Calendar.Year then
      if I = SelVehicle then
        DrawButton(12, I + 10, Chr(Ord('A') + I), V[I].Name, 'yellow')
      else
        DrawButton(12, I + 10, Chr(Ord('A') + I), V[I].Name);
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
