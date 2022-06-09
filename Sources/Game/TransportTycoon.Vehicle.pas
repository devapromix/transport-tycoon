unit TransportTycoon.Vehicle;

interface

type
  TVehicle = class(TObject)
  private
  public
    procedure Draw; virtual; abstract;
    procedure Step; virtual; abstract;
    function Move(const AX, AY: Integer): Boolean; virtual; abstract;
  end;

implementation

end.
