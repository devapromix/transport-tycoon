unit TransportTycoon.Scene.Dock;

interface

uses
  TransportTycoon.Scenes,
  TransportTycoon.Industries;

type

  { TSceneDock }

  TSceneDock = class(TScene)
  private
    FTown: TTownIndustry;
  public
    procedure Render; override;
    procedure Update(var Key: Word); override;
  end;

implementation

uses
  BearLibTerminal,
  SysUtils,
  TransportTycoon.Game;

{ TSceneDock }

procedure TSceneDock.Render;
var
  I: Integer;
begin
  DrawMap(Self.Width, Self.Height - 1);

  DrawFrame(5, 7, 70, 15);

  FTown := TTownIndustry(Game.Map.Industry[Game.Map.CurrentTown]);
  DrawTitle(FTown.Name + ' Dock');

  terminal_color('white');
  DrawText(7, 11, 'Passengers: ' + IntToStr(FTown.ProducesAmount
    [cgPassengers]));
  DrawText(7, 12, 'Bags of mail: ' + IntToStr(FTown.ProducesAmount
    [cgBagsOfMail]));

  for I := 0 to Game.Vehicles.ShipCount - 1 do
    DrawButton(37, I + 11, Game.Vehicles.Ship[I].InLocation(FTown.X, FTown.Y),
      Chr(Ord('A') + I), Game.Vehicles.Ship[I].Name);

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
    if (MX >= 37) and (MX <= 71) then
    begin
      I := MY - 11;
      case MY of
        11 .. 17:
          Key := TK_A + I;
      end;
    end;
    if (GetButtonsY = MY) then
    begin
      if (MX >= 26) and (MX <= 39) then
        Key := TK_V;
      if (MX >= 43) and (MX <= 53) then
        Key := TK_ESCAPE;
    end;
  end;
  case Key of
    TK_ESCAPE:
      Scenes.Back;
    TK_A .. TK_G:
      begin
        I := Key - TK_A;
        if Game.Vehicles.Ship[I].InLocation(FTown.X, FTown.Y) then
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
