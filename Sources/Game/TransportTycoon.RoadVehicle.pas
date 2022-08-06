unit TransportTycoon.RoadVehicle;

interface

uses
  TransportTycoon.Vehicle,
  TransportTycoon.Cargo;

type
  TRoadVehicleBase = record
    Name: string;
    Cargo: TCargoSet;
    Amount: Integer;
    Cost: Word;
    RunningCost: Word;
    Speed: Word;
    Since: Word;
  end;

const
  RoadVehicleBase: array [0 .. 0] of TRoadVehicleBase = (
    // #1
    (Name: 'Perry Bus'; Cargo: [cgPassengers]; Amount: 27; Cost: 4000;
    RunningCost: 18 * 12; Speed: 60; Since: 1950)
    //
    );

type

  { TRoadVehicle }

  TRoadVehicle = class(TVehicle)
  private
    FT: Integer;
    FState: string;
    FCargoAmount: Integer;
    FCargoMaxAmount: Integer;
    FCargo: TCargoSet;
    FCargoType: TCargo;
  public
    constructor Create(const AName: string; const AX, AY, ID: Integer);
    function Move(const AX, AY: Integer): Boolean; override;
    property State: string read FState;
    property Cargo: TCargoSet read FCargo;
    property CargoAmount: Integer read FCargoAmount;
    property CargoMaxAmount: Integer read FCargoMaxAmount;
    property CargoType: TCargo read FCargoType;
    procedure Step; override;
    procedure Load; override;
    procedure UnLoad; override;
    procedure AddOrder(const AIndex: Integer); overload;
  end;

implementation

uses
  SysUtils,
  TransportTycoon.Map,
  TransportTycoon.Game,
  TransportTycoon.Finances,
  TransportTycoon.PathFind,
  TransportTycoon.Industries,
  TransportTycoon.Stations;

{ TRoadVehicle }

function IsPath(X, Y: Integer): Boolean; stdcall;
begin
  Result := Game.Map.IsRoadVehiclePath(X, Y);
end;

procedure TRoadVehicle.AddOrder(const AIndex: Integer);
begin
  with Game.Map.Industry[AIndex] do
    AddOrder(AIndex, Name, X, Y);
end;

constructor TRoadVehicle.Create(const AName: string; const AX, AY, ID: Integer);
begin
  inherited Create(AName, AX, AY);
  FT := 0;
  FState := 'Wait';
  FCargoAmount := 0;
  FCargoMaxAmount := RoadVehicleBase[ID].Amount;
  FCargo := RoadVehicleBase[ID].Cargo;
  FCargoType := cgNone;
end;

procedure TRoadVehicle.Load;
var
  Cargo: TCargo;
begin
  FState := 'Load';
  for Cargo := Succ(Low(TCargo)) to High(TCargo) do
    if (Cargo in Game.Map.Industry[Order[OrderIndex].ID].Produces) and
      (Cargo in FCargo) then
    begin
      FCargoType := Cargo;
      while (Game.Map.Industry[Order[OrderIndex].ID].ProducesAmount[Cargo] > 0)
        and (FCargoAmount < FCargoMaxAmount) do
      begin
        Game.Map.Industry[Order[OrderIndex].ID].DecCargoAmount(Cargo);
        Inc(FCargoAmount);
      end;
      Exit;
    end;
end;

function TRoadVehicle.Move(const AX, AY: Integer): Boolean;
var
  NX, NY: Integer;
begin
  Result := False;
  FState := 'Move';
  NX := 0;
  NY := 0;
  if not IsMove(Game.Map.Width, Game.Map.Height, X, Y, AX, AY, @IsPath, NX, NY)
  then
    Exit;
  SetLocation(NX, NY);
  Result := (X <> AX) or (Y <> AY);
end;

procedure TRoadVehicle.Step;
var
  Cargo: TCargo;
  Station: TStation;
begin
  if Length(Order) > 0 then
  begin
    if not Move(Order[OrderIndex].X, Order[OrderIndex].Y) then
    begin
      Inc(FT);
      if Order[OrderIndex].ID <> LastStationId then
        UnLoad;
      case FCargoType of
        cgPassengers, cgMail:
          Station := TTownIndustry(Game.Map.Industry[Order[OrderIndex].ID])
            .BusStation;
      else
        Station := Game.Map.Industry[Order[OrderIndex].ID].TruckLoadingBay;
      end;
      FState := 'Service';
      if FT > (15 - (Station.Level * 2)) then
      begin
        FT := 0;
        Load;
        if FullLoad then
          for Cargo := Succ(Low(TCargo)) to High(TCargo) do
            if (Cargo in Game.Map.Industry[Order[OrderIndex].ID].Produces) and
              (Cargo in FCargo) then
            begin
              FCargoType := Cargo;
              if (FCargoAmount < FCargoMaxAmount) then
                Exit;
            end;
        IncOrder;
      end
      else
        IncDistance;
    end;
  end;
end;

procedure TRoadVehicle.UnLoad;
var
  Money: Integer;
begin
  SetLastStation;
  FState := 'Unload';
  if (CargoType in Game.Map.Industry[Order[OrderIndex].ID].Accepts) and
    (CargoType <> cgNone) and (CargoAmount > 0) then
  begin
    Money := (FCargoAmount * (Distance div 10)) * CargoPrice[CargoType];
    Game.Map.Industry[Order[OrderIndex].ID].IncAcceptsCargoAmount(CargoType,
      CargoAmount);
    Game.ModifyMoney(ttRoadVehicleIncome, Money);
    FCargoAmount := 0;
    FCargoType := cgNone;
  end;
  Distance := 0;
end;

end.
