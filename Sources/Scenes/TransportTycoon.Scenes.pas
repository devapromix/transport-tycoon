unit TransportTycoon.Scenes;

interface

uses
  BearLibTerminal;

type
  TSceneEnum = (scMainMenu, scGameMenu, scGenMenu, scWorld, scTown,
    scBuildInTown, scAirport, scAircraftHangar, scAircraft, scAircrafts,
    scFinances, scTowns, scCompany, scIndustry, scBuildNearIndustry, scDock,
    scShip, scShips, scShipDepot, scIndustries, scBuildMenu, scSettingsMenu,
    scOpenGameMenu, scRoadVehicle, scRoadVehicles, scTruckLoadingBay,
    scBusStation, scRoadVehicleDepot);

type
  TButtonRec = record
    ButtonIsActive: Boolean;
    ButtonKey: string;
    ButtonLabel: string;
  end;

type
  TScene = class(TObject)
  private
    FMX: Integer;
    FMY: Integer;
    FRX: Integer;
    FRY: Integer;
    FButtonsY: Integer;
    FButtons: array [0 .. 4] of TButtonRec;
    FTextLineY: Integer;
  public
    procedure Render; virtual; abstract;
    procedure Update(var Key: Word); virtual; abstract;
    procedure DrawText(const X, Y: Integer;
      Text, Color, BkColor: string); overload;
    procedure DrawText(const X, Y: Integer; Text: string;
      const Align: Integer = TK_ALIGN_LEFT); overload;
    procedure DrawText(const Y: Integer; Text: string); overload;
    procedure DrawTextLine(const X: Integer; const Text: string);
    procedure DrawMoney(const X, Y, Money: Integer;
      const Align: Integer = TK_ALIGN_RIGHT; F: Boolean = False);
    procedure DrawButton(const X, Y: Integer; IsActive: Boolean;
      Button, Text: string); overload;
    procedure DrawButton(const X, Y, W: Integer; IsActive, IsFlag: Boolean;
      Button, Text: string); overload;
    procedure DrawButton(const Y: Integer; IsActive: Boolean;
      Button, Text: string); overload;
    procedure DrawButton(const X, Y: Integer; Button, Text: string); overload;
    procedure DrawButton(const X, Y: Integer;
      Button, Text, Color: string); overload;
    procedure DrawButton(const Y: Integer; Button, Text: string); overload;
    function MakeButton(const IsActive: Boolean;
      const Button, Text: string): string;
    procedure DrawTitle(const Y: Integer; const Title: string); overload;
    procedure DrawTitle(const Title: string); overload;
    procedure DrawFrame(const X, Y, W, H: Integer);
    procedure DrawMap(const AWidth, AHeight: Integer);
    procedure ClearButtons;
    procedure AddButton(const Y: Integer; const Button, Text: string); overload;
    procedure AddButton(const Y: Integer; const IsActive: Boolean;
      const Button, Text: string); overload;
    function GetButton(const N: Integer): TButtonRec;
    function GetButtonsY: Integer;
    procedure RenderButtons;
    procedure DrawBar;
    function ScreenWidth: Integer;
    function ScreenHeight: Integer;
    property MX: Integer read FMX write FMX;
    property MY: Integer read FMY write FMY;
    property RX: Integer read FRX write FRX;
    property RY: Integer read FRY write FRY;
    procedure ScrollTo(const X, Y: Integer);
    procedure ScrollUp;
    procedure ScrollDown;
    procedure ScrollLeft;
    procedure ScrollRight;
    function Check(const F: Boolean): string;
    property TextLineY: Integer read FTextLineY write FTextLineY;
    function StrLim(const S: string; const N: Integer): string;
  end;

type
  TScenes = class(TScene)
  private
    FScene: array [TSceneEnum] of TScene;
    FSceneEnum: TSceneEnum;
    FBackSceneEnum: array [0 .. 2] of TSceneEnum;
    FCurrentVehicleScene: TSceneEnum;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Render; override;
    procedure Update(var Key: Word); override;
    property Scene: TSceneEnum read FSceneEnum write FSceneEnum;
    function GetScene(I: TSceneEnum): TScene;
    procedure SetScene(SceneEnum: TSceneEnum); overload;
    procedure SetScene(SceneEnum, BackSceneEnum: TSceneEnum); overload;
    property CurrentVehicleScene: TSceneEnum read FCurrentVehicleScene
      write FCurrentVehicleScene;
    procedure Back;
    procedure ClearQScenes;
  end;

