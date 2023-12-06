const std = @import("std");
const utils = @import("./utils.zig");
const expectEqual = std.testing.expectEqual;

const CharArray = std.ArrayList(u8);
const IntegerArray = std.ArrayList(i128);
const IntegerToIntegerMap = std.AutoArrayHashMap(i128, i128);

const Interval = struct {
    start: i128,
    end: i128,
    fn returnValid(self: Interval) ?i128 {
        if (self.end >= self.end) self else null;
    }
};

const IntervalMapResult = struct { mapped: ?Interval, before: ?Interval, after: ?Interval };

const IntervalMapper = struct {
    from: Interval,
    valueToAdd: i128,

    fn map(self: IntervalMapper, interval: Interval) IntervalMapResult {
        // Init invalid intervals
        var mapped: ?Interval = null;
        var before: ?Interval = null;
        var after: ?Interval = null;

        // interval start before
        if (interval.start < self.from.start) {
            if (interval.end < self.from.start) {
                before = interval;
            } else {
                before = Interval{ .start = interval.start, .end = self.from.start - 1 };
                mapped = Interval{ .start = self.from.start + self.valueToAdd, .end = @min(interval.end, self.from.end) + self.valueToAdd };

                if (interval.end > self.from.end) {
                    const afterStart = self.from.end + 1;
                    const afterEnd = interval.end;
                    after = Interval{ .start = afterStart, .end = afterEnd };
                }
            }
            // start in the middle
        } else if (interval.start <= self.from.end) {
            mapped = Interval{ .start = @max(interval.start, self.from.start) + self.valueToAdd, .end = @min(interval.end, self.from.end) + self.valueToAdd };

            if (interval.end > self.from.end) {
                const afterStart = self.from.end + 1;
                const afterEnd = interval.end;
                after = Interval{ .start = afterStart, .end = afterEnd };
            }
            // start after
        } else {
            after = interval;
        }

        return IntervalMapResult{ .mapped = mapped, .before = before, .after = after };
    }
};

const IntervalList = std.ArrayList(Interval);
const IntervalMapperList = std.ArrayList(IntervalMapper);

pub fn solve01(input: anytype, allocator: std.mem.Allocator) !i128 {
    var buffered = std.io.bufferedReader(input);
    var reader = buffered.reader();

    var arr = CharArray.init(allocator);
    defer arr.deinit();

    var maps = std.ArrayList(*IntegerToIntegerMap).init(allocator);
    defer maps.deinit();

    var seedToSoilMap = IntegerToIntegerMap.init(allocator);
    defer seedToSoilMap.deinit();
    try maps.append(&seedToSoilMap);

    var soilToFertilizerMap = IntegerToIntegerMap.init(allocator);
    defer soilToFertilizerMap.deinit();
    try maps.append(&soilToFertilizerMap);

    var fertilizerToWaterMap = IntegerToIntegerMap.init(allocator);
    defer fertilizerToWaterMap.deinit();
    try maps.append(&fertilizerToWaterMap);

    var waterToLightMap = IntegerToIntegerMap.init(allocator);
    defer waterToLightMap.deinit();
    try maps.append(&waterToLightMap);

    var lightToTemperatureMap = IntegerToIntegerMap.init(allocator);
    defer lightToTemperatureMap.deinit();
    try maps.append(&lightToTemperatureMap);

    var temperatureToHumdityMap = IntegerToIntegerMap.init(allocator);
    defer temperatureToHumdityMap.deinit();
    try maps.append(&temperatureToHumdityMap);

    var humidityToLocationMap = IntegerToIntegerMap.init(allocator);
    defer humidityToLocationMap.deinit();
    try maps.append(&humidityToLocationMap);

    var hasNextLine: bool = true;

    reader.streamUntilDelimiter(arr.writer(), '\n', null) catch |err| switch (err) {
        error.EndOfStream => hasNextLine = false,
        else => return err,
    };

    // first line contains the seeds
    var seeds = try utils.readNumbersFromLine(i128, arr, allocator);
    defer seeds.deinit();
    arr.clearRetainingCapacity();

    var mapNeedle: usize = 0;

    while (hasNextLine) {
        reader.streamUntilDelimiter(arr.writer(), '\n', null) catch |err| switch (err) {
            error.EndOfStream => hasNextLine = false,
            else => return err,
        };

        defer arr.clearRetainingCapacity();

        const fromValues = if (mapNeedle == 0) seeds.items else maps.items[mapNeedle - 1].values();

        const map = maps.items[mapNeedle];

        const numbers = try utils.readNumbersFromLine(i128, arr, allocator);
        defer numbers.deinit();

        if (numbers.items.len == 0) {
            if (map.count() != 0) {
                mapNeedle += 1;
                for (fromValues) |i| {
                    if (!map.contains(i)) {
                        try map.put(i, i);
                    }
                }
            }
            continue;
        }

        const to = numbers.items[0];
        const from = numbers.items[1];
        const count = @as(usize, @intCast(numbers.items[2]));

        for (fromValues) |i| {
            const j = i - from;
            if (j >= 0 and j < count) {
                try map.put(i, to + j);
            }
        }
    }

    var result: ?i128 = null;

    for (seeds.items) |seed| {
        var currentValue: i128 = seed;

        for (maps.items) |map| {
            currentValue = map.get(currentValue) orelse currentValue;
        }

        if (result) |r| {
            if (currentValue < r) {
                result = currentValue;
            }
        } else {
            result = currentValue;
        }
    }

    return result orelse -1; // -1 should never happen
}

