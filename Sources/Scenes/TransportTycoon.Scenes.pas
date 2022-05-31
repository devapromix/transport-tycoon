unit TransportTycoon.Scenes;

interface

type
  TSceneEnum = (scMenu, scGen, scWorld, scCity, scBuildInCity);

type

  { TScene }

  TScene = class(TObject)
  private

  public
    MX, MY: Integer;
    procedure Render; virtual; abstract;
    procedure Update(var Key: word); virtual; abstract;
    procedure DrawText(const X, Y: Integer; Text: string); overload;
    procedure DrawTitle(const Title: string);
    procedure DrawFrame(const X, Y, W, H: Integer);
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

type

  { TSceneMenu }

  TSceneMenu = class(TScene)
  private

  public
    procedure Render; override;
    procedure Update(var Key: word); override;
  end;

type

  { TSceneGen }

  TSceneGen = class(TScene)
  private

  public
    procedure Render; override;
    procedure Update(var Key: word); override;
  end;

var
  Scenes: TScenes;

implementation

uses
  BearLibTerminal,
  SysUtils,
  Graphics,
  TransportTycoon.Map,
  TransportTycoon.Game,
  TransportTycoon.Scene.City,
  TransportTycoon.Scene.World,
  TransportTycoon.Scene.BuildInCity;

{ TSceneGen }

procedure TSceneGen.Render;
begin
  DrawFrame(10, 5, 60, 15);
  DrawTitle('WORLD GENERATION');

  DrawText(12, 9, 'Map size: ' + MapSizeStr[Game.Map.Size]);
  DrawText(42, 9, 'No. of towns: ' + MapNoOfTownsStr[Game.Map.NoOfTowns]);

  // DrawText(12, 10, "[[C]] Rivers: " + gen_rivers_str());
  // DrawText(42, 10, "[[D]] No. of ind.: " + gen_indust_str());

  // DrawText(12, 11, "[[E]] Sea level: " + gen_sea_level_str());
  DrawText(42, 11, Format('Date: %s %d, %d', [MonStr[Game.Month], Game.Day,
    Game.Year]));

  DrawText(36, 17, 'GENERATE');
end;

procedure TSceneGen.Update(var Key: word);
begin
  if (Key = TK_MOUSE_LEFT) and (MX > 35) and (MX < 45) then
    case MY of
      17:
        begin
          Game.Clear;
          Game.Map.Gen;
          Game.IsPause := False;
          Scenes.SetScene(scWorld);
        end;
    end;
end;

{ TSceneMenu }

procedure TSceneMenu.Render;
begin
  DrawFrame(10, 5, 60, 15);
  DrawTitle('TRANSPORT TYCOON');

  DrawText(36, 11, 'NEW GAME');
  if not Game.IsGame then
    terminal_color('dark gray');
  DrawText(36, 12, 'CONTINUE');
  terminal_color('white');
  DrawText(38, 13, 'QUIT');

  DrawText(32, 17, 'APROMIX (C) 2022');
end;

procedure TSceneMenu.Update(var Key: word);
begin
  if (Key = TK_MOUSE_LEFT) then
    case MY of
      11:
        begin
          Game.New;
          Game.IsGame := False;
          Scenes.SetScene(scGen);
        end;
      12:
        if Game.IsGame then
        begin
          Game.IsPause := False;
          Scenes.SetScene(scWorld);
        end;
      13:
        terminal_close();
    end;
end;

{ TScene }

procedure TScene.DrawText(const X, Y: Integer; Text: string);
begin
  terminal_print(X, Y, Text);
end;

procedure TScene.DrawTitle(const Title: string);
begin
  terminal_print(40, 7, TK_ALIGN_CENTER, '[c=yellow]' + Title + '[/c]');
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

function TScene.Width: Integer;
begin
  Result := terminal_state(TK_WIDTH);
end;

function TScene.Height: Integer;
begin
  Result := terminal_state(TK_HEIGHT);
end;

{ TScenes }

constructor TScenes.Create;
begin
  inherited;
  FScene[scMenu] := TSceneMenu.Create;
  FScene[scGen] := TSceneGen.Create;
  FScene[scWorld] := TSceneWorld.Create;
  FScene[scCity] := TSceneCity.Create;
  FScene[scBuildInCity] := TSceneBuildInCity.Create;
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
    FScene[Scene].Render;
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
