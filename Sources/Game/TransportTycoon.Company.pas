unit TransportTycoon.Company;

interface

type
  TStatEnum = (seRoad, seTunnel, seCanal, seRoadBridge);

type

  { TStat }

  TStat = class(TObject)
  private
    FSt: array [TStatEnum] of Integer;
  public
    procedure Clear;
    function GetStat(const I: TStatEnum): Integer;
    procedure IncStat(const I: TStatEnum; const Value: Integer);
  end;

type

  { TCompany }

  TCompany = class(TObject)
  private
    FInavgurated: Integer;
    FTownID: Integer;
    FStat: TStat;
  public
    constructor Create;
    destructor Destroy; override;
    property Inavgurated: Integer read FInavgurated;
    property TownID: Integer read FTownID;
    property Stat: TStat read FStat write FStat;
    procedure Clear;
    function Name: string;
    function IsTownHQ: Boolean;
  end;

implementation

uses
  Math,
  TransportTycoon.Game,
  TransportTycoon.Map;

{ TStat }

procedure TStat.Clear;
var
  I: TStatEnum;
begin
  for I := Low(TStatEnum) to High(TStatEnum) do
    FSt[I] := 0;
end;

function TStat.GetStat(const I: TStatEnum): Integer;
begin
  Result := FSt[I];
end;

procedure TStat.IncStat(const I: TStatEnum; const Value: Integer);
begin
  Inc(FSt[I], Value);
end;

{ TCompany }

procedure TCompany.Clear;
begin
  FStat.Clear;
  FTownID := RandomRange(0, MapNoOfTownsInt[Game.Map.NoOfTowns]);
  FInavgurated := Game.Calendar.Year;
end;

constructor TCompany.Create;
begin
  FStat := TStat.Create;
end;

destructor TCompany.Destroy;
begin
  FStat.Free;
  inherited;
end;

function TCompany.IsTownHQ: Boolean;
begin
  Result := Game.Map.CurrentIndustry = FTownID
end;

function TCompany.Name: string;
begin
  Result := Game.Map.Industry[Game.Company.TownID].Name + ' TRANSPORT';
end;

end.
