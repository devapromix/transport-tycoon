unit TransportTycoon.Game;

interface

uses
  Classes,
  SysUtils,
  TransportTycoon.Map,
  TransportTycoon.Vehicles,
  TransportTycoon.Finances;

const
  MonStr: array [1 .. 12] of string = ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');

type
  TGame = class(TObject)
  private
    FMoney: Integer;
    FCompanyName: string;
    FCompanyInavgurated: Integer;
    FFinances: TFinances;
    FLoan: Integer;
  public const
    MaxLoan = 200000;
    StartMoney = MaxLoan div 2;
  public
    IsClearLand: Boolean;
    IsPause: Boolean;
    IsGame: Boolean;
    Map: TMap;
    Turn: Integer;
    Day: Integer;
    Month: Integer;
    Year: Integer;
    Vehicles: TVehicles;
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Step;
    procedure New;
    property Money: Integer read FMoney;
    procedure ModifyMoney(const AMoney: Integer); overload;
    procedure ModifyMoney(const ValueEnum: TValueEnum;
      const AMoney: Integer); overload;
    property Loan: Integer read FLoan;
    procedure CityGrow;
    property CompanyName: string read FCompanyName;
    property CompanyInavgurated: Integer read FCompanyInavgurated;
    property Finances: TFinances read FFinances write FFinances;
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
  FFinances := TFinances.Create;
  IsClearLand := False;
  IsPause := True;
  Self.New;
  Year := 1950;
  Map := TMap.Create;
  Map.Gen;
  Vehicles := TVehicles.Create;
end;

destructor TGame.Destroy;
begin
  Map.Free;
  Vehicles.Free;
  FFinances.Free;
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
  FCompanyName := TownNameStr[Math.RandomRange(0, Length(Map.City))] +
    ' TRANSPORT';
  FCompanyInavgurated := Self.Year;
end;

initialization

Game := TGame.Create;

finalization

Game.Free;

end.
