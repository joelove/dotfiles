---
name: loop
description: >-
  Run a prompt or task repeatedly on an interval. Use when the user invokes
  /skill:loop with an interval and a prompt. pi cannot wake itself, so this
  documents the supported bounded and scheduled mechanisms.
disable-model-invocation: true
---

# Loop

Accept `/skill:loop [interval] <prompt>`.

Intervals look like `30s`, `5m`, `2h`, `1d`. Convert unit words to short units. With no interval, the mode is self-paced (you choose the delay).

**pi has no background wake mechanism.** Unlike Cursor's monitored shell output, pi is not woken by shell output. Be explicit with the user about the limitation and pick one of the mechanisms below.

## 1. Bounded repetition within this turn

Use when the task should run a fixed number of times now, for example "check 5 times, 30 seconds apart":

```bash
for i in $(seq 1 "$N"); do
  <command>
  sleep "$SECONDS"
done
```

Run the prompt once immediately, then report the iteration count and interval. This stops on its own and does not survive the turn.

## 2. OS scheduling for durable runs

Use when the task must run on a schedule while pi is closed. Schedule a non-interactive pi invocation with cron or launchd:

```bash
# crontab -e: every 15 minutes
*/15 * * * * cd /path/to/repo && /path/to/pi -p "check deploy status and report"
```

- Prefer a dedicated prompt or a `/skill:loop`-style prompt file over a long inline string.
- Use a unique marker or script name so the entry is easy to find and remove.
- Never install a cron or launchd entry without the user's explicit confirmation.

## 3. Self-paced across turns

pi acts only when the user sends a message. If the user wants you to decide the cadence:

1. Run the prompt now.
2. Say whether the next run is gated on a time delay or on an observable event.
3. Propose when to check again and ask the user to re-invoke or send a follow-up.

Do not promise automatic wake-ups.

## Stopping

- Bounded: it stops on its own; report the result.
- Scheduled: remove the cron or launchd entry and confirm.
- Never leave a background process running that the user did not ask for.
