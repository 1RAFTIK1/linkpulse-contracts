# linkpulse-contracts — Makefile
#
# Единственный источник правды по .proto для всех сервисов LinkPulse.
# Требует установленного buf (см. `make tools`).

# Пиновка версий инструментов кодогенерации. Держим здесь, чтобы CI и локальная
# машина ставили ровно одно и то же.
BUF_VERSION            := v1.71.0
PROTOC_GEN_GO_VERSION  := v1.36.11
PROTOC_GEN_GRPC_VERSION:= v1.6.2

.DEFAULT_GOAL := help

.PHONY: help
help: ## Показать список целей
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'

.PHONY: tools
tools: ## Установить buf и плагины кодогенерации нужных версий
	go install github.com/bufbuild/buf/cmd/buf@$(BUF_VERSION)
	go install google.golang.org/protobuf/cmd/protoc-gen-go@$(PROTOC_GEN_GO_VERSION)
	go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@$(PROTOC_GEN_GRPC_VERSION)

.PHONY: generate
generate: ## Сгенерировать Go-код из .proto
	buf generate
	go mod tidy

.PHONY: lint
lint: ## Прогнать линт .proto
	buf lint

.PHONY: format
format: ## Отформатировать .proto по стилю buf
	buf format -w

.PHONY: breaking
breaking: ## Проверить обратную совместимость против main (нужен git-remote origin)
	buf breaking --against '.git#branch=main'

.PHONY: check-diff
check-diff: generate ## CI-проверка: сген-код не разошёлся со схемами
	git diff --exit-code -- gen/ || \
		(echo "gen/ разошёлся со схемами: запусти 'make generate' и закоммить" && exit 1)
