const std = @import("std");

const args = @import("args.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    try args.processArgs(alloc);
}
