import options
import types

import openai_api

# API для работы с ИИ
var ai:Option[IAiApi] = none(IAiApi)

# Получает API для работы с ИИ
proc get*():IAiApi =
    if ai.isSome:
        return ai.get()

    let ai = newOpenAiApi("https://api.openai.com/v1", "gpt-3.5-turbo")
    return ai