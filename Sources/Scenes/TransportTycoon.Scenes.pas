unit TransportTycoon.Scenes;

interface

uses
  TransportTycoon.Map,
  BearLibTerminal;

type
  TSceneEnum = (scMainMenu, scGameMenu, scGenMenu, scWorld, scTown,
    scBuildInTown, scAirport, scAircraftHangar, scAircraft, scAircrafts,
    scFinances, scTowns, scCompany, scIndustry, scBuildNearIndustry, scDock,
    scShip, scShips, scShipDepot, scIndustries, scBuildMenu, scSettingsMenu,
    scOpenGameMenu, scOpenGamePromptMenu, scOpenGameDoneMenu, scSaveGameMenu,
    scSaveGamePromptMenu, scSaveGameSavedMenu, scRoadVehicle, scRoadVehicles,
    scTruckLoadingBay, scBusStation, scRoadVehicleDepot);

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
    procedure Update(var AKey: Word); virtual; abstract;
    procedure DrawText(const AX, AY: Integer;
      AText, AColor, ABkColor: string); overload;
    procedure DrawText(const AX, AY: Integer; AText: string;
      const ATextAlign: Integer = TK_ALIGN_LEFT); overload;
    procedure DrawText(const AY: Integer; AText: string); overload;
    procedure DrawText(const AX, AY: Integer; const AText: string;
      const AIsActive: Boolean); overload;
    procedure DrawTextLine(const AX: Integer; const AText: string);
    procedure DrawMoney(const AX, AY, AMoney: Integer;
      const ATextAlign: Integer = TK_ALIGN_RIGHT; AIsFlag: Boolean = False);
    procedure DrawButton(const AX, AY: Integer; AIsActive: Boolean;
      AButton, AText: string); overload;
    procedure DrawButton(const AX, AY, AWidth: Integer;
      AIsActive, AIsFlag: Boolean; AButton, AText: string); overload;
    procedure DrawButton(const AX, AY, AWidth: Integer;
      AIsActive, AIsFlag: Boolean; AButton, AText, AColor: string); overload;
    procedure DrawButton(const AY: Integer; AIsActive: Boolean;
      AButton, AText: string); overload;
    procedure DrawButton(const AX, AY: Integer;
      AButton, AText: string); overload;
    procedure DrawButton(const AX, AY: Integer;
      AButton, AText, AColor: string); overload;
    procedure DrawButton(const AY: Integer; AButton, AText: string); overload;
    function MakeButton(const AIsActive: Boolean;
      const AButton, AText: string): string;
    procedure DrawTitle(const AY: Integer; const ATitle: string); overload;
    procedure DrawTitle(const ATitle: string); overload;
    procedure DrawFrame(const AX, AY, AWidth, AHeight: Integer); overload;
    procedure DrawFrame(const AWidth, AHeight: Integer); overload;
    procedure DrawMap(const AWidth, AHeight: Integer);
    procedure ClearButtons;
    procedure AddButton(const AY: Integer;
      const AButton, AText: string); overload;
    procedure AddButton(const AY: Integer; const AIsActive: Boolean;
      const AButton, AText: string); overload;
    function GetButton(const AIndex: Integer): TButtonRec;
    function GetButtonsY: Integer;
    procedure RenderButtons;
    procedure DrawBuildBar;
    procedure DrawGameBar;
    function ScreenWidth: Integer;
    function ScreenHeight: Integer;
    property MX: Integer read FMX write FMX;
    property MY: Integer read FMY write FMY;
    property RX: Integer read FRX write FRX;
    property RY: Integer read FRY write FRY;
    procedure ScrollTo(const AX, AY: Integer);
    procedure Scroll(const ADirectionEnum: TDirectionEnum);
    function Check(const AIsCheck: Boolean): string;
    property TextLineY: Integer read FTextLineY write FTextLineY;
    function StrLim(const AStr: string; const ALength: Integer): string;
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
    procedure Update(var AKey: Word); override;
    property Scene: TSceneEnum read FSceneEnum write FSceneEnum;
    function GetScene(ASceneEnum: TSceneEnum): TScene;
    procedure SetScene(ASceneEnum: TSceneEnum); overload;
    procedure SetScene(ASceneEnum, ABackSceneEnum: TSceneEnum); overload;
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
  TransportTycoon.Game,
  TransportTycoon.Scene.Menu.Main,
  TransportTycoon.Scene.Menu.Game,
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
  TransportTycoon.Scene.Menu.Build,
  TransportTycoon.Scene.Menu.Gen,
  TransportTycoon.Scene.Menu.Settings,
  TransportTycoon.Scene.Menu.OpenGame,
  TransportTycoon.Scene.Menu.OpenGame.Prompt,
  TransportTycoon.Scene.Menu.OpenGame.Done,
  TransportTycoon.Scene.Menu.SaveGame,
  TransportTycoon.Scene.Menu.SaveGame.Prompt,
  TransportTycoon.Scene.Menu.SaveGame.Saved,
  TransportTycoon.Scene.RoadVehicle,
  TransportTycoon.Scene.BusStation,
  TransportTycoon.Scene.TruckLoadingBay,
  TransportTycoon.Scene.RoadVehicleDepot,
  TransportTycoon.Scene.RoadVehicles,
  TransportTycoon.Palette,
  TransportTycoon.Construct;

