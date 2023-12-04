const std = @import("std");
const expectEqual = std.testing.expectEqual;

const CharArray = std.ArrayList(u8);

const CARDS_DELIMITER: []const u8 = ":";
const WINNING_NUMBERS_DELIMITER: u8 = '|';

pub fn solve01(input: anytype, allocator: std.mem.Allocator) !i128 {
    var buffered = std.io.bufferedReader(input);
    var reader = buffered.reader();

    var arr = CharArray.init(allocator);
    defer arr.deinit();

    var digits = CharArray.init(allocator);
    defer digits.deinit();

    var winningNumbers = std.AutoHashMap(i128, bool).init(allocator);
    defer winningNumbers.deinit();

    var result: i128 = 0;

    var hasNextHand = true;

    while (hasNextHand) {
        reader.streamUntilDelimiter(arr.writer(), '\n', null) catch |err| switch (err) {
            error.EndOfStream => hasNextHand = false,
            else => return err,
        };
        defer arr.clearRetainingCapacity();
        defer digits.clearRetainingCapacity();
        defer winningNumbers.clearRetainingCapacity();

        var points: i128 = 0;
        const winningNumbersNeedle = std.mem.indexOf(u8, arr.items, CARDS_DELIMITER) orelse continue;
        var handsNumbersNeedle = winningNumbersNeedle;

        for (arr.items[winningNumbersNeedle..]) |c| {
            handsNumbersNeedle += 1;

            if (std.ascii.isDigit(c)) {
                try digits.append(c);
            } else {
                if (digits.items.len > 0) {
                    const winningNumber = try std.fmt.parseInt(i128, digits.items, 10);
                    try winningNumbers.put(winningNumber, true);
                    digits.clearRetainingCapacity();
                }

                if (c == WINNING_NUMBERS_DELIMITER) {
                    break;
                }
            }
        }

        for (arr.items[handsNumbersNeedle..]) |c| {
            if (std.ascii.isDigit(c)) {
                try digits.append(c);
            } else {
                if (digits.items.len > 0) {
                    const handsNumber = try std.fmt.parseInt(i128, digits.items, 10);
                    if (winningNumbers.contains(handsNumber)) {
                        points = if (points > 0) points * 2 else 1;
                    }
                    digits.clearRetainingCapacity();
                }
            }
        }

        if (digits.items.len > 0) {
            const handsNumber = try std.fmt.parseInt(i128, digits.items, 10);
            if (winningNumbers.contains(handsNumber)) {
                points = if (points > 0) points * 2 else 1;
            }
            digits.clearRetainingCapacity();
        }

        result += points;
    }
    return result;
}

const ScratchCardsMap = std.AutoArrayHashMap(i128, i128);

fn computeWins(scratchcards: *ScratchCardsMap, cardInDisupute: i128, wins: i128) !void {
    const currentQuantity: i128 = scratchcards.get(cardInDisupute) orelse 0;
    const numberOfCards = currentQuantity + 1;
    try scratchcards.*.put(cardInDisupute, numberOfCards);

    var i = cardInDisupute + 1;
    const end = i + wins;
    while (i < end) {
        defer i += 1;
        const iCurrentQuantity = scratchcards.get(i) orelse 0;
        try scratchcards.*.put(i, iCurrentQuantity + currentQuantity + 1);
    }
}

pub fn solve02(input: anytype, allocator: std.mem.Allocator) !i128 {
    var buffered = std.io.bufferedReader(input);
    var reader = buffered.reader();

    var arr = CharArray.init(allocator);
    defer arr.deinit();

    var digits = CharArray.init(allocator);
    defer digits.deinit();

    var winningNumbers = std.AutoHashMap(i128, bool).init(allocator);
    defer winningNumbers.deinit();

    var scratchcards = ScratchCardsMap.init(allocator);
    defer scratchcards.deinit();

    var currentCard: i128 = 0;

    var hasNextHand = true;

    while (hasNextHand) {
        reader.streamUntilDelimiter(arr.writer(), '\n', null) catch |err| switch (err) {
            error.EndOfStream => hasNextHand = false,
            else => return err,
        };
        defer arr.clearRetainingCapacity();
        defer digits.clearRetainingCapacity();
        defer winningNumbers.clearRetainingCapacity();
        defer currentCard = currentCard + 1;

        const scratchcardInDispute: i128 = currentCard + 1;
        const winningNumbersNeedle = std.mem.indexOf(u8, arr.items, CARDS_DELIMITER) orelse continue;
        var handsNumbersNeedle = winningNumbersNeedle;

        for (arr.items[winningNumbersNeedle..]) |c| {
            handsNumbersNeedle += 1;

            if (std.ascii.isDigit(c)) {
                try digits.append(c);
            } else {
                if (digits.items.len > 0) {
                    const winningNumber = try std.fmt.parseInt(i128, digits.items, 10);
                    try winningNumbers.put(winningNumber, true);
                    digits.clearRetainingCapacity();
                }

                if (c == WINNING_NUMBERS_DELIMITER) {
                    break;
                }
            }
        }

        var wins: i128 = 0;

        for (arr.items[handsNumbersNeedle..]) |c| {
            if (std.ascii.isDigit(c)) {
                try digits.append(c);
            } else {
                if (digits.items.len > 0) {
                    const handsNumber = try std.fmt.parseInt(i128, digits.items, 10);
                    if (winningNumbers.contains(handsNumber)) {
                        wins += 1;
                    }
                    digits.clearRetainingCapacity();
                }
            }
        }

        if (digits.items.len > 0) {
            const handsNumber = try std.fmt.parseInt(i128, digits.items, 10);
            if (winningNumbers.contains(handsNumber)) {
                wins += 1;
            }
            digits.clearRetainingCapacity();
        }

        try computeWins(&scratchcards, scratchcardInDispute, wins);
    }
    var result: i128 = 0;
    for (scratchcards.values()) |v| {
        result += v;
    }
    return result;
}

test "day04 -> solve01 should solve example" {
    // Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
    // Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
    // Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
    // Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
    // Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
    // Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
    const exampleFile = try std.fs.cwd().openFile("./data/day04_01_example.txt", .{});
    defer exampleFile.close();

    const result = try solve01(exampleFile.reader(), std.testing.allocator);

    try expectEqual(@as(i128, 13), result);
}

test "day04 -> solve02 should solve example" {
    // Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
    // Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
    // Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
    // Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
    // Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
    // Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
    const exampleFile = try std.fs.cwd().openFile("./data/day04_02_example.txt", .{});
    defer exampleFile.close();

    const result = try solve02(exampleFile.reader(), std.testing.allocator);

    try expectEqual(@as(i128, 30), result);
}
