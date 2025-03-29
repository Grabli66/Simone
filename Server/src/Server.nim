import os
import mummy, mummy/routers
import std/marshal
import std/mimetypes
import std/strformat

import database/database
import database/types

const staticPath = "static"
const titleImage = "title.png"

const mimeTypesDb : MimeDB = newMimetypes()

# Возвращает начальную страницу с выбором игр
proc indexHandler(request: Request) =
  if not fileExists("index.html"):
    request.respond(404)
    return

  var headers: HttpHeaders
  let file = readFile("index.html")
  headers["Content-Type"] = "text/html"
  request.respond(200, headers, file)

# Возвращает файл
proc staticHandler(request: Request) =  
  let path = request.pathParams["name"]
  if not fileExists(path):
    request.respond(404)
    return

  let ext = splitFile(path).ext
  let mime  = mimeTypesDb.getMimeType(ext)

  var headers: HttpHeaders
  headers["Content-Type"] = mime  
  let file = readFile(path)
  request.respond(200, headers, file)

# Возвращает список игр
proc getGameList(request: Request) {.gcsafe.}  =
  type GameInfoDto = object
    id*: int
    name*: string
    description*: string
    imageUrl*: string    

  let dbConn = database.get()
  let games = dbConn.getGameInfoList()
    
  var gameDtos: seq[GameInfoDto] = @[]
  for game in games:
    var titleImagePath = fmt"games/game_{game.id}/{titleImage}"
    var imageUrl = fmt"/game/{staticPath}/{game.id}/{titleImage}"
    if not fileExists(titleImagePath):    
      imageUrl = "/static/unknownTitle.png"

    gameDtos.add(GameInfoDto(
      id: game.id,
      name: game.name,
      description: game.description,      
      imageUrl: imageUrl
    ))

  var headers: HttpHeaders
  headers["Content-Type"] = "application/json"
  request.respond(200, headers, $$gameDtos)

# Устанавливает игру
proc installGame(request: Request) =
  let dbConn = database.get()
  
  # Получаем данные из тела запроса
  let body = request.body
  var game: GameInfo
  try:
    game = to[GameInfo](body)
  except:
    var headers: HttpHeaders
    headers["Content-Type"] = "text/plain"
    request.respond(400, headers, "Неверный формат данных")
    return
  
  # Создаем новую игру в базе данных
  var headers: HttpHeaders
  headers["Content-Type"] = "application/json"
  let newGame = dbConn.createGame(game)
  request.respond(200, headers, $$newGame)

# Запускает игру
proc startGame(request: Request) =
  discard

# Возвращает статический файл для конкретной игры
proc getGameFile(request: Request) =
  let gameId = request.pathParams["id"]
  let fileName = request.pathParams["name"]
  let filePath = fmt"games/game_{gameId}/{fileName}"
  
  if not fileExists(filePath):
    request.respond(404)
    return

  let ext = splitFile(filePath).ext
  let mime = mimeTypesDb.getMimeType(ext)

  var headers: HttpHeaders
  headers["Content-Type"] = mime
  let file = readFile(filePath)
  request.respond(200, headers, file)

var router: Router
router.get("/", indexHandler)
router.get(fmt"/{staticPath}/@name", staticHandler)
router.get("/game", getGameList)
router.get("/game/start/@id", startGame)
router.post("/game/install", installGame)
router.get(fmt"/game/{staticPath}/@id/@name", getGameFile)

# Останавливает игру
# Обработчик статических ресурсов
# Websocket для сообщений игры

let server = newServer(router)
echo "Serving on http://localhost:8080"
server.serve(Port(8080))