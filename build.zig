const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addModule("Dynamic", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
    });

    const exe = b.addExecutable(.{
        .name = "Dynamic",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    });

    const shared_lib = std.Build.Step.Compile.create(b, .{
        .name = "Dynamic",
        .kind = .lib,
        .linkage = .dynamic, // This makes it a shared library so / .dll
        .root_module = lib,
    });
    shared_lib.root_module.pic = true;
    const install_dll = b.addInstallArtifact(shared_lib, .{ .dest_dir = .{ .override = .{ .custom = "dynamic" } } });

    const dll_step = b.step("dll", "Only build and produce a DLL");
    dll_step.dependOn(&install_dll.step);

    b.installArtifact(exe);
    const install_exe_docs = b.addInstallDirectory(.{
        .source_dir = exe.getEmittedDocs(),
        .install_dir = .prefix,
        .install_subdir = "docs/exe",
    });

    const install_lib_docs = b.addInstallDirectory(.{
        .source_dir = shared_lib.getEmittedDocs(),
        .install_dir = .prefix,
        .install_subdir = "docs/lib",
    });

    const docs_step = b.step("docs", "Generate documentation for both exe and lib");
    docs_step.dependOn(&install_exe_docs.step);
    docs_step.dependOn(&install_lib_docs.step);
    const run_step = b.step("run", "Run the app");

    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const exe_tests = b.addTest(.{
        .root_module = exe.root_module,
    });

    const run_exe_tests = b.addRunArtifact(exe_tests);

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_exe_tests.step);
}
