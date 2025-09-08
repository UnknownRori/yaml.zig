const std = @import("std");
const lib = @import("yaml_zig_lib");

const ArenaAllocator = std.heap.ArenaAllocator;
const testing = std.testing;

pub fn main() !void {
    var gpa: std.heap.GeneralPurposeAllocator(.{ .thread_safe = true }) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    const data =
        \\tags:
        \\  - fleeting
        \\created: 2025-08-08T03:02:00
        \\cssclasses:
        \\  - center-h1
    ;

    var parser = try lib.Parser.init(allocator, data);
    defer parser.deinit();

    var arena = ArenaAllocator.init(allocator);
    defer arena.deinit();
    const value = try parser.parse(arena.allocator());
    defer value.deinit();

    try testing.expectEqual(3, value.items.len);
    switch (value.items[0]) {
        .Sequence => |seq| {
            try testing.expectEqual(1, seq.value.items.len);
            try testing.expectEqualStrings("tags", seq.key.items);
            try testing.expectEqualStrings("fleeting", seq.value.items[0].items);
        },
        else => try testing.expect(false),
    }

    switch (value.items[1]) {
        .Scalar => |scalar| {
            try testing.expectEqualStrings("created", scalar.key.items);
        },
        else => try testing.expect(false),
    }

    switch (value.items[2]) {
        .Sequence => |seq| {
            try testing.expectEqual(1, seq.value.items.len);
            try testing.expectEqualStrings("cssclasses", seq.key.items);
        },
        else => try testing.expect(false),
    }
}
