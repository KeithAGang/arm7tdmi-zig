// --------------------------------------------------------------------------
// 1. THE LOGIC (Normal Zig)
// --------------------------------------------------------------------------

// We change this to a normal function (defaults to C calling convention or Zig's own).
// The compiler will now handle the stack frames for us automatically.
fn main() noreturn {
    const msg = "Hello Ya'll\n from Zig on ARM7TDMI!\n";

    for (msg) |c| {
        put_char_uart(c);
    }

    // Hang forever when done
    while (true) {}
}

fn put_char_dcc(c: u8) void {
    // WAIT LOOP: Poll the Status Register
    while (true) {
        // FIX: Changed 'mcr' to 'mrc' to READ status
        // Source: Manual Table 5-1 [1]
        const status = asm volatile ("mrc p14, 0, %[ret], c0, c0, 0"
            : [ret] "=r" (-> u32),
        );

        // Check Bit 1 (W bit). If clear (0), the write buffer is empty/ready.
        // Source: Manual 5.8.1 [2]
        if ((status & 2) == 0) break;
    }

    // WRITE: Send the character
    // Source: Manual Table 5-1 [1]
    asm volatile ("mcr p14, 0, %[data], c1, c0, 0"
        :
        : [data] "r" (c),
    );
}

fn put_char_uart(c: u8) void {
    // versatilepb UART0 Data Register is at 0x101f1000
    const uart0_dr: *volatile u32 = @ptrFromInt(0x101f1000);
    uart0_dr.* = c;
}

// --------------------------------------------------------------------------
// 2. THE BOOTSTRAP (The Naked Trampoline)
// --------------------------------------------------------------------------

export fn _start() callconv(.naked) noreturn {
    asm volatile (
    // 1. Setup Stack Pointer (SP / R13)
    // We set it to 0x4000 (End of RAM for this simple QEMU setup)
    // Source: R13 is the Stack Pointer [3]
        \\ ldr sp, =0x4000

        // 2. Jump to the main Zig function
        // 'bl' (Branch with Link) allows a return, though main never returns.
        \\ bl %[main_func]

        // 3. Safety Hang (in case main returns)
        \\ b .
        :
        : [main_func] "X" (&main),
    );

    // Zig requires a noreturn function to theoretically not reach the end
    while (true) {}
}
