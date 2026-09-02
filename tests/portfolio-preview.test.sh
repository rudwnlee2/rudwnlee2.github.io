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
  '백엔드 개발자 이경주입니다.'
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
  '문제를 이해하고,'
  '안정적인 흐름'
  'id="about"'
  '<h2>소개</h2>'
  '<p class="about-statement">기능 너머의 이유를 이해하려 합니다.</p>'
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
  'class="project-mini-flow"'
  'class="flow-node"'
  'class="flow-track"'
  'class="flow-branch-track"'
  'class="flow-branch-label"'
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

project_flow_count="$(grep -Fc -- 'class="project-mini-flow"' "$preview" || true)"
if (( project_flow_count != 2 )); then
  echo "FAIL: expected one compact flow in each project card, found $project_flow_count"
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

if ! grep -Fq -- 'min-height: 44px;' "$preview" || ! grep -Fq -- 'font-size: 14px;' "$preview"; then
  echo "FAIL: restored flow nodes must use the approved larger sizing"
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

for forbidden_pattern in 'BackendDeveloper' 'class="code-card"' 'class="hero-actions"' 'class="quick-facts' 'class="fact-number"' 'class="hero-capabilities"' 'class="project-visual' 'class="visual-mark"' 'class="sample-badge"' 'class="project-details"' 'class="project-flow"' 'class="flow-node accent"' 'class="system-architecture"' 'class="architecture-bar"' 'class="architecture-link"' 'class="architecture-frame"' 'class="architecture-addon"' 'class="architecture-image"' 'class="architecture-pending"' 'coupon-yaho-architecture.png' '<iframe' 'data-placeholder-project="true"' '임시 예시 프로젝트' '<small>Language</small>' '<span>01 · Core</span>' 'id="contact"' 'mailto:' '>연락처<' 'href="#about">소개</a>' '<title>경주 | Backend Developer</title>' '<span>경주의 포트폴리오</span>' '<h1>경주</h1>' '백엔드 개발자 경주입니다.' '© 2026 경주. All rights reserved.'; do
  if grep -Fq -- "$forbidden_pattern" "$preview"; then
    echo "FAIL: obsolete code-card content remains: $forbidden_pattern"
    exit 1
  fi
done

echo "PASS: portfolio preview contains every required section and behavior hook"
