import karax/[karax, karaxdsl, vdom, jstrutils, kajax, jjson]
include json

# Константа для статуса ошибки
const NotFoundStatus = 404
# Глобальная константа для успешного статуса
const SuccessStatus = 200

# Информация об игре
type GameInfo* = object
    # Уникальный идентификатор игры
    id*: int          
    # Название игры
    name*: string     
    # Описание игры
    description*: string
    # URL изображения игры
    imageUrl*: string 
    
# Состояние приложения
type AppState = object
  # Список игр
  games: seq[GameInfo]
  # Флаг загрузки
  isLoading: bool

var appState = AppState(
  games: @[],
  isLoading: true
) 

# Загружает список игр
proc fetchGames(onData:proc(res:seq[GameInfo])) =  
  ajaxGet("/game", @[], proc(status: int, response: cstring) =
    let data = parseJson($response)
    var games :seq[GameInfo] = @[]
    
    for gameJson in data:                        
        games.add(GameInfo(
          name: gameJson["name"].getStr(),
          description: gameJson["description"].getStr(),
          imageUrl: gameJson["imageUrl"].getStr()
        ))
    
    onData(games)
  )  

# Инициализирует состояние
proc initState() =
  # Загружает игры
  fetchGames(proc(res:seq[GameInfo]) =
      appState.games = res
      appState.isLoading = false
  )

# Создает DOM структуру приложения
proc createDom(): VNode =  
  # Отрисовывает карточку игры
  proc renderGameItem(game: GameInfo): VNode =
    result = buildHtml(tdiv(class = "game-item")):
      img(src = game.imageUrl, alt = game.name)
      tdiv(class = "game-title"): text game.name
      tdiv(class = "game-description"): text game.description      

  result = buildHtml(tdiv(class="content")):
    tdiv(class = "game-list"):
      if appState.isLoading:
        tdiv(class = "loading"): text "Загружается..."
      else:
        for i in countup(0, appState.games.len-1, 2):
          tdiv(class = "game-row"):
            renderGameItem(appState.games[i])
            if i + 1 < appState.games.len:
              renderGameItem(appState.games[i+1])

setRenderer createDom, "ROOT"
initState()