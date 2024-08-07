﻿unit TransportTycoon.Company;

interface

uses
  TransportTycoon.Construct;

type

  { TStat }

  TStat = class(TObject)
  private
    FStat: array [TConstructEnum] of Integer;
  public
    procedure Clear;
    function GetStat(const AConstructEnum: TConstructEnum): Integer;
    procedure IncStat(const AConstructEnum: TConstructEnum;
      const AValue: Integer = 1);
    procedure SetStat(const AConstructEnum: TConstructEnum;
      const AValue: Integer);
  end;

type

  { TCompany }

  TCompany = class(TObject)
  private
    FInavgurated: Integer;
    FTownIndex: Integer;
    FStat: TStat;
  public
    constructor Create;
    destructor Destroy; override;
    property Inavgurated: Integer read FInavgurated;
    property TownIndex: Integer read FTownIndex write FTownIndex;
    property Stat: TStat read FStat write FStat;
    procedure Clear;
    function Name: string;
    function IsTownHQ: Boolean;
  end;

implementation

uses
  Math,
  SysUtils,
  TransportTycoon.Game,
  TransportTycoon.Map,
  TransportTycoon.Industries;

{ TStat }

procedure TStat.Clear;
var
  LConstructEnum: TConstructEnum;
begin
  for LConstructEnum := Low(TConstructEnum) to High(TConstructEnum) do
    FStat[LConstructEnum] := 0;
end;

function TStat.GetStat(const AConstructEnum: TConstructEnum): Integer;
begin
  Result := FStat[AConstructEnum];
end;

procedure TStat.IncStat(const AConstructEnum: TConstructEnum;
  const AValue: Integer = 1);
begin
  Inc(FStat[AConstructEnum], AValue);
end;

procedure TStat.SetStat(const AConstructEnum: TConstructEnum;
  const AValue: Integer);
begin
  if AValue <= 0 then
    Exit;
  FStat[AConstructEnum] := AValue;
end;

{ TCompany }

procedure TCompany.Clear;
begin
  FTownIndex := 0;
  FStat.Clear;
  FInavgurated := Game.Calendar.Year;
end;

constructor TCompany.Create;
begin
  FStat := TStat.Create;
end;

destructor TCompany.Destroy;
begin
  FreeAndNil(FStat);
  inherited;
end;

function TCompany.IsTownHQ: Boolean;
begin
  Result := Game.Map.CurrentIndustry = FTownIndex
end;

function TCompany.Name: string;
begin
  Result := Game.Map.Industry[Game.Company.TownIndex].Name + ' TRANSPORT';
end;

end.
