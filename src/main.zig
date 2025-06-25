const std = @import("std");
const http = std.http;

const args = @import("args.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    const arguments = try args.processArgs(alloc);

    var client = http.Client{ .allocator = alloc };
    defer client.deinit();

    var buf: [4096]u8 = undefined;

    var req = try client.open(arguments.method, arguments.uri, .{ .server_header_buffer = &buf });
    defer req.deinit();

    try req.send();
    try req.finish();

    try req.wait();

    std.debug.print("body={s}", .{buf});
}
