const std = @import("std");

fn removeExtension(str: []const u8) []const u8 {
    var i: usize = 0;
    while (i < str.len) {
        if (str[i] == '.') {
            return str[0..i];
        }
        i += 1;
    }
    return str;
}

pub fn main() !u8 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var allocator = arena.allocator();
    var rawArgs = try std.process.argsWithAllocator(allocator);
    const ArgQueueType = std.TailQueue([]const u8);
    var args = ArgQueueType{};
    while (true) {
        var _v = rawArgs.next();
        if (_v == null) break;
        var v = try allocator.create(ArgQueueType.Node);
        v.* = .{ .data = try allocator.dupe(u8, _v.?) };
        args.append(v);
    }
    rawArgs.deinit();

    var name: []const u8 = removeExtension(std.fs.path.basename(b: {
        var tmp = args.popFirst();
        if (tmp == null) {
            break :b "mini-bb";
        }
        break :b tmp.?.data;
    }));

    if (std.mem.eql(u8, name, "")) {
        return 1;
    }

    const programs = .{
        .{ "yes", @import("./programs/yes.zig").main },
        .{ "cat", @import("./programs/cat.zig").main },
        .{ "true", @import("./programs/true.zig").main },
        .{ "false", @import("./programs/false.zig").main },
    };

    if ((args.first != null and (std.mem.eql(u8, args.first.?.data, "-h") or std.mem.eql(u8, args.first.?.data, "--help"))) or args.len == 0) {
        var commands = std.ArrayList(u8).init(allocator);
        defer commands.deinit();
        inline for (programs, 0..) |item, i| {
            try commands.appendSlice(item[0]);
            if (i < programs.len - 1){
                try commands.appendSlice(", ");
            }
            if (i%10 == 0){
                try commands.appendSlice("\n  ");
            }
        }
        var stdout = std.io.getStdOut();
        _ = try stdout.write(try std.fmt.allocPrint(allocator,
            \\Usage: {s} [-h|--help] [command]
            \\
            \\all commands:
            \\  {s}
        , .{ name, commands.items }));
    } else if (std.mem.eql(u8, name, "mini-bb")) {
        var n = args.popFirst();
        if (n != null and n.?.data[0] != '-') {
            name = n.?.data;
        }
    }

    inline for (programs) |value| {
        if (std.mem.eql(u8, value[0], name)) {
            var code = try value[1](allocator, &args);
            return code;
        }
    }

    return 0;
}
