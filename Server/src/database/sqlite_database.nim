import db_connector/db_sqlite
import strutils

import types

# Возвращает список игр
proc getGameInfoList(db:DbConn):seq[GameInfo] =
  for row in db.getAllRows(sql"SELECT id, name, description FROM games"):
    let game = GameInfo(
      id: parseInt(row[0]),
      name: row[1],
      description: row[2]
    )
    result.add(game)

# Создает новую игру
proc createGame(db:DbConn, game:GameInfo):GameInfo =
  let query = sql"""
    INSERT INTO games (name, description)
    VALUES (?, ?)
  """
  db.exec(query, game.name, game.description)
  
  let id = db.getRow(sql"SELECT last_insert_rowid()")[0]
  return GameInfo(
    id: parseInt(id),
    name: game.name,
    description: game.description
  )

# Получает игру по ID
proc getGameById(db:DbConn, id:int):GameInfo =
  let row = db.getRow(sql"SELECT id, name, description FROM games WHERE id = ?", id)
  if row.len > 0:
    return GameInfo(
      id: parseInt(row[0]),
      name: row[1],
      description: row[2]
    )
  raise newException(ValueError, "Игра не найдена")

# Обновляет информацию об игре
proc updateGame(db:DbConn, game:GameInfo):GameInfo =
  let query = sql"""
    UPDATE games 
    SET name = ?, description = ?
    WHERE id = ?
  """
  db.exec(query, game.name, game.description, game.id)
  return game

# Удаляет игру по ID
proc deleteGame(db:DbConn, id:int) =
  let query = sql"DELETE FROM games WHERE id = ?"
  db.exec(query, id)

# Добавляет тестовые игры в базу данных
proc addTestGames(db:DbConn) =
  let games = @[
    GameInfo(name: "Тетрис", description: "Классическая игра-головоломка с падающими блоками"),
    GameInfo(name: "Змейка", description: "Управляйте змейкой, собирая еду и избегая столкновений"),
    GameInfo(name: "Пакман", description: "Съешьте все точки, избегая призраков"),
    GameInfo(name: "Арканоид", description: "Разбивайте блоки с помощью мяча и платформы"),
    GameInfo(name: "Пятнашки", description: "Классическая головоломка с передвижением плиток"),
    GameInfo(name: "Сапёр", description: "Найдите все мины на поле, не подорвавшись"),
    GameInfo(name: "Крестики-нолики", description: "Классическая игра для двух игроков"),
    GameInfo(name: "Судоку", description: "Заполните сетку цифрами от 1 до 9"),
    GameInfo(name: "Шахматы", description: "Древняя стратегическая настольная игра"),
    GameInfo(name: "Морской бой", description: "Найдите и потопите корабли противника")
  ]
  
  for game in games:
    discard createGame(db, game)

# Инициализирует базу данных
proc initDatabase(db:DbConn) =
  let tableExists = db.getAllRows(sql"SELECT name FROM sqlite_master WHERE type='table' AND name='games'").len > 0
  
  let query = sql"""
    CREATE TABLE IF NOT EXISTS games (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      description TEXT
    );
  """
  db.exec(query)

  if not tableExists:
    addTestGames(db)

# Создает новый интерфейс базы данных
proc newDatabase*():IDatabase =
  let db = open("database.db", "", "", "")

  return IDatabase(
    init: proc() =
      initDatabase(db)
    ,
    getGameInfoList: proc():seq[GameInfo] =
      getGameInfoList(db)
    ,
    createGame: proc(game:GameInfo):GameInfo =
      createGame(db, game)
    ,
    getGameById: proc(id:int):GameInfo =
      getGameById(db, id)
    ,
    updateGame: proc(game:GameInfo):GameInfo =
      updateGame(db, game)
    ,
    deleteGame: proc(id:int) =
      deleteGame(db, id)
  )