var
  Scenes: TScenes;

implementation

uses
  Math,
  SysUtils,
  TransportTycoon.Log,
  TransportTycoon.Map,
  TransportTycoon.Game,
  TransportTycoon.Scene.GenMenu,
  TransportTycoon.Scene.MainMenu,
  TransportTycoon.Scene.GameMenu,
  TransportTycoon.Scene.Town,
  TransportTycoon.Scene.World,
  TransportTycoon.Scene.Industries,
  TransportTycoon.Scene.BuildInTown,
  TransportTycoon.Scene.Airport,
  TransportTycoon.Scene.AircraftHangar,
  TransportTycoon.Scene.Aircraft,
  TransportTycoon.Scene.Aircrafts,
  TransportTycoon.Scene.Finances,
  TransportTycoon.Scene.Towns,
  TransportTycoon.Scene.Company,
  TransportTycoon.Scene.Industry,
  TransportTycoon.Scene.BuildNearIndustry,
  TransportTycoon.Scene.Dock,
  TransportTycoon.Scene.Ships,
  TransportTycoon.Scene.Ship,
  TransportTycoon.Scene.ShipDepot,
  TransportTycoon.Scene.BuildMenu,
  TransportTycoon.Scene.Menu.Settings,
  TransportTycoon.Scene.Menu.OpenGame,
  TransportTycoon.Scene.RoadVehicle,
  TransportTycoon.Scene.BusStation,
  TransportTycoon.Scene.TruckLoadingBay,
  TransportTycoon.Scene.RoadVehicleDepot,
  TransportTycoon.Scene.RoadVehicles,
  TransportTycoon.Palette;

procedure TScene.DrawText(const X, Y: Integer; Text: string;
  const Align: Integer = TK_ALIGN_LEFT);
begin
  terminal_print(X, Y, Align, Text);
end;

procedure TScene.DrawTitle(const Y: Integer; const Title: string);
begin
  terminal_print(ScreenWidth div 2, Y, TK_ALIGN_CENTER, '[c=' + TPalette.Title +
    ']' + UpperCase(Title) + '[/c]');
end;

procedure TScene.DrawText(const Y: Integer; Text: string);
begin
  terminal_print(ScreenWidth div 2, Y, TK_ALIGN_CENTER, Text);
end;

procedure TScene.DrawTextLine(const X: Integer; const Text: string);
begin
  DrawText(X, FTextLineY, Text);
  Inc(FTextLineY);
end;

procedure TScene.DrawText(const X, Y: Integer; Text, Color, BkColor: string);
begin
  terminal_color(Color);
  terminal_bkcolor(BkColor);
  terminal_print(X, Y, Text);
end;

procedure TScene.DrawTitle(const Title: string);
begin
  DrawTitle(9, Title);
end;

function TScene.GetButton(const N: Integer): TButtonRec;
begin
  Result := FButtons[N];
end;

function TScene.GetButtonsY: Integer;
begin
  Result := FButtonsY;
end;

procedure TScene.DrawButton(const X, Y: Integer; Button, Text: string);
begin
  terminal_print(X, Y, Format('[c=%s][[%s]][/c] [c=%s]%s[/c]',
    [TPalette.ButtonKey, UpperCase(Button), TPalette.Default,
    UpperCase(Text)]));
end;

procedure TScene.AddButton(const Y: Integer; const Button, Text: string);
begin
  AddButton(Y, True, Button, Text);
end;

procedure TScene.AddButton(const Y: Integer; const IsActive: Boolean;
  const Button, Text: string);
var
  I: Integer;
begin
  FButtonsY := Y;
  for I := Low(FButtons) to High(FButtons) do
    if (FButtons[I].ButtonKey = '') then
    begin
      FButtons[I].ButtonIsActive := IsActive;
      FButtons[I].ButtonKey := Button;
      FButtons[I].ButtonLabel := Text;
      Exit;
    end;
end;

procedure TScene.ClearButtons;
var
  I: Integer;
begin
  for I := Low(FButtons) to High(FButtons) do
  begin
    FButtons[I].ButtonKey := '';
    FButtons[I].ButtonLabel := '';
  end;
end;

procedure TScene.DrawBar;
var
  Y: Integer;