procedure TScene.DrawText(const AX, AY: Integer; AText: string;
  const ATextAlign: Integer = TK_ALIGN_LEFT);
begin
  terminal_print(AX, AY, ATextAlign, AText);
end;

procedure TScene.DrawTitle(const AY: Integer; const ATitle: string);
begin
  terminal_print(ScreenWidth div 2, AY, TK_ALIGN_CENTER,
    '[c=' + TPalette.Title + ']' + UpperCase(ATitle) + '[/c]');
end;

procedure TScene.DrawText(const AY: Integer; AText: string);
begin
  terminal_print(ScreenWidth div 2, AY, TK_ALIGN_CENTER, AText);
end;

procedure TScene.DrawTextLine(const AX: Integer; const AText: string);
begin
  DrawText(AX, FTextLineY, AText);
  Inc(FTextLineY);
end;

procedure TScene.DrawText(const AX, AY: Integer;
  AText, AColor, ABkColor: string);
begin
  terminal_color(AColor);
  terminal_bkcolor(ABkColor);
  terminal_print(AX, AY, AText);
end;

procedure TScene.DrawText(const AX, AY: Integer; const AText: string;
  const AIsActive: Boolean);
begin
  if AIsActive then
    terminal_color(TPalette.Default)
  else
    terminal_color(TPalette.Unused);
  terminal_print(AX, AY, AText);
end;

procedure TScene.DrawTitle(const ATitle: string);
begin
  DrawTitle(9, ATitle);
end;

function TScene.GetButton(const AIndex: Integer): TButtonRec;
begin
  Result := FButtons[AIndex];
end;

function TScene.GetButtonsY: Integer;
begin
  Result := FButtonsY;
end;

procedure TScene.DrawButton(const AX, AY: Integer; AButton, AText: string);
begin
  terminal_print(AX, AY, Format('[c=%s][[%s]][/c] [c=%s]%s[/c]',
    [TPalette.ButtonKey, UpperCase(AButton), TPalette.Default,
    UpperCase(AText)]));
end;

procedure TScene.AddButton(const AY: Integer; const AButton, AText: string);
begin
  AddButton(AY, True, AButton, AText);
end;

procedure TScene.AddButton(const AY: Integer; const AIsActive: Boolean;
  const AButton, AText: string);
var
  LButton: Integer;
begin
  FButtonsY := AY;
  for LButton := Low(FButtons) to High(FButtons) do
    if (FButtons[LButton].ButtonKey = '') then
    begin
      FButtons[LButton].ButtonIsActive := AIsActive;
      FButtons[LButton].ButtonKey := AButton;
      FButtons[LButton].ButtonLabel := AText;
      Exit;
    end;
end;

procedure TScene.ClearButtons;
var
  LButton: Integer;
begin
  for LButton := Low(FButtons) to High(FButtons) do
  begin
    FButtons[LButton].ButtonKey := '';
    FButtons[LButton].ButtonLabel := '';
  end;
end;

procedure TScene.DrawGameBar;
var
  LY: Integer;
