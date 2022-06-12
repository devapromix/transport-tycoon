unit TransportTycoon.Vehicle;

interface

type
  TVehicle = class(TObject)
  private
    FVehicleID: Integer;
  public
    procedure Draw; virtual; abstract;
    procedure Step; virtual; abstract;
    function Move(const AX, AY: Integer): Boolean; virtual; abstract;
    property VehicleID: Integer read FVehicleID write FVehicleID;
  end;

implementation

end.
