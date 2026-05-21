#!/bin/sh
# SPDX-License-Identifier: MIT
#
# codeinjector smoke test. Run this inside the m32r-injector-toolchain image
# (gcc, ld, codeinjector all on PATH). Exits 0 on pass, non-zero on fail.
#
# Catches the failure mode where codeinjector tries to write RAM-VMA sections
# to the ROM buffer and panics with "range start index ... out of range".

set -eu

cd "$(dirname "$0")"
out=$(mktemp -d)
trap 'rm -rf "$out"' EXIT

# 1. Build the fixture ELF.
m32r-elf-gcc -nostdlib -Os -c sample.c -o "$out/sample.o"
m32r-elf-ld -T sample.ld "$out/sample.o" -o "$out/sample.elf"

# 2. Synthetic 4KB stock binary (all 0xFF, like erased flash).
dd if=/dev/zero bs=4096 count=1 status=none | tr '\000' '\377' > "$out/stock.bin"
test "$(wc -c < "$out/stock.bin")" -eq 4096

# 3. Run codeinjector. The fixture's RAM section is at VMA 0x800000 — far
#    outside the 4KB stock buffer. A working codeinjector skips it
#    (SHT_NOBITS); a regressed one panics.
codeinjector mmc-m32r "$out/stock.bin" "$out/sample.elf" "$out/patched.bin" > "$out/patches.xml"

# 4. Output sanity.
test -s "$out/patched.bin"
test -s "$out/patches.xml"
grep -q 'Hijack' "$out/patches.xml"

echo "codeinjector smoke test passed"
