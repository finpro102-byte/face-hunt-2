#!/usr/bin/env bash
# Скачивает N фотореалистичных лиц (StyleGAN) в assets/faces/ для офлайн-игры.
# Использование: bash tools/download_faces.sh 200
set -e
cd "$(dirname "$0")/.."
N="${1:-200}"
mkdir -p assets/faces
for i in $(seq 1 "$N"); do
  f="assets/faces/face_$(printf '%04d' "$i").jpg"
  if [ ! -s "$f" ]; then
    curl -sL --max-time 30 "https://thispersondoesnotexist.com/" -o "$f"
    sleep 1   # не ддосим демо-эндпоинт
  fi
  if [ $((i % 20)) -eq 0 ]; then echo "Скачано $i / $N"; fi
done
echo "Готово: $N лиц в assets/faces/"
echo "Теперь в lib/game_screen.dart замените провайдера:"
echo "  final FaceProvider _provider = AssetFaceProvider(count: $N);"
