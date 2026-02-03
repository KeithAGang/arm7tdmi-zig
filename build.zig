const std = @import("std");

pub fn build(b: *std.Build) void {
    // 1. Target ARM7TDMI bare-metal
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .arm,
        .cpu_model = .{ .explicit = &std.Target.arm.cpu.arm7tdmi },
        .os_tag = .freestanding,
        .abi = .eabi,
    });

    // const optimize = b.standardOptimizeOption(.{});

    // Create a module first
    const root_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = .Debug,
    });

    const exe = b.addExecutable(.{
        .name = "arm-test",
        .root_module = root_module,
    });

    exe.root_module.strip = false;

    // 2. Install the binary to zig-out/bin
    b.installArtifact(exe);

    // 3. Define run step
    const run_cmd = b.addSystemCommand(&.{
        "qemu-system-arm",
        "-M", "versatilepb", // The Board
        "-cpu", "arm926", // <--- CHANGED: Matches your list exactly
        //"-nographic", // use current terminal for I/O
        "-serial", "stdio", // Redirect serial to terminal
        "-semihosting", // enable semihosting for print support
        "-kernel",
    });
    const run_dbg = b.addSystemCommand(&.{
        "qemu-system-arm",
        //"/mnt/c/msys64/ucrt64/bin/qemu-system-arm.exe",
        "-M",
        "versatilepb",
        "-cpu",
        "arm926",
        "-serial",
        "stdio",
        "-semihosting",

        // FIX: The new, simple way to silence audio on modern QEMU
        "-audio",
        "none",

        // Debug flags MUST come before -kernel
        "-s", // Listen for GDB on port 1234
        "-S", // Freeze CPU at startup

        "-kernel",
    });
    const run_cmd2 = b.addSystemCommand(&.{
        "/mnt/c/msys64/ucrt64/bin/qemu-system-arm.exe", // to get the win output when in wsl
        "-M", "versatilepb", // The Board
        "-cpu", "arm926", // <--- CHANGED: Matches your list exactly
        //"-nographic", // use current terminal for I/O
        "-serial", "stdio", // Redirect serial to terminal
        "-semihosting", // enable semihosting for print support
        "-kernel",
    });

    // Tell QEMU to run the executable we just built
    run_cmd.addArtifactArg(exe);
    run_cmd2.addArtifactArg(exe);
    run_dbg.addArtifactArg(exe);

    // Create the 'run' step in zig build menu
    const run_step = b.step("run", "Run the app in QEMU.");
    const run_wsl_step = b.step("run-wsl", "Run the app in QEMU (msys32) from WSL.");
    const run_dbg_step = b.step("run-dbg", "Run the app in QEMU in Debug Mode.");
    run_step.dependOn(&run_cmd.step);
    run_wsl_step.dependOn(&run_cmd2.step);
    run_dbg_step.dependOn(&run_dbg.step);
}
