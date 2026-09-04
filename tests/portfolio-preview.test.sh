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
  '.hero-grid { display: grid; grid-template-columns: 260px minmax(0, 1fr); align-items: start; gap: 88px; }'
  'class="profile-photo-slot" aria-hidden="true"'
  '.profile-photo-slot {'
  'aspect-ratio: 3 / 4;'
  'class="hero-intro"'
  'class="hero-identity"'
  'class="hero-links"'
  '>Blog ↗<'
  '>GitHub ↗<'
  'class="hero-facts"'
  '<p class="hero-statement"><strong>동시 요청과 장애 상황에서도 데이터 정합성을 지키는</strong> 백엔드 개발자입니다.</p>'
  '<p class="hero-copy"><strong>동시성 제어·실패 감지·재처리</strong>가 가능한 구조를 프로젝트에서 구현하고 검증했습니다.</p>'
  '<strong>Concurrency Control</strong>'
  'Redis Lua로 여러 요청을 한 번에 처리'
  '<strong>Data Consistency</strong>'
  '진행 정보는 Redis, 마감 결과는 MySQL에 저장'
  '<strong>Failure Recovery</strong>'
  '저장 실패 시 남아 있는 마감 결과로 다시 시도'
  'id="about"'
  '<h2>소개</h2>'
  '<p><strong>동시 요청, 저장소 간 데이터 차이, 실패 이후의 흐름</strong>을 프로젝트에서 직접 다뤘습니다.</p>'
  '<p class="about-statement"><strong>실패한 뒤에도 다시 이어질 수 있는 구조</strong>를 고민합니다. 정상 동작을 만드는 데서 멈추지 않습니다.</p>'
  '<strong>데이터가 어긋나는 지점과 다시 처리할 방법을 함께 설계해 왔습니다.</strong>'
  '갈래말래에서는 <strong>투표 변경과 집계를 한 번에 처리하고, 저장 실패 후 같은 결과로 다시 시도하는 흐름</strong>을 구현했습니다.'
  '쿠폰 야호에서는 <strong>Redis와 MySQL의 발급 상태 비교와 DB 커밋 이후 종료 이벤트 전파</strong>를 구현했습니다.'
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
  '--solution-text: #d44c47;'
  '--solution-text: #ff7369;'
  '.about-main .about-statement { margin-bottom: 1rem; color: var(--emphasis-text);'
  '.hero-statement strong, .hero-copy strong, .section-heading > p strong, .about-main p strong {'
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
  '<p class="project-summary">그룹원의 조건에 맞는 메뉴 후보를 추천하고, 투표 결과로 최종 메뉴를 정하는 서비스</p>'
  '<p class="project-summary">Redis와 MySQL의 쿠폰 발급 상태를 비교하고, 종료 이벤트와 관제 지표를 여러 서버에서 일관되게 관리한 선착순 쿠폰 서비스</p>'
  '쿠폰 야호'
  'https://github.com/rudwnlee2/gallae-mallae-backend'
  'https://github.com/coupon-yaho/cy-be'
  '투표 기능'
  '운영현황'
  'class="project-header"'
  'class="project-document"'
  'class="project-key-results"'
  'class="project-key-result"'
  'class="project-validation" aria-labelledby="coupon-validation-title"'
  '<h4 id="coupon-validation-title">팀 프로젝트 전체 검증 결과</h4>'
  'class="project-validation-grid"'
  'class="project-validation-item"'
  '<strong>600 / 600건</strong>'
  '20 RPS로 30초간 발급, 시스템 오류·타임아웃 0건, p95 497.98ms'
  '<strong>80 / 80건</strong>'
  '발급 40건·사용 20건·사용 취소 10건·발급 취소 10건의 최종 상태 일치'
  '<strong>534만 건</strong>'
  '회원 100만 명·발급 300만 건·이력 534만 건의 정상 데이터에서 오류 검출 0건'
  '별도 오류 700건 주입으로 예상된 800건 모두 검출, 누락 0건·오탐 0건'
  'class="project-cases"'
  '.project-document { border-top: 2px solid var(--heading);'
  '.project-key-results { display: grid; grid-template-columns: 110px minmax(0, 1fr);'
  '.project-case { border-top: 1px solid var(--line-strong);'
  '.case-notion { display: grid;'
  '.case-section { display: grid; grid-template-columns: 78px minmax(0, 1fr);'
  '.project-title-row h3 { margin-bottom: .22rem; color: var(--heading); font-size: 1.65rem; }'
  '.project-summary { max-width: 760px; margin-bottom: 0; color: var(--heading); font-size: 1.08rem; line-height: 1.72; text-wrap: balance; word-break: keep-all; overflow-wrap: break-word; }'
  '.hero-statement, .hero-copy, .section-heading > p, .about-main p, .principle p, .project-case-heading h4, .case-section p, .credential-item h4, .credential-item p {'
  'text-wrap: pretty;'
  'word-break: keep-all;'
  'overflow-wrap: break-word;'
  '.project-role { padding: .3rem .55rem; border-radius: 999px; background: var(--panel-soft); color: var(--heading); font-size: .8rem;'
  '.project-key-result { display: grid; grid-template-columns: 28px minmax(0, 1fr); gap: .55rem; color: var(--heading); font-size: 1.05rem;'
  '.project-validation { border-top: 1px solid var(--line-strong); padding: 1.5rem 0; }'
  '.project-validation-grid { display: grid; grid-template-columns: repeat(3, minmax(0, 1fr));'
  '.project-validation-item strong { display: block; color: var(--heading); font-size: 1.35rem;'
  '.project-case-heading h4 { margin: 0; color: var(--heading); font-size: 1.4rem;'
  '.case-section h5 { margin: .1rem 0 0; color: var(--heading); font-size: .95rem;'
  '.case-section p { margin: 0; color: var(--heading); font-size: 1.1rem;'
  '.project-tech .tag { color: var(--heading); font-size: .84rem;'
  '.project-document p strong { color: inherit; font-weight: 850; }'
  '.case-section[data-case-stage="solution"] strong { color: var(--solution-text); }'
  'class="case-notion"'
  'data-case-stage="problem"'
  'data-case-stage="cause"'
  'data-case-stage="solution"'
  'data-case-stage="evaluation"'
  'data-case-stage="reflection"'
  'data-project-case="atomic-vote-change"'
  'data-project-case="async-recommendation"'
  'data-project-case="persistence-recovery"'
  'data-project-case="consistency-gaps"'
  'data-project-case="lifecycle-after-commit"'
  'data-project-case="prometheus-failure-isolation"'
  '4개 비교 지표로 Redis·MySQL 불일치 추적'
  'afterCommit과 Redis Pub/Sub으로 종료 지표 동기화'
  '관리자 HTTP API 27개 계약 구축'
  'Redis 구독 실패 시 5초 간격으로 재연결'
  '최근 24시간 동안 종료된 회차를 최대 1,000개까지 DB에서 다시 조회'
  'Grouped Query와 부분 응답으로 Prometheus 실패 격리'
  'Redis와 MySQL에 흩어진 발급 상태를 대조하는 <strong>정합성 검증 로직을 구현</strong>'
  '<strong>불일치가 발생한 저장소와 처리 단계를 구분</strong>'
  '<strong>네 비교 결과가 모두 0이고 초과 발급이 없을 때만 정상</strong>'
  'DB 커밋 완료 후에만 Redis Pub/Sub으로 발행'
  'Grouped Query로 묶고 영역별 제한 시간을 적용'
  'Redis Lua로 동시 투표 결과 일치'
  'RabbitMQ로 재추천 응답 분리'
  'AI 추천 결과를 기다리는 동안 API 응답이 늦어지고'
  'RabbitMQ 추천 Consumer에 작업을 전달'
  'API 응답과 장시간 추천 작업을 분리'
  'Redis 마감 집계 보존으로 DB 저장 재처리'
  'Redis 장애나 TTL 만료로 마감 집계가 사라지는 상황은 별도로 감지'
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
  '.profile-photo-slot { display: none; }'
  'prefers-reduced-motion: reduce'
)

