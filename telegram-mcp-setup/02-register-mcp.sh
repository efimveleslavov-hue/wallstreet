#!/usr/bin/env bash
#
# Шаг 4 — регистрация telegram-mcp в Claude Code (scope=user).
# Запуск ПОСЛЕ того, как получена строка-сессия (Шаг 3):
#     bash telegram-mcp-setup/02-register-mcp.sh
#
# Значения берутся из $HOME/telegram-mcp/.env. Строку-сессию можно либо
# положить в .env как TELEGRAM_SESSION_STRING, либо ввести по запросу.

set -euo pipefail

TARGET="${TELEGRAM_MCP_DIR:-$HOME/telegram-mcp}"
ENV_FILE="$TARGET/.env"
BIN="$TARGET/.venv/bin/telegram-mcp"

[ -f "$ENV_FILE" ] || { echo "!! Не найден $ENV_FILE — сначала запусти 01-install.sh"; exit 1; }
[ -x "$BIN" ]      || { echo "!! Не найден бинарь $BIN — сначала запусти 01-install.sh"; exit 1; }

# Читаем .env
# shellcheck disable=SC1090
set -a; source "$ENV_FILE"; set +a

: "${TELEGRAM_API_ID:?Впиши TELEGRAM_API_ID в $ENV_FILE}"
: "${TELEGRAM_API_HASH:?Впиши TELEGRAM_API_HASH в $ENV_FILE}"

SESSION="${TELEGRAM_SESSION_STRING:-}"
if [ -z "$SESSION" ]; then
  echo "Вставь строку-сессию (из session_string_generator.py) и нажми Enter:"
  read -r SESSION
fi
[ -n "$SESSION" ] || { echo "!! Пустая строка-сессия"; exit 1; }

echo "==> Удаляю прежнюю регистрацию (если была)..."
claude mcp remove telegram-mcp --scope user >/dev/null 2>&1 || true

echo "==> Регистрирую telegram-mcp..."
claude mcp add telegram-mcp --scope user \
  --env TELEGRAM_API_ID="$TELEGRAM_API_ID" \
  --env TELEGRAM_API_HASH="$TELEGRAM_API_HASH" \
  --env TELEGRAM_SESSION_STRING="$SESSION" \
  -- "$BIN" "$TARGET/telegram-data"

echo
echo "==> Проверка (claude mcp list):"
claude mcp list

echo
echo "Если telegram-mcp показан как Connected — открой НОВУЮ сессию Claude Code,"
echo "чтобы сервер подхватился, и вызови get_me для проверки аккаунта."
