const std = @import("std");

const help =\\Usage: rm [-h|--help]
            \\   or: rm [-r|-i|-f] <path>
            \\
            ;

pub fn main(allocator: std.mem.Allocator, args: *std.TailQueue([]const u8)) !u8 {
    var stdout = std.io.getStdOut();
    var options = struct {
        path: ?[]const u8 = null,
        interactive: bool = false,
        recurse: bool = false,
        force: bool = false,
    }{};
    while (args.len > 0){
        var tmp = args.popFirst();
        if (tmp == null)break;
        var arg = tmp.?.data;
        if (std.mem.eql(u8, arg, "-h") or std.mem.eql(u8, arg, "--help")){
            _ = try stdout.write(help);
            return 0;
        }else if (std.mem.eql(u8,arg, "-i") or std.mem.eql(u8, arg, "--interactive")){
            options.interactive = true;
        }else if (std.mem.eql(u8, arg, "-f") or std.mem.eql(u8, arg, "--force")){
            options.interactive = false;
        }else if (arg[0] == '-'){
            _ = try stdout.write(help);
            return 0;
        }else if (options.path == null){
            options.path = arg;
        }else{
            _ = try stdout.write(help);
            return 0;
        }
    }
    if (options.path == null){
        _ = try stdout.write(help);
        return 0;
    }
    b: {
        _ = std.fs.cwd().statFile(options.path.?) catch {
            if (!options.force) break :b;
        };
        if (options.interactive){
            var stdin = std.io.getStdIn();
            _ = try stdout.write(try std.fmt.allocPrint(
                allocator,
                \\remove '{s}' [Y/n]:
                , .{
                    std.fs.path.basename(options.path.?)
                }
            ));
            var awn = try stdin.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', 32) orelse "n";
            if (!(std.mem.eql(u8, awn, "Y") or std.mem.eql(u8, awn, "y"))){
                return 0;
            }
        }
    }
    try std.fs.cwd().deleteTree(options.path.?);
    return 0;
}
