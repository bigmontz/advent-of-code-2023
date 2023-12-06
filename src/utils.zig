const std = @import("std");

pub fn readNumbersFromLine(comptime T: type, line: std.ArrayList(u8), allocator: std.mem.Allocator) !std.ArrayList(T) {
    var digits = std.ArrayList(u8).init(allocator);
    defer digits.deinit();

    var numbers = std.ArrayList(T).init(allocator);

    for (line.items) |c| {
        if (std.ascii.isDigit(c)) {
            try digits.append(c);
        } else if (digits.items.len > 0) {
            const n = try std.fmt.parseInt(T, digits.items, 10);
            try numbers.append(n);
            digits.clearRetainingCapacity();
        }
    }

    if (digits.items.len > 0) {
        const n = try std.fmt.parseInt(T, digits.items, 10);
        try numbers.append(n);
        digits.clearRetainingCapacity();
    }

    return numbers;
}

pub fn readNumberFromLineIgnoreEspace(comptime T: type, line: std.ArrayList(u8), allocator: std.mem.Allocator) !T {
    var digits = std.ArrayList(u8).init(allocator);
    defer digits.deinit();

    for (line.items) |c| {
        if (std.ascii.isDigit(c)) {
            try digits.append(c);
        } else if (c != ' ' and digits.items.len > 0) {
            break;
        }
    }

    return try std.fmt.parseInt(T, digits.items, 10);
}
