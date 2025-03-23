# Интерфейс для работы с AI API
type IAiApi* = object
    # Получает завершенный текста
    complete*: proc(systemPrompt: string, userPrompt: string): string

