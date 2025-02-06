const std = @import("std");
pub fn build(b: *std.Build) void {
    const opt = b.standardOptimizeOption(.{ .preferred_optimize_mode = .ReleaseFast });
    const trg = b.standardTargetOptions(.{});
    const exe = b.addExecutable(.{ .name = "blink", .target = trg, .optimize = opt, .single_threaded = true, .strip = true, .linkage = .static, .root_source_file = b.path("src/main.zig") });
    b.installArtifact(exe);
    const run = b.addRunArtifact(exe);
    run.step.dependOn(b.getInstallStep());
    if (b.args) |x| run.addArgs(x);
    const run_step = b.step("run", "Run the program");
    run_step.dependOn(&run.step);
}
