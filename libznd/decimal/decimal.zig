const std = @import("std");
const utf = @import("std").unicode;





const Error = error {
	Failed_Init_Entier_Scale,
	Failed_isNumber_string,
	Failed_Number,
	Overflow_number,
};


var arenaDcml = std.heap.ArenaAllocator.init(std.heap.page_allocator);
var allocDcml = arenaDcml.allocator();


pub const DCMLFX = struct {
		val  : f128 ,			 // number 
		entier  : u8 ,			 // Left  part of the number
		scale   : u8 ,			 // Right part of the number


	var result :[] u8 = undefined;
	var work:[] u8 = undefined ;

	pub const CMP = enum (u8) {
			  LT ,
			  EQ ,
			  GT ,
			  ERR,
	};
	//--------------------------------------------------------------
	// Definition ex: for management -> accounting, stock, order...
	//--------------------------------------------------------------
	pub fn deinitDcml() void {
	    arenaDcml.deinit();
	    arenaDcml = std.heap.ArenaAllocator.init(std.heap.page_allocator);
	    allocDcml = arenaDcml.allocator();
	}


/// Initialise un nombre décimal fixe avec une partie entière et une partie décimale spécifiées.
/// @param Entier : Nombre de chiffres pour la partie entière.
/// @param Scale : Nombre de chiffres pour la partie décimale.
/// @return : Une structure DCMLFX initialisée.
/// @panic : Si la somme de Entier et Scale dépasse 34 ou si les deux sont égaux à zéro.

	pub fn init(Entier: u8 , Scale : u8   ) DCMLFX {
		if ((Entier + Scale  > 34) or 
			( Entier == 0 and Scale == 0 ) ) { 
				const s = @src();
                @panic(std.fmt.allocPrint(allocDcml,
                "\n\n\r file:{s} line:{d} column:{d} func:{s}  err:{}  init({d},{d})\n\r"
                ,.{s.file, s.line, s.column,s.fn_name,Error.Failed_Init_Entier_Scale,Entier,Scale})
                		catch unreachable);
        }
		const snum  = DCMLFX {
			.val = 0 ,
			.entier = Entier ,
			.scale  = Scale,
		};

		return snum;
	}




	// Frees the storage memory of DCMLFX
	pub fn deinit(dst: *DCMLFX) void {
		if ( dst.entier == 0 and dst.scale == 0 ) return
		allocDcml.free(result);
		allocDcml.free(work);
		dst.entier = 0;
		dst.scale = 0;
		dst.val = 0;
	}


	// debug dcml val, entier,scale
	pub fn debugPrint(dst: *DCMLFX, txt : []const u8) void {
		std.debug.print("debug: {s} --> dcml:{d} entier:{d} scale:{d} \r\n", .{
			txt,
			dst.val, dst.entier, dst.scale});
	}


	// Check if it's a number
	pub fn isNumber (str :[] const u8) bool {
		if (std.mem.eql(u8, str, "") ) return false;

		var iter = iterator(str);
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

	// normalize this conforms to the attributes 
	fn normalize( dst : *DCMLFX, r: f128) [] u8 {
		var sx : []  u8 = "";
		var sign :u8 = ' ';
		if ( r > 0 ) sign = '+';
		if ( r < 0 ) sign = '-';
		const val  = if(r > 0 or r == 0 ) r else r * -1 ;

     	work = std.fmt.allocPrint(allocDcml,"{c}{d:}",.{sign,val}) catch unreachable;
		defer allocDcml.free(work);

		var nx: isize = 0 ;
		var p: bool = false;
		var iterX = iterator(work);
		defer iterX.deinit();
		while (iterX.next()) |ch|  {
			const x = utf.utf8Decode(ch) catch unreachable;
			switch (x) {
				'0'...'9' => sx = std.fmt.allocPrint(allocDcml, "{s}{s}",.{sx,ch}) catch unreachable,
				'.' => {
					if( dst.scale > 0)sx = std.fmt.allocPrint(allocDcml, "{s}{s}",.{sx,ch}) catch unreachable;
					p = true;
				},
				'-' => sx = std.fmt.allocPrint(allocDcml, "{s}{s}",.{sx,ch}) catch unreachable,
				'+' => sx = std.fmt.allocPrint(allocDcml, "{s}{s}",.{sx,ch}) catch unreachable,
				else => {} ,
			}
			
			if ( p ) nx += 1;
			if ( nx >  dst.scale) break;
		}
		defer allocDcml.free(sx);
		return  allocDcml.dupe(u8, sx) catch unreachable;
	}


	
/// Vérifie si la partie entière de la valeur décimale dépasse les limites définies.
/// Cette fonction doit être appelée avant de sortir la valeur pour s'assurer qu'elle respecte les contraintes définies.
/// @param dst : Pointeur vers le nombre décimal à vérifier.
/// @return : true si la partie entière dépasse les limites, false sinon.

	pub fn isOverflow (dst: *DCMLFX) bool {
		if ( dst.entier == 0 and dst.scale == 0 ) {
			const s = @src();
            @panic( std.fmt.allocPrint(allocDcml,
            "\n\n\r file:{s} line:{d} column:{d} func:{s}({d}) out-of-service FIELD err:{}\n\r"
            ,.{s.file, s.line, s.column,s.fn_name,dst.val, Error.Failed_Number})
            	catch unreachable);
        }

		work = std.fmt.allocPrint(allocDcml, "{d}",.{dst.val}) catch unreachable;
		defer allocDcml.free(work);
		var iter = iterator(work);
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
		if (dst.entier < e ) return true
		else return false;
	}



	// You are responsible for the value.
	pub fn setDcml(dst: *DCMLFX, str: [] const u8)  void {
		if ( dst.entier == 0 and dst.scale == 0 ) {
			const s = @src();
            @panic( std.fmt.allocPrint(allocDcml,
            "\n\n\r file:{s} line:{d} column:{d} func:{s}({d},{s}) out-of-service FIELD err:{}\n\r"
            ,.{s.file, s.line, s.column,s.fn_name,dst.val,str, Error.Failed_Number})
            	catch unreachable);
        }

		if (!isNumber(str)) { 
				const s = @src();
                @panic( std.fmt.allocPrint(allocDcml,
                "\n\n\r file:{s} line:{d} column:{d} func:{s}({s})  err:{}  \n\r"
                ,.{s.file, s.line, s.column,s.fn_name, str, Error.Failed_isNumber_string})
                	catch unreachable);
        }

		dst.val = std.fmt.parseFloat(f128,str) catch unreachable;
		if(dst.isOverflow()) { 
				const s = @src();
                @panic( std.fmt.allocPrint(allocDcml,
                "\n\n\r file:{s} line:{d} column:{d} func:{s}({d})  err:{}  MAX_entier:{d}\n\r"
                ,.{s.file, s.line, s.column,s.fn_name,dst.val,Error.Overflow_number, dst.entier})
                	catch unreachable);
        }
	}

	// You are responsible for the value.
	pub fn set(dst: *DCMLFX, n: f128)  void {
		if ( dst.entier == 0 and dst.scale == 0 ) {
			const s = @src();
            @panic( std.fmt.allocPrint(allocDcml,
            "\n\n\r file:{s} line:{d} column:{d} func:{s}({d},{d}) out-of-service FIELD err:{}\n\r"
            ,.{s.file, s.line, s.column,s.fn_name,dst.val,n, Error.Failed_Number})
            	catch unreachable);
        }

		dst.val = n;
	}

	// setZeros and add B.
	pub fn zadd(dst: *DCMLFX ,src: DCMLFX) void {
		if ( (dst.entier == 0 and dst.scale == 0) or ( src.entier == 0 and src.scale == 0) ) {
			const s = @src();
            @panic( std.fmt.allocPrint(allocDcml,
            "\n\n\r file:{s} line:{d} column:{d} func:{s}({d},{d}) out-of-service FIELD err:{}\n\r"
            ,.{s.file, s.line, s.column,s.fn_name,dst.val,src.val, Error.Failed_Number})
            	catch unreachable);
        }
		dst.val = src.val;
		if(dst.isOverflow()) { 
			const s = @src();
	        @panic( std.fmt.allocPrint(allocDcml,
	        "\n\n\r file:{s} line:{d} column:{d} func:{s}({d:.0}) err:{}  MAX_entier:{d} \n\r"
	        ,.{s.file, s.line, s.column,s.fn_name,dst.val,Error.Overflow_number,dst.entier })
	        	catch unreachable);
        }
    }


	// set "0" 
	pub fn setZeros(dst: *DCMLFX) void {
		if ( dst.entier == 0 and dst.scale == 0 ) {
			const s = @src();
            @panic( std.fmt.allocPrint(allocDcml,
            "\n\n\r file:{s} line:{d} column:{d} func:{s}({d}) out-of-service FIELD err:{}\n\r"
            ,.{s.file, s.line, s.column,s.fn_name,dst.val, Error.Failed_Number})
            	catch unreachable);
        }

		dst.val = 0;
	}




	// isZeros 
	pub fn isZeros(dst: DCMLFX) bool{
		if ( dst.entier == 0 and dst.scale == 0 ) {
			const s = @src();
            @panic( std.fmt.allocPrint(allocDcml,
            "\n\n\r file:{s} line:{d} column:{d} func:{s}({d}) out-of-service FIELD err:{}\n\r"
            ,.{s.file, s.line, s.column,s.fn_name,dst.val, Error.Failed_Number})
            	catch unreachable);
        }

		if ( 0 == dst.val or 0.0 == dst.val) return true 
		else return false;
	}




	// ARRONDI comptable / commercial
	// round and truncate  5 => + 1
	pub fn round(dst: *DCMLFX) void {
		if ( dst.entier == 0 and dst.scale == 0 ) {
			const s = @src();
            @panic( std.fmt.allocPrint(allocDcml,
            "\n\n\r file:{s} line:{d} column:{d} func:{s}({d}) out-of-service FIELD err:{}\n\r"
            ,.{s.file, s.line, s.column,s.fn_name,dst.val, Error.Failed_Number})
            	catch unreachable);
        }

		var r: f128 = dst.val;
		var i : usize = 1;
		const m: c_int = 10;

		while( i <= dst.scale) : (i += 1) {
			r *=  m ;
		}

		work = std.fmt.allocPrint(allocDcml, "{d:.1}",.{r}) catch unreachable;
		defer allocDcml.free(work);
		r = std.fmt.parseFloat(f128, work) catch unreachable ;
		i = work.len - 1  ;
		if (work[i] < 53 and work[i - 2] < 53) r +=0.1 else r =@round(r);

		i = 1;
		while( i <= dst.scale) : (i += 1) {
			r =  r/m ;
		}
		dst.val = r;
	}

	pub fn roundTo(dst: *DCMLFX, a: DCMLFX) void {
		if ( (dst.entier == 0 and dst.scale == 0) or ( a.entier == 0 and a.scale == 0) ) {
			const s = @src();
            @panic( std.fmt.allocPrint(allocDcml,
            "\n\n\r file:{s} line:{d} column:{d} func:{s}({d},{d}) out-of-service FIELD err:{}\n\r"
            ,.{s.file, s.line, s.column,s.fn_name,dst.val,a.val, Error.Failed_Number})
            	catch unreachable);
        }

		var r: f128 = a.val;

		var i : usize  = 1;
		const m: c_int = 10;
		while( i <= dst.scale) : (i += 1) {
			r *=  m ;
		}

		work = std.fmt.allocPrint(allocDcml, "{d:.0}",.{r}) catch unreachable;
		defer allocDcml.free(work);
		
		r = std.fmt.parseFloat(f128, work) catch unreachable;
		i = work.len - 1  ;
		if (work[i] < 53 and work[i - 2] < 53) r +=0.1 else r =@round(r);

		i = 1;
		while( i <= dst.scale) : (i += 1) {
			r /= m;
		}
		dst.val = r;
	}





	// truncate without rounding 
	pub fn trunc(dst: *DCMLFX) void {
		if ( dst.entier == 0 and dst.scale == 0 ) {
			const s = @src();
            @panic( std.fmt.allocPrint(allocDcml,
            "\n\n\r file:{s} line:{d} column:{d} func:{s}({d}) out-of-service FIELD err:{}\n\r"
            ,.{s.file, s.line, s.column,s.fn_name,dst.val, Error.Failed_Number})
            	catch unreachable);
        }

		var r: f128 = dst.val;
		var i : i128 = 1;
		const m: c_int = 10;
		while( i <= dst.scale) : (i += 1) {
				r *=  m ;
		}
		
		work = normalize(dst , r );
		defer allocDcml.free(work);
		i = 1;
		r = std.fmt.parseFloat(f128, work) catch unreachable;
		while( i <= dst.scale) : (i += 1) {
			r /= m;
		}
		dst.val = r;
	}

	
	pub fn truncTo(dst: *DCMLFX, a : DCMLFX) void {
		if ( (dst.entier == 0 and dst.scale == 0) or ( a.entier == 0 and a.scale == 0) ) {
			const s = @src();
            @panic( std.fmt.allocPrint(allocDcml,
            "\n\n\r file:{s} line:{d} column:{d} func:{s}({d},{d}) out-of-service FIELD err:{}\n\r"
            ,.{s.file, s.line, s.column,s.fn_name,dst.val,a.val, Error.Failed_Number})
            	catch unreachable);
        }
		var r: f128 = a.val;
		var i : usize = 1;
		const m: c_int = 10;

		while( i <= dst.scale) : (i += 1) {
			r *=  m ;
		}
		work = normalize(dst , r );
		defer allocDcml.free(work);
		i = 1;
		r = std.fmt.parseFloat(f128, work) catch unreachable;
		while( i <= dst.scale) : (i += 1) {
			r /= m;
		}
		dst.val = r;		dst.val = r;

	}

/// Normalise la valeur décimale en respectant les attributs définis (entier et scale).
/// Cette fonction doit être appelée avant de sortir la valeur pour s'assurer qu'elle respecte les contraintes définies.
/// @param dst : Pointeur vers le nombre décimal à normaliser.
/// @return : Une chaîne de caractères représentant la valeur normalisée.
// Returns a formatted string for gestion, statistique ...
	pub fn string(dst: *DCMLFX ) [] const u8 {
        if ( dst.entier == 0 and dst.scale == 0 ) {
			const s = @src();
            @panic( std.fmt.allocPrint(allocDcml,
            "\n\n\r file:{s} line:{d} column:{d} func:{s}({d}) out-of-service FIELD err:{}\n\r"
            ,.{s.file, s.line, s.column,s.fn_name,dst.val, Error.Failed_Number})
            	catch unreachable);
        }

		if(dst.isOverflow()) { 
				const s = @src();
                @panic( std.fmt.allocPrint(allocDcml,
                "\n\n\r file:{s} line:{d} column:{d} func:{s}({d:.0}) err:{}   MAX_entier:{d} \n\r"
                ,.{s.file, s.line, s.column,s.fn_name,dst.val,Error.Overflow_number, dst.entier})
                    catch unreachable);
        }

        work = normalize(dst , dst.val );
		defer allocDcml.free(work);

		var iterA = iterator(work);
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
		if ( s > dst.scale ) {
			var iterB = iterator(work);
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

		result = allocDcml.dupe(u8, work) catch unreachable;
		defer allocDcml.free(result);

		if ( dst.scale > 0 ) {
			var n : usize = dst.scale - s;
			while (true) {
				if (n == 0) break;
				 if (!p) { result =  std.fmt.allocPrint(allocDcml,"{s}.", .{result}) catch unreachable; p =true;}
				 result  = std.fmt.allocPrint(allocDcml,"{s}0", .{result}) catch unreachable;
				 n -= 1;
			}
		}
		return allocDcml.dupe(u8, result) catch unreachable;
	}

	// It's not SQL-compliant, but it's handy for paper editions...
	pub fn editCodeFlt( dst: *DCMLFX, comptime  CODE_EDIT : []const u8)  [] const u8 {
		var PRINT_CODE: []const u8 = undefined;
		const v : f128 = if(dst.val > 0) dst.val else dst.val  * -1;
		const m: c_int = 10;

		const e = @trunc(v);
		
		var r = v - e;

		var i : i128 = 1;
		while( i <= dst.scale) : (i += 1) {
				r *=  m ;
		}
		r = @trunc(r);

		if ( dst.val == 0 ) PRINT_CODE = std.fmt.allocPrint(allocDcml, CODE_EDIT,.{' ',e,r}) catch unreachable;
		if ( dst.val > 0 )  PRINT_CODE = std.fmt.allocPrint(allocDcml, CODE_EDIT,.{'+',e,r}) catch unreachable;
		if ( dst.val < 0 )  PRINT_CODE = std.fmt.allocPrint(allocDcml, CODE_EDIT,.{'-',e,r}) catch unreachable;
		return PRINT_CODE;
	}


	// It's not SQL-compliant, but it's handy for paper editions...
	pub fn editCodeInt( dst: *DCMLFX, comptime  CODE_EDIT : []const u8 )  [] const u8 {
		var PRINT_CODE: []const u8 = undefined;
		const v : f128 = if(dst.val > 0) dst.val else dst.val  * -1;
		const e = @trunc(v);
		if ( dst.val == 0 ) PRINT_CODE = std.fmt.allocPrint(allocDcml, CODE_EDIT,.{' ',e}) catch unreachable;
		if ( dst.val > 0 )  PRINT_CODE = std.fmt.allocPrint(allocDcml, CODE_EDIT,.{'+',e}) catch unreachable;
		if ( dst.val < 0 )  PRINT_CODE = std.fmt.allocPrint(allocDcml, CODE_EDIT,.{'-',e}) catch unreachable;
		    return PRINT_CODE;
	}


	
	// function ADD
	pub fn add(dst: *DCMLFX ,a: DCMLFX) void {
		if ( (dst.entier == 0 and dst.scale == 0) or ( a.entier == 0 and a.scale == 0) ) {
			const s = @src();
            @panic( std.fmt.allocPrint(allocDcml,
            "\n\n\r file:{s} line:{d} column:{d} func:{s}({d},{d}) out-of-service FIELD err:{}\n\r"
            ,.{s.file, s.line, s.column,s.fn_name,dst.val,a.val, Error.Failed_Number})
            	catch unreachable);
        }
		dst.val += a.val;
	}
	pub fn @"+"(dst: *DCMLFX ,n: f128) void {
		if ( dst.entier == 0 and dst.scale == 0 ) {
			const s = @src();
            @panic( std.fmt.allocPrint(allocDcml,
            "\n\n\r file:{s} line:{d} column:{d} func:{s}({d},{d}) out-of-service FIELD err:{}\n\r"
            ,.{s.file, s.line, s.column,s.fn_name,dst.val,n, Error.Failed_Number})
            	catch unreachable);
        }
 
		dst.val += n;
	}



	// function ADD
	pub fn addTo(dst: *DCMLFX , a: DCMLFX ,b: DCMLFX) void {
		if ( (dst.entier == 0 and dst.scale == 0) or
			 ( a.entier == 0 and a.scale == 0)  or
			 ( b.entier == 0 and b.scale == 0)  ) {
			const s = @src();
            @panic( std.fmt.allocPrint(allocDcml,
            "\n\n\r file:{s} line:{d} column:{d} func:{s}({d},{d},{d}) out-of-service FIELD err:{}\n\r"
            ,.{s.file, s.line, s.column,s.fn_name,dst.val,a.val,b.val, Error.Failed_Number})
            	catch unreachable);
        }
		dst.val = a.val + b.val;
	}




	// function SUB
	pub fn sub(dst: *DCMLFX ,a: DCMLFX) void {
		if ( (dst.entier == 0 and dst.scale == 0) or ( a.entier == 0 and a.scale == 0) ) {
			const s = @src();
            @panic( std.fmt.allocPrint(allocDcml,
            "\n\n\r file:{s} line:{d} column:{d} func:{s}({d},{d}) out-of-service FIELD err:{}\n\r"
            ,.{s.file, s.line, s.column,s.fn_name,dst.val,a.val, Error.Failed_Number})
            	catch unreachable);
        }

		dst.val -= a.val;
	}
	pub fn @"-"(dst: *DCMLFX ,n: f128) void {
		if ( dst.entier == 0 and dst.scale == 0 ) {
			const s = @src();
            @panic( std.fmt.allocPrint(allocDcml,
            "\n\n\r file:{s} line:{d} column:{d} func:{s}({d},{d}) out-of-service FIELD err:{}\n\r"
            ,.{s.file, s.line, s.column,s.fn_name,dst.val,n, Error.Failed_Number})
            	catch unreachable);
        }
		dst.val -= n;
	}



	// function SUB
	pub fn subTo(dst: *DCMLFX ,a: DCMLFX ,b: DCMLFX) void {
		if ( (dst.entier == 0 and dst.scale == 0) or
			 ( a.entier == 0 and a.scale == 0)  or
			 ( b.entier == 0 and b.scale == 0)  ) {
			const s = @src();
            @panic( std.fmt.allocPrint(allocDcml,
            "\n\n\r file:{s} line:{d} column:{d} func:{s}({d},{d},{d}) out-of-service FIELD err:{}\n\r"
            ,.{s.file, s.line, s.column,s.fn_name,dst.val,a.val,b.val, Error.Failed_Number})
            	catch unreachable);
        }
        dst.val = a.val - b.val;
	}




	// function mult
	pub fn mult(dst: *DCMLFX ,a: DCMLFX) void {
		if ( (dst.entier == 0 and dst.scale == 0) or ( a.entier == 0 and a.scale == 0) ) {
			const s = @src();
            @panic( std.fmt.allocPrint(allocDcml,
            "\n\n\r file:{s} line:{d} column:{d} func:{s}({d},{d}) out-of-service FIELD err:{}\n\r"
            ,.{s.file, s.line, s.column,s.fn_name,dst.val,a.val, Error.Failed_Number})
            	catch unreachable);
        }
		dst.val *= a.val;
	}

	pub fn @"*"(dst: *DCMLFX , n: f128) void {
		if ( dst.entier == 0 and dst.scale == 0 ) {
			const s = @src();
            @panic( std.fmt.allocPrint(allocDcml,
            "\n\n\r file:{s} line:{d} column:{d} func:{s}({d},{d}) out-of-service FIELD err:{}\n\r"
            ,.{s.file, s.line, s.column,s.fn_name,dst.val,n, Error.Failed_Number})
            	catch unreachable);
        }

		dst.val *= n;
	}



	// function mult
	pub fn multTo(dst: *DCMLFX ,a: DCMLFX ,b: DCMLFX) void {
		if ( (dst.entier == 0 and dst.scale == 0) or
			 ( a.entier == 0 and a.scale == 0)  or
			 ( b.entier == 0 and b.scale == 0)  ) {
			const s = @src();
            @panic( std.fmt.allocPrint(allocDcml,
            "\n\n\r file:{s} line:{d} column:{d} func:{s}({d},{d},{d}) out-of-service FIELD err:{}\n\r"
            ,.{s.file, s.line, s.column,s.fn_name,dst.val,a.val,b.val, Error.Failed_Number})
            	catch unreachable);
        }

		dst.val = a.val * b.val;
	}



	// function div
	pub fn div(dst: *DCMLFX ,a: DCMLFX) bool {
		if ( (dst.entier == 0 and dst.scale == 0) or ( a.entier == 0 and a.scale == 0) ) {
			const s = @src();
            @panic( std.fmt.allocPrint(allocDcml,
            "\n\n\r file:{s} line:{d} column:{d} func:{s}({d},{d}) out-of-service FIELD err:{}\n\r"
            ,.{s.file, s.line, s.column,s.fn_name,dst.val, a.val, Error.Failed_Number})
            	catch unreachable);
        }
        if (a.val == 0 or a.val == 0.0) return false;

		dst.val /= a.val;
		return true;
	}

	pub fn @"/"(dst: *DCMLFX , n: f128) bool {
		if ( dst.entier == 0 and dst.scale == 0 ) {
			const s = @src();
            @panic( std.fmt.allocPrint(allocDcml,
            "\n\n\r file:{s} line:{d} column:{d} func:{s}({d},{d}) out-of-service FIELD err:{}\n\r"
            ,.{s.file, s.line, s.column,s.fn_name,dst.val,n, Error.Failed_Number})
            	catch unreachable);
        }

		if (n == 0 or n == 0.0) return false;

		dst.val /= n;
		return true;
	}
	

	// function div
	pub fn divTo(dst: *DCMLFX ,a: DCMLFX ,b: DCMLFX) bool {
		if ( (dst.entier == 0 and dst.scale == 0) or
			 ( a.entier == 0 and a.scale == 0)  or
			 ( b.entier == 0 and b.scale == 0)  ) {
			const s = @src();
            @panic( std.fmt.allocPrint(allocDcml,
            "\n\n\r file:{s} line:{d} column:{d} func:{s}({d},{d},{d}) out-of-service FIELD err:{}\n\r"
            ,.{s.file, s.line, s.column,s.fn_name,dst.val, a.val,b.val, Error.Failed_Number})
            	catch unreachable);
        }

		if (b.val == 0 or b.val == 0.0) return false;

		dst.val = a.val / b.val;
		return true;
	}


	// // function Floor
	pub fn floor(dst: *DCMLFX) void {
		if ( dst.entier == 0 and dst.scale == 0 ) {
			const s = @src();
            @panic( std.fmt.allocPrint(allocDcml,
            "\n\n\r file:{s} line:{d} column:{d} func:{s}({d}) out-of-service FIELD err:{}\n\r"
            ,.{s.file, s.line, s.column,s.fn_name,dst.val, Error.Failed_Number})
            	catch unreachable);
        } 
		dst.val = @floor(dst.val);
	}



	// // function ceiling
	pub fn ceil(dst: *DCMLFX) void {
		if ( dst.entier == 0 and dst.scale == 0 ) {
			const s = @src();
            @panic( std.fmt.allocPrint(allocDcml,
            "\n\n\r file:{s} line:{d} column:{d} func:{s}({d}) out-of-service FIELD err:{}\n\r"
            ,.{s.file, s.line, s.column,s.fn_name,dst.val, Error.Failed_Number})
            	catch unreachable);
        }
		dst.val = @ceil(dst.val);
	}

/// exemple division par zeros
/// Calcule le reste de la division de deux nombres décimaux fixes.
/// @param dst : Pointeur vers le nombre décimal de destination.
/// @param a : Nombre décimal dividende.
/// @param b : Nombre décimal diviseur.
/// @return : true si l'opération a réussi, false si b est égal à zéro.
	pub fn rem(dst: *DCMLFX ,a: DCMLFX ,b: DCMLFX) bool {
		if ( (dst.entier == 0 and dst.scale == 0) or
			 ( a.entier == 0 and a.scale == 0)  or
			 ( b.entier == 0 and b.scale == 0)  ) {
			const s = @src();
            @panic( std.fmt.allocPrint(allocDcml,
            "\n\n\r file:{s} line:{d} column:{d} func:{s}({d},{d},{d}) out-of-service FIELD err:{}\n\r"
            ,.{s.file, s.line, s.column,s.fn_name,dst.val, a.val, b.val, Error.Failed_Number})
            	catch unreachable);
        }

		if (b.val == 0 ) return false;
		dst.val = @rem(a.val , b.val);
		return true;
	}


	// function calculation of percentage
	pub fn getpercent(dst: *DCMLFX ,a: DCMLFX , b: DCMLFX) bool {
		if ( (dst.entier == 0 and dst.scale == 0) or
			 ( a.entier == 0 and a.scale == 0)  or
			 ( b.entier == 0 and b.scale == 0)  ) {
			const s = @src();
            @panic( std.fmt.allocPrint(allocDcml,
            "\n\n\r file:{s} line:{d} column:{d} func:{s}({d},{d},{d}) out-of-service FIELD err:{}\n\r"
            ,.{s.file, s.line, s.column,s.fn_name,dst.val,a.val,b.val, Error.Failed_Number})
            	catch unreachable);
        }

		if (b.isZeros()) return false;
		var r : f128 = 0;
		r = a.val / b.val;
		r *= 100;
		dst.val = r;
		return true;
	}

	// function calculation of percentage
	pub fn percent(dst: *DCMLFX ,a: DCMLFX , perct: DCMLFX) bool {
		if ( (dst.entier == 0 and dst.scale == 0) or ( a.entier == 0 and a.scale == 0) ) {
			const s = @src();
            @panic( std.fmt.allocPrint(allocDcml,
            "\n\n\r file:{s} line:{d} column:{d} func:{s}({d}, {d},{d}) out-of-service FIELD err:{}\n\r"
            ,.{s.file, s.line, s.column,s.fn_name,dst.val,a.val,perct.val, Error.Failed_Number})
            	catch unreachable);
        }

		if (perct.isZeros()) return false;
		dst.val = a.val * perct.val;
		dst.val /= 100;
		return true;
	}

	// function val * nbr * coef   1*x * 1.25
	pub fn rate(dst: *DCMLFX ,val: DCMLFX , nbr: DCMLFX, coef:DCMLFX) void {
		if ( (dst.entier == 0 and dst.scale == 0) or
			 ( val.entier == 0 and val.scale == 0) or
			 ( nbr.entier == 0 and nbr.scale == 0) or
			 ( coef.entier == 0 and coef.scale == 0) ) {
			const s = @src();
            @panic( std.fmt.allocPrint(allocDcml,
            "\n\n\r file:{s} line:{d} column:{d} func:{s}({d}) out-of-service FIELD err:{}\n\r"
            ,.{s.file, s.line, s.column,s.fn_name,dst.val, Error.Failed_Number})
            	catch unreachable);
        }
		var r : f128 = 0;
		// total htx
		dst.val = val.val *  nbr.val;
		// total ttx
		r  = (dst.val * coef.val) / 100;
		// total ttc
		dst.val += r;
	}

	// compare a , b returns EQ LT GT
	pub fn cmp(a: DCMLFX ,b: DCMLFX) CMP {
		if ( (a.entier == 0 and a.scale == 0) or ( b.entier == 0 and b.scale == 0) ) {
			const s = @src();
            @panic( std.fmt.allocPrint(allocDcml,
            "\n\n\r file:{s} line:{d} column:{d} func:{s}({d} ,{d}) out-of-service FIELD err:{}\n\r"
            ,.{s.file, s.line, s.column,s.fn_name,a.val,b.val, Error.Failed_Number})
            	catch unreachable);
        }
		const rep :  c_int  = if (a.val < b.val ) -1 else if (a.val > b.val ) 1 else 0 ;
		switch (rep) {
			-1 => return CMP.LT ,
			0  => return CMP.EQ ,
			1  => return CMP.GT ,
		  else => return CMP.ERR,
		}
	}



	pub const Expr = union(enum) {
	    Val: f128,
	    Add: Payload,
	    Div: Payload,
	    Sub: Payload,
	    Mul: Payload,
	};

	pub const Payload = struct {
	    left: *const Expr,
	    right: *const Expr,
	};


	pub fn eval(e: *const Expr) f128 {
	    return switch (e.*) {
	        Expr.Val => |v| v,
	        Expr.Add => |a| eval(a.left) + eval(a.right),
	        Expr.Sub => |s| eval(s.left) - eval(s.right),
	        Expr.Mul => |m| eval(m.left) * eval(m.right),
	        Expr.Div => |d| return if (eval(d.right) == 0) return std.math.nan(f128) else eval(d.left) / eval(d.right),

	    };
	}


	fn show_helper(expr: *const Payload, expr_name: []const u8, stdout: *const @TypeOf(std.io.getStdOut().writer())) anyerror!void {
	    try stdout.print("{s}", .{expr_name});
	    try show(expr.left, stdout);
	    try stdout.print(", ", .{});
	    try show(expr.right, stdout);
	    try stdout.print(")", .{});
	}
	pub fn show(e: *const Expr, stdout: *const @TypeOf(std.io.getStdOut().writer())) anyerror !void {
	    switch (e.*) {
	        Expr.Val => |n| try stdout.print("Val {d}", .{n}),
	        Expr.Add => |a| try show_helper(&a, "Add (", stdout),
	        Expr.Sub => |s| try show_helper(&s, "Sub (", stdout),
	        Expr.Mul => |m| try show_helper(&m, "Mul (", stdout),
	        Expr.Div => |d| try show_helper(&d, "Div (", stdout),
	    }
	}





};

		const DcmlIterator = struct {
			buf: []u8  ,
			index: usize ,

			        /// Deallocates the internal buffer
	        fn deinit(self: *DcmlIterator) void {
	            if (self.buf.len > 0) allocDcml.free(self.buf);
	            self.index =0;
	        }
	        


			fn next(it: *DcmlIterator) ?[]const u8 {
				if ( it.buf.len == 0 ) return null;

				if (it.index == it.buf.len) return null;
				const i = it.index;
				it.index += getUTF8Size(it.buf[i]);
				return it.buf[i..it.index];
			}

		};

		/// iterator String
		fn iterator(str:[] const u8) DcmlIterator {
			return DcmlIterator{
				.buf = allocDcml.dupe(u8,str) catch unreachable,
				.index = 0,
			};
		}

		/// Returns the UTF-8 character's size
		fn getUTF8Size(char: u8) u3 {
			return std.unicode.utf8ByteSequenceLength(char) catch {
			return 1;
			};
		}

