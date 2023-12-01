const std = @import("std");
const expect = std.testing.expect;

pub fn solve01(input: anytype, allocator: std.mem.Allocator) !i128 {
    var buffered = std.io.bufferedReader(input);
    var reader = buffered.reader();

    var arr = std.ArrayList(u8).init(allocator);
    defer arr.deinit();

    var result: i128 = 0;
    var hasNext: bool = true;

    while (hasNext) {
        reader.streamUntilDelimiter(arr.writer(), '\n', null) catch |err| switch (err) {
            error.EndOfStream => hasNext = false,
            else => return err,
        };

        var firstChar: ?u8 = null;
        var secondChar: u8 = 0;

        for (arr.items) |c| {
            if (std.ascii.isDigit(c)) {
                if (firstChar == null) {
                    firstChar = c;
                }
                secondChar = c;
            }
        }

        if (firstChar) |c| {
            result += try std.fmt.parseInt(i128, &[_]u8{ c, secondChar }, 10);
        }

        arr.clearRetainingCapacity();
    }
    return result;
}

pub fn solve02(input: anytype, allocator: std.mem.Allocator) !i128 {
    var buffered = std.io.bufferedReader(input);
    var reader = buffered.reader();
    const numbers = [_][]const u8{ "zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" };

    var arr = std.ArrayList(u8).init(allocator);
    defer arr.deinit();

    var result: i128 = 0;
    var hasNext: bool = true;

    while (hasNext) {
        reader.streamUntilDelimiter(arr.writer(), '\n', null) catch |err| switch (err) {
            error.EndOfStream => hasNext = false,
            else => return err,
        };

        var firstChar: ?u8 = null;
        var secondChar: u8 = 0;

        for (arr.items, 0..) |c, i| {
            var ch: u8 = c;
            const currentSlice = arr.items[i..];
            for (numbers, '0'..) |num, j| {
                if (std.mem.startsWith(u8, currentSlice, num)) {
                    ch = @truncate(j);
                    break;
                }
            }

            if (std.ascii.isDigit(ch)) {
                if (firstChar == null) {
                    firstChar = ch;
                }
                secondChar = ch;
            }
        }

        if (firstChar) |c| {
            result += try std.fmt.parseInt(i128, &[_]u8{ c, secondChar }, 10);
        }

        arr.clearRetainingCapacity();
    }
    return result;
}

test "day01 -> solve01 should solve example" {
    // 1abc2
    // pqr3stu8vwx
    // a1b2c3d4e5f
    // treb7uchet
    const exampleFile = try std.fs.cwd().openFile("./data/day01_01_example.txt", .{});
    defer exampleFile.close();

    const expectedResult: i128 = 142;

    const result = try solve01(exampleFile.reader(), std.testing.allocator);

    try expect(result == expectedResult);
}

test "day01 -> solve02 should solve example" {
    // two1nine
    // eightwothree
    // abcone2threexyz
    // xtwone3four
    // 4nineeightseven2
    // zoneight234
    // 7pqrstsixteen
    const exampleFile = try std.fs.cwd().openFile("./data/day01_02_example.txt", .{});
    defer exampleFile.close();

    const expectedResult: i128 = 281;

    const result = try solve02(exampleFile.reader(), std.testing.allocator);

    try expect(result == expectedResult);
}
