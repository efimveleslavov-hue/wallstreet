#!/usr/bin/env bash
#
# Читает сообщения бота @SashaStatus_bot за сегодня через telegram-mcp
# и присылает деловую сводку в Избранное (Saved Messages).
# Запускается по расписанию через launchd (12:00 и 17:00), но можно и вручную:
#     bash ~/wallstreet/telegram-mcp-setup/summary/sasha-summary.sh
#
set -uo pipefail

# --- окружение (launchd стартует с пустым PATH) ---
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.local/bin:$PATH"
# подтягиваем PATH из профиля пользователя (node может быть под nvm/fnm/volta)
source "$HOME/.zprofile" 2>/dev/null || true
source "$HOME/.zshrc"    2>/dev/null || true

LOG="$HOME/Library/Logs/sasha-summary.log"
mkdir -p "$(dirname "$LOG")"

BOT="@SashaStatus_bot"
MY_ID="992286066"   # мой аккаунт = Избранное (Saved Messages)

CLAUDE_BIN="$(command -v claude || echo /opt/homebrew/bin/claude)"

echo "===== $(date '+%Y-%m-%d %H:%M:%S') запуск sasha-summary =====" >>"$LOG"

read -r -d '' PROMPT <<PROMPT_EOF
Ты — фоновый ассистент, работаешь без участия человека. Используй только telegram-mcp.

1. Найди диалог с ботом ${BOT} (при необходимости resolve_username), прочитай его сообщения за СЕГОДНЯ (с 00:00 по текущий момент по местному времени). Бот присылает лиды: текст, диалоги и краткие саммари звонков.
2. Собери деловую сводку по этим лидам:
   • Сколько лидов за сегодня — число.
   • Разбивка по культурам: культура — суммарный объём в тоннах.
   • Итого тонн за день.
   • 1–3 коротких инсайта (заметные всплески, крупные лиды, необычное, повторяющиеся запросы).
3. Оформи КРАТКО, пунктами, в начале строка с датой и временем.
4. Отправь эту сводку мне в Избранное: send_message с chat_id=${MY_ID}. Больше НИКОМУ и НИЧЕГО не отправляй, ничего не пересылай, контакты не добавляй.
5. Если сообщений бота за сегодня нет — отправь коротко: "За сегодня лидов от ${BOT} пока нет".

Только чтение бота и одно сообщение мне. Никаких других действий.
PROMPT_EOF

"$CLAUDE_BIN" -p "$PROMPT" \
  --allowedTools "mcp__telegram-mcp" \
  >>"$LOG" 2>&1

echo "===== $(date '+%Y-%m-%d %H:%M:%S') завершено (код $?) =====" >>"$LOG"
