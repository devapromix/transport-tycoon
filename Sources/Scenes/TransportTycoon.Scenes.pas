unit TransportTycoon.Scenes;

interface

type
  TSceneEnum = (scMenu, scGen, scGame);

type

  { TScene }

  TScene = class(TObject)
  private

  public
    procedure Render; virtual; abstract;
    procedure Update(var Key: word); virtual; abstract;
    procedure DrawText(const X, Y: integer; Text: string); overload;
    procedure DrawTitle(const Title: string);
    procedure DrawFrame(const X, Y, W, H: integer);
    function Width: integer;
    function Height: integer;
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

type

  { TSceneGame }

  TSceneGame = class(TScene)
  private
    procedure DrawBar;
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
  TransportTycoon.Game;

{ TSceneGen }

procedure TSceneGen.Render;
begin
  DrawFrame(10, 5, 60, 15);
  DrawTitle('WORLD GENERATION');


  //DrawText(12, 9, "[[A]] Map size: " + gen_map_size_str());
  //DrawText(42, 9, "[[B]] No. of towns: " + gen_towns_str());

  //DrawText(12, 10, "[[C]] Rivers: " + gen_rivers_str());
  //DrawText(42, 10, "[[D]] No. of ind.: " + gen_indust_str());

  //DrawText(12, 11, "[[E]] Sea level: " + gen_sea_level_str());
  DrawText(42, 11, 'Date: Jan 1st, 1950');

  DrawText(36, 17, 'GENERATE');
end;

procedure TSceneGen.Update(var Key: word);
var
  X, Y: integer;
begin
  X := terminal_state(TK_MOUSE_X);
  Y := terminal_state(TK_MOUSE_Y);
  if (Key = TK_MOUSE_LEFT) and (X > 35) and (X < 45) then
    case Y of
      17:
      begin
        Game.Map.Gen;
        Scenes.SetScene(scGame);
      end;
    end;
end;

{ TSceneMenu }

procedure TSceneMenu.Render;
begin
  DrawFrame(10, 5, 60, 15);
  DrawTitle('TRANSPORT TYCOON');

  DrawText(36, 11, 'NEW GAME');
  DrawText(38, 12, 'LOAD');
  DrawText(38, 13, 'QUIT');

  DrawText(32, 17, 'APROMIX (C) 2022');
end;

procedure TSceneMenu.Update(var Key: word);
var
  X, Y: integer;
begin
  X := terminal_state(TK_MOUSE_X);
  Y := terminal_state(TK_MOUSE_Y);
  if (Key = TK_MOUSE_LEFT) then
    case Y of
      11:
        Scenes.SetScene(scGen);
      13:
        terminal_close();
    end;
end;

{ TScene }

procedure TScene.DrawText(const X, Y: integer; Text: string);
begin
  terminal_print(X, Y, Text);
end;

procedure TScene.DrawTitle(const Title: string);
begin
  terminal_print(40, 7, TK_ALIGN_CENTER, '[c=yellow]' + Title + '[/c]');
end;

procedure TScene.DrawFrame(const X, Y, W, H: integer);
var
  I: integer;
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
  terminal_put(x + w - 1, y, $2557);
  terminal_put(x, y + h - 1, $255A);
  terminal_put(x + w - 1, y + h - 1, $255D);
end;

function TScene.Width: integer;
begin
  Result := terminal_state(TK_WIDTH);
end;

function TScene.Height: integer;
begin
  Result := terminal_state(TK_HEIGHT);
end;

{ TScenes }

constructor TScenes.Create;
begin
  inherited;
  FScene[scMenu] := TSceneMenu.Create;
  FScene[scGen] := TSceneGen.Create;
  FScene[scGame] := TSceneGame.Create;
end;

procedure TScenes.Update(var Key: word);
begin
  if (FScene[Scene] <> nil) then
    FScene[Scene].Update(Key);
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

{ TSceneGame }

procedure TSceneGame.DrawBar;
begin
  terminal_color('white');
  terminal_bkcolor('black');
  terminal_clear_area(0, 24, 80, 1);
  DrawText(0, 24, Format('$%d', [Game.Money]));
  DrawText(12, 24, Format('Turn:%d', [Game.Turn]));
  DrawText(76, 24, 'MENU');
end;

procedure TSceneGame.Render;
var
  X, Y: integer;
begin
  Game.Map.Draw(Self.Width, Self.Height - 1);

  X := terminal_state(TK_MOUSE_X);
  Y := terminal_state(TK_MOUSE_Y);

  terminal_bkcolor('white');
  terminal_put(X, Y, $2588);
  terminal_color('black');
  terminal_put(X, Y, '#');

  DrawBar;
end;

procedure TSceneGame.Update(var Key: word);
var
  X, Y: integer;
begin
  X := terminal_state(TK_MOUSE_X);
  Y := terminal_state(TK_MOUSE_Y);
  if (Key = TK_MOUSE_LEFT) and (Y = 24) and (X > 75) then
    Scenes.SetScene(scMenu);
  case Key of
    TK_LEFT: ;
    TK_RIGHT: ;
    TK_UP: ;
    TK_DOWN: ;
  end;
end;

end.
