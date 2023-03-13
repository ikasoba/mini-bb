const std = @import("std");

pub fn main(_: std.mem.Allocator, args: *std.TailQueue([]const u8)) !u8 {
    var stdout = std.io.getStdOut();
    var tmp: ?[]const u8 = b: {
        var tmp = args.popFirst();
        if (tmp == null) break :b null;
        break :b tmp.?.data;
    };
    if (tmp != null and (std.mem.eql(u8, tmp.?, "-h") or std.mem.eql(u8, tmp.?, "--help"))) {
        _ = try stdout.write(
            \\Usage: cat [-h|--help] [path]
        );
        return 0;
    }
    if (tmp == null){
        var stdin = std.io.getStdIn();
        try stdout.writeFileAll(stdin, .{});
    }else{
        var content = try std.fs.cwd().openFile(tmp.?, .{ .mode = .read_only });
        defer content.close();
        try stdout.writeFileAll(content, .{});
    }
    return 0;
}
