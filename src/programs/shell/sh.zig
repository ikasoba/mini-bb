const std = @import("std");

pub fn main(allocator: std.mem.Allocator, args: *std.TailQueue([]const u8)) !u8 {
    var stdout = std.io.getStdOut();
    var stdin = std.io.getStdIn();
}
