#!/usr/bin/env bash

set -eu

portfolio="portfolio/index.html"

if [[ ! -f "$portfolio" ]]; then
  echo "FAIL: standalone portfolio is missing"
  exit 1
fi

for detail in portfolio/coupon-yaho/index.html portfolio/gallae-mallae/index.html; do
  if [[ -e "$detail" ]]; then
    echo "FAIL: obsolete detail page remains: $detail"
    exit 1
  fi
done

for link in '/portfolio/coupon-yaho/' '/portfolio/gallae-mallae/'; do
  if grep -Fq -- "$link" "$portfolio"; then
    echo "FAIL: portfolio still references an obsolete detail page: $link"
    exit 1
  fi
done

echo "PASS: standalone portfolio remains available and obsolete detail pages are removed"
