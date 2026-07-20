# Авто-саммари лидов от @SashaStatus_bot (2 раза в день)

Дважды в день (**12:00 и 17:00**) на твоём Mac запускается `claude` в фоне,
читает сообщения бота **@SashaStatus_bot** за сегодня и присылает тебе в
**Избранное** (Saved Messages) деловую сводку: сколько лидов, разбивка по
культурам в тоннах, итого за день и короткие инсайты.

Работает целиком на Mac (там подключён `telegram-mcp`). Только чтение бота +
одно сообщение тебе — ничего никому не рассылается.

## Установка (один раз)

Предполагается, что репозиторий склонирован в `~/wallstreet`. Если он в другом
месте — поправь путь в `com.ags.sasha-summary.plist` (строка с `sasha-summary.sh`).

```bash
# 1) Сделать скрипт исполняемым
chmod +x ~/wallstreet/telegram-mcp-setup/summary/sasha-summary.sh

# 2) Сначала проверить ВРУЧНУЮ, что сводка приходит в Избранное
bash ~/wallstreet/telegram-mcp-setup/summary/sasha-summary.sh
#   -> загляни в Telegram → Избранное; лог: ~/Library/Logs/sasha-summary.log

# 3) Поставить на расписание
cp ~/wallstreet/telegram-mcp-setup/summary/com.ags.sasha-summary.plist ~/Library/LaunchAgents/
launchctl unload ~/Library/LaunchAgents/com.ags.sasha-summary.plist 2>/dev/null
launchctl load  ~/Library/LaunchAgents/com.ags.sasha-summary.plist

# Проверить, что задача зарегистрирована:
launchctl list | grep sasha-summary
```

## Проверить прямо сейчас (не дожидаясь 12:00/17:00)

```bash
launchctl start com.ags.sasha-summary
```
Через минуту глянь Избранное и лог `~/Library/Logs/sasha-summary.log`.

## Поменять время

Отредактируй блок `StartCalendarInterval` в
`~/Library/LaunchAgents/com.ags.sasha-summary.plist` (часы/минуты), затем:
```bash
launchctl unload ~/Library/LaunchAgents/com.ags.sasha-summary.plist
launchctl load   ~/Library/LaunchAgents/com.ags.sasha-summary.plist
```

## Выключить

```bash
launchctl unload ~/Library/LaunchAgents/com.ags.sasha-summary.plist
rm ~/Library/LaunchAgents/com.ags.sasha-summary.plist
```

## Если сводка не пришла — куда смотреть

| Симптом | Что делать |
|---|---|
| В логе `claude: command not found` | Узнай путь: `which claude`; впиши его в `CLAUDE_BIN` в `sasha-summary.sh`. Аналогично может понадобиться путь к `node`. |
| Просит подтвердить инструмент / «permission» | В скрипте уже стоит `--allowedTools "mcp__telegram-mcp"`. Если всё равно спотыкается — временно добавь флаг `--dangerously-skip-permissions` в вызов `claude` в скрипте. |
| `telegram-mcp` не отвечает | Проверь `claude mcp list` → должно быть `✔ Connected`. При «session expired» — пересоздай строку-сессию (см. основной README, Шаг 3). |
| Ноутбук спал в 12:00/17:00 | launchd запустит задачу при ближайшем пробуждении. Точный запуск во сне не гарантируется. |

## Важно

- Задача работает, только когда Mac включён (в идеале не спит). Для «всегда
  вовремя» нужен постоянно работающий компьютер/сервер.
- Скрипт шлёт сводку строго на твой аккаунт (`chat_id=992286066`, Избранное) и
  ничего больше не отправляет.
