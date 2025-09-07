const std = @import("std");
const Ring = @import("spsc_ring.zig").Ring;

pub fn main() !void {
    var buf: [256]u64 = undefined;
    var ring = Ring(u64).init(buf[0..]);

    var producer_thread = try std.Thread.spawn(.{}, producer, .{&ring});
    var consumer_thread = try std.Thread.spawn(.{}, consumer, .{&ring});
    producer_thread.join();
    consumer_thread.join();
}

fn producer(ring: *Ring(u64)) void {
    _ = ring.enqueue(42);
}

fn consumer(ring: *Ring(u64)) !void {
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    while (true) {
        if (ring.dequeue()) |answer| {
            try stdout.print("answer = {}\n", .{answer});
            try stdout.flush();
            return;
        }
    }
}
