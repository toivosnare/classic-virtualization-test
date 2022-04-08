CROSS_COMPILE=riscv32-unknown-linux-gnu-
ENTRY_POINT_ADDR=0x81000000
MAKE=make
QEMU=qemu-system-riscv32

all: test opensbit

test: test.s
	$(CROSS_COMPILE)gcc -g -march=rv32i -mabi=ilp32 -ffreestanding -nostdlib -Ttext=$(ENTRY_POINT_ADDR) $< -o $@

opensbit:
	$(MAKE) CROSS_COMPILE=$(CROSS_COMPILE) PLATFORM=generic PLATFORM_RISCV_XLEN=32 FW_JUMP=y FW_JUMP_ADDR=$(ENTRY_POINT_ADDR) -C opensbi

run:
	$(QEMU) -M virt -nographic -bios opensbi/build/platform/generic/firmware/fw_jump.elf -kernel test

clean:
	rm -f test
	$(MAKE) -C opensbi clean
