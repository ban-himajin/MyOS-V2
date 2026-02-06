/*OUTPUT_FORMAT(binary)*/
ENTRY(start_16bit)

SECTIONS
{
    . = 0x8000;

    .text16 :
    {
        *(.text16)
        *(.text16.*)
    }

    .data16 :
    {
        *(.data16)
        *(.data16.*)
    }

    .text32 :
    {
        *(.text32)
        *(.text32.*)
    }

    .Ctext :
    {
        *(.Ctext)
        *(.Ctext.*)
    }

    .data32 :
    {
        *(.data32)
        *(.data32.*)
    }

    .data :
    {
        *(.data)
        *(.data32.*)
    }

    .rodata :
    {
        *(.rodata)
        *(.rodata.*)
    }

    .bss (NOLOAD):
    {
        *(.bss)
        *(.bss.*)
    }

}