const std = @import("std");
const utf = @import("std").unicode;



const c = @cImport( { @cInclude("mpdecimal.h"); } );

//---------------------------------------------------------------------------------
// begin  decimal
//
/// https://www.bytereef.org/mpdecimal/index.html 
/// const c = @cImport( { @cInclude("mpdecimal.h"); } );
/// installation with your package manager or download 
///
/// validated: by https://speleotrove.com/decimal/
/// official site thank you for making this standardization available
/// 
/// CTX_ADDR Communication structure for default common control decimal128 -> MPD_ROUND_05UP
/// openContex()
///
/// DCMLFX includes 3 values
///   number: mpdecimal structure [*c]
///   integer: number of integers in front of the point
///   scale: number of integers behind the point
///   associated function:
///   init: checks the relevance of bounding with mpdecimal and determines the fixed decimal
///   Test if the context is active otherwise it calls openContext()
///
///   free: frees the associated memory storage ".number" (not the definition)
///   debugPrint: small followed by ".number"
///   isNumber: check value is compliant '0-9 + - .' compliant SQL postgres DB2...
///   isValide: uses isNumber, and checks if the external value  complies with the boundary
///   isOverflow: check if the internal value is out of bounds
///   setDcml: give a value (text format) to ".number"
///   setZeros: forces the value 0 to ".number"
///   isZeros: checks if the value 0
///   round: two-function round and truncate (0.5 = +1) see finance...
///   trunc: to a function, truncate without rounding
///   string: if the scale part is larger than its definition, 
///   it rounds then adds zeros if necessary (respects the SQL display alignment standard on the left ex: 1.00)
///   add: a = a + b
///   sub: a = a - b
///   mul: a = a * b
///   div: a = a / b  if b = zeros raises an error
///   addTo: r = a + b
///   subTo: r = a - b
///   mulTo: r = a * b
///   divto: r = a / b  if b = zeros raises an error
///   floor: r = a
///   ceil : r = a
///   rem  : r = a / b  if b = zeros raises an error
///   rate: raises a value with the percentage ex ( n = (val*nbr) , val = (n * %1.25)
/// 
/// function off DCMLF
/// cmp: compare a , b returns EQ LT GT
/// mdrate module: returns ex: ttc , htx (base val, article nrb, rate = 25 ) practice in 5 operations
/// dsperr: practical @panic product in test 
/// debugContext: print context



pub var CTX_ADDR: c.mpd_context_t = undefined;

var startContext : bool = false ;







const dcmlError = error {
	Failed_Init_iEntier_iScale,
	Failed_set_precision_cMaxDigit,
	Failed_isNumber_string,
	Failed_valid_entier,
	Failed_valid_scale,
	Failed_valid_dot,
	isOverflow_entier,
	isOverflow_scale,
	isOverflow_entier_htx,
	isOverflow_entier_ttc,
	div_impossible_zeros,
	cmp_impossible
};



pub const CMP = enum (u8) {
		  LT ,
		  EQ ,
		  GT ,
};

var arenaDcml = std.heap.ArenaAllocator.init(std.heap.page_allocator);
var allocDcml = arenaDcml.allocator();
pub fn deinitDcml() void {
    arenaDcml.deinit();
    arenaDcml = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    allocDcml = arenaDcml.allocator();
}

