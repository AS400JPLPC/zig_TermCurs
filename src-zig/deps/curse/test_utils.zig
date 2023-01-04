test "testUtils" {
//pub fn main() !void {
  var text : [] const u8 = undefined;
  text = "123456";
  if  (isDigitStr(text , 1) == true )  text = try concatStr("+", text) ;
  std.debug.print("\n\r{s}\n\r",.{text});

  text =  alignStr(text,dds.ALIGNS.left,10) ;
  std.debug.print("\n\r>{s}<\n\r",.{text});

  text = "+123456";
  text =  alignStr(text,dds.ALIGNS.rigth,10) ;
  std.debug.print("\n\r>{s}<\n\r",.{text});

  text = "+123456";
  if (cmpStr(text,"-123456")) std.debug.print("\n\r>{}<\n\r",.{true})
  else std.debug.print("\n\r>{}<\n\r",.{false});
  std.debug.print("\n\r cmp>{}<\n\r",.{cmpStr(text,"+123456")});

  std.debug.print("\n\r nbr char str>{d}<\n\r",.{nbrCharStr(text)});


  const ArrayList = std.ArrayList;
  const test_allocator =  std.heap.page_allocator;
  var list = ArrayList([] const u8).init(test_allocator);
  defer list.deinit();
  try list.append("H");
  try list.append("e");
  try list.append("l");
  try list.append("l");
  try list.append("o");
  try list.append("x");
  try list.append(" Word!");

  std.debug.print("\n\r cmp>{s}<\n\r",.{list.items});

  list = removeListStr(list, 3) catch unreachable;
  std.debug.print("\n\r cmp>{s}<\n\r",.{list.items});

  list = removeListStr(list, 5) catch unreachable;

  for (list.items) |field| {
    std.debug.print("\n\r list.items>{s}<\n\r",.{field});
  }




  const geo = struct {
    pays: [] const u8,
    capital: [] const u8,
  };

  var Mlist = std.MultiArrayList(geo){};
  defer Mlist.deinit(test_allocator);

  try Mlist.ensureTotalCapacity(test_allocator, 1);

  Mlist.appendAssumeCapacity(.{
        .pays = "France",
        .capital = "Paris",
    });


  Mlist.appendAssumeCapacity(.{
        .pays = "Espagne",
        .capital = "Madrid",
    });

  Mlist.appendAssumeCapacity(.{
        .pays = "Italie",
        .capital = "Rome",
    });

  var i : usize = 0 ;
  while (i < 3) :(i += 1) {
  std.debug.print("\n\r list >{s}  {s}<\n\r",.{Mlist.items(.pays)[i],Mlist.items(.capital )[i] });
  }
  Mlist.orderedRemove(0);
  std.debug.print("\n\r list len >{d}<\n\r",.{Mlist.len});

  i= 0 ;
  while (i < Mlist.len) :(i += 1) {
  std.debug.print("\n\r list >{s}  {s}<\n\r",.{Mlist.items(.pays)[i],Mlist.items(.capital )[i] });
  }

  try Mlist.insert(test_allocator, 0, .{ .pays = "France",  .capital = "Paris", });
  std.debug.print("\n\r list len >{d}<\n\r",.{Mlist.len});
  i= 0 ;
  while (i < Mlist.len) :(i += 1) {
  std.debug.print("\n\r list >{s}  {s}<\n\r",.{Mlist.items(.pays)[i],Mlist.items(.capital )[i] });
  }


  // testing
  const allocator = std.heap.page_allocator;
  const Arg = struct {
    buf : std.ArrayList([] const u8) = std.ArrayList([] const u8).init(allocator),

   };


  var xlist = std.ArrayList([] const u8).init(allocator);
  defer xlist.deinit();

  var MlistArg = std.MultiArrayList(Arg){};
  defer MlistArg.deinit(allocator);

  try MlistArg.ensureTotalCapacity(allocator, 1);



  try xlist.append("France");
  try xlist.append("Paris");

  MlistArg.appendAssumeCapacity(.{
        .buf = xlist
    });



  //xlist = undefined;
  xlist = std.ArrayList([] const u8).init(allocator);

  try xlist.append("Espagne");
  try xlist.append("Madrid");

  MlistArg.appendAssumeCapacity(.{
        .buf = xlist
    });


  //xlist = undefined;
  xlist = std.ArrayList([] const u8).init(allocator);

  try xlist.append("Italie");
  try xlist.append("Rome");


  MlistArg.appendAssumeCapacity(.{
        .buf = xlist
    });


  std.debug.print("\n\r MlistArg len >{d}<\n\r",.{MlistArg.len});

  std.debug.print("\n\r MlistArg.buf >{s}<\n\r",.{MlistArg.items(.buf)[0].items[1]});

  i= 0 ;

  while (i < MlistArg.len) :(i += 1) {
    xlist = MlistArg.items(.buf)[i];

    for (xlist.items) | field | {
      std.debug.print("\n\r Field >{s}<\n\r",.{field});
    }
  }


  //MlistArg.deinit(allocator);

  try MlistArg.ensureTotalCapacity(allocator, 1);

  xlist = std.ArrayList([] const u8).init(allocator);
  try xlist.append("France");
  try xlist.append("Paris");

  MlistArg.appendAssumeCapacity(.{
        .buf = xlist
    });

  i= 0 ;

  while (i < MlistArg.len) :(i += 1) {
    xlist = MlistArg.items(.buf)[i];

    for (xlist.items) | field | {
      std.debug.print("\n\r Field >{s}<\n\r",.{field});
    }
  }
}