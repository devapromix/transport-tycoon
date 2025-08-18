unit TransportTycoon.Scene.TrainDepot;

interface

uses
  TransportTycoon.Scenes,
  TransportTycoon.Industries,
  TransportTycoon.Scene.VehicleDepot;

type
  TSceneTrainDepot = class(TSceneVehicleDepot)
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
  TransportTycoon.Train,
  TransportTycoon.Vehicles,
  TransportTycoon.Cargo;

procedure TSceneTrainDepot.Render;
var
  LVehicle: Integer;
begin
  inherited Render;

  FIndustry := Game.Map.Industry[Game.Map.CurrentIndustry];
  DrawTitle(8, FIndustry.Name + ' Train Depot');

  LVehicle := Math.EnsureRange(Game.Vehicles.CurrentVehicle, 0,
    Length(TrainBase) - 1);
  DrawVehiclesList(TrainBase, LVehicle);
  DrawVehicleInfo(TrainBase, LVehicle);

  AddButton(20, Game.Vehicles.IsBuyTrainAllowed, 'Enter', 'Buy Train');
  AddButton(20, 'Esc', 'Close');

  DrawGameBar;
end;

procedure TSceneTrainDepot.Update(var AKey: Word);
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
        if LVehicle > Length(TrainBase) - 1 then
          Exit;
        if TrainBase[LVehicle].Since > Game.Calendar.Year then
          Exit;
        Game.Vehicles.CurrentVehicle := LVehicle;
        Scenes.Render;
      end;
    TK_ENTER:
      begin
        if Game.Vehicles.IsBuyTrainAllowed then
        begin
          LVehicle := Game.Vehicles.CurrentVehicle;
          if (Game.Money >= TrainBase[LVehicle].Cost) then
          begin
            LTitle := Format('Train #%d (%s)',
              [Game.Vehicles.TrainCount + 1, TrainBase[LVehicle].Name]);
            Game.Vehicles.AddTrain(LTitle, Game.Map.CurrentIndustry,
              LVehicle);
            Scenes.Back;
          end;
        end;
      end;
  end;

end;

end.
