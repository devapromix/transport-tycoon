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
  Math,
  TransportTycoon.City,
  TransportTycoon.Game;

procedure TCompany.Clear;
begin
  FName := TownNameStr[Math.RandomRange(0, Length(Game.Map.City))] +
    ' TRANSPORT';
  FInavgurated := Game.Year;
end;

constructor TCompany.Create;
begin

end;

destructor TCompany.Destroy;
begin

  inherited;
end;

end.
