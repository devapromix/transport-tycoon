﻿unit TransportTycoon.Stations;

interface

type

  { TStation }

  TStation = class(TObject)
  private
    FCost: Integer;
    FLevel: Integer;
    FMaxLevel: Integer;
  public
    constructor Create(const ACost: Integer; const AMaxLevel: Integer = 1);
    property Level: Integer read FLevel;
    property MaxLevel: Integer read FMaxLevel;
    function Cost: Integer;
    procedure Build;
    function CanBuild: Boolean;
    function HasBuilding: Boolean;
  end;

type

  { TDock }

  TDock = class(TStation)
    function CanBuild(const X, Y: Integer): Boolean;
  end;

implementation

{ TStation }

uses
  TransportTycoon.Game,
  TransportTycoon.Finances,
  TransportTycoon.Map;

procedure TStation.Build;
begin
  if CanBuild then
  begin
    Game.ModifyMoney(ttConstruction, -Cost);
    Inc(FLevel);
  end;
end;

function TStation.CanBuild: Boolean;
begin
  Result := (FLevel < FMaxLevel) and (Game.Money >= Cost);
end;

function TStation.Cost: Integer;
begin
  Result := 0;
  if (FLevel < FMaxLevel) then
    Result := (FLevel + 1) * FCost;
end;

constructor TStation.Create(const ACost: Integer; const AMaxLevel: Integer = 1);
begin
  FLevel := 0;
  FCost := ACost;
  FMaxLevel := AMaxLevel;
end;

function TStation.HasBuilding: Boolean;
begin
  Result := FLevel > 0;
end;

{ TDock }

function TDock.CanBuild(const X, Y: Integer): Boolean;
begin
  Result := (FLevel < FMaxLevel) and (Game.Money >= Cost) and
    ((Game.Map.IsNearTile(X, Y, tlWater)
    or (Game.Map.IsNearTile(X, Y, tlCanal))))
end;

end.
