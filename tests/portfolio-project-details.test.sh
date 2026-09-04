#!/usr/bin/env bash

set -eu

preview="portfolio/index.html"
coupon_detail="portfolio/coupon-yaho/index.html"
vote_detail="portfolio/gallae-mallae/index.html"

for file in "$preview" "$coupon_detail" "$vote_detail"; do
  if [[ ! -f "$file" ]]; then
    echo "FAIL: $file is missing"
    exit 1
  fi
done

if grep -Fq -- 'href="/portfolio/coupon-yaho/"' "$preview"; then
  echo "FAIL: portfolio still links to the coupon detail page"
  exit 1
fi
if grep -Fq -- 'href="/portfolio/gallae-mallae/"' "$preview"; then
  echo "FAIL: portfolio still links to the vote detail page"
  exit 1
fi

for label in '프로젝트 목적' '담당 범위' '핵심 문제' '기술적 선택' '구현' '검증' '결과 및 회고' '사용 기술'; do
  if ! grep -Fq -- "$label" "$coupon_detail"; then
    echo "FAIL: coupon detail is missing section: $label"
    exit 1
  fi
  if ! grep -Fq -- "$label" "$vote_detail"; then
    echo "FAIL: vote detail is missing section: $label"
    exit 1
  fi
done

for detail in "$coupon_detail" "$vote_detail"; do
  if ! grep -Fq -- 'href="/portfolio/#projects"' "$detail"; then
    echo "FAIL: $detail does not provide a back link"
    exit 1
  fi
  if ! grep -Fq -- 'aria-label="다크 모드로 전환"' "$detail"; then
    echo "FAIL: $detail does not provide the theme toggle"
    exit 1
  fi
  if ! grep -Fq -- '@media (max-width: 760px)' "$detail"; then
    echo "FAIL: $detail does not provide a mobile layout"
    exit 1
  fi
done

if ! grep -Fq -- '/assets/diagrams/coupon-yaho-architecture.png' "$coupon_detail"; then
  echo "FAIL: coupon detail does not include the supplied architecture image"
  exit 1
fi

if ! grep -Fq -- 'Redis Lua' "$vote_detail" || ! grep -Fq -- '마감 스냅샷' "$vote_detail"; then
  echo "FAIL: vote detail does not explain the core vote flow"
  exit 1
fi

for websocket_term in 'WebSocket' 'STOMP' '웹소켓' '실시간 알림' '변경 알림' '구독 권한'; do
  if grep -Fq -- "$websocket_term" "$vote_detail"; then
    echo "FAIL: vote detail still contains WebSocket topic: $websocket_term"
    exit 1
  fi
done

echo "PASS: standalone project details remain complete but are not linked from the portfolio cards"
