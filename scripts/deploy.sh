#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────
# deploy.sh  –  Push image to Docker Hub & deploy container
# ──────────────────────────────────────────────────────────
set -euo pipefail

# ── Config ────────────────────────────────────────────────
APP_NAME="ecommerce-app"
DOCKERHUB_USER="${DOCKERHUB_USER:-your-dockerhub-username}"
GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
GIT_SHA=$(git rev-parse --short HEAD 2>/dev/null || echo "latest")

# ── Determine target repo ─────────────────────────────────
if [[ "$GIT_BRANCH" == "master" || "$GIT_BRANCH" == "main" ]]; then
  REPO="prod"
else
  REPO="dev"
fi

IMAGE_TAG="${DOCKERHUB_USER}/${REPO}:${GIT_SHA}"
IMAGE_LATEST="${DOCKERHUB_USER}/${REPO}:latest"

echo "╔══════════════════════════════════════════╗"
echo "║         ECOMMERCE APP – DEPLOY           ║"
echo "╚══════════════════════════════════════════╝"
echo "  Branch : $GIT_BRANCH → repo: $REPO"
echo "  Image  : $IMAGE_TAG"
echo "──────────────────────────────────────────"

# ── Docker Hub login ──────────────────────────────────────
echo "[1/4] Logging in to Docker Hub..."
echo "$DOCKERHUB_TOKEN" | docker login -u "$DOCKERHUB_USER" --password-stdin

# ── Push ─────────────────────────────────────────────────
echo "[2/4] Pushing images..."
docker push "$IMAGE_TAG"
docker push "$IMAGE_LATEST"
echo "✅ Images pushed to Docker Hub ($REPO)"

# ── Stop old container (if running) ──────────────────────
echo "[3/4] Removing old container (if exists)..."
docker rm -f "$APP_NAME" 2>/dev/null || true

# ── Run new container ─────────────────────────────────────
echo "[4/4] Starting new container on port 80..."
docker run -d \
  --name "$APP_NAME" \
  --restart unless-stopped \
  -p 80:80 \
  "$IMAGE_LATEST"

echo ""
echo "✅ Deployed successfully!"
echo "   Container : $APP_NAME"
echo "   Image     : $IMAGE_LATEST"
echo "   URL       : http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo 'YOUR_SERVER_IP')"
