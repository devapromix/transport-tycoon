unit TransportTycoon.Vehicle;

interface

type
  TVehicle = class(TObject)
  private
  public
    constructor Create;
    destructor Destroy; override;
    procedure Draw; virtual; abstract;
    procedure Step; virtual; abstract;
    function Move(const AX, AY: Integer): Boolean; virtual; abstract;
  end;

implementation

constructor TVehicle.Create;
begin

end;

destructor TVehicle.Destroy;
begin

  inherited;
end;

end.
