const std = @import("std");
const expectEqual = std.testing.expectEqual;

const SymbolLocation = struct { x: u128, y: u128 };
const NumberAndLocation = struct { number: i128, x1: u128, x2: u128, y: u128 };

const SymbolLocationArray = std.ArrayList(SymbolLocation);
const NumberAndLocationArray = std.ArrayList(NumberAndLocation);
const CharArray = std.ArrayList(u8);

fn numberAndLocation(digits: CharArray, x2: u128, y: u128) !NumberAndLocation {
    const number = try std.fmt.parseInt(i128, digits.items, 10);
    const start = digits.items.len - 1;
    return NumberAndLocation{ .number = number, .x1 = x2 - start, .x2 = x2, .y = y };
}

pub fn solve01(input: anytype, allocator: std.mem.Allocator) !i128 {
    var buffered = std.io.bufferedReader(input);
    var reader = buffered.reader();

    var arr = CharArray.init(allocator);
    defer arr.deinit();

    var digits = CharArray.init(allocator);
    defer digits.deinit();

    var symbolLocations = SymbolLocationArray.init(allocator);
    defer symbolLocations.deinit();

    var numbers = NumberAndLocationArray.init(allocator);
    defer numbers.deinit();

    var y: u128 = 0;

    var hasNextLine: bool = true;

    while (hasNextLine) {
        reader.streamUntilDelimiter(arr.writer(), '\n', null) catch |err| switch (err) {
            error.EndOfStream => hasNextLine = false,
            else => return err,
        };

        defer arr.clearRetainingCapacity();
        defer y += 1;
        defer digits.clearRetainingCapacity();

        for (arr.items, 0..) |c, x| {
            if (!std.ascii.isDigit(c) and c != '.') {
                try symbolLocations.append(SymbolLocation{ .x = x, .y = y });
            }

            if (std.ascii.isDigit(c)) {
                try digits.append(c);
            } else if (digits.items.len > 0) {
                const n = try numberAndLocation(digits, x - 1, y);
                try numbers.append(n);
                digits.clearRetainingCapacity();
            }
        }

        if (digits.items.len > 0) {
            const n = try numberAndLocation(digits, arr.items.len - 1, y);
            try numbers.append(n);
            digits.clearRetainingCapacity();
        }
    }

    var result: i128 = 0;
    for (numbers.items) |n| {
        const minY = @max(n.y, 1) - 1;
        const maxY = n.y + 1;
        const minX = @max(n.x1, 1) - 1;
        const maxX = n.x2 + 1;

        for (symbolLocations.items) |s| {
            if (s.x >= minX and s.x <= maxX and s.y >= minY and s.y <= maxY) {
                //std.debug.print("digits={d}, x1={d}, y={d}\n", .{ n.number, n.x1, n.y });
                result += n.number;
                break;
            }
        }
    }

    return result;
}

pub fn solve02(input: anytype, allocator: std.mem.Allocator) !i128 {
    var buffered = std.io.bufferedReader(input);
    var reader = buffered.reader();

    var arr = CharArray.init(allocator);
    defer arr.deinit();

    var digits = CharArray.init(allocator);
    defer digits.deinit();

    var symbolLocations = SymbolLocationArray.init(allocator);
    defer symbolLocations.deinit();

    var numbers = NumberAndLocationArray.init(allocator);
    defer numbers.deinit();

    var y: u128 = 0;

    var hasNextLine: bool = true;

    while (hasNextLine) {
        reader.streamUntilDelimiter(arr.writer(), '\n', null) catch |err| switch (err) {
            error.EndOfStream => hasNextLine = false,
            else => return err,
        };

        defer arr.clearRetainingCapacity();
        defer y += 1;
        defer digits.clearRetainingCapacity();

        for (arr.items, 0..) |c, x| {
            if (c == '*') {
                try symbolLocations.append(SymbolLocation{ .x = x, .y = y });
            }

            if (std.ascii.isDigit(c)) {
                try digits.append(c);
            } else if (digits.items.len > 0) {
                const n = try numberAndLocation(digits, x - 1, y);
                try numbers.append(n);
                digits.clearRetainingCapacity();
            }
        }

        if (digits.items.len > 0) {
            const n = try numberAndLocation(digits, arr.items.len - 1, y);
            try numbers.append(n);
            digits.clearRetainingCapacity();
        }
    }

    var adjacents = std.ArrayList(i128).init(allocator);
    defer adjacents.deinit();
    var result: i128 = 0;
    for (symbolLocations.items) |s| {
        defer adjacents.clearRetainingCapacity();
        for (numbers.items) |n| {
            const minY = @max(n.y, 1) - 1;
            const maxY = n.y + 1;
            const minX = @max(n.x1, 1) - 1;
            const maxX = n.x2 + 1;
            if (s.x >= minX and s.x <= maxX and s.y >= minY and s.y <= maxY) {
                try adjacents.append(n.number);
                if (adjacents.items.len > 2) {
                    break;
                }
            }
        }

        if (adjacents.items.len == 2) {
            result += adjacents.items[0] * adjacents.items[1];
        }
    }

    return result;
}

test "day03 -> solve01 should solve example" {
    // 467..114..
    // ...*......
    // ..35..633.
    // ......#...
    // 617*......
    // .....+.58.
    // ..592.....
    // ......755.
    // ...$.*....
    // .664.598..

    const exampleFile = try std.fs.cwd().openFile("./data/day03_01_example.txt", .{});
    defer exampleFile.close();

    const result = try solve01(exampleFile.reader(), std.testing.allocator);

    try expectEqual(@as(i128, 4361), result);
}

test "day03 -> solve02 should solve example" {
    // 467..114..
    // ...*......
    // ..35..633.
    // ......#...
    // 617*......
    // .....+.58.
    // ..592.....
    // ......755.
    // ...$.*....
    // .664.598..

    const exampleFile = try std.fs.cwd().openFile("./data/day03_02_example.txt", .{});
    defer exampleFile.close();

    const result = try solve02(exampleFile.reader(), std.testing.allocator);

    try expectEqual(@as(i128, 467835), result);
}
