unit TransportTycoon.City;

interface

const
  TownNameStr: array [0 .. 12] of string = ('Edington', 'Graningville',
    'Traburg', 'Nordington', 'Grufingley', 'Funtfield', 'Sadtown', 'Lanwell',
    'Granbridge', 'Trenington', 'Gadstone', 'Chendhattan', 'Drinningwille');
  AirportSizeStr: array [0 .. 5] of string = ('None', 'Small Airport',
    'Commuter Airport', 'City Airport', 'Metropolitan Airport',
    'International Airport');

type
  TCity = class(TObject)
  private
    FName: string;
    FX, FY: Integer;
    FPopulation: Integer;
    FPassengers: Integer;
    FBagsOfMail: Integer;
    FHouses: Word;
    FAirport: Integer;
    function GrowModif: Integer;
  public
    constructor Create(const AName: string; const AX, AY: Integer);
    property Population: Integer read FPopulation;
    property Passengers: Integer read FPassengers write FPassengers;
    property BagsOfMail: Integer read FBagsOfMail write FBagsOfMail;
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
  TransportTycoon.Game,
  TransportTycoon.Finances;

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
    Game.ModifyMoney(ttConstruction, -NeedMoney);
    Inc(FAirport);
  end;
end;

constructor TCity.Create(const AName: string; const AX, AY: Integer);
begin
  FName := AName;
  FX := AX;
  FY := AY;
  FPopulation := 0;
  ModifyPopulation(Math.RandomRange(250, 1500));
  FPassengers := 0;
  FBagsOfMail := 0;
  FAirport := 0;
end;

procedure TCity.Grow;
begin
  if Math.RandomRange(0, 25) <= GrowModif then
    ModifyPopulation(Math.RandomRange(GrowModif * 8, GrowModif * 12));
  if Airport > 0 then
  begin
    FPassengers := (FPopulation div Math.RandomRange(40, 50) * Airport) +
      Math.RandomRange(1, 10);
    FBagsOfMail := (FPopulation div Math.RandomRange(160, 190) * Airport);
  end
  else
  begin
    FPassengers := 0;
    FBagsOfMail := 0;
  end;
end;

function TCity.GrowModif: Integer;
begin
  Result := Airport { + Seaport + Trainstation } + 5;
end;

procedure TCity.ModifyPopulation(const APopulation: Integer);
begin
  FPopulation := FPopulation + APopulation;
  FHouses := FPopulation div 30;
end;

end.
