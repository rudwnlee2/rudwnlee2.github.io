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
  'class="profile-photo"'
  'border: 1px solid var(--line-strong);'
  'box-shadow: 0 14px 32px rgba(15, 23, 42, .1);'
  'src="/assets/img/profile/lee-gyeongju.jpg"'
  'alt="백엔드 개발자 이경주 프로필 사진"'
  'width="591" height="787"'
  'fetchpriority="high"'
  'class="hero-intro"'
  'class="hero-identity"'
  'class="hero-links"'
  '>Blog ↗<'
  '>GitHub ↗<'
  'class="hero-facts"'
  '동시 요청과 장애 상황에서도 데이터 정합성을 지키는 백엔드 개발자입니다.'
  '동시성 제어, 실패 감지, 재처리가 가능한 구조를 프로젝트에서 구현하고 검증했습니다.'
  '<strong>Concurrency Control</strong>'
  'Redis Lua로 여러 요청을 한 번에 처리'
  '<strong>Data Consistency</strong>'
  '진행 정보는 Redis, 마감 결과는 MySQL에 저장'
  '<strong>Failure Recovery</strong>'
  '저장 실패 시 남아 있는 마감 결과로 다시 시도'
  'id="about"'
  '<h2>소개</h2>'
  '동시 요청, 저장소 간 데이터 차이, 실패 이후의 흐름을 프로젝트에서 직접 다뤘습니다.'
  '<p class="about-statement">정상 동작을 만드는 데서 멈추지 않고, 실패한 뒤에도 다시 이어질 수 있는 구조를 고민합니다.</p>'
  '백엔드 개발을 하며 동시에 요청이 들어올 때 데이터가 어떻게 바뀌는지, 서로 다른 저장소의 값이 어디에서 어긋날 수 있는지 살펴왔습니다.'
  '갈래말래에서는 투표 변경과 집계를 한 번에 처리하고, 저장 실패 후 같은 결과로 다시 시도하는 흐름을 구현했습니다.'
  '쿠폰 야호에서는 Redis와 MySQL의 발급 상태를 비교하고, DB 커밋 이후 종료 이벤트를 여러 서버에 전파했습니다.'
  '기능을 완성하는 것뿐 아니라 실패 지점을 확인할 수 있는 지표와 누락을 보정하는 방법까지 함께 고민했습니다.'
  '선택한 기술의 보장 범위와 한계를 테스트로 확인하며, 운영 중에도 문제를 찾고 대응할 수 있는 백엔드를 만들고자 합니다.'
  '<strong>동시 상태 정합성</strong>'
  'Redis Lua로 투표 변경과 집계를 한 번에 처리'
  '<strong>저장소 간 데이터 비교</strong>'
  'Redis·MySQL 발급 상태를 네 가지 기준으로 비교'
  '<strong>실패 복구와 누락 보정</strong>'
  '저장 실패 시 재시도하고, 놓친 종료 정보는 DB 조회로 보정'
  '--emphasis-text: #111827;'
  '--emphasis-text: #f8fafc;'
  '.about-main .about-statement { margin-bottom: 1rem; color: var(--emphasis-text);'
  'id="skills"'
  'class="skill-categories compact"'
  'class="tech-grid"'
  'background: #fff; padding: 5px;'
  'data-skill-category="backend"'
  'data-skill-category="data"'
  'data-skill-category="messaging"'
  'data-skill-category="etc"'
  'id="projects"'
  '갈래말래'
  '<span class="project-summary-line">그룹원의 조건에 맞는 메뉴 후보를 추천하고,</span>'
  '<span class="project-summary-line">투표 결과로 최종 메뉴를 정하는 서비스</span>'
  '쿠폰 야호'
  'https://github.com/rudwnlee2/gallae-mallae-backend'
  'https://github.com/coupon-yaho/cy-be'
  '투표 기능'
  '운영현황'
  'class="project-header"'
  'class="project-icon"'
  'class="project-cases"'
  '.project-cases { display: grid; gap: 1rem; margin-top: 1.25rem; }'
  '.project-card { overflow: hidden; border-radius: .85rem; padding: 1.5rem; }'
  '.project-case { overflow: hidden; border: 1px solid var(--line-strong); border-radius: .9rem; background: var(--panel); padding: 0; }'
  'background: var(--panel-soft); padding: .85rem 1rem;'
  'background: var(--accent); color: #fff;'
  '.case-summary { display: grid; padding: .2rem 1rem 1rem; }'
  '.case-summary-row { display: grid; grid-template-columns: 88px minmax(0, 1fr);'
  '.case-summary-label { color: var(--heading); font-size: .8rem;'
  '.project-summary { max-width: 760px; margin-bottom: 0; color: var(--heading);'
  '.project-summary-line { display: block; }'
  '.project-role { padding: .25rem .48rem; border-radius: 999px; background: var(--panel-soft); color: var(--heading); font-size: .72rem;'
  '.project-highlight p { margin: 0; color: var(--heading);'
  '.project-highlight > strong { display: block;'
  '.case-summary-content p { margin: 0; color: var(--heading); font-size: .86rem;'
  'class="case-comparison-list"'
  '.case-comparison-list { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr));'
  '.architecture-summary { color: var(--heading);'
  '.flow-boundary-label { color: var(--heading);'
  '.flow-node small { color: var(--heading);'
  '.flow-note-copy { color: var(--heading);'
  '.project-tech .tag { color: var(--heading);'
  '.project-card p strong { color: inherit; font-weight: 850; }'
  'class="case-summary"'
  'class="case-summary-row problem"'
  'class="case-summary-row decision"'
  'class="case-summary-row outcome"'
  'class="mermaid sequence-diagram"'
  'sequenceDiagram'
  'participant Owner as 방장'
  'participant Service as FinalMenuSelectionService'
  'participant MQ as RabbitMQ'
  'participant Worker as 추천 Consumer'
  'SurveyRequested 발행'
  '재추천 작업 전달'
  'participant Redis as Redis 마감 집계'
  'alt DB 저장 성공'
  'https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs'
  '.sequence-diagram > svg { display: block; width: 100% !important; min-width: 680px; max-width: none;'
  '.hero-intro { order: -1; }'
  '.profile-photo-slot { width: min(170px, 50vw); }'
  'mirrorActors: false'
  'participant Batch as Batch 서버'
  'participant Event as afterCommit'
  'participant Redis as Redis Pub/Sub'
  'participant APIs as API 서버들'
  'data-project-case="atomic-vote-change"'
  'data-project-case="async-recommendation"'
  'data-project-case="persistence-recovery"'
  'data-project-case="consistency-gaps"'
  'data-project-case="lifecycle-after-commit"'
  'data-project-case="prometheus-failure-isolation"'
  'Redis와 MySQL 간 데이터 불일치 추적'
  '종료 이벤트 기반 다중 서버 지표 정리'
  'Prometheus 조회 실패 격리'
  '전체 수량 − Redis 잔여 수량 ↔ DB 활성 쿠폰 수'
  'Redis 누적 발급 수 ↔ Redis 발급 회원 수'
  'Redis 누적 발급 수 ↔ DB 누적 발급 이력'
  'DB 활성 쿠폰 수 ↔ DB 재고 테이블의 활성 카운터'
  'DB 커밋이 끝난 뒤에만 발행'
  '최근 종료 회차를 DB에서 다시 조회'
  'grouped query로 한 번에 조회'
  '동시 투표 결과 정합성'
  'RabbitMQ 기반 재추천 비동기 처리'
  'AI 추천 결과를 기다려야 해 응답이 늦어지고'
  '기존 RabbitMQ 추천 흐름에 연결'
  'API 응답을 장시간 추천 작업과 분리'
  'Redis 장애나 TTL 만료로 마감 집계가 유실되는 상황을 탐지할 지표가 필요'
  'DB 저장 실패 후 재처리'
  '<div class="project-roles"><span class="project-role">2026.07.16 ~ 07.27</span><span class="project-role">5인 팀</span><span class="project-role primary">팀장</span><span class="project-role primary">투표 기능 담당</span></div>'
  'id="credentials"'
  '<p class="eyebrow">Education &amp; Credentials</p><h2>교육 및 자격</h2>'
  'class="credentials-grid"'
  '<h3 id="education-heading">교육·학력</h3>'
  '<span class="credential-kind">학력</span>'
  '<h4>한신대학교</h4>'
  '<span class="credential-period"><time datetime="2020-02">2020.02</time><span>~</span><time datetime="2026-08">2026.08</time></span>'
  '<span class="credential-kind">교육</span>'
  '<h4>LG U+ 유레카 백엔드 과정</h4>'
  '<span class="credential-period"><time datetime="2026-04">2026.04</time><span>~</span><time datetime="2026-10">2026.10</time></span>'
  '<span class="credential-status">진행 중</span>'
  '<h3 id="certification-heading">자격증</h3>'
  '<h4>정보처리기사</h4>'
  '<p>한국산업인력공단</p>'
  '<time datetime="2025-09-12">2025.09.12</time>'
  '<h4>SQLD</h4>'
  '<p>한국데이터산업진흥원(Kdata)</p>'
  '<time datetime="2024-04-05">2024.04.05</time>'
  '.project-repo {'
  '.project-repo:hover {'
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

