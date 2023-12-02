const std = @import("std");
const expectEqual = std.testing.expectEqual;

// number of cubes
// 12 red cubes, 13 green cubes, and 14 blue cubes
const RED_CUBES: i128 = 12;
const GREEN_CUBES: i128 = 13;
const BLUE_CUBES: i128 = 14;
const GAME_DELIMITER: []const u8 = ":";
const CUBE_DELIMITER: []const u8 = ",";
const ROUND_DELIMITER: []const u8 = ";";

const Colors = enum { red, green, blue };

pub fn solve01(input: anytype, allocator: std.mem.Allocator) !i128 {
    var buffered = std.io.bufferedReader(input);
    var reader = buffered.reader();

    var arr = std.ArrayList(u8).init(allocator);
    defer arr.deinit();

    var result: i128 = 0;
    var hasNextGame: bool = true;

    while (hasNextGame) {
        reader.streamUntilDelimiter(arr.writer(), '\n', null) catch |err| switch (err) {
            error.EndOfStream => hasNextGame = false,
            else => return err,
        };

        defer arr.clearRetainingCapacity();

        const gameDelimiterPos = std.mem.indexOf(u8, arr.items, GAME_DELIMITER) orelse continue;
        var validGame = true;
        var currentPos = gameDelimiterPos + 1;

        while (validGame and currentPos < arr.items.len) {
            const cubeDelimiterPos = std.mem.indexOfPos(u8, arr.items, currentPos, CUBE_DELIMITER) orelse arr.items.len;
            const roundDelimiterPos = std.mem.indexOfPos(u8, arr.items, currentPos, ROUND_DELIMITER) orelse arr.items.len;
            const end = @min(cubeDelimiterPos, roundDelimiterPos);
            const cube = std.mem.trim(u8, arr.items[currentPos..end], " ");
            var it = std.mem.splitSequence(u8, cube, " ");
            const countStr = it.first();
            const count = try std.fmt.parseInt(i128, countStr, 10);
            const colorStr = it.next() orelse break;
            const color = std.meta.stringToEnum(Colors, colorStr) orelse break;
            const maxCubes = switch (color) {
                .red => RED_CUBES,
                .green => GREEN_CUBES,
                .blue => BLUE_CUBES,
            };
            validGame = count <= maxCubes;
            currentPos = end + 1;
        }

        if (!validGame) {
            continue;
        }

        const gameSlice = arr.items[5..gameDelimiterPos];
        const validGameNumber = try std.fmt.parseInt(i128, gameSlice, 10);
        result += validGameNumber;
    }

    return result;
}

pub fn solve02(input: anytype, allocator: std.mem.Allocator) !i128 {
    var buffered = std.io.bufferedReader(input);
    var reader = buffered.reader();

    var arr = std.ArrayList(u8).init(allocator);
    defer arr.deinit();

    var result: i128 = 0;
    var hasNextGame: bool = true;

    while (hasNextGame) {
        reader.streamUntilDelimiter(arr.writer(), '\n', null) catch |err| switch (err) {
            error.EndOfStream => hasNextGame = false,
            else => return err,
        };

        defer arr.clearRetainingCapacity();

        const gameDelimiterPos = std.mem.indexOf(u8, arr.items, GAME_DELIMITER) orelse continue;

        var currentPos = gameDelimiterPos + 1;
        var redCubesNeeded: i128 = 0;
        var blueCubesNeeded: i128 = 0;
        var greenCubesNeeded: i128 = 0;

        while (currentPos < arr.items.len) {
            const cubeDelimiterPos = std.mem.indexOfPos(u8, arr.items, currentPos, CUBE_DELIMITER) orelse arr.items.len;
            const roundDelimiterPos = std.mem.indexOfPos(u8, arr.items, currentPos, ROUND_DELIMITER) orelse arr.items.len;
            const end = @min(cubeDelimiterPos, roundDelimiterPos);
            const cube = std.mem.trim(u8, arr.items[currentPos..end], " ");
            var it = std.mem.splitSequence(u8, cube, " ");
            const countStr = it.first();
            const count = try std.fmt.parseInt(i128, countStr, 10);
            const colorStr = it.next() orelse break;
            const color = std.meta.stringToEnum(Colors, colorStr) orelse break;
            switch (color) {
                .red => {
                    redCubesNeeded = @max(redCubesNeeded, count);
                },
                .green => {
                    greenCubesNeeded = @max(greenCubesNeeded, count);
                },
                .blue => {
                    blueCubesNeeded = @max(blueCubesNeeded, count);
                },
            }
            currentPos = end + 1;
        }

        result += redCubesNeeded * greenCubesNeeded * blueCubesNeeded;
    }

    return result;
}

test "day02 -> solve01 should solve example" {
    // Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
    // Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
    // Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
    // Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
    // Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green

    const exampleFile = try std.fs.cwd().openFile("./data/day02_01_example.txt", .{});
    defer exampleFile.close();

    const result = try solve01(exampleFile.reader(), std.testing.allocator);

    try expectEqual(@as(i128, 8), result);
}

test "day02 -> solve02 should solve example" {
    // Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
    // Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
    // Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
    // Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
    // Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green

    const exampleFile = try std.fs.cwd().openFile("./data/day02_02_example.txt", .{});
    defer exampleFile.close();

    const result = try solve02(exampleFile.reader(), std.testing.allocator);

    try expectEqual(@as(i128, 2286), result);
}
