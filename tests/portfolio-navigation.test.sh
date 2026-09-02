#!/usr/bin/env bash

set -eu

navigation="_layouts/page.html"
portfolio="_pages/portfolio/index.html"
coupon="_pages/portfolio/coupon-yaho.html"
vote="_pages/portfolio/gallae-mallae.html"

if ! grep -Fq -- "href=\"{{ '/portfolio/' | prepend: site.baseurl }}\">소개</a>" "$navigation"; then
  echo "FAIL: the site introduction menu does not link to /portfolio/"
  exit 1
fi

declare -A expected_permalinks=(
  ["$portfolio"]="permalink: /portfolio/"
  ["$coupon"]="permalink: /portfolio/coupon-yaho/"
  ["$vote"]="permalink: /portfolio/gallae-mallae/"
)

for file in "${!expected_permalinks[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "FAIL: $file is missing"
    exit 1
  fi
  if ! grep -Fq -- "${expected_permalinks[$file]}" "$file"; then
    echo "FAIL: $file does not define ${expected_permalinks[$file]}"
    exit 1
  fi
done

for obsolete in portfolio-preview.html portfolio-project-coupon-yaho.html portfolio-project-gallae-mallae.html; do
  if [[ -e "$obsolete" ]]; then
    echo "FAIL: obsolete root page remains: $obsolete"
    exit 1
  fi
done

echo "PASS: the introduction menu and portfolio pages use stable public URLs"
