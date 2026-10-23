#!/bin/sh
# Local whisper.cpp server for pi-speech dictation.
#
# Builds the joelove/whisper.cpp fork, fetches the large-v3-turbo-q5_0 model,
# links the binaries into ~/.local/bin, and installs/loads the LaunchAgent that
# serves the recogniser on 127.0.0.1:8080. pi-speech reaches it through
# PI_SPEECH_STT_URL (exported in .zshrc). Idempotent: re-run after a pull to
# rebuild. See README.md and .config/whisper/.
set -eu

REPO="${WHISPER_REPO:-$HOME/Projects/whisper.cpp}"
REMOTE="${WHISPER_REMOTE:-git@github.com:joelove/whisper.cpp.git}"
BRANCH="${WHISPER_BRANCH:-personal}"
MODEL="${WHISPER_MODEL:-large-v3-turbo-q5_0}"
MODEL_PATH="$REPO/models/ggml-$MODEL.bin"
LABEL="com.joelove.whisper-server"
PLIST_SRC="$(cd "$(dirname "$0")/.." && pwd)/.config/whisper/$LABEL.plist"
PLIST_DEST="$HOME/Library/LaunchAgents/$LABEL.plist"

for tool in git cmake ffmpeg; do
  command -v "$tool" >/dev/null 2>&1 || {
    echo "setup-whisper: $tool is missing (brew install $tool)" >&2
    exit 1
  }
done

# 1. The fork, frozen upstream, personal branch.
if [ -d "$REPO/.git" ]; then
  git -C "$REPO" fetch --quiet origin
  git -C "$REPO" checkout -q "$BRANCH"
  git -C "$REPO" pull --ff-only --quiet
else
  git clone --quiet --branch "$BRANCH" "$REMOTE" "$REPO"
fi

# 2. Build with Metal (the default on Apple Silicon).
cmake -B "$REPO/build" -S "$REPO" -DCMAKE_BUILD_TYPE=Release >/dev/null
cmake --build "$REPO/build" -j --config Release >/dev/null

# 3. The model, once.
if [ ! -f "$MODEL_PATH" ]; then
  ( cd "$REPO" && sh ./models/download-ggml-model.sh "$MODEL" >/dev/null )
fi

# 4. Binaries on PATH.
mkdir -p "$HOME/.local/bin"
ln -sfn "$REPO/build/bin/whisper-server" "$HOME/.local/bin/whisper-server"
ln -sfn "$REPO/build/bin/whisper-cli" "$HOME/.local/bin/whisper-cli"

# 5. The LaunchAgent, reloaded.
mkdir -p "$HOME/Library/LaunchAgents"
ln -sfn "$PLIST_SRC" "$PLIST_DEST"
launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
sleep 1
# A racing bootout can make bootstrap fail with an I/O error even though the
# service is loaded; kickstart then just restarts it either way.
launchctl bootstrap "gui/$(id -u)" "$PLIST_DEST" 2>/dev/null || true
launchctl kickstart -k "gui/$(id -u)/$LABEL"

echo "whisper-server ready on 127.0.0.1:8080 (model $MODEL)"
