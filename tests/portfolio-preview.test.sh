#!/usr/bin/env bash

set -eu

preview="portfolio/index.html"
if [[ ! -f "$preview" ]]; then
  echo "FAIL: $preview is missing"
  exit 1
fi

required_patterns=(
  '<html lang="ko">'
  '<title>이경주 | Backend Developer</title>'
  '이경주의 포트폴리오'
  '<h1>이경주</h1>'
  '© 2026 이경주. All rights reserved.'
  '<body class="editorial-portfolio">'
  'class="hero hero-compact"'
  '--section-space: 48px;'
  '--section-space-mobile: 36px;'
  'class="profile-photo-slot"'
  'class="hero-intro"'
  'class="hero-identity"'
  'class="hero-links"'
  '>Blog ↗<'
  '>GitHub ↗<'
  'class="hero-facts"'
  '동시에 바뀌는 상태를 안전하게 다룹니다.'
  'Redis Lua로 투표 변경과 집계를 원자적으로 처리하고,'
  'Redis와 MySQL 사이의 저장 경계를 설계했습니다.'
  '동시 요청과 저장 실패 이후에도 데이터가 어긋나지 않고'
  '다시 처리할 수 있는 백엔드 구조를 고민합니다.'
  '<strong>Concurrency Control</strong><span>Redis Lua를 활용한 원자적 상태 변경</span>'
  '<strong>Data Consistency</strong><span>진행 상태와 확정 결과의 저장 경계 설계</span>'
  '<strong>Failure Recovery</strong><span>실패 후 다시 처리할 수 있는 스냅샷 보존</span>'
  'id="about"'
  '<h2>소개</h2>'
  '정상 동작뿐 아니라 동시 요청, 중복 실행,'
  '저장 실패 이후의 동작까지 함께 설계합니다.'
  '<p class="about-statement">빠르게 전달하는 것보다, 정확하게 이어지는 흐름을 중요하게 생각합니다.</p>'
  '여러 사용자가 동시에 선택을 제출하고 기존 선택을 변경하는 상황에서도'
  'DB 저장이 완료되기 전에는 마감 스냅샷을 삭제하지 않도록 설계했습니다.'
  '정상 흐름뿐 아니라 중복 마감과 DB 저장 실패 이후의 재시도 경로까지 검증했습니다.'
  '<strong>원자적으로 변경합니다</strong>'
  '<strong>데이터의 수명에 따라 저장합니다</strong>'
  '<strong>실패 이후를 설계합니다</strong>'
  'id="skills"'
  'class="skill-categories compact"'
  'class="tech-grid"'
  'background: #fff; padding: 5px;'
  'data-skill-category="backend"'
  'data-skill-category="data"'
  'data-skill-category="messaging"'
  'data-skill-category="infra"'
  'id="projects"'
  '갈래말래'
  '쿠폰 야호'
  'https://github.com/rudwnlee2/gallae-mallae-backend'
  'https://github.com/coupon-yaho/cy-be'
  '투표 도메인'
  '운영현황'
  'class="project-header"'
  'class="project-icon"'
  'class="project-highlights"'
  'class="project-architecture" data-architecture="coupon"'
  'class="project-architecture" data-architecture="vote"'
  'class="architecture-diagram"'
  'aria-label="쿠폰 야호 시스템 아키텍처"'
  'aria-label="갈래말래 투표 시스템 아키텍처"'
  '>Queue Gateway<'
  '>Queue Redis<'
  '>Coupon Service<'
  '>Coupon Redis<'
  '>운영 관제 · 담당 영역<'
  '>Vote API<'
  '>Redis Lua<'
  '>Active Vote<'
  '>Closed Snapshot<'
  '>MySQL Result<'
  'id="stories"'
  'id="experience"'
  'class="shell section-layout"'
  'aria-label="다크 모드로 전환"'
  '@media (max-width: 760px)'
  'prefers-reduced-motion: reduce'
)

for pattern in "${required_patterns[@]}"; do
  if ! grep -Fq -- "$pattern" "$preview"; then
    echo "FAIL: missing required pattern: $pattern"
    exit 1
  fi
done

for websocket_term in 'WebSocket' 'STOMP' '웹소켓' '실시간 연결' '실시간 메시지' '실시간 알림' '변경 알림' '구독 권한'; do
  if grep -Fq -- "$websocket_term" "$preview"; then
    echo "FAIL: portfolio preview still contains WebSocket topic: $websocket_term"
    exit 1
  fi
done

tech_icon_count="$(grep -Fc -- 'class="tech-icon"' "$preview" || true)"
if (( tech_icon_count != 8 )); then
  echo "FAIL: expected exactly 8 technology icon slots, found $tech_icon_count"
  exit 1
fi

