const std = @import("std");

pub fn main(allocator: std.mem.Allocator, args: *std.TailQueue([]const u8)) !u8 {
    var stdout = std.io.getStdOut();
    var tmp = b: {
        var tmp = args.popFirst();
        if (tmp == null) break :b "yes";
        break :b tmp.?.data;
    };
    if (std.mem.eql(u8, tmp, "-h") or std.mem.eql(u8, tmp, "--help")) {
        _ = try stdout.write(
            \\Usage: yes [-h|--help] [string]
        );
        return 0;
    }
    var msg = try std.mem.concat(allocator, u8, &[_][]const u8{ tmp[0..tmp.len], "\n" });
    while (true) {
        _ = try stdout.write(msg);
    }
}
