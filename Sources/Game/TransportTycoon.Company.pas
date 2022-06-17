unit TransportTycoon.Company;

interface

type
  TCompany = class(TObject)
  private
    FName: string;
    FInavgurated: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    property Name: string read FName;
    property Inavgurated: Integer read FInavgurated;
    procedure Clear;
  end;

implementation

uses
  TransportTycoon.City,
  TransportTycoon.Game;

procedure TCompany.Clear;
begin
  repeat
    FName := TCity.GenName;
  until Game.Map.HasTownName(FName);
  FName := FName + ' TRANSPORT';
  FInavgurated := Game.Calendar.Year;
end;

constructor TCompany.Create;
begin

end;

destructor TCompany.Destroy;
begin

  inherited;
end;

end.
