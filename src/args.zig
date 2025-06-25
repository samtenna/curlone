const std = @import("std");
const ArrayList = std.ArrayList;
const Uri = std.Uri;
const Method = std.http.Method;

const Args = struct {
    method: Method,
    uri: Uri,
};

const ArgumentsError = error{
    InvalidFlag,
    InvalidMethod,
    MalformedArguments,
};

pub fn processArgs(alloc: std.mem.Allocator) !Args {
    var argsText = try std.process.argsWithAllocator(alloc);
    defer argsText.deinit();
    var list = ArrayList([]const u8).init(alloc);

    while (argsText.next()) |arg| {
        try list.append(arg);
    }

    var args = Args{
        .method = Method.GET,
        .uri = try Uri.parse("http://localhost:80"),
    };

    if (list.items.len < 2 or list.items.len % 2 != 0) {
        return ArgumentsError.MalformedArguments;
    }

    // disregard the first and last arguments (executable and uri)
    var i: usize = 1;
    while (i < list.items.len) : (i += 2) {
        if (list.items[i][0] != '-') {
            // must be at the start of the uri
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
                    return ArgumentsError.InvalidMethod;
                }
            },
            else => return ArgumentsError.InvalidFlag,
        }
    }

    const original_uri_slice = list.items[list.items.len - 1];
    const owned_uri = try alloc.dupe(u8, original_uri_slice);
    const uri = try std.Uri.parse(owned_uri);
    args.uri = uri;

    return args;
}
