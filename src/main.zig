const std = @import("std");
const builtin = @import("builtin");
const linux = std.os.linux;
fn die(comptime fmt: []const u8, args: anytype) noreturn {
    std.io.getStdOut().writer().print(fmt, args) catch {};
    linux.exit(1);
}
fn die_err(comptime msg: []const u8, err: anyerror) noreturn {
    die(msg ++ ": {s}\n", .{@errorName(err)});
}
fn put(fd: usize, status: bool) void {
    const txt = if (status) "1" else "0";
    const ret = linux.pwrite(@intCast(fd), txt, 1, 0);
    if (ret != 1) std.debug.print("Error writing: {d}\n", .{ret});
}
fn die_if_error(comptime msg: []const u8, r: usize) ?noreturn {
    if (r >= 0) return null;
    die("{s}: E{s}\n", .{ msg, @tagName(linux.E.init((~r + 1))) });
}
pub fn main() void {
    if (builtin.os.tag != .linux) @compileError("This program can only be compiled for linux.");
    if (linux.geteuid() != 0) die("This program needs to be run as root. (Try using sudo)\n", .{});
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const alloc = arena.allocator();
    var args = std.process.args();
    const name = args.next().?;
    const device = args.next() orelse die("Usage: {s} <DEVICE>", .{name});
    var term: linux.termios = undefined;
    _ = die_if_error("tcgetattr", linux.tcgetattr(0, &term));
    term.lflag.ICANON = false;
    term.lflag.ECHO = false;
    _ = die_if_error("tcsetattr", linux.tcsetattr(0, .NOW, &term));
    var chr: [1]u8 = [_]u8{0};
    const path: [:0]u8 = std.fmt.allocPrintZ(alloc, "/sys/class/leds/{s}/brightness", .{device}) catch @panic("Error allocating path.");
    const fd = linux.open(path.ptr, .{ .ACCMODE = .WRONLY }, 0);
    _ = die_if_error("open", fd);
    //) catch |err| die("open: {s}: {s}", .{path, @errorName(err)};
    while (linux.read(0, @ptrCast(&chr), 1) != 0) {
        switch (chr[0]) {
            'y' => put(fd, true),
            'n' => put(fd, false),
            'q' => break,
            else => {},
        }
    }
}