begin
  try
    LY := Self.ScreenHeight - 1;
    terminal_color(TPalette.Default);
    terminal_bkcolor(TPalette.Background);
    terminal_clear_area(0, LY, 80, 1);
    DrawMoney(0, LY, Game.Money, TK_ALIGN_LEFT, True);
    DrawText(12, LY, Format('Turn:%d', [Game.Turn]));
    DrawButton(25, LY, 'B', 'Build');
    DrawText(56, LY, Game.Calendar.GetDate);
    if (Scenes.FSceneEnum <> scWorld) then
      if Game.Construct.IsConstruct then
        DrawButton(70, LY, False, 'ESC', 'EXIT')
      else
        DrawButton(70, LY, False, 'ESC', 'MENU')
    else if Game.Construct.IsConstruct then
      DrawButton(70, LY, 'ESC', 'EXIT')
    else
      DrawButton(70, LY, 'ESC', 'MENU');
    if (Scenes.FSceneEnum <> scWorld) and (Scenes.FSceneEnum <> scGameMenu) then
    begin
      DrawButton(25, LY, False, 'B', 'Build');
      if Game.IsPause then
        DrawButton(35, LY, False, 'P', 'Paused')
      else
        DrawButton(35, LY, False, 'P', 'Pause');
    end
    else
    begin
      if Game.IsPause then
        DrawText(35, ScreenHeight - 1, '[c=' + TPalette.ButtonKey +
          '][[P]][/c] [c=red]PAUSED[/c]')
      else
        DrawButton(35, LY, 'P', 'Pause');
    end;
  except
    on E: Exception do
      Log.Add('TScene.DrawGameBar', E.Message);
  end;
end;

procedure TScene.DrawBuildBar;
var
  LY: Integer;
begin
  try
    LY := 0;
    terminal_color(TPalette.Default);
    terminal_bkcolor(TPalette.Background);
    terminal_clear_area(0, LY, 80, 1);
    DrawText(LY, Game.Construct.GetConstructStr);
  except
    on E: Exception do
      Log.Add('TScene.DrawBuildBar', E.Message);
  end;
end;

procedure TScene.DrawButton(const AY: Integer; AButton, AText: string);
begin
  terminal_print(ScreenWidth div 2, AY, TK_ALIGN_CENTER,
    Format('[c=%s][[%s]][/c] [c=%s]%s[/c]', [TPalette.ButtonKey,
    UpperCase(AButton), TPalette.Default, UpperCase(AText)]));
end;

procedure TScene.DrawButton(const AX, AY, AWidth: Integer;
  AIsActive, AIsFlag: Boolean; AButton, AText: string);
begin
  DrawButton(AX, AY, AIsActive, AButton, AText);
  DrawText(AX + AWidth - 4, AY, '[c=' + TPalette.Default + '][[' +
    Check(AIsFlag) + ']][/c]');
end;

procedure TScene.DrawButton(const AX, AY, AWidth: Integer;
  AIsActive, AIsFlag: Boolean; AButton, AText, AColor: string);
begin
  DrawButton(AX, AY, AButton, AText, AColor);
  DrawText(AX + AWidth - 4, AY, '[c=' + TPalette.Default + '][[' +
    Check(AIsFlag) + ']][/c]');
end;

procedure TScene.DrawButton(const AX, AY: Integer;
  AButton, AText, AColor: string);
begin
  terminal_print(AX, AY, Format('[c=%s][[%s]][/c] [c=%s]%s[/c]',
    [TPalette.ButtonKey, UpperCase(AButton), AColor, UpperCase(AText)]));
end;

procedure TScene.DrawButton(const AX, AY: Integer; AIsActive: Boolean;
  AButton, AText: string);
begin
  terminal_print(AX, AY, MakeButton(AIsActive, AButton, AText));
end;

procedure TScene.DrawButton(const AY: Integer; AIsActive: Boolean;
  AButton, AText: string);
begin
  terminal_print(ScreenWidth div 2, AY, TK_ALIGN_CENTER,
    MakeButton(AIsActive, AButton, AText));
end;

procedure TScene.DrawFrame(const AX, AY, AWidth, AHeight: Integer);
var
  LX, LY: Integer;