begin
  try
    Y := Self.ScreenHeight - 1;
    terminal_color(TPalette.Default);
    terminal_bkcolor(TPalette.Background);
    terminal_clear_area(0, Y, 80, 1);
    DrawMoney(0, Y, Game.Money, TK_ALIGN_LEFT, True);
    DrawText(12, Y, Format('Turn:%d', [Game.Turn]));
    DrawText(56, Y, Game.Calendar.GetDate);
    if (Scenes.FSceneEnum <> scWorld) then
      DrawButton(70, Y, False, 'ESC', 'MENU')
    else
      DrawButton(70, Y, 'ESC', 'MENU');
    if (Scenes.FSceneEnum <> scWorld) and (Scenes.FSceneEnum <> scGameMenu) then
    begin
      if Game.IsPause then
        DrawButton(25, Y, False, 'P', 'Paused')
      else
        DrawButton(25, Y, False, 'P', 'Pause');
    end
    else
    begin
      if Game.IsPause then
        DrawText(25, ScreenHeight - 1, '[c=' + TPalette.ButtonKey +
          '][[P]][/c] [c=red]PAUSED[/c]')
      else
        DrawButton(25, Y, 'P', 'Pause');
    end;
  except
    on E: Exception do
      Log.Add('TScene.DrawBar', E.Message);
  end;
end;

procedure TScene.DrawButton(const Y: Integer; Button, Text: string);
begin
  terminal_print(ScreenWidth div 2, Y, TK_ALIGN_CENTER,
    Format('[c=%s][[%s]][/c] [c=%s]%s[/c]', [TPalette.ButtonKey,
    UpperCase(Button), TPalette.Default, UpperCase(Text)]));
end;

procedure TScene.DrawButton(const X, Y, W: Integer; IsActive, IsFlag: Boolean;
  Button, Text: string);
begin
  DrawButton(X, Y, IsActive, Button, Text);
  DrawText(X + W - 4, Y, '[c=' + TPalette.Default + '][[' + Check(IsFlag) +
    ']][/c]');
end;

procedure TScene.DrawButton(const X, Y: Integer; Button, Text, Color: string);
begin
  terminal_print(X, Y, Format('[c=%s][[%s]][/c] [c=%s]%s[/c]',
    [TPalette.ButtonKey, UpperCase(Button), Color, UpperCase(Text)]));
end;

procedure TScene.DrawButton(const X, Y: Integer; IsActive: Boolean;
  Button, Text: string);
begin
  terminal_print(X, Y, MakeButton(IsActive, Button, Text));
end;

procedure TScene.DrawButton(const Y: Integer; IsActive: Boolean;
  Button, Text: string);
begin
  terminal_print(ScreenWidth div 2, Y, TK_ALIGN_CENTER,
    MakeButton(IsActive, Button, Text));
end;

procedure TScene.DrawFrame(const X, Y, W, H: Integer);
var
  I: Integer;
begin
  terminal_clear_area(X, Y, W, H);
  for I := X + 1 to X + W - 2 do
  begin
    terminal_put(I, Y, $2550);
    terminal_put(I, Y + H - 1, $2550);
  end;
  for I := Y + 1 to Y + H - 2 do
  begin
    terminal_put(X, I, $2551);
    terminal_put(X + W - 1, I, $2551);
  end;
  terminal_put(X, Y, $2554);
  terminal_put(X + W - 1, Y, $2557);
  terminal_put(X, Y + H - 1, $255A);
  terminal_put(X + W - 1, Y + H - 1, $255D);
end;

procedure TScene.DrawMap(const AWidth, AHeight: Integer);
begin
  try
    Game.Map.Draw(AWidth, AHeight);
    Game.Vehicles.Draw;
  except
    on E: Exception do
      Log.Add('TScene.DrawMap', E.Message);
  end;
end;

procedure TScene.DrawMoney(const X, Y, Money: Integer;
  const Align: Integer = TK_ALIGN_RIGHT; F: Boolean = False);
begin
  if Money = 0 then
    terminal_print(X, Y, Align, Format('[c=%s]$%d[/c]',
      [TPalette.Default, Money]));
  if Money > 0 then
    if F then
      terminal_print(X, Y, Align, Format('[c=green]$%d[/c]', [Money]))
    else
      terminal_print(X, Y, Align, Format('[c=green]+$%d[/c]', [Money]));
  if Money < 0 then
    terminal_print(X, Y, Align, Format('[c=red]-$%d[/c]', [Abs(Money)]));
