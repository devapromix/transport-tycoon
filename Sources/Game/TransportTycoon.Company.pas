unit TransportTycoon.Company;

interface

uses
  System.Generics.Collections,
  TransportTycoon.Construct;

type

  { TStat }

  TStat = class(TObject)
  private
    FStat: TList<Integer>;
  public
    constructor Create;
    destructor Destroy; override;
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
    property Inavgurated: Integer read FInavgurated write FInavgurated;
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
    FStat[Ord(LConstructEnum)] := 0;
end;

constructor TStat.Create;
var
  LConstructEnum: TConstructEnum;
begin
  FStat := TList<Integer>.Create;
  for LConstructEnum := Low(TConstructEnum) to High(TConstructEnum) do
    FStat.Add(0);
end;

destructor TStat.Destroy;
begin
  FreeAndNil(FStat);
  inherited;
end;

function TStat.GetStat(const AConstructEnum: TConstructEnum): Integer;
begin
  Result := FStat[Ord(AConstructEnum)];
end;

procedure TStat.IncStat(const AConstructEnum: TConstructEnum;
  const AValue: Integer = 1);
begin
  FStat[Ord(AConstructEnum)] := FStat[Ord(AConstructEnum)] + AValue;
end;

procedure TStat.SetStat(const AConstructEnum: TConstructEnum;
  const AValue: Integer);
begin
  if AValue <= 0 then
    Exit;
  FStat[Ord(AConstructEnum)] := AValue;
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
