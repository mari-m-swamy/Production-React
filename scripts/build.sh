#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────
# build.sh  –  Build & tag the ecommerce-app Docker image
# ──────────────────────────────────────────────────────────
set -euo pipefail

# ── Config ────────────────────────────────────────────────
APP_NAME="ecommerce-app"
DOCKERHUB_USER="${DOCKERHUB_USER:-your-dockerhub-username}"
GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
GIT_SHA=$(git rev-parse --short HEAD 2>/dev/null || echo "latest")
BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# ── Determine target repo (dev vs prod) ───────────────────
if [[ "$GIT_BRANCH" == "master" || "$GIT_BRANCH" == "main" ]]; then
  REPO="prod"
else
  REPO="dev"
fi

IMAGE_TAG="${DOCKERHUB_USER}/${REPO}:${GIT_SHA}"
IMAGE_LATEST="${DOCKERHUB_USER}/${REPO}:latest"

echo "╔══════════════════════════════════════════╗"
echo "║         ECOMMERCE APP – BUILD            ║"
echo "╚══════════════════════════════════════════╝"
echo "  Branch   : $GIT_BRANCH"
echo "  Repo     : $REPO"
echo "  Tag      : $IMAGE_TAG"
echo "  Built at : $BUILD_DATE"
echo "──────────────────────────────────────────"

# ── Build ─────────────────────────────────────────────────
echo "[1/3] Building Docker image..."
docker build \
  --build-arg BUILD_DATE="$BUILD_DATE" \
  --build-arg GIT_SHA="$GIT_SHA" \
  -t "$APP_NAME:latest" \
  -t "$APP_NAME:$GIT_SHA" \
  -t "$IMAGE_TAG" \
  -t "$IMAGE_LATEST" \
  .

echo "[2/3] Image built successfully."

# ── Smoke test ────────────────────────────────────────────
echo "[3/3] Running smoke test..."
CONTAINER_ID=$(docker run -d --rm -p 8099:80 "$APP_NAME:latest")
sleep 3
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8099 || echo "000")
docker stop "$CONTAINER_ID" > /dev/null

if [[ "$HTTP_STATUS" == "200" ]]; then
  echo "✅ Smoke test passed (HTTP $HTTP_STATUS)"
else
  echo "❌ Smoke test failed (HTTP $HTTP_STATUS)"
  exit 1
fi

echo ""
echo "✅ Build complete → $IMAGE_TAG"
echo "   Run 'scripts/deploy.sh' to push & deploy."
