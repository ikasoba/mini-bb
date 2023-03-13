const std = @import("std");

pub fn main(_: std.mem.Allocator, args: *std.TailQueue([]const u8)) !u8 {
    var stdout = std.io.getStdOut();
    var tmp = b: {
        var tmp = args.popFirst();
        if (tmp == null) break :b null;
        break :b tmp.?.data;
    };
    if (tmp != null and (std.mem.eql(u8, tmp.?, "-h") or std.mem.eql(u8, tmp.?, "--help"))) {
        _ = try stdout.write(
            \\Usage: false [-h|--help]
            \\  return exit code 1
        );
        return 0;
    }
    return 1;
}
