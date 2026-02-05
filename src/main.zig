export fn _start() callconv(.naked) noreturn {
    asm volatile (
    // 1. SETUP
        \\ ldr sp, =0x4000 

        // 2. Prepare Precious Data
        \\ mov r0, #10
        \\ mov r1, #50
        \\ mov r2, #100

        // 3. The PUSH: Save State
        \\ stmdb sp!, {r0-r2} // Store Multiple Decrement Before (Standard Push), "!" updates SP to the new location

        // 4. THE DESTRUCTION (Simulate Work)
        \\ mov r0, #0           // Clobber registers
        \\ mov r1, #0
        \\ mov r2, #0

        // 5. THE "POP" (Restore State)
        // LDMIA = Load Multiple Increment After (Standard Pop)
        \\ ldmia sp!, {r0-r2}

        // 6. LOOP
        \\ loop: b loop
    );
    while (true) {}
}
