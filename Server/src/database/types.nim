# Информация об игре
type GameInfo* = object
    id*: int
    name*: string
    description*: string

# Интерфейс базы данных
type IDatabase* = object
    # Инициализирует базу данных
    init*: proc():void {.gcsafe.}    
    # Создает новую игру
    createGame*: proc(game:GameInfo):GameInfo {.gcsafe.}
    # Получает игру по ID
    getGameById*: proc(id:int):GameInfo {.gcsafe.}
    # Обновляет информацию об игре
    updateGame*: proc(game:GameInfo):GameInfo {.gcsafe.}
    # Удаляет игру по ID
    deleteGame*: proc(id:int):void {.gcsafe.} 
    # Возвращает список игр с их информацией
    getGameInfoList*: proc():seq[GameInfo] {.gcsafe.}