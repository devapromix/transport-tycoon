unit TransportTycoon.Finances;

interface

type
  TValueEnum = (ttRoadVehicleIncome, ttTrainIncome, ttShipIncome,
    ttAircraftIncome, ttRoadVehicleRunningCosts, ttTrainRunningCosts,
    ttShipRunningCosts, ttAircraftRunningCosts, ttLoanInterest, ttConstruction,
    ttNewVehicles);

type
  TFinances = class(TObject)
  private

  public
    Value: array [TValueEnum] of Integer;
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function Values(const ValueEnum: array of TValueEnum): Integer;
    procedure ModifyValue(const ValueEnum: TValueEnum; const AValue: Integer);
  end;

implementation

procedure TFinances.Clear;
var
  I: TValueEnum;
begin
  for I := Low(TValueEnum) to High(TValueEnum) do
    Value[I] := 0;
end;

constructor TFinances.Create;
begin
  Self.Clear;
end;

destructor TFinances.Destroy;
begin

  inherited;
end;

procedure TFinances.ModifyValue(const ValueEnum: TValueEnum;
  const AValue: Integer);
begin
  Value[ValueEnum] := Value[ValueEnum] + AValue;
end;

function TFinances.Values(const ValueEnum: array of TValueEnum): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to Length(ValueEnum) - 1 do
    Result := Result + Value[ValueEnum[I]];
end;

end.