pub const DCMLFX = struct {
		number  : [*c]c.mpd_t ,	 // number 
		entier  : u8 ,			 // Left  part of the number
		scale   : u8 ,			 // Right part of the number



	var result :[] u8 = undefined;
	var work:[] u8 = undefined ;
	//--------------------------------------------------------------
	// Definition ex: for management -> accounting, stock, order...
	//--------------------------------------------------------------
	// MPD_DECIMAL32 = 32     MPD_ROUND_HALF_EVEN  
	// MPD_DECIMAL64 = 64     MPD_ROUND_HALF_EVEN   
	// MPD_DECIMAL128 = 128   MPD_ROUND_HALF_EVEN 34   digit IEE754
	// MPD_DECIMAL256 = 256   MPD_ROUND_HALF_EVEN 70   laboratoire
	// MPD_DECIMAL512 = 512   MPD_ROUND_HALF_EVEN 142  spatial
	fn openContext() void {
		c.mpd_maxcontext(&CTX_ADDR)  ;
		_= c.mpd_ieee_context(&CTX_ADDR, 128);  // 128  256  512
		_= c.mpd_qsetround(&CTX_ADDR, 6); // default MPD_ROUND_HALF_EVEN
		startContext = true ;
	}


	pub fn init(iEntier: u8 , iScale : u8   ) DCMLFX {
		if (!startContext) openContext();
		if ((iEntier + iScale  > c.mpd_getprec(&CTX_ADDR)) or 
			( iEntier == 0 and iScale == 0 ) ) @panic("Failed_Init_iEntier_iScale") ;
		const snum  = DCMLFX {
			.number = c.mpd_new(&CTX_ADDR) ,
			.entier = iEntier ,
			.scale  = iScale,
		};

		c.mpd_set_string(@ptrCast(snum.number), @ptrCast("0"),  &CTX_ADDR);

		return snum;
	}




	// Frees the storage memory of DCMLFX.number
	pub fn deinit(cnbr: DCMLFX) void {
		c.mpd_set_string(@ptrCast(cnbr.number), @ptrCast(""), &CTX_ADDR );
		c.mpd_del(cnbr.number);
		allocDcml.free(result);
		allocDcml.free(work);
	}


	// debug dcml number, entier,scale
	pub fn debugPrint(cnbr: DCMLFX, txt : []const u8) void {
		std.debug.print("debug: {s} --> dcml:{s} entier:{d} scale:{d}  \r\n", .{
			txt,
			c.mpd_to_eng(cnbr.number, 0), cnbr.entier, cnbr.scale });
	}

	pub fn isActif(cnbr: DCMLFX) bool {
		if ( c.mpd_isnan(cnbr.number) == 0 )  return true else return false ;
	}

 

	// Numerical value control
	fn isNumber (str :[] const u8) bool {
		if (std.mem.eql(u8, str, "") ) return false;
		var iter = iteratDcml.iterator(str);
		defer iter.deinit();
		var b: bool = true;
		var p: bool = false;
		var i: usize =0;
		while (iter.next()) |ch| :( i += 1) {
			const x = utf.utf8Decode(ch) catch unreachable;
			switch (x) {
				'0'...'9' => continue ,
				'.' => {
					if ( p ) b = false 
					else {  p = true ; continue ; }  // control is . unique
				},
				'-' => { if ( i ==  0 ) continue else b = false ; } ,
				'+' => { if ( i ==  0 ) continue else b = false ; } ,
				else => b = false ,
			}
		}
		return b;
	}




	// Validity check
	pub fn isValid (cnbr: DCMLFX, str :[] const u8) ! void {
		if (!isNumber(str)) return dcmlError.Failed_isNumber_string;
		var iter = iteratDcml.iterator(str);
		defer iter.deinit();
		var e: usize = 0 ;	// nbr carctère entier
		var s: usize = 0 ;	// nbr carctère scale
		var p: bool =false;   // '.' 
		while (iter.next()) |ch|  {
			const x = utf.utf8Decode(ch) catch unreachable;
			switch (x) {
				'0'...'9' =>  { if (!p ) e += 1  else s += 1;},
				'.' => p = true,
				else => {},
			}
		}
		if (cnbr.entier < e) return dcmlError.Failed_valid_entier;
		if (cnbr.scale  < s) return dcmlError.Failed_valid_scale;
		if (p and s == 0)	return dcmlError.Failed_valid_dot;
		return ;
	}




	// Validity check Overflow
	pub fn isOverflow (cnbr: DCMLFX) ! void {
		work = std.fmt.allocPrint(allocDcml,"{s}", .{std.mem.span(c.mpd_to_eng(cnbr.number, 0))}) catch unreachable;
		var iter = iteratDcml.iterator(work);
		defer iter.deinit();
		var e: usize = 0 ;	// nbr carctère entier
		var s: usize = 0 ;	// nbr carctère scale
		var p: bool =false;   // '.' 
		while (iter.next()) |ch|  {
			const x = utf.utf8Decode(ch) catch unreachable;
			switch (x) {
				'0'...'9' =>  { if (!p ) e += 1  else s += 1; },
				'.' => p = true,
				else => {},
			}
		}
		if (cnbr.entier < e) return dcmlError.isOverflow_entier;
		if (cnbr.scale  < s) return dcmlError.isOverflow_scale;
	}



	// You are responsible for the value.
	pub fn setDcml(cnbr: DCMLFX, str: []const u8)  ! void {
		if (!isNumber(str)) return dcmlError.Failed_isNumber_string;
		if ( str.len == 0 ) {
			c.mpd_set_string(@ptrCast(cnbr.number), @ptrCast("0"),  &CTX_ADDR );
			return;
		}
		c.mpd_set_string(@ptrCast(cnbr.number), @ptrCast(str),  &CTX_ADDR );
	}




	// set "0" 
	pub fn setZeros(cnbr: DCMLFX) void {
		c.mpd_set_string(@ptrCast(cnbr.number), @ptrCast("0"),  &CTX_ADDR);
	}




	// isZeros 
	pub fn isZeros(cnbr: DCMLFX) bool{
		if ( 1 == c.mpd_iszero(cnbr.number)) return true 
		else return false;
	}




	// ARRONDI comptable / commercial
	// round and truncate  5 => + 1
	pub fn round(cnbr: DCMLFX) void {
		const r: [*c]c.mpd_t = c.mpd_qnew();
		var i : usize = 1;
		const m: c_int = 10;
		c.mpd_copy(r , cnbr.number , &CTX_ADDR);
		if (cnbr.scale > 0){
			while( i <= cnbr.scale) : (i += 1) {
				c.mpd_mul_i32(r , r, m , &CTX_ADDR);
			}
			i = 1;
			c.mpd_round_to_int(r , r,  &CTX_ADDR);
			while( i <= cnbr.scale) : (i += 1) {
				c.mpd_div_i32(r , r, m , &CTX_ADDR);
			}
		}
		else c.mpd_floor(r , r,  &CTX_ADDR);
		c.mpd_copy(cnbr.number , r,  &CTX_ADDR);
		c.mpd_del(r);
	}





	// truncate without rounding 
	pub fn trunc(cnbr: DCMLFX) void {
		const r: [*c]c.mpd_t = c.mpd_qnew();
		var i : usize = 1;
		const m: c_int = 10;
		c.mpd_copy(r , cnbr.number , &CTX_ADDR);
		if (cnbr.scale > 0){
			while( i <= cnbr.scale) : (i += 1) {
				c.mpd_mul_i32(r , r, m ,  &CTX_ADDR);
			}
			i = 1;
			c.mpd_trunc(r , r, &CTX_ADDR);
			while( i <= cnbr.scale) : (i += 1) {
				c.mpd_div_i32(r , r, m , &CTX_ADDR);
			}
		}
		else c.mpd_floor(r , r, &CTX_ADDR);
		c.mpd_copy(cnbr.number , r, &CTX_ADDR);
		c.mpd_del(r);
	}




	// Returns a formatted string for gestion, statistique ...
	pub fn string(cnbr: DCMLFX ) [] const u8 {
		if ( c.mpd_isnan(cnbr.number) != 0 )  @panic("undefine_dcml");


		work = std.fmt.allocPrint(allocDcml,"{s}",.{std.mem.span(c.mpd_to_eng(cnbr.number, 0))}) catch unreachable;

		var iterA = iteratDcml.iterator(work);
		defer iterA.deinit();
		var s: usize = 0 ;	// nbr carctère scale
		var p: bool =false;   // '.' 
		while (iterA.next()) |ch|  {
			const x = utf.utf8Decode(ch) catch unreachable;
			switch (x) {
			'0'...'9' =>  { if (p ) s += 1 ; },
			'.' => p = true,
			else => {},
			}
		}

		if ( s > cnbr.scale ) { 
			cnbr.round(); 
			work = std.fmt.allocPrint(allocDcml,"{s}", .{std.mem.span(c.mpd_to_eng(cnbr.number, 0))})
				 catch unreachable;

			var iterB = iteratDcml.iterator(work);
			defer iterB.deinit();
			s = 0 ;  
			p =false;   
			while (iterB.next()) |ch|  {
				const x = utf.utf8Decode(ch) catch unreachable;
				switch (x) {
					'0'...'9' =>  { if (p ) s += 1 ; },
					'.' => p = true,
					else => {},
				}
			}
		}

		if ( cnbr.scale > 0 ) {
			var n : usize = cnbr.scale - s;
			result = std.fmt.allocPrint(allocDcml,"{s}", .{work}) catch unreachable;
			while (true) {
				if (n == 0) break;
				 if (!p) { result =  std.fmt.allocPrint(allocDcml,"{s}.", .{result}) catch unreachable; p =true;}
				 result  = std.fmt.allocPrint(allocDcml,"{s}0", .{result}) catch unreachable;
				 n -= 1;
			}
		
			return  result;
		}
		else return work ;
	}




	// function ADD
	pub fn add(a: DCMLFX ,b: DCMLFX) !void {
		if( a.isZeros()) {a.setZeros() ; return ;}
		c.mpd_add(a.number, a.number, b.number, &CTX_ADDR);
		a.isOverflow() catch | err | {
			if (err == dcmlError.isOverflow_entier) return err ;
		} ;
	}




	// function ADD
	pub fn addTo(r: DCMLFX , a: DCMLFX ,b: DCMLFX) !void {
		if( a.isZeros()) {r.setZeros() ; return ;}
		c.mpd_add(r.number, a.number, b.number, &CTX_ADDR);
		r.isOverflow() catch | err | {
			if (err == dcmlError.isOverflow_entier) return err ;
		} ;
	}




	// function SUB
	pub fn sub(a: DCMLFX ,b: DCMLFX) !void {
		if( a.isZeros()) {a.setZeros() ; return ;}
		c.mpd_sub(a.number, a.number, b.number, &CTX_ADDR);
		a.isOverflow() catch | err | {
			if (err == dcmlError.isOverflow_entier) return err ;
		} ;
	}




	// function SUB
	pub fn subTo(r: DCMLFX ,a: DCMLFX ,b: DCMLFX) !void {
		if( a.isZeros()) {r.setZeros() ; return ;}
		c.mpd_sub(r.number, a.number, b.number, &CTX_ADDR);
		r.isOverflow() catch | err | {
			if (err == dcmlError.isOverflow_entier) return err ;
		} ;
	}




	// function mult
	pub fn mult(a: DCMLFX ,b: DCMLFX) !void {
		if( a.isZeros()) {a.setZeros() ; return ;}
		c.mpd_mul(a.number, a.number, b.number, &CTX_ADDR);
		a.isOverflow() catch | err | {
			if (err == dcmlError.isOverflow_entier) return err ;
		} ;
	}




	// function mult
	pub fn multTo(r: DCMLFX ,a: DCMLFX ,b: DCMLFX) !void {
		if( a.isZeros()) {r.setZeros() ; return ;}
		c.mpd_mul(r.number, a.number, b.number, &CTX_ADDR,);
		r.isOverflow() catch | err | {
			if (err == dcmlError.isOverflow_entier) return err ;
		} ;
	}




	// function div
	pub fn div(a: DCMLFX ,b: DCMLFX) !void {
		if( b.isZeros()) return dcmlError.div_impossible_zeros;
		if( a.isZeros()) {a.setZeros() ; return ;}
		c.mpd_div(a.number, a.number, b.number, &CTX_ADDR);
		a.isOverflow() catch | err | {
			if (err == dcmlError.isOverflow_entier) return err ;
		} ;
	}




	// function mult
	pub fn divTo(r: DCMLFX ,a: DCMLFX ,b: DCMLFX) !void {
		if( b.isZeros()) return dcmlError.div_impossible_zeros;
		if( a.isZeros()) {r.setZeros() ; return ;}
		c.mpd_mul(r.number, a.number, b.number, &CTX_ADDR,);
		r.isOverflow() catch | err | {
			if (err == dcmlError.isOverflow_entier) return err ;
		} ;
	}




	// function Floor
	pub fn floor(r: DCMLFX ,a: DCMLFX) !void {
		if( a.isZeros()) {r.setZeros() ; return ;}
		c.mpd_floor(r.number, a.number,  &CTX_ADDR);
		r.isOverflow() catch | err | {
			if (err == dcmlError.isOverflow_entier) return err ;
		} ;
	}




	// function ceiling
	pub fn ceil(r: DCMLFX ,a: DCMLFX) !void {
		if( a.isZeros()) {r.setZeros() ; return ;}
		c.mpd_ceil(r.number, a.number,  &CTX_ADDR);
		r.isOverflow() catch | err | {
			if (err == dcmlError.isOverflow_entier) return err ;
		} ;
	}



	// function remainder
	pub fn rem(r: DCMLFX ,a: DCMLFX ,b: DCMLFX) !void {
		if( b.isZeros()) return dcmlError.div_impossible_zeros;
		if( a.isZeros()) {r.setZeros() ; return ;}
		c.mpd_rem(r.number, a.number, b.number, &CTX_ADDR);
		r.isOverflow() catch | err | {
			if (err == dcmlError.isOverflow_entier) return err ;
		} ;
	}




	// function val * nbr * coef   1*x * 1.25
	pub fn rate(res: DCMLFX ,val: DCMLFX , nbr: DCMLFX, coef:DCMLFX) !void {
		if( val.isZeros()) {res.setZeros() ; return ;}
		// total htx
		c.mpd_mul(res.number,val.number, nbr.number, &CTX_ADDR);
		// total ttc
		c.mpd_mul(res.number,res.number, coef.number, &CTX_ADDR);

	}




};	



	// Shows mode debug serious programming errors
	pub fn dsperr(errpgm :anyerror ) void { 
		const allocator = std.heap.page_allocator;
		const msgerr:[]const u8 = std.fmt.allocPrint(allocator,"To report: {any} ",.{errpgm }) catch unreachable; 
		@panic(msgerr);
	}

	// debug context
	pub fn debugContext() void {
		std.debug.print("{any}\n", .{CTX_ADDR});
	}

	// compare a , b returns EQ LT GT
	pub fn cmp(a: DCMLFX ,b: DCMLFX) ! CMP {
		const rep :  c_int  = c.mpd_cmp(a.number ,b.number, &CTX_ADDR);
		switch (rep) {
			-1 => return CMP.LT ,
			0  => return CMP.EQ ,
			1  => return CMP.GT ,
			else => return dcmlError.cmp_impossible
		}
	}

