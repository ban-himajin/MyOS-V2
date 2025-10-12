RESULTNAME	=boot.img
ASSEMBLY	=boot1.asm boot2.asm
KERNEL		=kernel.c
LINKER		=Linker.ld
# HEADER		=stdio.h

run: $(RESULTNAME)
	qemu-system-x86_64 -drive format=raw,file=$(RESULTNAME) -vga std

$(RESULTNAME):$(assembly:.asm=.bin) $(KERNEL:.c=.bin)
#	X=$(foreach assembly, $(ASSEMBLY), $(assembly:.asm=.bin)) $(KERNEL:.c=.bin)
#	$(foreach y, $(foreach assembly, $(ASSEMBLY), $(assembly:.asm=.bin)) $(KERNEL:.c=.bin), \
		dd if=$(y) of=$(RESULTNAME) bs=512 count=1 conv=sync;)
	@rm -f $(RESULTNAME)
	@ for ver in $(ASSEMBLY:.asm=.bin) $(KERNEL:.c=.bin); do\
		dd if=$$ver of=$(RESULTNAME) bs=512 count=1 conv=sync;\
	done


#$(foreach assembly, $(ASSEMBLY), $(assembly:.asm=.bin)) $(KERNEL:.c=.bin):$(ASSEMBLY) $(KERNEL) $(LINKER)
$(assembly:.asm=.bin) $(KERNEL:.c=.bin):$(ASSEMBLY) $(KERNEL) $(LINKER)
	@for ver in $(ASSEMBLY) $(KERNEL);do\
		case $$ver in\
			*.asm)\
				nasm -f bin $$ver -o $${ver%.asm}.bin;;\
			*.c)\
				x86_64-elf-gcc -c $$ver -o $${ver%.c}.o -ffreestanding -O2 -Wall -Wextra;\
				x86_64-elf-gcc -T $(LINKER) -o $${ver%.c}.elf $${ver%.c}.o -ffreestanding -nostdlib;\
				x86_64-elf-objcopy -O binary $${ver%.c} $${ver%.c}.bin;;\
		esac\
	done