for pattern in "${required_patterns[@]}"; do
  if ! grep -Fq -- "$pattern" "$preview"; then
    echo "FAIL: missing required pattern: $pattern"
    exit 1
  fi
done

for removed_photo_marker in 'class="profile-photo"' '/assets/img/profile/lee-gyeongju.jpg' '백엔드 개발자 이경주 프로필 사진'; do
  if grep -Fq -- "$removed_photo_marker" "$preview"; then
    echo "FAIL: profile photo remains in the standalone portfolio: $removed_photo_marker"
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

case_notion_count="$(grep -Fc -- 'class="case-notion"' "$preview" || true)"
if (( case_notion_count != 6 )); then
  echo "FAIL: expected one Notion-style body per project case, found $case_notion_count"
  exit 1
fi

case_process_list_count="$(grep -Fc -- 'class="case-process-list"' "$preview" || true)"
if (( case_process_list_count != 0 )); then
  echo "FAIL: duplicate three-step process lists remain beside the diagrams: $case_process_list_count"
  exit 1
fi

for removed_diagram_markup in 'class="mermaid' 'sequenceDiagram' 'mermaid.initialize' 'mermaid.esm.min.mjs' 'class="project-architecture' 'class="responsive-flow"'; do
  if grep -Fq -- "$removed_diagram_markup" "$preview"; then
    echo "FAIL: project diagrams must be removed completely: $removed_diagram_markup"
    exit 1
  fi