begin
  terminal_bkcolor(TPalette.FrameBackground);
  terminal_clear_area(AX + 1, AY + 1, AWidth, AHeight);

  for LX := AX + 1 to AX + AWidth - 1 do
    Game.Map.DrawTile(LX, AY + AHeight, False);
  for LY := AY + 1 to AY + AHeight do
    Game.Map.DrawTile(AX + AWidth, LY, False);

  terminal_color(TPalette.Default);
  terminal_bkcolor(TPalette.Background);
  terminal_clear_area(AX, AY, AWidth, AHeight);
  for LX := AX + 1 to AX + AWidth - 2 do
  begin
    terminal_put(LX, AY, $2550);
    terminal_put(LX, AY + AHeight - 1, $2550);
  end;
  for LY := AY + 1 to AY + AHeight - 2 do
  begin
    terminal_put(AX, LY, $2551);
    terminal_put(AX + AWidth - 1, LY, $2551);
  end;
  terminal_put(AX, AY, $2554);
  terminal_put(AX + AWidth - 1, AY, $2557);
  terminal_put(AX, AY + AHeight - 1, $255A);
  terminal_put(AX + AWidth - 1, AY + AHeight - 1, $255D);
end;

procedure TScene.DrawFrame(const AWidth, AHeight: Integer);
var
  LX, LY: Integer;
begin
  LX := (Self.ScreenWidth div 2) - (AWidth div 2);
  LY := (Self.ScreenHeight div 2) - (AHeight div 2) - 1;
  DrawFrame(LX, LY, AWidth, AHeight)
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

procedure TScene.DrawMoney(const AX, AY, AMoney: Integer;
  const ATextAlign: Integer = TK_ALIGN_RIGHT; AIsFlag: Boolean = False);
begin
  if AMoney = 0 then
    terminal_print(AX, AY, ATextAlign, Format('[c=%s]$%d[/c]',
      [TPalette.Default, AMoney]));
  if AMoney > 0 then
    if AIsFlag then
      terminal_print(AX, AY, ATextAlign, Format('[c=green]$%d[/c]', [AMoney]))
    else
      terminal_print(AX, AY, ATextAlign, Format('[c=green]+$%d[/c]', [AMoney]));
  if AMoney < 0 then
    terminal_print(AX, AY, ATextAlign, Format('[c=red]-$%d[/c]',
      [Abs(AMoney)]));
end;

function TScene.ScreenWidth: Integer;
begin
  Result := terminal_state(TK_WIDTH);
end;

function TScene.ScreenHeight: Integer;
begin
  Result := terminal_state(TK_HEIGHT);
end;

procedure TScene.ScrollTo(const AX, AY: Integer);
begin
  try
    Game.Map.Left := EnsureRange(AX - (ScreenWidth div 2), 0,
      Game.Map.Width - ScreenWidth);
    Game.Map.Top := EnsureRange(AY - (ScreenHeight div 2), 0,
      Game.Map.Height - ScreenHeight);
  except
    on E: Exception do
      Log.Add('TScene.ScrollTo', E.Message);
  end;
end;

function TScene.StrLim(const AStr: string; const ALength: Integer): string;
begin
  if Length(AStr) > ALength then
  begin
    Result := Trim(Copy(AStr, 1, ALength - 3)) + '...';
  end
  else
    Result := AStr;
end;

function TScene.Check(const AIsCheck: Boolean): string;
begin
  if AIsCheck then
    Result := 'X'
  else
    Result := #32;
end;

procedure TScene.Scroll(const ADirectionEnum: TDirectionEnum);
var
  LF: Boolean;
begin
  LF := False;
  try
    case ADirectionEnum of
      drEast:
        LF := (Game.Map.Left < Game.Map.Width - Self.ScreenWidth);
      drWest:
        LF := (Game.Map.Left > 0);
      drSouth:
        LF := (Game.Map.Top <= Game.Map.Height - Self.ScreenHeight);
      drNorth:
        LF := (Game.Map.Top > 0);
    end;
    if LF then
    begin
      Game.Map.Top := Game.Map.Top + Direction[ADirectionEnum].Y;
      Game.Map.Left := Game.Map.Left + Direction[ADirectionEnum].X;
    end;
  except
    on E: Exception do
      Log.Add('TScenes.Scroll', E.Message);
  end;
end;

function TScene.MakeButton(const AIsActive: Boolean;
  const AButton, AText: string): string;
var
  LColorButton, LColorText: string;
begin
  if AIsActive then
  begin
    LColorButton := TPalette.ButtonKey;
    LColorText := TPalette.Default;
  end
  else
  begin
    LColorButton := TPalette.Unused;
    LColorText := TPalette.Unused;
  end;
  Result := Format('[c=' + LColorButton + '][[%s]][/c] [c=' + LColorText +
    ']%s[/c]', [UpperCase(AButton), UpperCase(AText)]);
