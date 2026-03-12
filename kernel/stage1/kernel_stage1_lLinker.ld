ENTRY(start_kernel)

SECTIONS
{
    /*. = 0xFFFF800000000000;*/
    /*. = 0xFFD5555555DDDDFF*/
    . = 0x100000

    .text :
    {
        *(.text)
        *(.text.*)
    }

    .data :
    {
        *(.data)
        *(.data.*)
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

    end = .;
}