pub fn solve02(input: anytype, allocator: std.mem.Allocator) !i128 {
    var buffered = std.io.bufferedReader(input);
    var reader = buffered.reader();

    var arr = CharArray.init(allocator);
    defer arr.deinit();

    var hasNextLine: bool = true;

    reader.streamUntilDelimiter(arr.writer(), '\n', null) catch |err| switch (err) {
        error.EndOfStream => hasNextLine = false,
        else => return err,
    };

    var currentIntervals = IntervalList.init(allocator);
    defer currentIntervals.deinit();

    var workingIntervals = IntervalList.init(allocator);
    defer workingIntervals.deinit();

    var nextIntervals = IntervalList.init(allocator);
    defer nextIntervals.deinit();

    var intervalMapppers = IntervalMapperList.init(allocator);
    defer intervalMapppers.deinit();

    // first line contains the seeds pairs
    var seedsPairs = try utils.readNumbersFromLine(i128, arr, allocator);
    defer seedsPairs.deinit();

    //std.debug.print("==== INTERVALS =====\n", .{});

    for (0..seedsPairs.items.len / 2) |i| {
        const start = seedsPairs.items[i * 2];
        const count = @as(usize, @intCast(seedsPairs.items[i * 2 + 1]));
        const interval = Interval{ .start = start, .end = start + count - 1 };
        //std.debug.print("interval {d} {d}\n", .{ interval.start, interval.end });
        try currentIntervals.append(interval);
    }
    arr.clearRetainingCapacity();

    while (hasNextLine) {
        reader.streamUntilDelimiter(arr.writer(), '\n', null) catch |err| switch (err) {
            error.EndOfStream => hasNextLine = false,
            else => return err,
        };

        defer arr.clearRetainingCapacity();
        defer workingIntervals.clearRetainingCapacity();

        const numbers = try utils.readNumbersFromLine(i128, arr, allocator);
        defer numbers.deinit();

        if (numbers.items.len == 0) {
            if (intervalMapppers.items.len != 0) {
                try nextIntervals.appendSlice(currentIntervals.items);
                const temp = nextIntervals;
                nextIntervals = currentIntervals;
                currentIntervals = temp;

                //std.debug.print("==== INTERVALS =====\n", .{});
                // for (currentIntervals.items) |j| {
                //     std.debug.print("interval {d} {d}\n", .{ j.start, j.end });
                // }
                nextIntervals.clearRetainingCapacity();
                intervalMapppers.clearRetainingCapacity();
            }
            continue;
        }

        const to = numbers.items[0];
        const from = numbers.items[1];
        const count = numbers.items[2];

        const mapper = IntervalMapper{ .from = Interval{ .start = from, .end = from + count - 1 }, .valueToAdd = to - from };
        try intervalMapppers.append(mapper);

        for (currentIntervals.items) |interval| {
            const m = mapper.map(interval);
            if (m.mapped) |n| try nextIntervals.append(n);
            if (m.before) |b| try workingIntervals.append(b);
            if (m.after) |a| try workingIntervals.append(a);
        }

        currentIntervals.clearRetainingCapacity();
        try currentIntervals.appendSlice(workingIntervals.items);
    }

    var result: ?i128 = null;

    for (currentIntervals.items) |i| {
        //std.debug.print("interval {d} {d}\n", .{ i.start, i.end });

        if (result) |r| {
            result = @min(r, i.start);
        } else {
            result = i.start;
        }
    }

    return result orelse -1; // -1 should never happen
}

test "day05 -> solve01 should solve example" {
    // seeds: 79 14 55 13

    // seed-to-soil map:
    // 50 98 2
    // 52 50 48

    // soil-to-fertilizer map:
    // 0 15 37
    // 37 52 2
    // 39 0 15

    // fertilizer-to-water map:
    // 49 53 8
    // 0 11 42
    // 42 0 7
    // 57 7 4

    // water-to-light map:
    // 88 18 7
    // 18 25 70

    // light-to-temperature map:
    // 45 77 23
    // 81 45 19
    // 68 64 13

    // temperature-to-humidity map:
    // 0 69 1
    // 1 0 69

    // humidity-to-location map:
    // 60 56 37
    // 56 93 4
    const exampleFile = try std.fs.cwd().openFile("./data/day05_01_example.txt", .{});
    defer exampleFile.close();

    const result = try solve01(exampleFile.reader(), std.testing.allocator);

    try expectEqual(@as(i128, 35), result);
}

test "day05 -> solve02 should solve example" {
    // seeds: 79 14 55 13

    // seed-to-soil map:
    // 50 98 2
    // 52 50 48

    // soil-to-fertilizer map:
    // 0 15 37
    // 37 52 2
    // 39 0 15

    // fertilizer-to-water map:
    // 49 53 8
    // 0 11 42
    // 42 0 7
    // 57 7 4

    // water-to-light map:
    // 88 18 7
    // 18 25 70

    // light-to-temperature map:
    // 45 77 23
    // 81 45 19
    // 68 64 13

    // temperature-to-humidity map:
    // 0 69 1
    // 1 0 69

    // humidity-to-location map:
    // 60 56 37
    // 56 93 4
    const exampleFile = try std.fs.cwd().openFile("./data/day05_02_example.txt", .{});
    defer exampleFile.close();

    const result = try solve02(exampleFile.reader(), std.testing.allocator);

    try expectEqual(@as(i128, 46), result);
}
