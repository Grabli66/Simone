import os
import mummy, mummy/routers
import std/marshal
import std/mimetypes

import database/database
import database/types

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
  let dbConn = database.get()

  let games = dbConn.getGameInfoList()
    
  var headers: HttpHeaders
  headers["Content-Type"] = "application/json"
  request.respond(200, headers, $$games)

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

var router: Router
router.get("/", indexHandler)
router.get("/static/@name", staticHandler)
router.get("/game", getGameList)
router.get("/game/start/@id", startGame)
router.post("/game/install", installGame)

# Останавливает игру
# Обработчик статических ресурсов
# Websocket для сообщений игры

let server = newServer(router)
echo "Serving on http://localhost:8080"
server.serve(Port(8080))