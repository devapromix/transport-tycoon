unit TransportTycoon.Scenes;

interface

uses
  BearLibTerminal;

type
  TSceneEnum = (scMainMenu, scGameMenu, scGen, scWorld, scCity, scBuildInCity,
    scAirport, scHangar, scAircraft, scAircrafts, scOrders, scFinances, scTowns,
    scCompany);

type
  TButtonRec = record
    ButtonIsActive: Boolean;
    ButtonKey: string;
    ButtonLabel: string;
  end;

type
  TScene = class(TObject)
  private
    FButtons: array [0 .. 4] of TButtonRec;
    FButtonsY: Integer;
  public
    MX, MY: Integer;
    procedure Render; virtual; abstract;
    procedure Update(var Key: word); virtual; abstract;
    procedure DrawText(const X, Y: Integer; Text: string;
      const Align: Integer = TK_ALIGN_LEFT); overload;
    procedure DrawText(const Y: Integer; Text: string); overload;
    procedure DrawMoney(const X, Y, Money: Integer;
      const Align: Integer = TK_ALIGN_RIGHT; F: Boolean = False);
    procedure DrawButton(const X, Y: Integer; IsActive: Boolean;
      Button, Text: string); overload;
    procedure DrawButton(const Y: Integer; IsActive: Boolean;
      Button, Text: string); overload;
    procedure DrawButton(const X, Y: Integer; Button, Text: string); overload;
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
    function Width: Integer;
    function Height: Integer;
  end;

type
  TScenes = class(TScene)
  private
    FScene: array [TSceneEnum] of TScene;
    FSceneEnum: TSceneEnum;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Render; override;
    procedure Update(var Key: word); override;
    property Scene: TSceneEnum read FSceneEnum write FSceneEnum;
    function GetScene(I: TSceneEnum): TScene;
    procedure SetScene(SceneEnum: TSceneEnum);
  end;

var
  Scenes: TScenes;

implementation

uses
  SysUtils,
  Graphics,
  TransportTycoon.Map,
  TransportTycoon.Game,
  TransportTycoon.Scene.Gen,
  TransportTycoon.Scene.MainMenu,
  TransportTycoon.Scene.GameMenu,
  TransportTycoon.Scene.City,
  TransportTycoon.Scene.World,
  TransportTycoon.Scene.BuildInCity,
  TransportTycoon.Scene.Airport,
  TransportTycoon.Scene.Hangar,
  TransportTycoon.Scene.Aircraft,
  TransportTycoon.Scene.Orders,
  TransportTycoon.Scene.Aircrafts,
  TransportTycoon.Scene.Finances,
  TransportTycoon.Scene.Towns,
  TransportTycoon.Scene.Company;

{ TScene }

procedure TScene.DrawText(const X, Y: Integer; Text: string;
  const Align: Integer = TK_ALIGN_LEFT);
begin
  terminal_print(X, Y, Align, Text);
end;

procedure TScene.DrawTitle(const Y: Integer; const Title: string);
begin
  terminal_print(Width div 2, Y, TK_ALIGN_CENTER,
    '[c=yellow]' + UpperCase(Title) + '[/c]');
end;

procedure TScene.DrawText(const Y: Integer; Text: string);
begin
  terminal_print(Width div 2, Y, TK_ALIGN_CENTER, Text);
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
  terminal_print(X, Y, Format('[c=light yellow][[%s]][/c] [c=white]%s[/c]',
    [UpperCase(Button), UpperCase(Text)]));
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
  Y := Self.Height - 1;
  terminal_color('white');
  terminal_bkcolor('darkest gray');
  terminal_clear_area(0, Y, 80, 1);
  DrawMoney(0, Y, Game.Money, TK_ALIGN_LEFT, True);
  DrawText(12, Y, Format('Turn:%d', [Game.Turn]));
  DrawText(56, Y, Game.Calendar.GetDate);
  DrawButton(70, Y, 'ESC', 'MENU');
end;

procedure TScene.DrawButton(const Y: Integer; Button, Text: string);
begin
  terminal_print(Width div 2, Y, TK_ALIGN_CENTER,
    Format('[c=light yellow][[%s]][/c] [c=white]%s[/c]', [UpperCase(Button),
    UpperCase(Text)]));
end;

