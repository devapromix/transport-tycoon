unit TransportTycoon.Company;

interface

uses
  System.Generics.Collections,
  TransportTycoon.Construct;

type

  { TCompany }

  TCompany = class(TObject)
  private
    FInavgurated: Integer;
    FTownIndex: Integer;
    FStatistics: TList<Integer>;
  public
    constructor Create;
    destructor Destroy; override;
    property Inavgurated: Integer read FInavgurated write FInavgurated;
    property TownIndex: Integer read FTownIndex write FTownIndex;
    property Statistics: TList<Integer> read FStatistics write FStatistics;
    procedure Clear;
    function GetName: string;
    function IsTownHQ: Boolean;
    procedure IncStatistic(const AConstructEnum: TConstructEnum;
      const AValue: Integer = 1);
    function GetStatistic(const AConstructEnum: TConstructEnum): Integer;
  end;

implementation

uses
  Math,
  SysUtils,
  TransportTycoon.Game,
  TransportTycoon.Map,
  TransportTycoon.Industries;

{ TCompany }

procedure TCompany.Clear;
var
  LConstructEnum: TConstructEnum;
begin
  FTownIndex := 0;
  FInavgurated := Game.Calendar.Year;
  for LConstructEnum := Low(TConstructEnum) to High(TConstructEnum) do
    FStatistics[Ord(LConstructEnum)] := 0;
end;

constructor TCompany.Create;
var
  LConstructEnum: TConstructEnum;
begin
  FStatistics := TList<Integer>.Create;
  for LConstructEnum := Low(TConstructEnum) to High(TConstructEnum) do
    FStatistics.Add(0);
end;

destructor TCompany.Destroy;
begin
  FreeAndNil(FStatistics);
  inherited;
end;

function TCompany.IsTownHQ: Boolean;
begin
  Result := Game.Map.CurrentIndustry = FTownIndex
end;

function TCompany.GetName: string;
begin
  Result := Game.Map.Industry[Game.Company.TownIndex].Name + ' TRANSPORT';
end;

procedure TCompany.IncStatistic(const AConstructEnum: TConstructEnum;
  const AValue: Integer = 1);
begin
  FStatistics[Ord(AConstructEnum)] := FStatistics[Ord(AConstructEnum)] + AValue;
end;

function TCompany.GetStatistic(const AConstructEnum: TConstructEnum): Integer;
begin
  Result := FStatistics[Ord(AConstructEnum)];
end;

end.
