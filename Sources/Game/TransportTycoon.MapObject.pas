unit TransportTycoon.MapObject;

interface

type
  TLocation = record
    X: Integer;
    Y: Integer;
  end;

type
  TMapObject = class(TObject)
  private
    FLocation: TLocation;
    FName: string;
  public
    constructor Create(const AName: string; const AX, AY: Integer); overload;
    constructor Create(const AX, AY: Integer); overload;
    constructor Create; overload;
    property Name: string read FName write FName;
    property Location: TLocation read FLocation write FLocation;
    procedure SetLocation(const AX, AY: Integer);
    function GetLocation: TLocation;
    function InLocation(const AX, AY: Integer): Boolean;
    property X: Integer read FLocation.X;
    property Y: Integer read FLocation.Y;
  end;

implementation

constructor TMapObject.Create;
begin
  FLocation.X := 0;
  FLocation.Y := 0;
end;

constructor TMapObject.Create(const AX, AY: Integer);
begin
  FLocation.X := AX;
  FLocation.Y := AY;
end;

constructor TMapObject.Create(const AName: string; const AX, AY: Integer);
begin
  FLocation.X := AX;
  FLocation.Y := AY;
  FName := AName;
end;

function TMapObject.GetLocation: TLocation;
begin
  Result := FLocation;
end;

function TMapObject.InLocation(const AX, AY: Integer): Boolean;
begin
  Result := (X = AX) and (Y = AY);
end;

procedure TMapObject.SetLocation(const AX, AY: Integer);
begin
  FLocation.X := AX;
  FLocation.Y := AY;
end;

end.
