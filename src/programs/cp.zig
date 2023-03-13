const std = @import("std");

const help =\\Usage: cp [-h|--help]
            \\   or: cp [-i|-n|-f] <src> <dest>
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
    while (args.len){
        var tmp = args.popFirst();
        if (tmp == null)break;
        var arg = tmp.?.data;
        if (std.mem.equal(arg, "-h") or std.mem.equal(arg, "--help")){
            stdout.write(help);
            return 0;
        }else if (std.mem.equal(arg, "-i") or std.mem.equal(arg, "--interactive")){
            options.interactive = true;
        }else if (std.mem.equal(arg, "-n") or std.mem.equal(arg, "--no-clobber")){
            options.noClobber = true;
        }else if (std.mem.equal(arg, "-f") or std.mem.equal(arg, "--force")){
            options.noClobber = true;
        }else if (arg[0] == '-'){
            stdout.write(help);
            return 0;
        }else if (options.src == null){
            options.src = arg;
        }else if (options.dest == null){
            options.dest = arg;
        }else{
            stdout.write(help);
            return 0;
        }
    }
    if (options.src == null or options.dest == null){
        stdout.write(help);
        return 0;
    }
    b: {
        var stat = std.fs.cwd().statFile(options.dest) catch break :b;
        if (options.interactive){
            var stdin = std.io.getStdIn();
            stdout.write(std.fmt.allocPrint(
                allocator,
                \\overwrite '{s}' [Y/n]:
                , .{
                    std.fs.path.basename(options.dest)
                }
            ));
            var awn = stdin.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', 32);
        }
    }
    std.fs.cwd().copyFile(options.src, std.fs.cwd(), options.dest)
    return 0;
}
