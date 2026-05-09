#!/usr/bin/env bash
set -euo pipefail

# ── Config ────────────────────────────────────────────────
APP_NAME="ecommerce-app"
AWS_REGION="${AWS_DEFAULT_REGION:-us-east-1}"
ACCOUNT_ID="${ACCOUNT_ID:-558316745366}"
ECR_URI="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${APP_NAME}"
GIT_SHA=$(git rev-parse --short HEAD 2>/dev/null || echo "latest")
BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo "╔══════════════════════════════════════════╗"
echo "║         ECOMMERCE APP – BUILD            ║"
echo "╚══════════════════════════════════════════╝"
echo "  ECR URI  : $ECR_URI"
echo "  Tag      : $GIT_SHA"
echo "  Built at : $BUILD_DATE"
echo "──────────────────────────────────────────"

# ── ECR Login ─────────────────────────────────────────────
echo "[1/4] Logging in to ECR..."
aws ecr get-login-password --region "$AWS_REGION" | \
  docker login --username AWS --password-stdin \
  "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

# ── Build ─────────────────────────────────────────────────
echo "[2/4] Building Docker image..."
docker build \
  -t "${APP_NAME}:latest" \
  -t "${APP_NAME}:${GIT_SHA}" \
  -t "${ECR_URI}:latest" \
  -t "${ECR_URI}:${GIT_SHA}" \
  .

# ── Smoke Test ────────────────────────────────────────────
echo "[3/4] Running smoke test..."
CONTAINER_ID=$(docker run -d --rm -p 8099:80 "${APP_NAME}:latest")
sleep 3
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8099 || echo "000")
docker stop "$CONTAINER_ID" > /dev/null

if [[ "$HTTP_STATUS" == "200" ]]; then
  echo "✅ Smoke test passed (HTTP $HTTP_STATUS)"
else
  echo "❌ Smoke test failed (HTTP $HTTP_STATUS)"
  exit 1
fi

echo "[4/4] Build complete → $ECR_URI:$GIT_SHA"
echo "   Run 'scripts/deploy.sh' to push & deploy."
