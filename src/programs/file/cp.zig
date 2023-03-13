const std = @import("std");

const help =\\Usage: cp [-h|--help]
            \\   or: cp [-i|-n|-f] <src> <dest>
            \\
            ;

pub fn main(allocator: std.mem.Allocator, args: *std.TailQueue([]const u8)) !u8 {
    var stdout = std.io.getStdOut();
    var options = struct {
        src: ?[]const u8 = null,
        dest: ?[]const u8 = null,
        interactive: bool = false,
        noClobber: bool = false,
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
        }else if (std.mem.eql(u8, arg, "-n") or std.mem.eql(u8, arg, "--no-clobber")){
            options.noClobber = true;
        }else if (std.mem.eql(u8, arg, "-f") or std.mem.eql(u8, arg, "--force")){
            options.interactive = false;
        }else if (arg[0] == '-'){
            _ = try stdout.write(help);
            return 0;
        }else if (options.src == null){
            options.src = arg;
        }else if (options.dest == null){
            options.dest = arg;
        }else{
            _ = try stdout.write(help);
            return 0;
        }
    }
    if (options.src == null or options.dest == null){
        _ = try stdout.write(help);
        return 0;
    }
    b: {
        _ = std.fs.cwd().statFile(options.dest.?) catch break :b;
        if (options.interactive){
            var stdin = std.io.getStdIn();
            _ = try stdout.write(try std.fmt.allocPrint(
                allocator,
                \\overwrite '{s}' [Y/n]:
                , .{
                    std.fs.path.basename(options.dest.?)
                }
            ));
            var awn = try stdin.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', 32) orelse "n";
            if (std.mem.eql(u8, awn, "Y") or std.mem.eql(u8, awn, "y")){
                try std.fs.cwd().deleteFile(options.dest.?);
            }else{
                return 0;
            }
        }else if (options.noClobber){
            return 0;
        }
    }
    try std.fs.cwd().copyFile(options.src.?, std.fs.cwd(), options.dest.?, .{});
    return 0;
}
