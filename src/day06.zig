const std = @import("std");
const utils = @import("./utils.zig");
const expectEqual = std.testing.expectEqual;

pub fn solve01(input: anytype, allocator: std.mem.Allocator) !i128 {
    var buffered = std.io.bufferedReader(input);
    var reader = buffered.reader();

    var arr = std.ArrayList(u8).init(allocator);
    defer arr.deinit();

    try reader.streamUntilDelimiter(arr.writer(), '\n', null);

    const timelist = try utils.readNumbersFromLine(i128, arr, allocator);
    defer timelist.deinit();

    var ended = false;

    arr.clearRetainingCapacity();
    reader.streamUntilDelimiter(arr.writer(), '\n', null) catch |err| switch (err) {
        error.EndOfStream => ended = true,
        else => return err,
    };

    const distanceList = try utils.readNumbersFromLine(i128, arr, allocator);
    defer distanceList.deinit();

    var result: i128 = 1;

    for (timelist.items, distanceList.items) |time, distance| {
        var waysOfWin: i128 = 0;

        var velocity: i32 = 0;
        while (velocity < time) : (velocity += 1) {
            const traveled = velocity * (time - velocity);

            if (traveled > distance) {
                waysOfWin += 1;
            }
        }

        result *= waysOfWin;
    }
    return result;
}

pub fn solve02(input: anytype, allocator: std.mem.Allocator) !i128 {
    var buffered = std.io.bufferedReader(input);
    var reader = buffered.reader();

    var arr = std.ArrayList(u8).init(allocator);
    defer arr.deinit();

    try reader.streamUntilDelimiter(arr.writer(), '\n', null);

    const time = try utils.readNumberFromLineIgnoreEspace(i128, arr, allocator);
    var ended = false;

    arr.clearRetainingCapacity();
    reader.streamUntilDelimiter(arr.writer(), '\n', null) catch |err| switch (err) {
        error.EndOfStream => ended = true,
        else => return err,
    };

    const distance = try utils.readNumberFromLineIgnoreEspace(i128, arr, allocator);

    var waysOfWin: i128 = 0;

    var velocity: i32 = 0;
    while (velocity < time) : (velocity += 1) {
        const traveled = velocity * (time - velocity);

        if (traveled > distance) {
            waysOfWin += 1;
        }
    }

    return waysOfWin;
}

test "day06 -> solve01 should solve example" {
    // Time:      7  15   30
    // Distance:  9  40  200
    const exampleFile = try std.fs.cwd().openFile("./data/day06_01_example.txt", .{});
    defer exampleFile.close();

    const result = try solve01(exampleFile.reader(), std.testing.allocator);

    try expectEqual(@as(i128, 288), result);
}

test "day06 -> solve02 should solve example" {
    // Time:      7  15   30
    // Distance:  9  40  200
    const exampleFile = try std.fs.cwd().openFile("./data/day06_01_example.txt", .{});
    defer exampleFile.close();

    const result = try solve02(exampleFile.reader(), std.testing.allocator);

    try expectEqual(@as(i128, 71503), result);
}
