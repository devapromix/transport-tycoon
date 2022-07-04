unit TransportTycoon.Cargo;

interface

type
  TCargo = (cgPassengers, cgMail, cgGoods, cgCoal, cgWood);

const
  CargoStr: array [TCargo] of string = ('Passengers', 'Mail', 'Goods',
    'Coal', 'Wood');

type
  TCargoAmount = array [TCargo] of Integer;

type
  TCargoSet = set of TCargo;

implementation

end.
