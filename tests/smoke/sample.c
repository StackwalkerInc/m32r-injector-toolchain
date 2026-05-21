/*
 * Synthetic codeinjector smoke fixture.
 *
 * Triggers the layout that broke in the wild (codeinjector v0.1.0 and earlier):
 * a NOBITS section (COMMON-backed globals) placed in RAM at a VMA past the
 * end of the stock binary. A regressed codeinjector tries to write that VMA
 * to the stock buffer and panics.
 */
char ram_buffer[16];   /* tentative def → SHT_NOBITS / COMMON */

int patched_func(int x) { return x + 1; }
