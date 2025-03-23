import types
import sqlite_database as sqlite
import options

var db {.threadvar.} : Option[IDatabase]

# Возвращает интерфейс базы данных
proc get*() : IDatabase {.gcsafe.} =
  if db.isSome:
    return db.get()

  let database = sqlite.newDatabase()
  database.init()

  db = some(database)

  return database