.section .text
.global _start
_start:
    la a0, hello_message    # Print hello message.
    jal puts
    la t0, trap_handler     # Setup trap vector.
    csrw stvec, t0
    la t0, test_start       # Return to test_start with sret.
    csrw sepc, t0
    li t0, (1 << 8)         # Return in U-mode with sret.
    csrc sstatus, t0
    sret
test_start:
    sret
    ecall
    mret
    ecall
    wfi
    ecall
    sfence.vma
    ecall
test_end:
    nop

.align 4
trap_handler:
    csrr t0, scause
    li t1, 8
    beq t0, t1, test_fail   # If trap cause was environment call from U-mode.
    li a0, '.'              # Print a dot to show test progress.
    jal putc
    csrr t0, sepc           # Return to the instruction in
    addi t0, t0, (2 * 4)    # the test following the ecall.
    la t1, test_end
    beq t0, t1, test_pass
    csrw sepc, t0
    sret
test_fail:
    la a0, fail_message     # Print fail message.
    jal puts
    j halt
test_pass:
    la a0, pass_message     # Print pass message.
    jal puts
halt:
    j halt

# Function to print a string. Register a0 should point to a null terminated string.
puts:
    mv s0, ra
    mv s1, a0
1:
    lb a0, 0(s1)
    beqz a0, 2f             # Loop until terminating null byte is found.
    jal putc
    addi s1, s1, 1
    j 1b
2:
    mv ra, s0
    ret

# Function to print a character. Register a0 should contain the character to print.
putc:
    li a7, 1                # 1 is the OpenSBI system call ID for CONSOLE_PUTCHAR.
    ecall                   # Make system call to OpenSBI.
    ret

.section .rodata
hello_message:
    .string "\nClassic Virtulization Test\n"
fail_message:
    .string "\n❌ Test failed!\n"
pass_message:
    .string "\n✅ Test passed!\n"