for websocket_term in 'WebSocket' 'STOMP' '웹소켓' '실시간 연결' '실시간 메시지' '실시간 알림' '실시간 투표' '변경 알림' '구독 권한'; do
  if grep -Fq -- "$websocket_term" "$preview"; then
    echo "FAIL: portfolio preview still contains WebSocket topic: $websocket_term"
    exit 1
  fi
done

if grep -Fq -- '<span class="tag">Lua Script</span>' "$preview"; then
  echo "FAIL: Lua Script remains in a project technology tag"
  exit 1
fi

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

project_architecture_count="$(grep -Fc -- 'class="project-architecture' "$preview" || true)"
if (( project_architecture_count != 0 )); then
  echo "FAIL: standalone project architecture should be removed, found $project_architecture_count"
  exit 1
fi

architecture_svg_count="$(grep -Fc -- 'class="architecture-diagram"' "$preview" || true)"
if (( architecture_svg_count != 0 )); then
  echo "FAIL: fixed-coordinate SVG diagrams remain in the project cards: $architecture_svg_count"
  exit 1
fi

responsive_flow_count="$(grep -Fc -- 'class="responsive-flow"' "$preview" || true)"
if (( responsive_flow_count != 0 )); then
  echo "FAIL: custom responsive architecture flows should be removed, found $responsive_flow_count"
  exit 1
