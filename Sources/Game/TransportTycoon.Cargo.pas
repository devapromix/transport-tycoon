unit TransportTycoon.Cargo;

interface

type
  TCargo = (cgNone, cgPassengers, cgMail, cgGoods, cgCoal, cgWood);

const
  CargoStr: array [TCargo] of string = ('None', 'Passengers', 'Mail', 'Goods',
    'Coal', 'Wood');

const
  CargoPrice: array [TCargo] of Byte = (0, 7, 8, 9, 10, 9);

type
  TCargoAmount = array [TCargo] of Integer;

type
  TCargoSet = set of TCargo;

implementation

end.
