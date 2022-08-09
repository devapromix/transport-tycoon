unit TransportTycoon.Company;

interface

type
  TCompany = class(TObject)
  private
    FInavgurated: Integer;
    FTownID: Integer;
  public
    property Inavgurated: Integer read FInavgurated;
    property TownID: Integer read FTownID;
    procedure Clear;
    function Name: string;
    function IsTownHQ: Boolean;
  end;

implementation

uses
  Math,
  TransportTycoon.Game,
  TransportTycoon.Map;

procedure TCompany.Clear;
begin
  FTownID := RandomRange(0, MapNoOfTownsInt[Game.Map.NoOfTowns]);
  FInavgurated := Game.Calendar.Year;
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
