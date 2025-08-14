ENTRY(_start)

/* Adjust sizes to your design */
MEMORY
{
  ROM (rx)  : ORIGIN = 0x80000000, LENGTH = 64K
  RAM (rwx) : ORIGIN = 0x00000000, LENGTH = 32M
}

/* Provide symbols the startup needs */
PROVIDE(__bss_start = 0);
PROVIDE(__bss_end   = 0);
PROVIDE(_stack_top  = ORIGIN(RAM) + LENGTH(RAM));

SECTIONS
{
  .text : {
    KEEP(*(.init))         /* crt0.S puts _start here */
    *(.text*)
    *(.rodata*)
  } > ROM

  /* Load .data into ROM but run from RAM (copy at startup if needed) */
  .data : {
    *(.data*)
  } > RAM AT > ROM

  .bss (NOLOAD) : {
    __bss_start = .;
    *(.bss*)
    *(COMMON)
    __bss_end = .;
  } > RAM
}
