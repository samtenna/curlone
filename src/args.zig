const std = @import("std");
const ArrayList = std.ArrayList;

const Args = struct {
    method: Method,
    url: []const u8,
};

const Method = enum {
    GET,
    POST,
    PUT,
    DELETE,
};

pub fn processArgs(alloc: std.mem.Allocator) !void {
    var argsText = try std.process.argsWithAllocator(alloc);
    var list = ArrayList([]const u8).init(alloc);

    while (argsText.next()) |arg| {
        try list.append(arg);
    }

    var args = Args{
        .method = Method.GET,
        .url = "127.0.0.1",
    };

    if (list.items.len < 2 or list.items.len % 2 != 0) {
        return error.InvalidArguments;
    }

    // disregard the first and last arguments (executable and url)
    var i: usize = 1;
    while (i < list.items.len) : (i += 2) {
        if (list.items[i][0] != '-') {
            // must be at the start of the url
            break;
        }

        switch (list.items[i][1]) {
            'X' => {
                if (std.mem.eql(u8, list.items[i + 1], "GET")) {
                    args.method = Method.GET;
                } else if (std.mem.eql(u8, list.items[i + 1], "POST")) {
                    args.method = Method.POST;
                } else if (std.mem.eql(u8, list.items[i + 1], "PUT")) {
                    args.method = Method.PUT;
                } else if (std.mem.eql(u8, list.items[i + 1], "DELETE")) {
                    args.method = Method.DELETE;
                } else {
                    return error.InvalidMethod;
                }
            },
            else => {
                std.debug.print("found unknown option: {s}\n", .{list.items[i]});
            },
        }
    }

    const url = list.items[list.items.len - 1];
    args.url = url;

    std.debug.print("Method: {s}, URL: {s}\n", .{ @tagName(args.method), args.url });
}
