/*
 * Synthetic linker layout for the codeinjector smoke test.
 *
 * - "Hijack" at offset 0x100: a fixed-address ROM patch (4 bytes).
 * - "Body" at offset 0x800: the new function body in ROM free space.
 * - "RAM": COMMON-backed RAM (VMA 0x800000, way past the stock bin's size).
 *   This is the critical section: codeinjector must skip it because it has
 *   no file content (SHT_NOBITS). If the skip is missing, codeinjector
 *   panics trying to write VMA 0x800000 into a 4KB stock buffer.
 */
MEMORY {
	UNUSED_RAM : ORIGIN = 0x800000, LENGTH = 0x100
}

SECTIONS {
	"Hijack" 0x100 : { LONG(patched_func) }
	"Body" 0x800 : { *(.text) *(.rodata) }
	"RAM" : { *(COMMON) *(.bss) } > UNUSED_RAM
}
