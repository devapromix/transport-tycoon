unit TransportTycoon.Scenes;

interface

type
  TSceneEnum = (scMenu, scGen, scWorld, scCity, scBuildInCity, scAirport);

type

  { TScene }

  TScene = class(TObject)
  private

  public
    MX, MY: Integer;
    procedure Render; virtual; abstract;
    procedure Update(var Key: word); virtual; abstract;
    procedure DrawText(const X, Y: Integer; Text: string);
    procedure DrawButton(const X, Y: Integer; IsActive: Boolean;
      Button, Text: string); overload;
    procedure DrawButton(const X, Y: Integer; Button, Text: string); overload;
    procedure DrawButton(const Y: Integer; Button, Text: string); overload;
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

var
  Scenes: TScenes;

implementation

uses
  BearLibTerminal,
  SysUtils,
  Graphics,
  TransportTycoon.Map,
  TransportTycoon.Game,
  TransportTycoon.Scene.Gen,
  TransportTycoon.Scene.Menu,
  TransportTycoon.Scene.City,
  TransportTycoon.Scene.World,
  TransportTycoon.Scene.BuildInCity,
  TransportTycoon.Scene.Airport;

{ TScene }

procedure TScene.DrawText(const X, Y: Integer; Text: string);
begin
  terminal_print(X, Y, Text);
end;

procedure TScene.DrawTitle(const Title: string);
begin
  terminal_print(Width div 2, 7, TK_ALIGN_CENTER, '[c=yellow]' + Title
    + '[/c]');
end;

procedure TScene.DrawButton(const X, Y: Integer; Button, Text: string);
begin
  terminal_print(X, Y, Format('[c=light yellow][[%s]][/c] [c=white]%s[/c]',
    [Button, Text]));
end;

procedure TScene.DrawButton(const Y: Integer; Button, Text: string);
begin
  terminal_print(Width div 2, Y, TK_ALIGN_CENTER,
    Format('[c=light yellow][[%s]][/c] [c=white]%s[/c]', [Button, Text]));
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
    [Button, Text]));
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
  FScene[scAirport] := TSceneAirport.Create;
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
