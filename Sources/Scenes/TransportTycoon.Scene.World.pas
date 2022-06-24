unit TransportTycoon.Scene.World;

interface

uses
  TransportTycoon.Scenes;

type

  { TSceneWorld }

  TSceneWorld = class(TScene)
  private
    procedure TownInfo(const TownID: Word);
    procedure IndustryInfo(const IndustryID: Word);
    procedure AircraftInfo(const AircraftID: Word);
    procedure TileInfo(S: string);
  public
    procedure Render; override;
    procedure Update(var Key: Word); override;
  end;

implementation

uses
  Math,
  BearLibTerminal,
  SysUtils,
  TransportTycoon.Map,
  TransportTycoon.Game,
  TransportTycoon.Finances;

{ TSceneWorld }

procedure TSceneWorld.TileInfo(S: string);
var
  L: Integer;
begin
  L := Length(S);
  if L > 18 then
    S := Trim(Copy(S, 1, 14)) + '...';
  DrawText(45, Height - 1, S, TK_ALIGN_CENTER);
end;

procedure TSceneWorld.AircraftInfo(const AircraftID: Word);
var
  VX, VY, L: Integer;
  S: string;
begin
  S := Game.Vehicles.Aircraft[AircraftID].Name;
  L := EnsureRange(Length(S) + 8, 20, 40);
  TileInfo(S);
  if (MY < Height - 10) then
    VY := MY + 1
  else
    VY := MY - 5;
  if (MX < Width - (Width div 2)) then
    VX := MX + 1
  else
    VX := MX - L;
  terminal_bkcolor('darkest gray');
  DrawFrame(VX, VY, L, 5);
  DrawText(VX + (L div 2), VY + 2, '[c=yellow]' + UpperCase(S) + '[/c]',
    TK_ALIGN_CENTER);
  DrawText(MX, MY, '@', 'yellow', 'gray');
end;

procedure TSceneWorld.TownInfo(const TownID: Word);
var
  VX, VY, L: Integer;
  S: string;
begin
  S := Game.Map.Town[TownID].Name;
  L := EnsureRange(Length(S) + 8, 20, 40);
  TileInfo(S);
  if (MY < Height - 10) then
    VY := MY + 1
  else
    VY := MY - 7;
  if (MX < Width - (Width div 2)) then
    VX := MX + 1
  else
    VX := MX - L;
  terminal_bkcolor('darkest gray');
  DrawFrame(VX, VY, L, 7);
  DrawText(VX + (L div 2), VY + 2, '[c=yellow]' + UpperCase(S) + '[/c]',
    TK_ALIGN_CENTER);
  DrawText(VX + (L div 2), VY + 4,
    'Pop.: ' + IntToStr(Game.Map.Town[TownID].Population), TK_ALIGN_CENTER);
  DrawText(MX, MY, '#', 'yellow', 'gray');
end;

procedure TSceneWorld.IndustryInfo(const IndustryID: Word);
var
  VX, VY, L: Integer;
  S: string;
begin
  S := Game.Map.Industry[IndustryID].Name;
  L := Length(S) + 8;
  TileInfo(S);
  if (MY < Height - 10) then
    VY := MY + 1
  else
    VY := MY - 5;
  if (MX < Width - (Width div 2)) then
    VX := MX + 1
  else
    VX := MX - L;
  terminal_bkcolor('darkest gray');
  DrawFrame(VX, VY, L, 5);
  DrawText(VX + (L div 2), VY + 2, '[c=yellow]' + UpperCase(S) + '[/c]',
    TK_ALIGN_CENTER);
  DrawText(MX, MY, Tile[Game.Map.Cell[RX][RY]].Tile, 'yellow', 'gray');
end;

procedure TSceneWorld.Render;
var
  I: Integer;
begin
  DrawMap(Self.Width, Self.Height - 1);

  if Game.IsClearLand then
  begin
    terminal_bkcolor('red');
    terminal_put(MX, MY, $2588);
  end
  else
  begin
    terminal_bkcolor('gray');
    terminal_put(MX, MY, $2588);
  end;
  terminal_color('black');
  terminal_put(MX, MY, Tile[Game.Map.Cell[RX][RY]].Tile);

  DrawBar;

  if (MY < Self.Height - 1) then
  begin
    if Tile[Game.Map.Cell[RX][RY]].Tile = Tile[tlTown].Tile then
      TownInfo(Game.Map.GetCurrentCity(RX, RY))
    else if Game.Map.Cell[RX][RY] in IndustryTiles then
      IndustryInfo(Game.Map.GetCurrentIndustry(RX, RY))
    else
    begin
      I := Game.Vehicles.GetCurrentAircraft(RX, RY);
      if I >= 0 then
        AircraftInfo(I)
      else
        TileInfo(Tile[Game.Map.Cell[RX][RY]].Name);
    end;
  end;
  if (MY = Self.Height - 2) then
    ScrollDown;
  if (MY = 0) then
    ScrollUp;
  if (MX = Self.Width - 1) then
    ScrollRight;
  if (MX = 0) then
    ScrollLeft;
end;

procedure TSceneWorld.Update(var Key: Word);
var
  I: Integer;
begin
  if (Key = TK_MOUSE_LEFT) then
  begin
    if (MY = Self.Height - 1) then
    begin
      if (MX >= 70) then
        Key := TK_ESCAPE;
      if (MX <= 10) then
        Key := TK_F;
      if (MX >= 25) and (MX <= 34) then
        Key := TK_P;
    end
    else
    begin
      if not Game.IsClearLand then
      begin
        if (Game.Map.Cell[RX][RY] = tlTown) then
        begin
          if Game.Map.EnterInCity(RX, RY) then
            Scenes.SetScene(scTown);
          Exit;
        end;
        if (Game.Map.Cell[RX][RY] in IndustryTiles) then
        begin
          if Game.Map.EnterInIndustry(RX, RY) then
            Scenes.SetScene(scIndustry);
          Exit;
        end;
        I := Game.Vehicles.GetCurrentAircraft(RX, RY);
        if I >= 0 then
        begin
          Game.Vehicles.CurrentVehicle := I;
          Scenes.SetScene(scAircraft);
          Exit;
        end;
      end;
      if (Game.Map.Cell[RX][RY] in TreeTiles) then
      begin
        if not Game.IsClearLand then
          Exit;
        Game.Map.ClearLand(RX, RY);
        Scenes.Render;
        Exit;
      end;
    end;
  end;
  if (Key = TK_MOUSE_RIGHT) then
  begin
    if Game.IsClearLand then
    begin
      Game.IsClearLand := False;
      Scenes.Render;
      Exit;
    end;
  end;
  case Key of
    TK_ESCAPE:
      begin
        if Game.IsClearLand then
        begin
          Game.IsClearLand := False;
          Scenes.Render;
          Exit;
        end;
        Scenes.SetScene(scGameMenu);
      end;
    TK_LEFT:
      ScrollLeft;
    TK_RIGHT:
      ScrollRight;
    TK_UP:
      ScrollUp;
    TK_DOWN:
      ScrollDown;
    TK_F:
      Scenes.SetScene(scFinances);
    TK_G:
      Scenes.SetScene(scCompany);
    TK_N:
      Scenes.SetScene(scTowns);
    TK_P:
      begin
        Game.IsPause := not Game.IsPause;
        Scenes.Render
      end;
  end;
end;

end.
