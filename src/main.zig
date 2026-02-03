export fn _start() callconv(.naked) noreturn {
    asm volatile (
    // 1. SETUP
        \\ ldr sp, =0x10000     // Initialize Stack Pointer (Safety net)
        \\ mov r0, #0           // R0 = Player 1 Score (Starts at 0)
        \\ mov r1, #10          // R1 = Player 2 Score (Starts at 10)
        \\ mov r2, #5           // R2 = Referee Counter (5 turns remain)

        // 2. THE GAME LOOP
        \\ game_loop:
        \\   bl p1_smash        // Player 1 hits! (Jumps to function)
        \\   bl p2_fault        // Player 2 messes up! (Jumps to function)
        \\   b game_loop        // Infinite rally
    );
    while (true) {}
}

// Function A: Player 1 scores, Referee counts down
export fn p1_smash() callconv(.naked) void {
    asm volatile (
        \\ add r0, r0, #1       // Score goes UP
        \\ sub r2, r2, #1       // Turns go DOWN
        \\ mov pc, lr           // RETURN HOME
    );
}

// Function B: Player 2 loses points
export fn p2_fault() callconv(.naked) void {
    asm volatile (
        \\ sub r1, r1, #1       // Score goes DOWN
        \\ mov pc, lr           // RETURN HOME
    );
}