tech_image_count="$(grep -Fc -- 'class="tech-icon-image"' "$preview" || true)"
if (( tech_image_count != 8 )); then
  echo "FAIL: every technology must use a real image logo, found $tech_image_count"
  exit 1
fi

skills_markup="$(sed -n '/<section class="section alt" id="skills">/,/<\/section>/p' "$preview")"
for removed_skill in 'Linux' 'Prometheus'; do
  if grep -Fq -- ">$removed_skill<" <<< "$skills_markup"; then
    echo "FAIL: removed skill remains in the technology stack: $removed_skill"
    exit 1
  fi
done

for icon in java spring hibernate mysql redis apachekafka docker githubactions; do
  icon_path="assets/img/tech/$icon.svg"
  if [[ ! -f "$icon_path" ]]; then
    echo "FAIL: real technology icon is missing: $icon_path"
    exit 1
  fi
  if ! grep -Fq -- "src=\"/$icon_path\"" "$preview"; then
    echo "FAIL: portfolio does not use technology icon: $icon_path"
    exit 1
  fi
done

project_architecture_count="$(grep -Fc -- 'class="project-architecture"' "$preview" || true)"
if (( project_architecture_count != 2 )); then
  echo "FAIL: expected one architecture diagram in each project card, found $project_architecture_count"
  exit 1
fi

architecture_svg_count="$(grep -Fc -- 'class="architecture-diagram"' "$preview" || true)"
if (( architecture_svg_count != 2 )); then
  echo "FAIL: every project architecture must use a responsive SVG, found $architecture_svg_count"
  exit 1
fi

section_layout_count="$(grep -Fc -- 'class="shell section-layout"' "$preview" || true)"
if (( section_layout_count != 5 )); then
  echo "FAIL: every content section must use the editorial left-label layout, found $section_layout_count"
  exit 1
fi

content_card_count="$(grep -Fc -- 'class="card ' "$preview" || true)"
if (( content_card_count != 2 )); then
  echo "FAIL: only the two featured projects should remain as full cards, found $content_card_count"
  exit 1
fi

if [[ ! -f "portfolio-preview-before-hybrid.png" ]]; then
  echo "FAIL: the pre-redesign screenshot must be preserved"
  exit 1
fi

if ! grep -Fq -- 'min-width: 760px;' "$preview" || ! grep -Fq -- '.architecture-label { fill: var(--heading); font-size: 12px;' "$preview"; then
  echo "FAIL: architecture diagrams must remain readable at card width"
  exit 1
fi

profile_line="$(grep -nF 'class="profile-photo-slot"' "$preview" | head -n 1 | cut -d: -f1)"
intro_line="$(grep -nF 'class="hero-intro"' "$preview" | head -n 1 | cut -d: -f1)"
if (( profile_line >= intro_line )); then
  echo "FAIL: profile image must appear before the hero introduction"
  exit 1
fi

coupon_project_line="$(grep -nF '<h3>쿠폰 야호</h3>' "$preview" | head -n 1 | cut -d: -f1)"
gallae_project_line="$(grep -nF '<h3>갈래말래</h3>' "$preview" | head -n 1 | cut -d: -f1)"
if (( coupon_project_line >= gallae_project_line )); then
  echo "FAIL: projects must be ordered newest first"
  exit 1
fi

for forbidden_pattern in 'BackendDeveloper' 'class="code-card"' 'class="hero-actions"' 'class="quick-facts' 'class="fact-number"' 'class="hero-capabilities"' 'class="project-visual' 'class="visual-mark"' 'class="sample-badge"' 'class="project-details"' 'class="project-flow"' 'class="project-mini-flow"' 'class="flow-node accent"' 'class="system-architecture"' 'class="architecture-bar"' 'class="architecture-link"' 'class="architecture-frame"' 'class="architecture-addon"' 'class="architecture-image"' 'class="architecture-pending"' 'coupon-yaho-architecture.png' '<iframe' 'data-placeholder-project="true"' '임시 예시 프로젝트' '<small>Language</small>' '<span>01 · Core</span>' 'id="contact"' 'mailto:' '>연락처<' 'href="#about">소개</a>' '<title>경주 | Backend Developer</title>' '<span>경주의 포트폴리오</span>' '<h1>경주</h1>' '백엔드 개발자 경주입니다.' '© 2026 경주. All rights reserved.' '문제를 이해하고, 안정적인 흐름을 설계합니다.' '데이터 흐름과 Kafka 학습' '기능 너머의 이유를 이해하려 합니다.' '<strong>근거 있는 선택</strong>' '<strong>운영 관점</strong>' '<strong>학습의 기록</strong>'; do
  if grep -Fq -- "$forbidden_pattern" "$preview"; then
    echo "FAIL: obsolete code-card content remains: $forbidden_pattern"
    exit 1
  fi
done

echo "PASS: portfolio preview contains every required section and behavior hook"
