unit TransportTycoon.Scene.RoadVehicleDepot;

interface

uses
  TransportTycoon.Scenes,
  TransportTycoon.Industries,
  TransportTycoon.Scene.VehicleDepot;

type
  TSceneRoadVehicleDepot = class(TSceneVehicleDepot)
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
  LSelVehicle: Integer;
begin
  inherited Render;

  FIndustry := Game.Map.Industry[Game.Map.CurrentIndustry];
  DrawTitle(8, FIndustry.Name + ' Road Vehicle Depot');

  LSelVehicle := Math.EnsureRange(Game.Vehicles.CurrentVehicle, 0,
    Length(RoadVehicleBase) - 1);
  DrawVehiclesList(RoadVehicleBase, LSelVehicle);
  DrawVehicleInfo(RoadVehicleBase, LSelVehicle);

  AddButton(20, Game.Vehicles.IsBuyRoadVehicleAllowed, 'Enter',
    'Buy Road Vehicle');
  AddButton(20, 'Esc', 'Close');

  DrawBar;
end;

procedure TSceneRoadVehicleDepot.Update(var Key: Word);
var
  I: Integer;
  LTitle: string;
begin
  inherited Update(Key);
  if (Key = TK_MOUSE_LEFT) then
  begin
    if (GetButtonsY = MY) then
    begin
      case MX of
        21 .. 44:
          Key := TK_ENTER;
        48 .. 58:
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
            LTitle := Format('Road Vehicle #%d (%s)',
              [Game.Vehicles.RoadVehicleCount + 1, RoadVehicleBase[I].Name]);
            Game.Vehicles.AddRoadVehicle(LTitle, Game.Map.CurrentIndustry, I);
            Scenes.Back;
          end;
        end;
      end;
  end;

end;

end.
