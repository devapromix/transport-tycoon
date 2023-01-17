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
    procedure Update(var AKey: Word); override;
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
  LVehicle: Integer;
begin
  inherited Render;

  FIndustry := Game.Map.Industry[Game.Map.CurrentIndustry];
  DrawTitle(8, FIndustry.Name + ' Road Vehicle Depot');

  LVehicle := Math.EnsureRange(Game.Vehicles.CurrentVehicle, 0,
    Length(RoadVehicleBase) - 1);
  DrawVehiclesList(RoadVehicleBase, LVehicle);
  DrawVehicleInfo(RoadVehicleBase, LVehicle);

  AddButton(20, Game.Vehicles.IsBuyRoadVehicleAllowed, 'Enter',
    'Buy Road Vehicle');
  AddButton(20, 'Esc', 'Close');

  DrawGameBar;
end;

procedure TSceneRoadVehicleDepot.Update(var AKey: Word);
var
  LVehicle: Integer;
  LTitle: string;
begin
  inherited Update(AKey);
  if (AKey = TK_MOUSE_LEFT) then
  begin
    if (GetButtonsY = MY) then
    begin
      case MX of
        21 .. 44:
          AKey := TK_ENTER;
        48 .. 58:
          AKey := TK_ESCAPE;
      end;
    end;
  end;
  case AKey of
    TK_ESCAPE:
      Scenes.Back;
    TK_A .. TK_I:
      begin
        LVehicle := AKey - TK_A;
        if LVehicle > Length(RoadVehicleBase) - 1 then
          Exit;
        if RoadVehicleBase[LVehicle].Since > Game.Calendar.Year then
          Exit;
        Game.Vehicles.CurrentVehicle := LVehicle;
        Scenes.Render;
      end;
    TK_ENTER:
      begin
        if Game.Vehicles.IsBuyRoadVehicleAllowed then
        begin
          LVehicle := Game.Vehicles.CurrentVehicle;
          if (Game.Money >= RoadVehicleBase[LVehicle].Cost) then
          begin
            LTitle := Format('Road Vehicle #%d (%s)',
              [Game.Vehicles.RoadVehicleCount + 1,
              RoadVehicleBase[LVehicle].Name]);
            Game.Vehicles.AddRoadVehicle(LTitle, Game.Map.CurrentIndustry,
              LVehicle);
            Scenes.Back;
          end;
        end;
      end;
  end;

end;

end.
