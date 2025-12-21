
const std = @import("std");

//Forms/Grid/Menu
var arenaTui = std.heap.ArenaAllocator.init(std.heap.page_allocator);
pub const allocTui = arenaTui.allocator();
pub fn deinitTui() void {
    _= arenaTui.reset(.free_all);
}

//Grid
pub const allocData = std.heap.page_allocator;



var arenaUtl = std.heap.ArenaAllocator.init(std.heap.page_allocator);
pub const allocUtl = arenaUtl.allocator();
pub fn deinitUtl() void {
    _= arenaUtl.reset(.free_all);
}