end;

function TScene.ScreenWidth: Integer;
begin
  Result := terminal_state(TK_WIDTH);
end;

function TScene.ScreenHeight: Integer;
begin
  Result := terminal_state(TK_HEIGHT);
end;

procedure TScene.ScrollTo(const X, Y: Integer);
begin
  try
    Game.Map.Left := EnsureRange(X - (ScreenWidth div 2), 0,
      Game.Map.Width - ScreenWidth);
    Game.Map.Top := EnsureRange(Y - (ScreenHeight div 2), 0,
      Game.Map.Height - ScreenHeight);
  except
    on E: Exception do
      Log.Add('TScene.ScrollTo', E.Message);
  end;
end;

procedure TScene.ScrollUp;
begin
  try
    if (Game.Map.Top > 0) then
      Game.Map.Top := Game.Map.Top - 1;
  except
    on E: Exception do
      Log.Add('TScenes.ScrollUp', E.Message);
  end;
end;

function TScene.StrLim(const S: string; const N: Integer): string;
begin
  if Length(S) > N then
  begin
    Result := Trim(Copy(S, 1, N - 3)) + '...';
  end
  else
    Result := S;
end;

function TScene.Check(const F: Boolean): string;
begin
  if F then
    Result := 'X'
  else
    Result := #32;
end;

procedure TScene.ScrollDown;
begin
  try
    if (Game.Map.Top <= Game.Map.Height - Self.ScreenHeight) then
      Game.Map.Top := Game.Map.Top + 1;
  except
    on E: Exception do
      Log.Add('TScenes.ScrollDown', E.Message);
  end;
end;

procedure TScene.ScrollLeft;
begin
  try
    if (Game.Map.Left > 0) then
      Game.Map.Left := Game.Map.Left - 1;
  except
    on E: Exception do
      Log.Add('TScene.ScrollLeft', E.Message);
  end;
end;

procedure TScene.ScrollRight;
begin
  try
    if (Game.Map.Left < Game.Map.Width - Self.ScreenWidth) then
      Game.Map.Left := Game.Map.Left + 1;
  except
    on E: Exception do
      Log.Add('TScene.ScrollRight', E.Message);
  end;
end;

function TScene.MakeButton(const IsActive: Boolean;
  const Button, Text: string): string;
var
  ColorButton, ColorText: string;
begin
  if IsActive then
  begin
    ColorButton := TPalette.ButtonKey;
    ColorText := TPalette.Default;
  end
  else
  begin
    ColorButton := TPalette.Unused;
    ColorText := TPalette.Unused;
  end;
  Result := Format('[c=' + ColorButton + '][[%s]][/c] [c=' + ColorText +
    ']%s[/c]', [UpperCase(Button), UpperCase(Text)]);
end;

procedure TScene.RenderButtons;
var
  I: Integer;
  S: string;
begin
  S := '';
  for I := Low(FButtons) to High(FButtons) do
    if (FButtons[I].ButtonKey <> '') then
    begin
      S := S + MakeButton(FButtons[I].ButtonIsActive, FButtons[I].ButtonKey,
        FButtons[I].ButtonLabel);
      if (I < High(FButtons)) and (FButtons[I + 1].ButtonKey <> '') then
        S := S + ' | ';
    end;
  terminal_print(ScreenWidth div 2, FButtonsY, TK_ALIGN_CENTER, S);
end;

