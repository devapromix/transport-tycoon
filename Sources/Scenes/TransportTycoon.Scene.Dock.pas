unit TransportTycoon.Scene.Dock;

interface

uses
  TransportTycoon.Scenes,
  TransportTycoon.Industries;

type

  { TSceneDock }

  TSceneDock = class(TScene)
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
  TransportTycoon.Cargo;

{ TSceneDock }

procedure TSceneDock.Render;
var
  I, J: Integer;
  Cargo: TCargo;
begin
  DrawMap(Self.ScreenWidth, Self.ScreenHeight - 1);

  DrawFrame(5, 7, 70, 15);

  FIndustry := Game.Map.Industry[Game.Map.CurrentIndustry];

  DrawTitle(FIndustry.Name + ' Dock');

  terminal_color('white');
  J := 11;
  for Cargo := Succ(Low(TCargo)) to High(TCargo) do
  begin
    if Cargo in FIndustry.Produces then
    begin
      DrawText(7, J, Format('%s: %d', [CargoStr[Cargo],
        FIndustry.ProducesAmount[Cargo]]));
      Inc(J);
    end;
  end;

  for I := 0 to Game.Vehicles.ShipCount - 1 do
    DrawButton(37, I + 11, Game.Vehicles.Ship[I].InLocation(FIndustry.X,
      FIndustry.Y), Chr(Ord('A') + I), Game.Vehicles.Ship[I].Name);

  AddButton(19, 'V', 'Ship Depot');
  AddButton(19, 'Esc', 'Close');

  DrawBar;
end;

procedure TSceneDock.Update(var Key: Word);
var
  I: Integer;
begin
  if (Key = TK_MOUSE_LEFT) then
  begin
    case MX of
      37 .. 71:
        begin
          I := MY - 11;
          case MY of
            11 .. 17:
              Key := TK_A + I;
          end;
        end;
    end;
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