fi

flow_branch_wrap_count="$(grep -Fc -- 'class="flow-branch-wrap"' "$preview" || true)"
if (( flow_branch_wrap_count != 0 )); then
  echo "FAIL: custom finalization and recovery branch diagrams remain, found $flow_branch_wrap_count"
  exit 1
fi

project_case_count="$(grep -Fc -- 'data-project-case=' "$preview" || true)"
if (( project_case_count != 6 )); then
  echo "FAIL: expected three solved cases for each project, found $project_case_count"
  exit 1
fi

case_summary_count="$(grep -Fc -- 'class="case-summary"' "$preview" || true)"
if (( case_summary_count != 6 )); then
  echo "FAIL: expected one concise summary per project case, found $case_summary_count"
  exit 1
fi

case_process_list_count="$(grep -Fc -- 'class="case-process-list"' "$preview" || true)"
if (( case_process_list_count != 0 )); then
  echo "FAIL: duplicate three-step process lists remain beside the diagrams: $case_process_list_count"
  exit 1
fi

mermaid_sequence_count="$(grep -Fc -- 'class="mermaid sequence-diagram"' "$preview" || true)"
if (( mermaid_sequence_count != 3 )); then
  echo "FAIL: only lifecycle propagation, async recommendation, and persistence recovery should use Mermaid sequences, found $mermaid_sequence_count"
  exit 1
fi

