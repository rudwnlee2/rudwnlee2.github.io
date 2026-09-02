#!/usr/bin/env bash

set -eu

navigation="_layouts/page.html"
mobile_navigation="_includes/sidebar.html"
portfolio="portfolio/index.html"
coupon="portfolio/coupon-yaho/index.html"
vote="portfolio/gallae-mallae/index.html"

if ! grep -Fq -- "href=\"{{ '/portfolio/' | prepend: site.baseurl }}\">소개</a>" "$navigation"; then
  echo "FAIL: the site introduction menu does not link to /portfolio/"
  exit 1
fi

if ! grep -Fq -- 'class="flat-category-item portfolio-link"' "$mobile_navigation" || ! grep -Fq -- "href=\"{{ '/portfolio/' | prepend: site.baseurl }}\"" "$mobile_navigation"; then
  echo "FAIL: the mobile navigation does not link to /portfolio/"
  exit 1
fi

for file in "$portfolio" "$coupon" "$vote"; do
  if [[ ! -f "$file" ]]; then
    echo "FAIL: $file is missing"
    exit 1
  fi
  if [[ "$(head -n 1 "$file")" != '<!doctype html>' ]]; then
    echo "FAIL: $file must be a standalone static document without front matter"
    exit 1
  fi
done

for obsolete in _pages/portfolio/index.html _pages/portfolio/coupon-yaho.html _pages/portfolio/gallae-mallae.html portfolio-preview.html portfolio-project-coupon-yaho.html portfolio-project-gallae-mallae.html; do
  if [[ -e "$obsolete" ]]; then
    echo "FAIL: obsolete root page remains: $obsolete"
    exit 1
  fi
done

echo "PASS: the introduction menu links to standalone portfolio pages at stable public URLs"