end;

procedure TScene.RenderButtons;
var
  LButton: Integer;
  LLine: string;
begin
  LLine := '';
  for LButton := Low(FButtons) to High(FButtons) do
    if (FButtons[LButton].ButtonKey <> '') then
    begin
      LLine := LLine + MakeButton(FButtons[LButton].ButtonIsActive,
        FButtons[LButton].ButtonKey, FButtons[LButton].ButtonLabel);
      if (LButton < High(FButtons)) and (FButtons[LButton + 1].ButtonKey <> '')
      then
        LLine := LLine + ' | ';
    end;
  terminal_print(ScreenWidth div 2, FButtonsY, TK_ALIGN_CENTER, LLine);
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
  FScene[scOpenGamePromptMenu] := TSceneOpenGamePromptMenu.Create;
  FScene[scOpenGameDoneMenu] := TSceneOpenGameDoneMenu.Create;
  FScene[scSaveGameMenu] := TSceneSaveGameMenu.Create;
  FScene[scSaveGamePromptMenu] := TSceneSaveGamePromptMenu.Create;
  FScene[scSaveGameSavedMenu] := TSceneSaveGameSavedMenu.Create;
  FScene[scRoadVehicle] := TSceneRoadVehicle.Create;
  FScene[scRoadVehicles] := TSceneRoadVehicles.Create;
  FScene[scBusStation] := TSceneBusStation.Create;
  FScene[scTruckLoadingBay] := TSceneTruckLoadingBay.Create;
  FScene[scRoadVehicleDepot] := TSceneRoadVehicleDepot.Create;
end;

procedure TScenes.Update(var AKey: Word);
begin
  try
    if (FScene[Scene] <> nil) then
      with FScene[Scene] do
      begin
        MX := EnsureRange(terminal_state(TK_MOUSE_X), 0,
          MapSizeInt[Game.Map.MapSize]);
        MY := EnsureRange(terminal_state(TK_MOUSE_Y), 0,
          MapSizeInt[Game.Map.MapSize]);
        RX := EnsureRange(Game.Map.Left + MX, 0, MapSizeInt[Game.Map.MapSize]);
        RY := EnsureRange(Game.Map.Top + MY, 0, MapSizeInt[Game.Map.MapSize]);
        Update(AKey);
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

procedure TScenes.SetScene(ASceneEnum, ABackSceneEnum: TSceneEnum);
var
  LSceneEnum: Integer;
begin
  try
    for LSceneEnum := 0 to High(FBackSceneEnum) do
      if FBackSceneEnum[LSceneEnum] = scWorld then
      begin
        FBackSceneEnum[LSceneEnum] := ABackSceneEnum;
        Break;
      end;
    SetScene(ASceneEnum);
  except
    on E: Exception do
      Log.Add('TScenes.SetScene', E.Message);
  end;
end;

destructor TScenes.Destroy;
var
  LSceneEnum: TSceneEnum;
begin
  for LSceneEnum := Low(TSceneEnum) to High(TSceneEnum) do
    FreeAndNil(FScene[LSceneEnum]);
  inherited;
end;

procedure TScenes.SetScene(ASceneEnum: TSceneEnum);
begin
  try
    Self.Scene := ASceneEnum;
    Self.Render;
  except
    on E: Exception do
      Log.Add('TScenes.SetScene', E.Message);
  end;
end;

function TScenes.GetScene(ASceneEnum: TSceneEnum): TScene;
begin
  Result := FScene[ASceneEnum];
end;

procedure TScenes.Back;
var
  LSceneEnum: Integer;
begin
  try
    for LSceneEnum := High(FBackSceneEnum) downto 0 do
      if FBackSceneEnum[LSceneEnum] <> scWorld then
      begin
        Self.Scene := FBackSceneEnum[LSceneEnum];
        Self.Render;
        FBackSceneEnum[LSceneEnum] := scWorld;
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
  LSceneEnum: Integer;
begin
  try
    for LSceneEnum := 0 to High(FBackSceneEnum) do
      FBackSceneEnum[LSceneEnum] := scWorld;
  except
    on E: Exception do
      Log.Add('TScenes.ClearQScenes', E.Message);
  end;
end;

end.
