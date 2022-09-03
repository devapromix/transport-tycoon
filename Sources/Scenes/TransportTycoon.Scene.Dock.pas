unit TransportTycoon.Scene.Dock;

interface

uses
  TransportTycoon.Scenes,
  TransportTycoon.Scene.Station,
  TransportTycoon.Industries;

type

  { TSceneDock }

  TSceneDock = class(TSceneStation)
  private
    FIndustry: TIndustry;
  public
    procedure Render; override;
    procedure Update(var Key: Word); override;
  end;

implementation

uses
  BearLibTerminal,
  SysUtils,
  TransportTycoon.Game,
  TransportTycoon.Cargo,
  TransportTycoon.Palette;

{ TSceneDock }

procedure TSceneDock.Render;
var
  I, LY: Integer;
  LCargo: TCargo;
begin
  inherited Render;

  FIndustry := Game.Map.Industry[Game.Map.CurrentIndustry];

  DrawTitle(FIndustry.Name + ' Dock');

  terminal_color(TPalette.Default);
  LY := 11;
  for LCargo := Succ(Low(TCargo)) to High(TCargo) do
  begin
    if LCargo in FIndustry.Produces then
    begin
      DrawText(7, LY, Format('%s: %d/%d', [CargoStr[LCargo],
        FIndustry.ProducesAmount[LCargo], FIndustry.MaxCargo]));
      Inc(LY);
    end;
  end;

  for I := 0 to Game.Vehicles.ShipCount - 1 do
    DrawButton(37, I + 11, Game.Vehicles.Ship[I].InLocation(FIndustry.X,
      FIndustry.Y), Chr(Ord('A') + I), StrLim(Game.Vehicles.Ship[I].Name, 30));

  AddButton(19, 'V', 'Ship Depot');
  AddButton(19, 'Esc', 'Close');

  DrawBar;
end;

procedure TSceneDock.Update(var Key: Word);
var
  I: Integer;
begin
  inherited Update(Key);
  if (Key = TK_MOUSE_LEFT) then
  begin
    if (GetButtonsY = MY) then
    begin
      case MX of
        26 .. 39:
          Key := TK_V;
        43 .. 53:
          Key := TK_ESCAPE;
      end;
    end;
  end;
  case Key of
    TK_ESCAPE:
      Scenes.Back;
    TK_A .. TK_G:
      begin
        I := Key - TK_A;
        if Game.Vehicles.Ship[I].InLocation(FIndustry.X, FIndustry.Y) then
        begin
          Game.Vehicles.CurrentVehicle := I;
          Scenes.SetScene(scShip, scDock);
        end;
      end;
    TK_V:
      Scenes.SetScene(scShipDepot);
  end;
end;

end.
