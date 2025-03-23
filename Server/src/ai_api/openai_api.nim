import httpclient
import json
import types

# Тип для работы с OpenAI API
type OpenAiApi = object
    # Модель для генерации текста
    model: string
    # HTTP клиент для отправки запросов
    client: HttpClient
    # Базовый URL API
    baseUrl: string

# Завершает текст с помощью OpenAI API
proc complete(self: OpenAiApi, systemPrompt: string, userPrompt: string): string =
    let requestBody = %* {
        "model": self.model,
        "messages": [
            {"role": "system", "content": systemPrompt},
            {"role": "user", "content": userPrompt}
        ],
        "temperature": 0.7
    }

    let response = self.client.post(self.baseUrl & "/v1/chat/completions", $requestBody)
    
    if response.status != "200":
        raise newException(ValueError, "API error: " & response.body)

    let jsonResponse = parseJson(response.body)
    result = jsonResponse["choices"][0]["message"]["content"].getStr()

# Создает новый API для работы с ИИ в формате с OpenAI
proc newOpenAiApi*(baseUrl: string, model: string): IAiApi =
    var api = OpenAiApi(
        model: model,
        client: newHttpClient(),
        baseUrl: baseUrl
    )
    api.client.headers = newHttpHeaders({
        "Content-Type": "application/json"
    })    
    return IAiApi(
        complete: proc(systemPrompt: string, userPrompt: string): string =
            return complete(api, systemPrompt, userPrompt)
    )