for removed_finalization_content in 'data-project-case="duplicate-finalization"' '자동·수동 마감 중복 막기' 'participant Scheduler as 자동 마감' 'participant User as 수동 마감'; do
  if grep -Fq -- "$removed_finalization_content" "$preview"; then
    echo "FAIL: removed duplicate-finalization case remains: $removed_finalization_content"
    exit 1
  fi
done

if ! grep -Fq -- '<span class="tag">RabbitMQ</span>' "$preview"; then
  echo "FAIL: RabbitMQ is missing from the Gallae-Mallae technology tags"
  exit 1
fi

if grep -Fq -- 'project-detail-link' "$preview" || grep -Fq -- '>상세 보기<' "$preview"; then
  echo "FAIL: standalone detail links must not appear on the portfolio page"
  exit 1
fi

gallae_markup="$(sed -n '/<h3>갈래말래<\/h3>/,/<div class="project-footer">/p' "$preview")"
for case_stage in 문제 '선택과 실행' '검증과 한계'; do
  stage_count="$(grep -Fc -- "<strong>$case_stage</strong>" <<< "$gallae_markup" || true)"
  if (( stage_count != 3 )); then
    echo "FAIL: every Gallae-Mallae case must contain one '$case_stage' stage, found $stage_count"
    exit 1
  fi
done

for jargon in '원자성' '영속화' '직렬화' 'Snapshot' 'PESSIMISTIC_WRITE' '도메인'; do
  if grep -Fq -- "$jargon" <<< "$gallae_markup"; then
    echo "FAIL: Gallae-Mallae copy still contains report-style jargon: $jargon"
    exit 1
  fi
done

if grep -Fq -- '<div class="case-summary-content"><strong>' <<< "$gallae_markup"; then
  echo "FAIL: project case content still splits one idea into a dark lead and gray explanation"
  exit 1
fi

emphasized_case_row_count="$(grep -F -- '<div class="case-summary-content"><p>' <<< "$gallae_markup" | grep -Fc -- '<strong>' || true)"
if (( emphasized_case_row_count != 9 )); then
  echo "FAIL: every project case row must emphasize at least one key term, found $emphasized_case_row_count"
  exit 1
fi

coupon_markup="$(sed -n '/<h3>쿠폰 야호<\/h3>/,/<div class="project-footer">/p' "$preview")"
for case_stage in 문제 '선택과 실행' '검증과 한계'; do
  stage_count="$(grep -Fc -- "<strong>$case_stage</strong>" <<< "$coupon_markup" || true)"
  if (( stage_count != 3 )); then
    echo "FAIL: every Coupon Yaho case must contain one '$case_stage' stage, found $stage_count"
    exit 1
  fi
done

emphasized_coupon_row_count="$(grep -F -- '<div class="case-summary-content"><p>' <<< "$coupon_markup" | grep -Fc -- '<strong>' || true)"
if (( emphasized_coupon_row_count != 8 )); then
  echo "FAIL: every prose row in Coupon Yaho must emphasize at least one key term, found $emphasized_coupon_row_count"
  exit 1
fi

comparison_item_count="$(grep -Fo -- '<li>' <<< "$coupon_markup" | wc -l)"
if (( comparison_item_count != 4 )); then
  echo "FAIL: Coupon Yaho consistency case must show four comparison pairs, found $comparison_item_count"
  exit 1
fi

if ! grep -Fq -- '<span class="tag">Apache Kafka</span>' <<< "$coupon_markup"; then
  echo "FAIL: Apache Kafka is missing from the Coupon Yaho technology tags"
  exit 1
fi

for removed_notification_copy in 'data-project-case="notification-retry"' '알림 발송 실패를 다시 처리하기' 'Outbox Relay' '알림 Consumer' '1초·5초·20초'; do
  if grep -Fq -- "$removed_notification_copy" <<< "$coupon_markup"; then
    echo "FAIL: removed notification case remains: $removed_notification_copy"
    exit 1
  fi
done

projects_markup="$(sed -n '/<section class="section" id="projects">/,/<section class="section" id="credentials">/p' "$preview")"
if grep -E '<h4>[^<]*하기</h4>' <<< "$projects_markup"; then
  echo "FAIL: project case titles must use concise noun phrases instead of '~하기' endings"
  exit 1
