﻿unit TransportTycoon.Town;

interface

uses
  TransportTycoon.MapObject,
  TransportTycoon.Industries;

const
  AirportSizeStr: array [0 .. 5] of string = ('None', 'Small Airport',
    'Commuter Airport', 'City Airport', 'Metropolitan Airport',
    'International Airport');
  DockSizeStr: array [0 .. 1] of string = ('None', 'Dock');

type

  { TTown }

  TTown = class(TIndustry)
  private
    FPopulation: Integer;
    FHouses: Word;
    FAirport: Integer;
    FCompanyHeadquarters: Integer;
    FDock: Integer;
    function GrowModif: Integer;
  public const
    HQCost = 250;
    DockCost = 9000;
  public
    constructor Create(const AName: string; const AX, AY: Integer);
    property Population: Integer read FPopulation;
    property Houses: Word read FHouses;
    property Airport: Integer read FAirport;
    property CompanyHeadquarters: Integer read FCompanyHeadquarters;
    property Dock: Integer read FDock;
    procedure ModifyPopulation(const APopulation: Integer);
    procedure BuildAirport;
    procedure BuildCompanyHeadquarters;
    procedure BuildDock;
    function AirportCost: Integer;
    procedure Grow;
    class function GenName: string;
    function CanBuildAirport: Boolean;
  end;

implementation

uses
  Math,
  Classes,
  SysUtils,
  TransportTycoon.Game,
  TransportTycoon.Finances;

{ TTown }

function TTown.AirportCost: Integer;
begin
  if (FAirport < 5) then
    Result := (FAirport + 1) * 8000
  else
    Result := 0;
end;

procedure TTown.BuildAirport;
begin
  if CanBuildAirport then
  begin
    Game.ModifyMoney(ttConstruction, -AirportCost);
    Inc(FAirport);
  end;
end;

procedure TTown.BuildCompanyHeadquarters;
begin
  if (FCompanyHeadquarters = 0) and (Game.Map.CurrentTown = Game.Company.TownID)
    and (Game.Money >= HQCost) then
    Game.ModifyMoney(ttConstruction, -HQCost);
  FCompanyHeadquarters := 1;
end;

procedure TTown.BuildDock;
begin
  if (FDock = 0) and (Game.Money >= DockCost) then
  begin
    Game.ModifyMoney(ttConstruction, -DockCost);
    FDock := 1;
  end;
end;

function TTown.CanBuildAirport: Boolean;
begin
  Result := (FAirport < 5) and (Game.Money >= AirportCost);
end;

constructor TTown.Create(const AName: string; const AX, AY: Integer);
begin
  inherited Create(AName, AX, AY);
  Accepts := [cgPassengers, cgBagsOfMail, cgGoods];
  Produces := [cgPassengers, cgBagsOfMail];
  FPopulation := 0;
  ModifyPopulation(Math.RandomRange(250, 1500));
  FAirport := 0;
  FCompanyHeadquarters := 0;
  FDock := 0;
end;

procedure TTown.Grow;
var
  MonthPassengers: Integer;
  MonthBagsOfMail: Integer;
begin
  if Math.RandomRange(0, 25) <= GrowModif then
    ModifyPopulation(Math.RandomRange(GrowModif * 8, GrowModif * 12));
  MonthPassengers := FPopulation div Math.RandomRange(40, 50);
  MonthBagsOfMail := FPopulation div Math.RandomRange(160, 190);
  if Airport > 0 then
  begin
    SetCargoAmount(cgPassengers, MonthPassengers);
    SetCargoAmount(cgBagsOfMail, MonthBagsOfMail);
  end;
end;

class function TTown.GenName: string;
var
  S: array [0 .. 1] of TStringList;
  I: Integer;
begin
  for I := 0 to 1 do
    S[I] := TStringList.Create;
  S[0].DelimitedText :=
    '"Eding","Graning","Vorg","Tra","Nording","Agring","Gran","Funt","Grufing",'
    + '"Trening","Chend","Drinning","Long","Tor"';
  S[1].DelimitedText :=
    '"ville","burg","ley","ly","field","town","well","bridge","ton","stone",' +
    '"hattan"';
  Result := '';
  for I := 0 to 1 do
  begin
    Result := Result + S[I][Random(S[I].Count - 1)];
    S[I].Free;
  end;
end;

function TTown.GrowModif: Integer;
begin
  Result := Airport + Dock { + Trainstation } + 5;
end;

procedure TTown.ModifyPopulation(const APopulation: Integer);
begin
  FPopulation := FPopulation + APopulation;
  FHouses := FPopulation div 30;
end;

end.