done

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

if grep -Fq -- 'project-summary-line' "$preview"; then
  echo "FAIL: forced project summary line breaks must not remain"
  exit 1
fi

gallae_markup="$(sed -n '/<h3>갈래말래<\/h3>/,/<div class="project-footer">/p' "$preview")"
for case_stage in problem cause solution evaluation reflection; do
  stage_count="$(grep -Fc -- "data-case-stage=\"$case_stage\"" <<< "$gallae_markup" || true)"
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

coupon_markup="$(sed -n '/<h3>쿠폰 야호<\/h3>/,/<div class="project-footer">/p' "$preview")"
coupon_lifecycle_line="$(grep -nF 'data-project-case="lifecycle-after-commit"' <<< "$coupon_markup" | cut -d: -f1)"
coupon_prometheus_line="$(grep -nF 'data-project-case="prometheus-failure-isolation"' <<< "$coupon_markup" | cut -d: -f1)"
coupon_consistency_line="$(grep -nF 'data-project-case="consistency-gaps"' <<< "$coupon_markup" | cut -d: -f1)"
if (( coupon_lifecycle_line >= coupon_prometheus_line || coupon_prometheus_line >= coupon_consistency_line )); then
  echo "FAIL: Coupon Yaho consistency case must appear third"
  exit 1
fi

for case_stage in problem cause solution evaluation reflection; do
  stage_count="$(grep -Fc -- "data-case-stage=\"$case_stage\"" <<< "$coupon_markup" || true)"
  if (( stage_count != 3 )); then
    echo "FAIL: every Coupon Yaho case must contain one '$case_stage' stage, found $stage_count"
    exit 1
  fi
done

for project_name in '갈래말래' '쿠폰 야호'; do
  if [[ "$project_name" == '갈래말래' ]]; then project_markup="$gallae_markup"; else project_markup="$coupon_markup"; fi
  for unbolded_stage in problem cause reflection; do
    if grep -F -- "data-case-stage=\"$unbolded_stage\"" <<< "$project_markup" | grep -Fq -- '<strong>'; then
      echo "FAIL: $unbolded_stage copy in $project_name must not use bold emphasis"
      exit 1
    fi
  done
done

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
for obsolete_project_structure in 'class="case-summary"' 'class="case-summary-row' 'class="sequence-diagram"' 'class="case-comparison-list"' '<strong>검증과 한계</strong>' '<strong>선택과 실행</strong>' '전체 수량 − Redis 잔여 수량'; do
  if grep -Fq -- "$obsolete_project_structure" <<< "$projects_markup"; then
    echo "FAIL: obsolete project structure remains: $obsolete_project_structure"
    exit 1
  fi
done

for obsolete_case_stage in 'data-case-stage="work"' 'data-case-stage="process"' '<h5>업무</h5>' '<h5>과정</h5>'; do
  if grep -Fq -- "$obsolete_case_stage" <<< "$projects_markup"; then
    echo "FAIL: obsolete case stage remains: $obsolete_case_stage"
    exit 1
  fi
done
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

project_document_count="$(grep -Fc -- 'class="project-document"' "$preview" || true)"
if (( project_document_count != 2 )); then
  echo "FAIL: expected two document-style projects, found $project_document_count"
  exit 1
fi

if [[ ! -f "portfolio-preview-before-hybrid.png" ]]; then
  echo "FAIL: the pre-redesign screenshot must be preserved"
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
