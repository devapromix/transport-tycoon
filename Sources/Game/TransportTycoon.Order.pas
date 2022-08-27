unit TransportTycoon.Order;

interface

type
  TOrder = record
    Id: Integer;
    Name: string;
    X, Y: Integer;
  end;

type
  TOrders = class(TObject)
  private
    FOrder: array of TOrder;
    FOrderIndex: Integer;
    function GetOrder(Index: Integer): TOrder;
    procedure SetOrder(Index: Integer; const Value: TOrder);
  public
    property Order[Index: Integer]: TOrder read GetOrder write SetOrder;
    procedure AddOrder(const TownIndex: Integer; const AName: string;
      const AX, AY: Integer);
    procedure DelOrder(const AIndex: Integer);
    function IsOrder(const AIndex: Integer): Boolean;
    procedure IncOrder;
    function Count: Integer;
    property OrderIndex: Integer read FOrderIndex write FOrderIndex;
  end;

implementation

{ TOrders }

procedure TOrders.AddOrder(const TownIndex: Integer; const AName: string;
  const AX, AY: Integer);
begin
  SetLength(FOrder, Length(FOrder) + 1);
  FOrder[High(FOrder)].Id := TownIndex;
  FOrder[High(FOrder)].Name := AName;
  FOrder[High(FOrder)].X := AX;
  FOrder[High(FOrder)].Y := AY;
end;

function TOrders.Count: Integer;
begin
  Result := Length(FOrder);
end;

procedure TOrders.DelOrder(const AIndex: Integer);
var
  I: Integer;
begin
  if (Length(FOrder) > 1) then
  begin
    if AIndex > High(FOrder) then
      Exit;
    if AIndex < Low(FOrder) then
      Exit;
    if AIndex = High(FOrder) then
    begin
      SetLength(FOrder, Length(FOrder) - 1);
      Exit;
    end;
    for I := AIndex + 1 to Length(FOrder) - 1 do
      FOrder[I - 1] := FOrder[I];
    SetLength(FOrder, Length(FOrder) - 1);
  end;
end;

function TOrders.GetOrder(Index: Integer): TOrder;
begin
  Result := FOrder[Index];
end;

procedure TOrders.IncOrder;
begin
  FOrderIndex := FOrderIndex + 1;
  if (FOrderIndex > High(FOrder)) then
    FOrderIndex := 0;
end;

function TOrders.IsOrder(const AIndex: Integer): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Length(FOrder) - 1 do
    if FOrder[I].Id = AIndex then
      Exit(True);
end;

procedure TOrders.SetOrder(Index: Integer; const Value: TOrder);
begin
  FOrder[Index] := Value
end;

end.
