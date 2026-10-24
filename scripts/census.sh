#!/usr/bin/env bash
# Syntax-checks every game source file with GCC and summarizes the errors.
# Usage: scripts/census.sh [gcc-extra-flags]   (run from repo root)
set -u
EXTRA="${*:-}"
OUT=census; mkdir -p "$OUT"
INC="-Icompat -Iinclude -Ibuild/GZ2E01/include -Iassets/GZ2E01 -Isrc -Ilibs/JSystem/include -Ilibs/dolphin/include -Ilibs/dolphin/include/dolphin"
one() {
  f="$1"; tmp="$OUT/e.$$.txt"
  if timeout 120 g++ -std=gnu++17 -fsyntax-only -fpermissive -w -fno-exceptions -fno-rtti \
      -include compat/tp_compat.h $INC -DVERSION=0 -D__GEKKO__ -DNDEBUG $EXTRA "$f" >"$tmp" 2>&1
  then echo "OK $f"
  else echo "FAIL $f :: $(grep -m1 -E 'error' "$tmp" | sed 's/^[^ ]* //' | cut -c1-160)"; fi
  rm -f "$tmp"
}
export -f one; export INC EXTRA OUT
find src libs/JSystem/src -name '*.cpp' | grep -v '^src/REL' | sort \
  | xargs -P "$(nproc)" -I{} bash -c 'one {}' > "$OUT/results.txt"
ok=$(grep -c '^OK' "$OUT/results.txt" || true); fail=$(grep -c '^FAIL' "$OUT/results.txt" || true)
{ echo "OK=$ok FAIL=$fail TOTAL=$((ok+fail))"; echo "--- top error causes ---"
  grep '^FAIL' "$OUT/results.txt" | sed 's/.*:: //' | sort | uniq -c | sort -rn | head -40; } | tee "$OUT/summary.txt"
