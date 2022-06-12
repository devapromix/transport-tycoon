unit TransportTycoon.Game;

interface

uses
  Classes,
  SysUtils,
  TransportTycoon.Map,
  TransportTycoon.Company,
  TransportTycoon.Vehicles,
  TransportTycoon.Finances;

const
  MonStr: array [1 .. 12] of string = ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');

type
  TGame = class(TObject)
  private
    FMoney: Integer;
    FFinances: TFinances;
    FLoan: Integer;
    FCompany: TCompany;
    FVehicles: TVehicles;
    FMap: TMap;
  public const
    MaxLoan = 200000;
    StartMoney = MaxLoan div 2;
    Version = '0.1';
  public
    IsClearLand: Boolean;
    IsPause: Boolean;
    IsGame: Boolean;
    Turn: Integer;
    Day: Integer;
    Month: Integer;
    Year: Integer;
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Step;
    procedure New;
    procedure CityGrow;
    property Money: Integer read FMoney;
    procedure ModifyMoney(const AMoney: Integer); overload;
    procedure ModifyMoney(const ValueEnum: TValueEnum;
      const AMoney: Integer); overload;
    property Loan: Integer read FLoan;
    property Company: TCompany read FCompany;
    property Finances: TFinances read FFinances write FFinances;
    property Vehicles: TVehicles read FVehicles;
    property Map: TMap read FMap;
  end;

var
  Game: TGame;

implementation

uses
  Math,
  TransportTycoon.City,
  TransportTycoon.Scenes;

{ TGame }

constructor TGame.Create;
begin
  FCompany := TCompany.Create;
  FFinances := TFinances.Create;
  IsClearLand := False;
  IsPause := True;
  Self.New;
  Year := 1950;
  FMap := TMap.Create;
  FMap.Gen;
  FVehicles := TVehicles.Create;
end;

destructor TGame.Destroy;
begin
  FMap.Free;
  FVehicles.Free;
  FFinances.Free;
  FCompany.Free;
  inherited Destroy;
end;

procedure TGame.ModifyMoney(const ValueEnum: TValueEnum; const AMoney: Integer);
begin
  Finances.ModifyValue(ValueEnum, Abs(AMoney));
  FMoney := FMoney + AMoney;
end;

procedure TGame.ModifyMoney(const AMoney: Integer);
begin
  FMoney := FMoney + AMoney;
end;

procedure TGame.New;
begin
  Day := 1;
  Month := 1;
end;

procedure TGame.CityGrow;
var
  I: Integer;
begin
  for I := 0 to Length(Map.City) - 1 do
    Map.City[I].Grow;
end;

procedure TGame.Step;
begin
  if not IsGame or IsPause then
    Exit;

  Inc(Turn);
  Inc(Day);
  if Day > 30 then
  begin
    Day := 1;
    Inc(Month);
    Self.CityGrow;
    Game.Vehicles.RunningCosts;
    Game.ModifyMoney(ttLoanInterest, -(Game.Loan div 600));
  end;
  if Month > 12 then
  begin
    Month := 1;
    Inc(Year);
    Scenes.SetScene(scFinances);
  end;

  Vehicles.Step;
end;

procedure TGame.Clear;
begin
  Self.New;
  IsGame := True;
  IsClearLand := False;
  Turn := 0;
  FMoney := StartMoney;
  FLoan := StartMoney;
  FFinances.Clear;
  Map.Gen;
  Company.Clear;
end;

initialization

Game := TGame.Create;

finalization

Game.Free;

end.
