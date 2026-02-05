# ARM7TDMI Assembly & Interpreter in Zig

## Overview
This project documents the thoughts and plans to learn **ARM7TDMI assembly**, using the **ARM7TDMI Technical Reference Manual** as the primary source of truth.

The immediate approach involves writing inline assembly to explore the instruction set. The ultimate goal is to utilize this knowledge to build a fully functional ARM7TDMI interpreter using **Zig**.

## Roadmap
1.  **Exploration**: Learn the ARM7TDMI language by writing and running inline assembly.
2.  **Implementation**: Develop an interpreter in Zig based on the understanding gained from the exploration phase.

## Current Status
The project is currently in a haphazard state, focused on getting the ARM7TDMI language mechanics down.

## Requirements
*   **Language**: Zig
*   **Emulation**: QEMU (with ARM variants installed)
*   **OS**: Windows or Linux (Please refer to the `build.zig` file for specific build configurations)

## Debugging Guide (Linux / WSL)

For debugging, `gdb-multiarch` is recommended. Follow this workflow to inspect the execution:

1.  **Build the Project**:
    Ensure the project is built successfully.

2.  **Start QEMU in Debug Mode**:
    Run the following command to start a "frozen" QEMU instance. This will wait for a debugger to connect.
    ```bash
    zig build run-dbg
    ```

3.  **Launch GDB**:
    Open a **new terminal** in the project directory and run:
    ```bash
    gdb-multiarch
    ```

4.  **Load Debug Symbols**:
    Inside the GDB prompt, load the symbols from the binary:
    ```gdb
    file zig-out/bin/arch-test
    ```

5.  **Connect to QEMU**:
    Connect GDB to the QEMU instance listening on localhost port 1234:
    ```gdb
    target remote :1234
    ```

You can now step through the assembly, inspect registers, and debug the execution flow.