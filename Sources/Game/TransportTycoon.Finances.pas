unit TransportTycoon.Finances;

interface

uses
  TransportTycoon.Calendar;

type
  TValueEnum = (ttRoadVehicleIncome, ttTrainIncome, ttShipIncome,
    ttAircraftIncome, ttRoadVehicleRunningCosts, ttTrainRunningCosts,
    ttShipRunningCosts, ttAircraftRunningCosts, ttLoanInterest, ttConstruction,
    ttNewVehicles);

type

  { TFinanceYear }

  TFinanceYear = class(TObject)
  private
    FValue: array [TValueEnum] of Integer;
  public
    constructor Create;
    procedure Clear;
    function Value(const AValueEnum: TValueEnum): Integer;
    function Values(const AValuesEnum: array of TValueEnum): Integer;
    procedure ModifyValue(const AValueEnum: TValueEnum; const AValue: Integer);
  end;

type

  { TFinances }

  TFinances = class(TObject)
  private
    FFinanceYear: array [StartYear .. FinishYear] of TFinanceYear;
    FIsYear: array [StartYear .. FinishYear] of Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function Count: Integer;
    function Value(const AValueEnum: TValueEnum; const AYear: Word): Integer;
    function Values(const AValuesEnum: array of TValueEnum;
      const AYear: Word): Integer;
    procedure ModifyValue(const AValueEnum: TValueEnum; const AValue: Integer);
    procedure SetYear(const AYear: Word);
  end;

implementation

{ TFinanceYear }

uses
  SysUtils,
  TransportTycoon.Game;

procedure TFinanceYear.Clear;
var
  LValueEnum: TValueEnum;
begin
  for LValueEnum := Low(TValueEnum) to High(TValueEnum) do
    FValue[LValueEnum] := 0;
end;

constructor TFinanceYear.Create;
begin
  Self.Clear;
end;

procedure TFinanceYear.ModifyValue(const AValueEnum: TValueEnum;
  const AValue: Integer);
begin
  FValue[AValueEnum] := FValue[AValueEnum] + AValue;
end;

function TFinanceYear.Value(const AValueEnum: TValueEnum): Integer;
begin
  Result := FValue[AValueEnum];
end;

function TFinanceYear.Values(const AValuesEnum: array of TValueEnum): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to Length(AValuesEnum) - 1 do
    Result := Result + FValue[AValuesEnum[I]];
end;

{ TFinances }

procedure TFinances.Clear;
var
  LYear: Word;
begin
  for LYear := StartYear to FinishYear do
  begin
    FFinanceYear[LYear].Clear;
    FIsYear[LYear] := False;
  end;
end;

function TFinances.Count: Integer;
var
  LYear: Word;
begin
  Result := 0;
  for LYear := StartYear to FinishYear do
    if FIsYear[LYear] then
      Inc(Result);
end;

constructor TFinances.Create;
var
  LYear: Word;
begin
  for LYear := StartYear to FinishYear do
    FFinanceYear[LYear] := TFinanceYear.Create;
  Clear;
end;

destructor TFinances.Destroy;
var
  LYear: Word;
begin
  for LYear := StartYear to FinishYear do
    FreeAndNil(FFinanceYear[LYear]);
  inherited;
end;

procedure TFinances.ModifyValue(const AValueEnum: TValueEnum;
  const AValue: Integer);
begin
  FFinanceYear[Game.Calendar.Year].ModifyValue(AValueEnum, AValue);
end;

procedure TFinances.SetYear(const AYear: Word);
begin
  FIsYear[AYear] := True;
end;

function TFinances.Value(const AValueEnum: TValueEnum;
  const AYear: Word): Integer;
begin
  Result := FFinanceYear[AYear].Value(AValueEnum);
end;

function TFinances.Values(const AValuesEnum: array of TValueEnum;
  const AYear: Word): Integer;
begin
  Result := FFinanceYear[AYear].Values(AValuesEnum);
end;

end.
