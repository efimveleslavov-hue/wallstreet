#!/usr/bin/env bash
#
# Шаг 1 — установка сервера chigwell/telegram-mcp на локальный Mac.
# Запуск:  bash telegram-mcp-setup/01-install.sh
#
# Скрипт идемпотентный: можно запускать повторно.

set -euo pipefail

REPO_URL="https://github.com/chigwell/telegram-mcp.git"
TARGET="${TELEGRAM_MCP_DIR:-$HOME/telegram-mcp}"

echo "==> Целевая папка: $TARGET"

# --- 1. Проверяем git и python3, при отсутствии ставим через brew (macOS) ---
need_brew=0
command -v git      >/dev/null 2>&1 || need_brew=1
command -v python3  >/dev/null 2>&1 || need_brew=1

if [ "$need_brew" -eq 1 ]; then
  if command -v brew >/dev/null 2>&1; then
    echo "==> Ставлю недостающие git/python через Homebrew..."
    command -v git     >/dev/null 2>&1 || brew install git
    command -v python3 >/dev/null 2>&1 || brew install python
  else
    echo "!! Нет git и/или python3, и Homebrew не найден."
    echo "   Установи Homebrew (https://brew.sh) или git+python вручную, затем повтори."
    exit 1
  fi
fi

echo "==> git:    $(command -v git)"
echo "==> python: $(command -v python3)  ($(python3 --version))"

# --- 2. Клонируем (или обновляем) репозиторий ---
if [ -d "$TARGET/.git" ]; then
  echo "==> Репозиторий уже есть, обновляю..."
  git -C "$TARGET" pull --ff-only || echo "   (pull пропущен — есть локальные изменения, это нормально)"
else
  echo "==> Клонирую $REPO_URL ..."
  git clone "$REPO_URL" "$TARGET"
fi

# --- 3. venv + установка ---
if [ ! -d "$TARGET/.venv" ]; then
  echo "==> Создаю виртуальное окружение .venv ..."
  python3 -m venv "$TARGET/.venv"
fi

echo "==> Устанавливаю пакет (pip install -e .) ..."
# shellcheck disable=SC1091
source "$TARGET/.venv/bin/activate"
python -m pip install --upgrade pip >/dev/null
pip install -e "$TARGET"

# --- 4. Готовим .env рядом с проектом telegram-mcp ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ ! -f "$TARGET/.env" ]; then
  cp "$SCRIPT_DIR/.env.example" "$TARGET/.env"
  echo "==> Создал $TARGET/.env из шаблона — впиши в него TELEGRAM_API_ID и TELEGRAM_API_HASH."
fi

echo
echo "✅ Шаг 1 готов."
echo "   Дальше: получи API_ID/API_HASH на https://my.telegram.org/apps,"
echo "   впиши их в $TARGET/.env, затем сгенерируй строку-сессию (см. README, Шаг 3)."
echo
echo "   Полезный путь бинаря для регистрации MCP:"
echo "     $TARGET/.venv/bin/telegram-mcp"