const iteratDcml = struct {
	var strbuf:[] const u8 = undefined;
		/// Errors that may occur when using String
		const ErrNbrch = error{
			InvalideAllocBuffer,
		};



		const Dcmliterator = struct {
			buf: []u8  ,
			index: usize ,

			fn allocBuffer ( size :usize) ErrNbrch![]u8 {
			 	const buf = allocDcml.alloc(u8, size) catch {
					return ErrNbrch.InvalideAllocBuffer;
				 };
				return buf;
			}

			        /// Deallocates the internal buffer
	        fn deinit(self: *Dcmliterator) void {
	            if (self.buf.len > 0) allocDcml.free(self.buf);
	            strbuf = "";
	            self.index =0;
	        }
	        


			fn next(it: *Dcmliterator) ?[]const u8 {
				const optional_buf: ?[]u8  = allocBuffer(strbuf.len) catch return null;

				it.buf= optional_buf orelse "";
				var n : usize = 0;
				while (true) {
					if (n >= strbuf.len) break;
					it.buf[n] = strbuf[n];
					n += 1;
				}

				if (it.index == it.buf.len) return null;
				const i = it.index;
				it.index += getUTF8Size(it.buf[i]);
				return it.buf[i..it.index];
			}

			fn preview(it: *Dcmliterator) ?[]const u8 {
				const optional_buf: ?[]u8  = allocBuffer(strbuf.len) catch return null;
				it.buf= optional_buf orelse "";
				var n : usize = 0;
				while (true) {
					if (n >= strbuf.len) break;
					it.buf[n] = strbuf[n];
					n += 1;
				}

				if (it.index == 0) return null;
				const i = it.buf.len;
				it.index -= getUTF8Size(it.buf[i]);
				return it.buf[i..it.index];
			}
		};

		/// iterator String
		fn iterator(str:[] const u8) Dcmliterator {
			strbuf = str;

			return Dcmliterator{
				.buf = undefined,
				.index = 0,
			};
		}

		/// Returns the UTF-8 character's size
		fn getUTF8Size(char: u8) u3 {
			return std.unicode.utf8ByteSequenceLength(char) catch {
			return 1;
			};
		}
	};

