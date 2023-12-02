const std = @import("std");
const day01 = @import("./day01.zig");
const day02 = @import("./day02.zig");

test {
    std.testing.refAllDecls(@This());
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const cwd = std.fs.cwd();
    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    // Day 01
    const day01Puzzle01File = try cwd.openFile("./data/day01.txt", .{});
    defer day01Puzzle01File.close();
    const day01Puzzle01Result = try day01.solve01(day01Puzzle01File.reader(), allocator);
    try printResult(stdout, "01", "01", day01Puzzle01Result);
    try bw.flush();

    const day01Puzzle02File = try cwd.openFile("./data/day01.txt", .{});
    defer day01Puzzle02File.close();
    const day01Puzzle02Result = try day01.solve02(day01Puzzle02File.reader(), allocator);
    try printResult(stdout, "01", "02", day01Puzzle02Result);
    try bw.flush();

    // Day 02
    const day02Puzzle01File = try cwd.openFile("./data/day02.txt", .{});
    defer day02Puzzle01File.close();
    const day02Puzzle01Result = try day02.solve01(day02Puzzle01File.reader(), allocator);
    try printResult(stdout, "02", "01", day02Puzzle01Result);
    try bw.flush();

    const day02Puzzle02File = try cwd.openFile("./data/day02.txt", .{});
    defer day02Puzzle02File.close();
    const day02Puzzle02Result = try day02.solve02(day02Puzzle02File.reader(), allocator);
    try printResult(stdout, "02", "02", day02Puzzle02Result);
    try bw.flush();
}

fn printResult(writer: anytype, day: []const u8, puzzle: []const u8, result: i128) !void {
    try writer.print("Day {s} -> Puzzle {s} -> Result: {d}\n", .{ day, puzzle, result });
}
