unit TransportTycoon.Vehicle;

interface

uses
  TransportTycoon.MapObject;

type
  TGetXYVal = function(X, Y: Integer): Boolean; stdcall;

type
  TVehicle = class(TMapObject)
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
