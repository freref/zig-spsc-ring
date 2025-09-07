const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const mod = b.addModule("spsc_ring", .{
        .root_source_file = b.path("spsc_ring.zig"),
        .target = target,
    });

    const example_exe = b.addExecutable(.{
        .name = "demo",
        .root_module = b.createModule(.{
            .root_source_file = b.path("demo.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "spsc_queue", .module = mod },
            },
        }),
    });
    b.installArtifact(example_exe);

    const run_example = b.step("run", "Run the example");
    const run_example_cmd = b.addRunArtifact(example_exe);
    run_example.dependOn(&run_example_cmd.step);
    if (b.args) |args| run_example_cmd.addArgs(args);
}
