unit TransportTycoon.Order;

interface

uses
  TransportTycoon.MapObject;

type

  { TOrder }

  TOrder = class(TMapObject)
  private
    FIndustryIndex: Integer;
  public
    property IndustryIndex: Integer read FIndustryIndex write FIndustryIndex;
  end;

type

  { TOrders }

  TOrders = class(TObject)
  private
    FOrder: TArray<TOrder>;
    FOrderIndex: Integer;
    function GetOrder(AIndex: Integer): TOrder;
    procedure SetOrder(AIndex: Integer; AOrder: TOrder);
  public
    destructor Destroy; override;
    property Order[Index: Integer]: TOrder read GetOrder write SetOrder;
    procedure AddOrder(const AIndustryIndex: Integer;
      const AIndustryName: string; const AX, AY: Integer);
    procedure DelOrder(const AIndex: Integer);
    function IsOrder(const AIndex: Integer): Boolean;
    procedure IncOrder;
    function Count: Integer;
    property OrderIndex: Integer read FOrderIndex write FOrderIndex;
  end;

implementation

uses
  SysUtils;

{ TOrders }

procedure TOrders.AddOrder(const AIndustryIndex: Integer;
  const AIndustryName: string; const AX, AY: Integer);
begin
  SetLength(FOrder, Length(FOrder) + 1);
  FOrder[High(FOrder)] := TOrder.Create(AIndustryName, AX, AY);
  FOrder[High(FOrder)].IndustryIndex := AIndustryIndex;
end;

function TOrders.Count: Integer;
begin
  Result := Length(FOrder);
end;

procedure TOrders.DelOrder(const AIndex: Integer);
var
  LOrder: Integer;
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
    for LOrder := AIndex + 1 to Length(FOrder) - 1 do
      FOrder[LOrder - 1] := FOrder[LOrder];
    SetLength(FOrder, Length(FOrder) - 1);
  end;
end;

destructor TOrders.Destroy;
var
  LOrder: Integer;
begin
  for LOrder := 0 to Count - 1 do
    FreeAndNil(FOrder[LOrder]);
  inherited;
end;

function TOrders.GetOrder(AIndex: Integer): TOrder;
begin
  Result := FOrder[AIndex];
end;

procedure TOrders.IncOrder;
begin
  FOrderIndex := FOrderIndex + 1;
  if (FOrderIndex > High(FOrder)) then
    FOrderIndex := 0;
end;

function TOrders.IsOrder(const AIndex: Integer): Boolean;
var
  LOrder: Integer;
begin
  Result := False;
  for LOrder := 0 to Length(FOrder) - 1 do
    if FOrder[LOrder].IndustryIndex = AIndex then
      Exit(True);
end;

procedure TOrders.SetOrder(AIndex: Integer; AOrder: TOrder);
begin
  FOrder[AIndex] := AOrder
end;

end.