fi

for retrospective_ending in '했습니다.' '있었습니다.' '됐습니다.' '필요했습니다.'; do
  if grep -Fq -- "$retrospective_ending" <<< "$projects_markup"; then
    echo "FAIL: project copy still uses repetitive retrospective ending: $retrospective_ending"
    exit 1
  fi
done

if grep -Fq -- '.project-highlight strong {' "$preview"; then
  echo "FAIL: project label styling also affects emphasized terms inside body copy"
  exit 1
fi

for obsolete_case_stage in '<strong>핵심 문제</strong>' '<strong>트레이드오프</strong>' '<strong>선택</strong>'; do
  if grep -Fq -- "$obsolete_case_stage" <<< "$gallae_markup"; then
    echo "FAIL: obsolete Gallae-Mallae case stage remains: $obsolete_case_stage"
    exit 1
  fi
done

for obsolete_case_layout in 'class="case-narrative"' 'class="case-story"' 'class="case-story-step' 'class="case-editorial"' 'class="case-block'; do
  if grep -Fq -- "$obsolete_case_layout" <<< "$gallae_markup"; then
    echo "FAIL: obsolete Gallae-Mallae case layout remains: $obsolete_case_layout"
    exit 1
  fi
done

section_layout_count="$(grep -Fc -- 'class="shell section-layout"' "$preview" || true)"
if (( section_layout_count != 4 )); then
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

if ! grep -Fq -- '.flow-track { display: grid;' "$preview" || ! grep -Fq -- '.flow-track { grid-template-columns: 1fr;' "$preview"; then
  echo "FAIL: project diagrams must switch from horizontal tracks to a vertical mobile flow"
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

for forbidden_pattern in 'BackendDeveloper' 'class="code-card"' 'class="hero-actions"' 'class="quick-facts' 'class="fact-number"' 'class="hero-capabilities"' 'class="project-visual' 'class="visual-mark"' 'class="sample-badge"' 'class="project-details"' 'class="project-flow"' 'class="project-mini-flow"' 'class="flow-node accent"' 'class="architecture-diagram"' 'class="system-architecture"' 'class="architecture-bar"' 'class="architecture-link"' 'class="architecture-frame"' 'class="architecture-addon"' 'class="architecture-image"' 'class="architecture-pending"' 'coupon-yaho-architecture.png' '<iframe' 'data-placeholder-project="true"' '임시 예시 프로젝트' '<small>Language</small>' '<span>01 · Core</span>' 'id="contact"' 'mailto:' '>연락처<' 'href="#about">소개</a>' 'href="#stories"' 'id="stories"' 'Engineering stories' 'class="story-card"' 'id="experience"' 'class="timeline"' 'class="timeline-item"' '내용 입력 필요' '회사 또는 주요 활동명' '교육 과정 또는 팀 프로젝트' 'class="profile-photo-placeholder"' '.profile-photo-slot::before' '프로필 이미지 추가 예정' '사진 추가 예정' '<title>경주 | Backend Developer</title>' '<span>경주의 포트폴리오</span>' '<h1>경주</h1>' '백엔드 개발자 경주입니다.' '© 2026 경주. All rights reserved.' '문제를 이해하고, 안정적인 흐름을 설계합니다.' '데이터 흐름과 Kafka 학습' '기능 너머의 이유를 이해하려 합니다.' '<strong>근거 있는 선택</strong>' '<strong>운영 관점</strong>' '<strong>학습의 기록</strong>'; do
  if grep -Fq -- "$forbidden_pattern" "$preview"; then
    echo "FAIL: obsolete code-card content remains: $forbidden_pattern"
    exit 1
  fi
done

profile_image="assets/img/profile/lee-gyeongju.jpg"
if [[ ! -s "$profile_image" ]]; then
  echo "FAIL: profile image asset is missing or empty: $profile_image"
  exit 1
fi

echo "PASS: portfolio preview contains every required section and behavior hook"
