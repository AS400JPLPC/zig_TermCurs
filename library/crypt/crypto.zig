	///-----------------------
	/// build crypto
	/// zi=g 0.12.0 dev
	///-----------------------


const std = @import("std");
const crypto = std.crypto;
const Ghash = std.crypto.onetimeauth.Ghash;
const math = std.math;
const mem = std.mem;
const modes = crypto.core.modes;
const AuthenticationError = crypto.errors.AuthenticationError;

/// référence https://github.com/ziglang/zig/blob/master/lib/std/crypto/aes_gcm.zig
/// thank you zig-lang

pub const Aes128Gcm = AesGcm(crypto.core.aes.Aes128);
pub const Aes256Gcm = AesGcm(crypto.core.aes.Aes256);

const random = std.crypto.random;

pub fn AesGcm(comptime Aes: anytype) type {

	return struct {
		pub const tag_length = 16;
		pub const nonce_length = 12;
		pub const key_length = Aes.key_bits / 8;

		const zeros = [_]u8{0} ** 16;
		/// `tag`: Authentication tag
		/// `ad`: Associated data
		/// `npub`: Public nonce
		/// `k`: Private key
		pub fn encrypt(c: [] u8, tag: *[tag_length]u8, m: []const u8,
						npub: [nonce_length]u8, key: [key_length]u8) void {

			const ad :[]u8 ="";
			const aes = Aes.initEnc(key);
			var h: [16]u8 = undefined;
			aes.encrypt(&h, &zeros);

			var t: [16]u8 = undefined;
			var j: [16]u8 = undefined;
			j[0..nonce_length].* = npub;
			mem.writeInt(u32, j[nonce_length..][0..4], 1, .big);
			aes.encrypt(&t, &j);

			const block_count = (math.divCeil(usize, ad.len, Ghash.block_length) catch unreachable) +
								(math.divCeil(usize, c.len, Ghash.block_length) catch unreachable) + 1;
			var mac = Ghash.initForBlockCount(&h, block_count);
			mac.update(ad);
			mac.pad();

			mem.writeInt(u32, j[nonce_length..][0..4], 2, .big);
			modes.ctr(@TypeOf(aes), aes, c, m, j, .big);
			mac.update(c[0..m.len][0..]);
			mac.pad();

			var final_block = h;
			mem.writeInt(u64, final_block[0..8], ad.len * 8, .big);
			mem.writeInt(u64, final_block[8..16], m.len * 8, .big);
			mac.update(&final_block);
			mac.final(tag);
			for (t, 0..) |x, i| {
				tag[i] ^= x;
			}
		}
		/// `tag`: Authentication tag
		/// `ad`: Associated data
		/// `npub`: Public nonce
		/// `k`: Private key
		pub fn decrypt(c: []u8, tag: [tag_length]u8, m: []u8,
						npub: [nonce_length]u8, key: [key_length]u8) AuthenticationError!void {

			const ad :[]u8 ="";
			const aes = Aes.initEnc(key);
			var h: [16]u8 = undefined;
			aes.encrypt(&h, &zeros);

			var t: [16]u8 = undefined;
			var j: [16]u8 = undefined;
			j[0..nonce_length].* = npub;
			mem.writeInt(u32, j[nonce_length..][0..4], 1, .big);
			aes.encrypt(&t, &j);

			const block_count = (math.divCeil(usize, ad.len, Ghash.block_length) catch unreachable) +
							 (math.divCeil(usize, c.len, Ghash.block_length) catch unreachable) + 1;
			var mac = Ghash.initForBlockCount(&h, block_count);
			mac.update(ad);
			mac.pad();

			mac.update(c);
			mac.pad();

			var final_block = h;
			mem.writeInt(u64, final_block[0..8], ad.len * 8, .big);
			mem.writeInt(u64, final_block[8..16], m.len * 8, .big);
			mac.update(&final_block);
			var computed_tag: [Ghash.mac_length]u8 = undefined;
			mac.final(&computed_tag);
			for (t, 0..) |x, i| {
				computed_tag[i] ^= x;
			}

			const verify = crypto.utils.timingSafeEql([tag_length]u8, computed_tag, tag);
			if (!verify) {
				crypto.utils.secureZero(u8, &computed_tag);
				@memset(m, undefined);
				return error.AuthenticationFailed;
			}

			mem.writeInt(u32, j[nonce_length..][0..4], 2, .big);
			modes.ctr(@TypeOf(aes), aes, m, c, j, .big);
		}
	};
}
