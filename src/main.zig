const std = @import("std");
const day01 = @import("./day01.zig");
const day02 = @import("./day02.zig");
const day03 = @import("./day03.zig");
const day04 = @import("./day04.zig");
const day05 = @import("./day05.zig");
const day06 = @import("./day06.zig");

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

    // Day 03
    const day03Puzzle01File = try cwd.openFile("./data/day03.txt", .{});
    defer day03Puzzle01File.close();
    const day03Puzzle01Result = try day03.solve01(day03Puzzle01File.reader(), allocator);
    try printResult(stdout, "03", "01", day03Puzzle01Result);
    try bw.flush();

    const day03Puzzle02File = try cwd.openFile("./data/day03.txt", .{});
    defer day03Puzzle02File.close();
    const day03Puzzle02Result = try day03.solve02(day03Puzzle02File.reader(), allocator);
    try printResult(stdout, "03", "02", day03Puzzle02Result);
    try bw.flush();

    // Day 04
    const day04Puzzle01File = try cwd.openFile("./data/day04.txt", .{});
    defer day04Puzzle01File.close();
    const day04Puzzle01Result = try day04.solve01(day04Puzzle01File.reader(), allocator);
    try printResult(stdout, "04", "01", day04Puzzle01Result);
    try bw.flush();

    const day04Puzzle02File = try cwd.openFile("./data/day04.txt", .{});
    defer day04Puzzle02File.close();
    const day04Puzzle02Result = try day04.solve02(day04Puzzle02File.reader(), allocator);
    try printResult(stdout, "04", "02", day04Puzzle02Result);
    try bw.flush();

    // Day 05
    const day05Puzzle01File = try cwd.openFile("./data/day05.txt", .{});
    defer day05Puzzle01File.close();
    const day05Puzzle01Result = try day05.solve01(day05Puzzle01File.reader(), allocator);
    try printResult(stdout, "05", "01", day05Puzzle01Result);
    try bw.flush();

    const day05Puzzle02File = try cwd.openFile("./data/day05.txt", .{});
    defer day05Puzzle02File.close();
    const day05Puzzle02Result = try day05.solve02(day05Puzzle02File.reader(), allocator);
    try printResult(stdout, "05", "02 (wrong)", day05Puzzle02Result);
    try bw.flush();

    // Day 06
    const day06Puzzle01File = try cwd.openFile("./data/day06.txt", .{});
    defer day06Puzzle01File.close();
    const day06Puzzle01Result = try day06.solve01(day06Puzzle01File.reader(), allocator);
    try printResult(stdout, "06", "01", day06Puzzle01Result);
    try bw.flush();

    const day06Puzzle02File = try cwd.openFile("./data/day06.txt", .{});
    defer day06Puzzle02File.close();
    const day06Puzzle02Result = try day06.solve02(day06Puzzle02File.reader(), allocator);
    try printResult(stdout, "06", "02", day06Puzzle02Result);
    try bw.flush();
}

fn printResult(writer: anytype, day: []const u8, puzzle: []const u8, result: i128) !void {
    try writer.print("Day {s} -> Puzzle {s} -> Result: {d}\n", .{ day, puzzle, result });
}