procedure TScene.DrawButton(const X, Y: Integer; IsActive: Boolean;
  Button, Text: string);
var
  CB, CT: string;
begin
  if IsActive then
  begin
    CB := 'light yellow';
    CT := 'white';
  end
  else
  begin
    CB := 'gray';
    CT := 'gray';
  end;

  terminal_print(X, Y, Format('[c=' + CB + '][[%s]][/c] [c=' + CT + ']%s[/c]',
    [UpperCase(Button), UpperCase(Text)]));
end;

procedure TScene.DrawButton(const Y: Integer; IsActive: Boolean;
  Button, Text: string);
begin
  terminal_print(Width div 2, Y, TK_ALIGN_CENTER,
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
  Game.Map.Draw(AWidth, AHeight);
  Game.Vehicles.Draw;
end;

procedure TScene.DrawMoney(const X, Y, Money: Integer;
  const Align: Integer = TK_ALIGN_RIGHT; F: Boolean = False);
begin
  if Money = 0 then
    terminal_print(X, Y, Align, Format('[c=white]$%d[/c]', [Money]));
  if Money > 0 then
    if F then
      terminal_print(X, Y, Align, Format('[c=green]$%d[/c]', [Money]))
    else
      terminal_print(X, Y, Align, Format('[c=green]+$%d[/c]', [Money]));
  if Money < 0 then
    terminal_print(X, Y, Align, Format('[c=red]-$%d[/c]', [Abs(Money)]));
end;

function TScene.Width: Integer;
begin
  Result := terminal_state(TK_WIDTH);
end;

function TScene.Height: Integer;
begin
  Result := terminal_state(TK_HEIGHT);
end;

function TScene.MakeButton(const IsActive: Boolean;
  const Button, Text: string): string;
var
  CB, CT: string;
begin
  if IsActive then
  begin
    CB := 'light yellow';
    CT := 'white';
  end
  else
  begin
    CB := 'gray';
    CT := 'gray';
  end;
  Result := Format('[c=' + CB + '][[%s]][/c] [c=' + CT + ']%s[/c]',
    [UpperCase(Button), UpperCase(Text)]);
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
  terminal_bkcolor(0);
  terminal_print(Width div 2, FButtonsY, TK_ALIGN_CENTER, S);
end;

{ TScenes }

constructor TScenes.Create;
begin
  inherited;
  FScene[scMainMenu] := TSceneMainMenu.Create;
  FScene[scGameMenu] := TSceneGameMenu.Create;
  FScene[scGen] := TSceneGen.Create;
  FScene[scWorld] := TSceneWorld.Create;
  FScene[scCity] := TSceneCity.Create;
  FScene[scBuildInCity] := TSceneBuildInCity.Create;
  FScene[scAirport] := TSceneAirport.Create;
  FScene[scHangar] := TSceneHangar.Create;
  FScene[scAircraft] := TSceneAircraft.Create;
  FScene[scAircrafts] := TSceneAircrafts.Create;
  FScene[scTowns] := TSceneTowns.Create;
  FScene[scOrders] := TSceneOrders.Create;
  FScene[scFinances] := TSceneFinances.Create;
  FScene[scCompany] := TSceneCompany.Create;
end;

procedure TScenes.Update(var Key: word);
begin
  if (FScene[Scene] <> nil) then
    with FScene[Scene] do
    begin
      MX := terminal_state(TK_MOUSE_X);
      MY := terminal_state(TK_MOUSE_Y);
      Update(Key);
    end;
end;

procedure TScenes.Render;
begin
  terminal_clear();
  terminal_bkcolor(0);
  if (FScene[Scene] <> nil) then
    with FScene[Scene] do
    begin
      ClearButtons;
      Render;
      RenderButtons;
      terminal_color('white');
      terminal_print(0, 0, Format('%dx%d', [MX, MY]));
    end;
  terminal_bkcolor(0);
end;

destructor TScenes.Destroy;
var
  I: TSceneEnum;
begin
  for I := Low(TSceneEnum) to High(TSceneEnum) do
    FScene[I].Free;
  inherited;
end;

procedure TScenes.SetScene(SceneEnum: TSceneEnum);
begin
  Self.Scene := SceneEnum;
  Self.Render;
end;

function TScenes.GetScene(I: TSceneEnum): TScene;
begin
  Result := FScene[I];
end;

end.
