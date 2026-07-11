# linkpulse-contracts

Общие контракты проекта **LinkPulse**: gRPC-сервисы и формат событий Kafka в виде
Protocol Buffers, плюс сгенерированный Go-код. Единый источник правды по схемам —
все остальные сервисы подключают этот модуль через `go get`.

## Что внутри

```
proto/
  auth/v1/auth.proto              # AuthService.ValidateToken
  events/v1/click_event.proto     # ClickEvent (payload Kafka + элемент gRPC-стрима)
  analytics/v1/analytics.proto    # AnalyticsService.{GetLinkStats,StreamLiveClicks}
gen/go/...                        # сгенерированный код (коммитится в репозиторий)
buf.yaml                          # линт + breaking-проверка схем
buf.gen.yaml                      # что и куда генерировать
```

`gen/go` **коммитится намеренно** — так сервисы получают готовый код обычным
`go get github.com/1RAFTIK1/linkpulse-contracts`, без установленного buf у себя.

## Инструменты

| Инструмент | Версия | Зачем |
|---|---|---|
| [buf](https://buf.build) | v1.71.0 | линт схем, breaking-проверка, кодогенерация |
| protoc-gen-go | v1.36.11 | типы сообщений (`*.pb.go`) |
| protoc-gen-go-grpc | v1.6.2 | клиенты/серверы gRPC (`*_grpc.pb.go`) |

Установить: `make tools`.

## Как пользоваться

```bash
make generate   # buf generate + go mod tidy
make lint       # линт .proto
make format     # форматирование .proto
make breaking   # проверка обратной совместимости против main
```

После правки любого `.proto` обязательно `make generate` и коммит `gen/`.
CI (`buf breaking` + `check-diff`) не даст смёржить рассинхрон схем и кода.

## Подключение из сервиса

```bash
go get github.com/1RAFTIK1/linkpulse-contracts@latest
```

```go
import (
    eventsv1    "github.com/1RAFTIK1/linkpulse-contracts/gen/go/events/v1"
    authv1      "github.com/1RAFTIK1/linkpulse-contracts/gen/go/auth/v1"
    analyticsv1 "github.com/1RAFTIK1/linkpulse-contracts/gen/go/analytics/v1"
)
```

Версионирование — по SemVer через git-теги (`v0.1.0`, ...). Ломающее изменение
схемы = мажорная версия.