constructor TScenes.Create;
begin
  inherited;
  ClearQScenes;
  FScene[scMainMenu] := TSceneMainMenu.Create;
  FScene[scGameMenu] := TSceneGameMenu.Create;
  FScene[scGenMenu] := TSceneGenMenu.Create;
  FScene[scWorld] := TSceneWorld.Create;
  FScene[scTown] := TSceneTown.Create;
  FScene[scBuildInTown] := TSceneBuildInTown.Create;
  FScene[scAirport] := TSceneAirport.Create;
  FScene[scAircraftHangar] := TSceneAircraftHangar.Create;
  FScene[scAircraft] := TSceneAircraft.Create;
  FScene[scAircrafts] := TSceneAircrafts.Create;
  FScene[scTowns] := TSceneTowns.Create;
  FScene[scFinances] := TSceneFinances.Create;
  FScene[scCompany] := TSceneCompany.Create;
  FScene[scIndustry] := TSceneIndustry.Create;
  FScene[scBuildNearIndustry] := TSceneBuildNearIndustry.Create;
  FScene[scDock] := TSceneDock.Create;
  FScene[scShip] := TSceneShip.Create;
  FScene[scShips] := TSceneShips.Create;
  FScene[scShipDepot] := TSceneShipDepot.Create;
  FScene[scIndustries] := TSceneIndustries.Create;
  FScene[scBuildMenu] := TSceneBuildMenu.Create;
  FScene[scSettingsMenu] := TSceneSettingsMenu.Create;
  FScene[scOpenGameMenu] := TSceneOpenGameMenu.Create;
  FScene[scRoadVehicle] := TSceneRoadVehicle.Create;
  FScene[scRoadVehicles] := TSceneRoadVehicles.Create;
  FScene[scBusStation] := TSceneBusStation.Create;
  FScene[scTruckLoadingBay] := TSceneTruckLoadingBay.Create;
  FScene[scRoadVehicleDepot] := TSceneRoadVehicleDepot.Create;
end;

procedure TScenes.Update(var Key: Word);
begin
  try
    if (FScene[Scene] <> nil) then
      with FScene[Scene] do
      begin
        MX := EnsureRange(terminal_state(TK_MOUSE_X), 0,
          MapSizeInt[Game.Map.Size]);
        MY := EnsureRange(terminal_state(TK_MOUSE_Y), 0,
          MapSizeInt[Game.Map.Size]);
        RX := EnsureRange(Game.Map.Left + MX, 0, MapSizeInt[Game.Map.Size]);
        RY := EnsureRange(Game.Map.Top + MY, 0, MapSizeInt[Game.Map.Size]);
        Update(Key);
      end;
  except
    on E: Exception do
      Log.Add('TScenes.Update', E.Message);
  end;
end;

procedure TScenes.Render;
begin
  try
    if (FScene[Scene] <> nil) then
      with FScene[Scene] do
      begin
        ClearButtons;
        Render;
        RenderButtons;
        terminal_color(TPalette.Default);
        terminal_bkcolor(TPalette.Background);
        if Game.IsDebug then
        begin
          terminal_print(0, 0, Format('X:%d, Y:%d', [RX, RY]));
          terminal_print(0, 1, Format('MX:%d, MY:%d', [MX, MY]));
        end;
      end;
  except
    on E: Exception do
      Log.Add('TScenes.Render', E.Message);
  end;
end;

procedure TScenes.SetScene(SceneEnum, BackSceneEnum: TSceneEnum);
var
  I: Integer;
begin
  try
    for I := 0 to High(FBackSceneEnum) do
      if FBackSceneEnum[I] = scWorld then
      begin
        FBackSceneEnum[I] := BackSceneEnum;
        Break;
      end;
    SetScene(SceneEnum);
  except
    on E: Exception do
      Log.Add('TScenes.SetScene', E.Message);
  end;
end;

destructor TScenes.Destroy;
var
  SceneEnum: TSceneEnum;
begin
  for SceneEnum := Low(TSceneEnum) to High(TSceneEnum) do
    FScene[SceneEnum].Free;
  inherited;
end;

procedure TScenes.SetScene(SceneEnum: TSceneEnum);
begin
  try
    Self.Scene := SceneEnum;
    Self.Render;
  except
    on E: Exception do
      Log.Add('TScenes.SetScene', E.Message);
  end;
end;

function TScenes.GetScene(I: TSceneEnum): TScene;
begin
  Result := FScene[I];
end;

procedure TScenes.Back;
var
  I: Integer;
begin
  try
    for I := High(FBackSceneEnum) downto 0 do
      if FBackSceneEnum[I] <> scWorld then
      begin
        Self.Scene := FBackSceneEnum[I];
        Self.Render;
        FBackSceneEnum[I] := scWorld;
        Exit;
      end;
    if FBackSceneEnum[0] = scWorld then
      SetScene(scWorld);
  except
    on E: Exception do
      Log.Add('TScenes.Back', E.Message);
  end;
end;

procedure TScenes.ClearQScenes;
var
  I: Integer;
begin
  try
    for I := 0 to High(FBackSceneEnum) do
      FBackSceneEnum[I] := scWorld;
  except
    on E: Exception do
      Log.Add('TScenes.ClearQScenes', E.Message);
  end;
end;

end.
