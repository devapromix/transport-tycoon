unit TransportTycoon.City;

interface

const
  TownNameStr: array [0 .. 2] of string = ('EDINGTON', 'GRANINGVILLE',
    'TRABURG');
  AirportSizeStr: array [0 .. 5] of string = ('None', 'Small Airport',
    'Commuter Airport', 'City Airport', 'Metropolitan Airport',
    'International Airport');

type
  TCargo = record
    Airport: Cardinal;
  end;

type
  TCity = class(TObject)
  private
    FName: string;
    FX, FY: Integer;
    FPopulation: Integer;
    FPassengers: TCargo;
    FMail: TCargo;
    FHouses: Word;
    FAirport: Integer;
  public
    constructor Create(const AName: string; const AX, AY: Integer);
    property Population: Integer read FPopulation write FPopulation;
    property Passengers: TCargo read FPassengers;
    property Mail: TCargo read FMail;
    property Houses: Word read FHouses;
    property Name: string read FName;
    property X: Integer read FX;
    property Y: Integer read FY;
    property Airport: Integer read FAirport;
    procedure ModifyPopulation(const APopulation: Integer);
    procedure BuildAirport;
    function AirportCost: Integer;
    procedure Grow;
  end;

implementation

uses
  Math,
  SysUtils,
  TransportTycoon.Game;

function TCity.AirportCost: Integer;
begin
  if (FAirport < 5) then
    Result := (FAirport + 1) * 1000
  else
    Result := 0;
end;

procedure TCity.BuildAirport;
var
  NeedMoney: Integer;
begin
  NeedMoney := AirportCost;
  if (FAirport < 5) and (Game.Money >= NeedMoney) then
  begin
    Game.ModifyMoney(-NeedMoney);
    Inc(FAirport);
  end;
end;

constructor TCity.Create(const AName: string; const AX, AY: Integer);
begin
  FName := AName;
  FX := AX;
  FY := AY;
  FPopulation := Math.RandomRange(250, 1500);
  FHouses := Population div 30;
  FPassengers.Airport := 0;
  FMail.Airport := 0;
  FAirport := 0;
end;

procedure TCity.Grow;
begin
  ModifyPopulation(Math.RandomRange(Airport * 10, Airport * 20));
  if Airport > 0 then
  begin
    FPassengers.Airport := (FPopulation div Math.RandomRange(40, 50) * Airport)
      + Math.RandomRange(1, 10);
    FMail.Airport := (FPopulation div Math.RandomRange(160, 190) * Airport);
  end
  else
  begin
    FPassengers.Airport := 0;
    FMail.Airport := 0;
  end;
end;

procedure TCity.ModifyPopulation(const APopulation: Integer);
begin
  FPopulation := FPopulation + APopulation;
  FHouses := Population div 30;
end;

end.
