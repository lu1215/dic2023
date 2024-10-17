// 
// Designer: N26124264
// 盧尚毅
//
module AES(
    input clk,
    input rst,
    input [127:0] P,
    input [127:0] K,
    output reg [127:0] C,
    output reg valid
    // // test output
    // output [127:0] p_reg_test,
    // output [127:0] k_reg_test
    );

// write your design here //
// parameter 
// IDLE = 0,
// ADD_ROUND_KEY = 1,
// SUB_BYTES = 2,
// SHIFT_ROWS = 3,
// MIX_COLUMNS = 4;

// gf multiplication //
function [7:0] gf_2_8_mul;
    input [7:0] i;
    input [7:0] j;
    reg [7:0] gf_2_mul;
    reg [9:0] mul_ans;
    begin
        // output [7:0] o
        mul_ans = j << 1;
        gf_2_mul = (mul_ans[8] == 1'b1)? (mul_ans[7:0] ^ {8'b00011011}) : mul_ans[7:0];
        gf_2_8_mul = (i == 8'd2)? gf_2_mul: (i == 8'd3) ? gf_2_mul ^ j : j;
    end
endfunction

// lookup table 1d array //
// reg [7:0] lookup_table[255:0];
// initial begin
//     lookup_table[0] =8'h63; lookup_table[1] =8'h7c; lookup_table[2] =8'h77; lookup_table[3] =8'h7b; lookup_table[4] =8'hf2; lookup_table[5] =8'h6b; lookup_table[6] =8'h6f; lookup_table[7] =8'hc5; lookup_table[8] =8'h30; lookup_table[9] =8'h01; lookup_table[10] =8'h67; lookup_table[11] =8'h2b; lookup_table[12] =8'hfe; lookup_table[13] =8'hd7; lookup_table[14] =8'hab; lookup_table[15] =8'h76;
//     lookup_table[16] =8'hca; lookup_table[17] =8'h82; lookup_table[18] =8'hc9; lookup_table[19] =8'h7d; lookup_table[20] =8'hfa; lookup_table[21] =8'h59; lookup_table[22] =8'h47; lookup_table[23] =8'hf0; lookup_table[24] =8'had; lookup_table[25] =8'hd4; lookup_table[26] =8'ha2; lookup_table[27] =8'haf; lookup_table[28] =8'h9c; lookup_table[29] =8'ha4; lookup_table[30] =8'h72; lookup_table[31] =8'hc0;
//     lookup_table[32] =8'hb7; lookup_table[33] =8'hfd; lookup_table[34] =8'h93; lookup_table[35] =8'h26; lookup_table[36] =8'h36; lookup_table[37] =8'h3f; lookup_table[38] =8'hf7; lookup_table[39] =8'hcc; lookup_table[40] =8'h34; lookup_table[41] =8'ha5; lookup_table[42] =8'he5; lookup_table[43] =8'hf1; lookup_table[44] =8'h71; lookup_table[45] =8'hd8; lookup_table[46] =8'h31; lookup_table[47] =8'h15;
//     lookup_table[48] =8'h04; lookup_table[49] =8'hc7; lookup_table[50] =8'h23; lookup_table[51] =8'hc3; lookup_table[52] =8'h18; lookup_table[53] =8'h96; lookup_table[54] =8'h05; lookup_table[55] =8'h9a; lookup_table[56] =8'h07; lookup_table[57] =8'h12; lookup_table[58] =8'h80; lookup_table[59] =8'he2; lookup_table[60] =8'heb; lookup_table[61] =8'h27; lookup_table[62] =8'hb2; lookup_table[63] =8'h75;
//     lookup_table[64] =8'h09; lookup_table[65] =8'h83; lookup_table[66] =8'h2c; lookup_table[67] =8'h1a; lookup_table[68] =8'h1b; lookup_table[69] =8'h6e; lookup_table[70] =8'h5a; lookup_table[71] =8'ha0; lookup_table[72] =8'h52; lookup_table[73] =8'h3b; lookup_table[74] =8'hd6; lookup_table[75] =8'hb3; lookup_table[76] =8'h29; lookup_table[77] =8'he3; lookup_table[78] =8'h2f; lookup_table[79] =8'h84;
//     lookup_table[80] =8'h53; lookup_table[81] =8'hd1; lookup_table[82] =8'h00; lookup_table[83] =8'hed; lookup_table[84] =8'h20; lookup_table[85] =8'hfc; lookup_table[86] =8'hb1; lookup_table[87] =8'h5b; lookup_table[88] =8'h6a; lookup_table[89] =8'hcb; lookup_table[90] =8'hbe; lookup_table[91] =8'h39; lookup_table[92] =8'h4a; lookup_table[93] =8'h4c; lookup_table[94] =8'h58; lookup_table[95] =8'hcf;
//     lookup_table[96] =8'hd0; lookup_table[97] =8'hef; lookup_table[98] =8'haa; lookup_table[99] =8'hfb; lookup_table[100] =8'h43; lookup_table[101] =8'h4d; lookup_table[102] =8'h33; lookup_table[103] =8'h85; lookup_table[104] =8'h45; lookup_table[105] =8'hf9; lookup_table[106] =8'h02; lookup_table[107] =8'h7f; lookup_table[108] =8'h50; lookup_table[109] =8'h3c; lookup_table[110] =8'h9f; lookup_table[111] =8'ha8;
//     lookup_table[112] =8'h51; lookup_table[113] =8'ha3; lookup_table[114] =8'h40; lookup_table[115] =8'h8f; lookup_table[116] =8'h92; lookup_table[117] =8'h9d; lookup_table[118] =8'h38; lookup_table[119] =8'hf5; lookup_table[120] =8'hbc; lookup_table[121] =8'hb6; lookup_table[122] =8'hda; lookup_table[123] =8'h21; lookup_table[124] =8'h10; lookup_table[125] =8'hff; lookup_table[126] =8'hf3; lookup_table[127] =8'hd2;
//     lookup_table[128] =8'hcd; lookup_table[129] =8'h0c; lookup_table[130] =8'h13; lookup_table[131] =8'hec; lookup_table[132] =8'h5f; lookup_table[133] =8'h97; lookup_table[134] =8'h44; lookup_table[135] =8'h17; lookup_table[136] =8'hc4; lookup_table[137] =8'ha7; lookup_table[138] =8'h7e; lookup_table[139] =8'h3d; lookup_table[140] =8'h64; lookup_table[141] =8'h5d; lookup_table[142] =8'h19; lookup_table[143] =8'h73;
//     lookup_table[144] =8'h60; lookup_table[145] =8'h81; lookup_table[146] =8'h4f; lookup_table[147] =8'hdc; lookup_table[148] =8'h22; lookup_table[149] =8'h2a; lookup_table[150] =8'h90; lookup_table[151] =8'h88; lookup_table[152] =8'h46; lookup_table[153] =8'hee; lookup_table[154] =8'hb8; lookup_table[155] =8'h14; lookup_table[156] =8'hde; lookup_table[157] =8'h5e; lookup_table[158] =8'h0b; lookup_table[159] =8'hdb;
//     lookup_table[160] =8'he0; lookup_table[161] =8'he1; lookup_table[162] =8'h32; lookup_table[163] =8'h3a; lookup_table[164] =8'h0a; lookup_table[165] =8'h49; lookup_table[166] =8'h06; lookup_table[167] =8'h24; lookup_table[168] =8'h5c; lookup_table[169] =8'hc2; lookup_table[170] =8'hd3; lookup_table[171] =8'hac; lookup_table[172] =8'h62; lookup_table[173] =8'h91; lookup_table[174] =8'h95; lookup_table[175] =8'he4;
//     lookup_table[176] =8'h79; lookup_table[177] =8'he7; lookup_table[178] =8'hc8; lookup_table[179] =8'h37; lookup_table[180] =8'h6d; lookup_table[181] =8'h8d; lookup_table[182] =8'hd5; lookup_table[183] =8'h4e; lookup_table[184] =8'ha9; lookup_table[185] =8'h6c; lookup_table[186] =8'h56; lookup_table[187] =8'hf4; lookup_table[188] =8'hea; lookup_table[189] =8'h65; lookup_table[190] =8'h7a; lookup_table[191] =8'hae;
//     lookup_table[192] =8'h08; lookup_table[193] =8'hba; lookup_table[194] =8'h78; lookup_table[195] =8'h25; lookup_table[196] =8'h2e; lookup_table[197] =8'h1c; lookup_table[198] =8'ha6; lookup_table[199] =8'hb4; lookup_table[200] =8'hc6; lookup_table[201] =8'he8; lookup_table[202] =8'hdd; lookup_table[203] =8'h74; lookup_table[204] =8'h1f; lookup_table[205] =8'h4b; lookup_table[206] =8'hbd; lookup_table[207] =8'h8b;
//     lookup_table[208] =8'h8a; lookup_table[209] =8'h70; lookup_table[210] =8'h3e; lookup_table[211] =8'hb5; lookup_table[212] =8'h66; lookup_table[213] =8'h48; lookup_table[214] =8'h03; lookup_table[215] =8'hf6; lookup_table[216] =8'h0e; lookup_table[217] =8'h61; lookup_table[218] =8'h35; lookup_table[219] =8'h57; lookup_table[220] =8'hb9; lookup_table[221] =8'h86; lookup_table[222] =8'hc1; lookup_table[223] =8'h1d;
//     lookup_table[224] =8'h9e; lookup_table[225] =8'he1; lookup_table[226] =8'hf8; lookup_table[227] =8'h98; lookup_table[228] =8'h11; lookup_table[229] =8'h69; lookup_table[230] =8'hd9; lookup_table[231] =8'h8e; lookup_table[232] =8'h94; lookup_table[233] =8'h9b; lookup_table[234] =8'h1e; lookup_table[235] =8'h87; lookup_table[236] =8'he9; lookup_table[237] =8'hce; lookup_table[238] =8'h55; lookup_table[239] =8'h28;
//     lookup_table[240] =8'hdf; lookup_table[241] =8'h8c; lookup_table[242] =8'ha1; lookup_table[243] =8'h89; lookup_table[244] =8'h0d; lookup_table[245] =8'hbf; lookup_table[246] =8'he6; lookup_table[247] =8'h42; lookup_table[248] =8'h68; lookup_table[249] =8'h41; lookup_table[250] =8'h99; lookup_table[251] =8'h2d; lookup_table[252] =8'h0f; lookup_table[253] =8'hb0; lookup_table[254] =8'h54; lookup_table[255] =8'hbb;
// end


// look up table for sub_bytes function //
function [7:0] sub_byte;
    input [7:0] i;
    begin
        case (i)
            8'h00: sub_byte=8'h63; 8'h01: sub_byte=8'h7c; 8'h02: sub_byte=8'h77; 8'h03: sub_byte=8'h7b; 8'h04: sub_byte=8'hf2; 8'h05: sub_byte=8'h6b; 8'h06: sub_byte=8'h6f; 8'h07: sub_byte=8'hc5; 8'h08: sub_byte=8'h30; 8'h09: sub_byte=8'h01; 8'h0a: sub_byte=8'h67; 8'h0b: sub_byte=8'h2b; 8'h0c: sub_byte=8'hfe; 8'h0d: sub_byte=8'hd7; 8'h0e: sub_byte=8'hab; 8'h0f: sub_byte=8'h76;
	        8'h10: sub_byte=8'hca; 8'h11: sub_byte=8'h82; 8'h12: sub_byte=8'hc9; 8'h13: sub_byte=8'h7d; 8'h14: sub_byte=8'hfa; 8'h15: sub_byte=8'h59; 8'h16: sub_byte=8'h47; 8'h17: sub_byte=8'hf0; 8'h18: sub_byte=8'had; 8'h19: sub_byte=8'hd4; 8'h1a: sub_byte=8'ha2; 8'h1b: sub_byte=8'haf; 8'h1c: sub_byte=8'h9c; 8'h1d: sub_byte=8'ha4; 8'h1e: sub_byte=8'h72; 8'h1f: sub_byte=8'hc0;
	        8'h20: sub_byte=8'hb7; 8'h21: sub_byte=8'hfd; 8'h22: sub_byte=8'h93; 8'h23: sub_byte=8'h26; 8'h24: sub_byte=8'h36; 8'h25: sub_byte=8'h3f; 8'h26: sub_byte=8'hf7; 8'h27: sub_byte=8'hcc; 8'h28: sub_byte=8'h34; 8'h29: sub_byte=8'ha5; 8'h2a: sub_byte=8'he5; 8'h2b: sub_byte=8'hf1; 8'h2c: sub_byte=8'h71; 8'h2d: sub_byte=8'hd8; 8'h2e: sub_byte=8'h31; 8'h2f: sub_byte=8'h15;
            8'h30: sub_byte=8'h04; 8'h31: sub_byte=8'hc7; 8'h32: sub_byte=8'h23; 8'h33: sub_byte=8'hc3; 8'h34: sub_byte=8'h18; 8'h35: sub_byte=8'h96; 8'h36: sub_byte=8'h05; 8'h37: sub_byte=8'h9a; 8'h38: sub_byte=8'h07; 8'h39: sub_byte=8'h12; 8'h3a: sub_byte=8'h80; 8'h3b: sub_byte=8'he2; 8'h3c: sub_byte=8'heb; 8'h3d: sub_byte=8'h27; 8'h3e: sub_byte=8'hb2; 8'h3f: sub_byte=8'h75;
            8'h40: sub_byte=8'h09; 8'h41: sub_byte=8'h83; 8'h42: sub_byte=8'h2c; 8'h43: sub_byte=8'h1a; 8'h44: sub_byte=8'h1b; 8'h45: sub_byte=8'h6e; 8'h46: sub_byte=8'h5a; 8'h47: sub_byte=8'ha0; 8'h48: sub_byte=8'h52; 8'h49: sub_byte=8'h3b; 8'h4a: sub_byte=8'hd6; 8'h4b: sub_byte=8'hb3; 8'h4c: sub_byte=8'h29; 8'h4d: sub_byte=8'he3; 8'h4e: sub_byte=8'h2f; 8'h4f: sub_byte=8'h84;
            8'h50: sub_byte=8'h53; 8'h51: sub_byte=8'hd1; 8'h52: sub_byte=8'h00; 8'h53: sub_byte=8'hed; 8'h54: sub_byte=8'h20; 8'h55: sub_byte=8'hfc; 8'h56: sub_byte=8'hb1; 8'h57: sub_byte=8'h5b; 8'h58: sub_byte=8'h6a; 8'h59: sub_byte=8'hcb; 8'h5a: sub_byte=8'hbe; 8'h5b: sub_byte=8'h39; 8'h5c: sub_byte=8'h4a; 8'h5d: sub_byte=8'h4c; 8'h5e: sub_byte=8'h58; 8'h5f: sub_byte=8'hcf;
            8'h60: sub_byte=8'hd0; 8'h61: sub_byte=8'hef; 8'h62: sub_byte=8'haa; 8'h63: sub_byte=8'hfb; 8'h64: sub_byte=8'h43; 8'h65: sub_byte=8'h4d; 8'h66: sub_byte=8'h33; 8'h67: sub_byte=8'h85; 8'h68: sub_byte=8'h45; 8'h69: sub_byte=8'hf9; 8'h6a: sub_byte=8'h02; 8'h6b: sub_byte=8'h7f; 8'h6c: sub_byte=8'h50; 8'h6d: sub_byte=8'h3c; 8'h6e: sub_byte=8'h9f; 8'h6f: sub_byte=8'ha8;
            8'h70: sub_byte=8'h51;
            8'h71: sub_byte=8'ha3;
            8'h72: sub_byte=8'h40;
            8'h73: sub_byte=8'h8f;
            8'h74: sub_byte=8'h92;
            8'h75: sub_byte=8'h9d;
            8'h76: sub_byte=8'h38;
            8'h77: sub_byte=8'hf5;
            8'h78: sub_byte=8'hbc;
            8'h79: sub_byte=8'hb6;
            8'h7a: sub_byte=8'hda;
            8'h7b: sub_byte=8'h21;
            8'h7c: sub_byte=8'h10;
            8'h7d: sub_byte=8'hff;
            8'h7e: sub_byte=8'hf3;
            8'h7f: sub_byte=8'hd2;
            8'h80: sub_byte=8'hcd;
            8'h81: sub_byte=8'h0c;
            8'h82: sub_byte=8'h13;
            8'h83: sub_byte=8'hec;
            8'h84: sub_byte=8'h5f;
            8'h85: sub_byte=8'h97;
            8'h86: sub_byte=8'h44;
            8'h87: sub_byte=8'h17;
            8'h88: sub_byte=8'hc4;
            8'h89: sub_byte=8'ha7;
            8'h8a: sub_byte=8'h7e;
            8'h8b: sub_byte=8'h3d;
            8'h8c: sub_byte=8'h64;
            8'h8d: sub_byte=8'h5d;
            8'h8e: sub_byte=8'h19;
            8'h8f: sub_byte=8'h73;
            8'h90: sub_byte=8'h60;
            8'h91: sub_byte=8'h81;
            8'h92: sub_byte=8'h4f;
            8'h93: sub_byte=8'hdc;
            8'h94: sub_byte=8'h22;
            8'h95: sub_byte=8'h2a;
            8'h96: sub_byte=8'h90;
            8'h97: sub_byte=8'h88;
            8'h98: sub_byte=8'h46;
            8'h99: sub_byte=8'hee;
            8'h9a: sub_byte=8'hb8;
            8'h9b: sub_byte=8'h14;
            8'h9c: sub_byte=8'hde;
            8'h9d: sub_byte=8'h5e;
            8'h9e: sub_byte=8'h0b;
            8'h9f: sub_byte=8'hdb;
            8'ha0: sub_byte=8'he0;
            8'ha1: sub_byte=8'h32;
            8'ha2: sub_byte=8'h3a;
            8'ha3: sub_byte=8'h0a;
            8'ha4: sub_byte=8'h49;
            8'ha5: sub_byte=8'h06;
            8'ha6: sub_byte=8'h24;
            8'ha7: sub_byte=8'h5c;
            8'ha8: sub_byte=8'hc2;
            8'ha9: sub_byte=8'hd3;
            8'haa: sub_byte=8'hac;
            8'hab: sub_byte=8'h62;
            8'hac: sub_byte=8'h91;
            8'had: sub_byte=8'h95;
            8'hae: sub_byte=8'he4;
            8'haf: sub_byte=8'h79;
            8'hb0: sub_byte=8'he7;
            8'hb1: sub_byte=8'hc8;
            8'hb2: sub_byte=8'h37;
            8'hb3: sub_byte=8'h6d;
            8'hb4: sub_byte=8'h8d;
            8'hb5: sub_byte=8'hd5;
            8'hb6: sub_byte=8'h4e;
            8'hb7: sub_byte=8'ha9;
            8'hb8: sub_byte=8'h6c;
            8'hb9: sub_byte=8'h56;
            8'hba: sub_byte=8'hf4;
            8'hbb: sub_byte=8'hea;
            8'hbc: sub_byte=8'h65;
            8'hbd: sub_byte=8'h7a;
            8'hbe: sub_byte=8'hae;
            8'hbf: sub_byte=8'h08;
            8'hc0: sub_byte=8'hba;
            8'hc1: sub_byte=8'h78;
            8'hc2: sub_byte=8'h25;
            8'hc3: sub_byte=8'h2e;
            8'hc4: sub_byte=8'h1c;
            8'hc5: sub_byte=8'ha6;
            8'hc6: sub_byte=8'hb4;
            8'hc7: sub_byte=8'hc6;
            8'hc8: sub_byte=8'he8;
            8'hc9: sub_byte=8'hdd;
            8'hca: sub_byte=8'h74;
            8'hcb: sub_byte=8'h1f;
            8'hcc: sub_byte=8'h4b;
            8'hcd: sub_byte=8'hbd;
            8'hce: sub_byte=8'h8b;
            8'hcf: sub_byte=8'h8a;
            8'hd0: sub_byte=8'h70;
            8'hd1: sub_byte=8'h3e;
            8'hd2: sub_byte=8'hb5;
            8'hd3: sub_byte=8'h66;
            8'hd4: sub_byte=8'h48;
            8'hd5: sub_byte=8'h03;
            8'hd6: sub_byte=8'hf6;
            8'hd7: sub_byte=8'h0e;
            8'hd8: sub_byte=8'h61;
            8'hd9: sub_byte=8'h35;
            8'hda: sub_byte=8'h57;
            8'hdb: sub_byte=8'hb9;
            8'hdc: sub_byte=8'h86;
            8'hdd: sub_byte=8'hc1;
            8'hde: sub_byte=8'h1d;
            8'hdf: sub_byte=8'h9e;
            8'he0: sub_byte=8'he1;
            8'he1: sub_byte=8'hf8;
            8'he2: sub_byte=8'h98;
            8'he3: sub_byte=8'h11;
            8'he4: sub_byte=8'h69;
            8'he5: sub_byte=8'hd9;
            8'he6: sub_byte=8'h8e;
            8'he7: sub_byte=8'h94;
            8'he8: sub_byte=8'h9b;
            8'he9: sub_byte=8'h1e;
            8'hea: sub_byte=8'h87;
            8'heb: sub_byte=8'he9;
            8'hec: sub_byte=8'hce;
            8'hed: sub_byte=8'h55;
            8'hee: sub_byte=8'h28;
            8'hef: sub_byte=8'hdf;
            8'hf0: sub_byte=8'h8c;
            8'hf1: sub_byte=8'ha1;
            8'hf2: sub_byte=8'h89;
            8'hf3: sub_byte=8'h0d;
            8'hf4: sub_byte=8'hbf;
            8'hf5: sub_byte=8'he6;
            8'hf6: sub_byte=8'h42;
            8'hf7: sub_byte=8'h68;
            8'hf8: sub_byte=8'h41;
            8'hf9: sub_byte=8'h99;
            8'hfa: sub_byte=8'h2d;
            8'hfb: sub_byte=8'h0f;
            8'hfc: sub_byte=8'hb0;
            8'hfd: sub_byte=8'h54;
            8'hfe: sub_byte=8'hbb;
            8'hff: sub_byte=8'h16;
        endcase
    end
endfunction

// declare variables //
reg [127:0] k_reg0;
reg [127:0] k_in0;
reg [127:0] p_in0;
reg [127:0] p_reg0;
reg [127:0] p_in;
reg [127:0] p_reg;
reg [127:0] p_in2;
reg [127:0] p_reg2;
reg [127:0] p_in3;
reg [127:0] p_reg3;
reg [127:0] p_in4;
reg [127:0] p_reg4;
reg [127:0] p_in5;
reg [127:0] p_reg5;
reg [127:0] p_in6;
reg [127:0] p_reg6;
reg [127:0] p_in7;
reg [127:0] p_reg7;
reg [127:0] p_in8;
reg [127:0] p_reg8;
reg [127:0] p_in9;
reg [127:0] p_reg9;
reg [127:0] p_in10;
reg [127:0] p_reg10;
reg [127:0] k_reg;
reg [31: 0] tmp_key;
reg [127:0] k_in2;
reg [127:0] k_reg2;
reg [31: 0] tmp_key2;
reg [127:0] k_in3;
reg [127:0] k_reg3;
reg [31: 0] tmp_key3;
reg [127:0] k_in4;
reg [127:0] k_reg4;
reg [31: 0] tmp_key4;
reg [127:0] k_in5;
reg [127:0] k_reg5;
reg [31: 0] tmp_key5;
reg [127:0] k_in6;
reg [127:0] k_reg6;
reg [31: 0] tmp_key6;
reg [127:0] k_in7;
reg [127:0] k_reg7;
reg [31: 0] tmp_key7;
reg [127:0] k_in8;
reg [127:0] k_reg8;
reg [31: 0] tmp_key8;
reg [127:0] k_in9;
reg [127:0] k_reg9;
reg [31: 0] tmp_key9;
reg [127:0] k_in10;
reg [127:0] k_reg10;
reg [31: 0] tmp_key10;
// reg [2:0] state;
// reg [2:0] next_state;
integer i, counter;
// reg [3:0] row_index;
// reg [3:0] col_index;
// reg [79:0] rcon_matrix = {8'h01, 8'h02, 8'h04, 8'h08, 8'h10, 8'h20, 8'h40, 8'h80, 8'h1b, 8'h36};

// process input data //
always @ (*) begin
    // first add_round_key //
    for (i = 0; i < 16; i = i + 1) begin
        p_reg0[i<<3 +: 8] = P[i<<3 +: 8] ^ K[i<<3 +: 8];
    end 
end

// first round
always @ (*) begin
    // // first add_round_key //
    // for (i = 0; i < 16; i = i + 1) begin
    //     p_reg[i<<3 +: 8] = P[i<<3 +: 8] ^ K[i<<3 +: 8];
    // end
    // then sub_bytes and shift_rows //
    {p_reg[127 -: 8], p_reg[95 -: 8], p_reg[63 -: 8], p_reg[31 -: 8]} = {sub_byte(p_in0[127 -: 8]), sub_byte(p_in0[95 -: 8]), sub_byte(p_in0[63 -: 8]), sub_byte(p_in0[31 -: 8])};
    {p_reg[119 -: 8], p_reg[87 -: 8], p_reg[55 -: 8], p_reg[23 -: 8]} = {sub_byte(p_in0[87 -: 8]), sub_byte(p_in0[55 -: 8]), sub_byte(p_in0[23 -: 8]), sub_byte(p_in0[119 -: 8])};
    {p_reg[111 -: 8], p_reg[79 -: 8], p_reg[47 -: 8], p_reg[15 -: 8]} = {sub_byte(p_in0[47 -: 8]), sub_byte(p_in0[15 -: 8]), sub_byte(p_in0[111 -: 8]), sub_byte(p_in0[79 -: 8])};
    {p_reg[103 -: 8], p_reg[71 -: 8], p_reg[39 -: 8], p_reg[7 -: 8]} = {sub_byte(p_in0[7 -: 8]), sub_byte(p_in0[103 -: 8]), sub_byte(p_in0[71 -: 8]), sub_byte(p_in0[39 -: 8])};
    // then mix_columns //
    {p_reg[7: 0], p_reg[15 : 8], p_reg[23: 16], p_reg[31: 24]} = {
        gf_2_8_mul(2, p_reg[7 :0]) ^ p_reg[15 :8] ^ p_reg[23 :16] ^ gf_2_8_mul(3, p_reg[31 :24]), 
        gf_2_8_mul(3, p_reg[7: 0]) ^ gf_2_8_mul(2, p_reg[15: 8]) ^ p_reg[23 :16] ^ p_reg[31: 24],
        gf_2_8_mul(3, p_reg[15: 8]) ^ gf_2_8_mul(2, p_reg[23: 16]) ^ p_reg[31: 24] ^ p_reg[7: 0], 
        gf_2_8_mul(3, p_reg[23: 16]) ^ gf_2_8_mul(2, p_reg[31: 24]) ^ p_reg[7: 0] ^ p_reg[15: 8] 
    };
    {p_reg[39: 32], p_reg[47: 40], p_reg[55: 48], p_reg[63: 56]} = {
        gf_2_8_mul(2, p_reg[39: 32]) ^ p_reg[47: 40] ^ p_reg[55: 48] ^ gf_2_8_mul(3, p_reg[63: 56]), 
        gf_2_8_mul(3, p_reg[39: 32]) ^ gf_2_8_mul(2, p_reg[47: 40]) ^ p_reg[55: 48] ^ p_reg[63: 56],
        gf_2_8_mul(3, p_reg[47: 40]) ^ gf_2_8_mul(2, p_reg[55: 48]) ^ p_reg[63: 56] ^ p_reg[39: 32], 
        gf_2_8_mul(3, p_reg[55: 48]) ^ gf_2_8_mul(2, p_reg[63: 56]) ^ p_reg[39: 32] ^ p_reg[47: 40] 
    };
    {p_reg[71: 64], p_reg[79: 72], p_reg[87: 80], p_reg[95: 88]} = {
        gf_2_8_mul(2, p_reg[71: 64]) ^ p_reg[79: 72] ^ p_reg[87: 80] ^ gf_2_8_mul(3, p_reg[95: 88]), 
        gf_2_8_mul(3, p_reg[71: 64]) ^ gf_2_8_mul(2, p_reg[79: 72]) ^ p_reg[87: 80] ^ p_reg[95: 88],
        gf_2_8_mul(3, p_reg[79: 72]) ^ gf_2_8_mul(2, p_reg[87: 80]) ^ p_reg[95: 88] ^ p_reg[71: 64], 
        gf_2_8_mul(3, p_reg[87: 80]) ^ gf_2_8_mul(2, p_reg[95: 88]) ^ p_reg[71: 64] ^ p_reg[79: 72] 
    };
    {p_reg[103: 96], p_reg[111: 104], p_reg[119: 112], p_reg[127: 120]} = {
        gf_2_8_mul(2, p_reg[103: 96]) ^ p_reg[111: 104] ^ p_reg[119: 112] ^ gf_2_8_mul(3, p_reg[127: 120]), 
        gf_2_8_mul(3, p_reg[103: 96]) ^ gf_2_8_mul(2, p_reg[111: 104]) ^ p_reg[119: 112] ^ p_reg[127: 120],
        gf_2_8_mul(3, p_reg[111: 104]) ^ gf_2_8_mul(2, p_reg[119: 112]) ^ p_reg[127: 120] ^ p_reg[103: 96], 
        gf_2_8_mul(3, p_reg[119: 112]) ^ gf_2_8_mul(2, p_reg[127: 120]) ^ p_reg[103: 96] ^ p_reg[111: 104] 
    };
end

// second round
always @ (*) begin
    // // first add_round_key //
    // for (i = 0; i < 16; i = i + 1) begin
    //     p_reg2[i<<3 +: 8] = P[i<<3 +: 8] ^ K[i<<3 +: 8];
    // end
    // then sub_bytes and shift_rows //
    {p_reg2[127 -: 8], p_reg2[95 -: 8], p_reg2[63 -: 8], p_reg2[31 -: 8]} = {sub_byte(p_in2[127 -: 8]), sub_byte(p_in2[95 -: 8]), sub_byte(p_in2[63 -: 8]), sub_byte(p_in2[31 -: 8])};
    {p_reg2[119 -: 8], p_reg2[87 -: 8], p_reg2[55 -: 8], p_reg2[23 -: 8]} = {sub_byte(p_in2[87 -: 8]), sub_byte(p_in2[55 -: 8]), sub_byte(p_in2[23 -: 8]), sub_byte(p_in2[119 -: 8])};
    {p_reg2[111 -: 8], p_reg2[79 -: 8], p_reg2[47 -: 8], p_reg2[15 -: 8]} = {sub_byte(p_in2[47 -: 8]), sub_byte(p_in2[15 -: 8]), sub_byte(p_in2[111 -: 8]), sub_byte(p_in2[79 -: 8])};
    {p_reg2[103 -: 8], p_reg2[71 -: 8], p_reg2[39 -: 8], p_reg2[7 -: 8]} = {sub_byte(p_in2[7 -: 8]), sub_byte(p_in2[103 -: 8]), sub_byte(p_in2[71 -: 8]), sub_byte(p_in2[39 -: 8])};
    // then mix_columns //
    {p_reg2[7: 0], p_reg2[15 : 8], p_reg2[23: 16], p_reg2[31: 24]} = {
        gf_2_8_mul(2, p_reg2[7 :0]) ^ p_reg2[15 :8] ^ p_reg2[23 :16] ^ gf_2_8_mul(3, p_reg2[31 :24]), 
        gf_2_8_mul(3, p_reg2[7: 0]) ^ gf_2_8_mul(2, p_reg2[15: 8]) ^ p_reg2[23 :16] ^ p_reg2[31: 24],
        gf_2_8_mul(3, p_reg2[15: 8]) ^ gf_2_8_mul(2, p_reg2[23: 16]) ^ p_reg2[31: 24] ^ p_reg2[7: 0], 
        gf_2_8_mul(3, p_reg2[23: 16]) ^ gf_2_8_mul(2, p_reg2[31: 24]) ^ p_reg2[7: 0] ^ p_reg2[15: 8] 
    };
    {p_reg2[39: 32], p_reg2[47: 40], p_reg2[55: 48], p_reg2[63: 56]} = {
        gf_2_8_mul(2, p_reg2[39: 32]) ^ p_reg2[47: 40] ^ p_reg2[55: 48] ^ gf_2_8_mul(3, p_reg2[63: 56]), 
        gf_2_8_mul(3, p_reg2[39: 32]) ^ gf_2_8_mul(2, p_reg2[47: 40]) ^ p_reg2[55: 48] ^ p_reg2[63: 56],
        gf_2_8_mul(3, p_reg2[47: 40]) ^ gf_2_8_mul(2, p_reg2[55: 48]) ^ p_reg2[63: 56] ^ p_reg2[39: 32], 
        gf_2_8_mul(3, p_reg2[55: 48]) ^ gf_2_8_mul(2, p_reg2[63: 56]) ^ p_reg2[39: 32] ^ p_reg2[47: 40] 
    };
    {p_reg2[71: 64], p_reg2[79: 72], p_reg2[87: 80], p_reg2[95: 88]} = {
        gf_2_8_mul(2, p_reg2[71: 64]) ^ p_reg2[79: 72] ^ p_reg2[87: 80] ^ gf_2_8_mul(3, p_reg2[95: 88]), 
        gf_2_8_mul(3, p_reg2[71: 64]) ^ gf_2_8_mul(2, p_reg2[79: 72]) ^ p_reg2[87: 80] ^ p_reg2[95: 88],
        gf_2_8_mul(3, p_reg2[79: 72]) ^ gf_2_8_mul(2, p_reg2[87: 80]) ^ p_reg2[95: 88] ^ p_reg2[71: 64], 
        gf_2_8_mul(3, p_reg2[87: 80]) ^ gf_2_8_mul(2, p_reg2[95: 88]) ^ p_reg2[71: 64] ^ p_reg2[79: 72] 
    };
    {p_reg2[103: 96], p_reg2[111: 104], p_reg2[119: 112], p_reg2[127: 120]} = {
        gf_2_8_mul(2, p_reg2[103: 96]) ^ p_reg2[111: 104] ^ p_reg2[119: 112] ^ gf_2_8_mul(3, p_reg2[127: 120]), 
        gf_2_8_mul(3, p_reg2[103: 96]) ^ gf_2_8_mul(2, p_reg2[111: 104]) ^ p_reg2[119: 112] ^ p_reg2[127: 120],
        gf_2_8_mul(3, p_reg2[111: 104]) ^ gf_2_8_mul(2, p_reg2[119: 112]) ^ p_reg2[127: 120] ^ p_reg2[103: 96], 
        gf_2_8_mul(3, p_reg2[119: 112]) ^ gf_2_8_mul(2, p_reg2[127: 120]) ^ p_reg2[103: 96] ^ p_reg2[111: 104] 
    };
    // then add_round_key //
    // for (i = 0; i < 16; i = i + 1) begin
    //     p_reg2[i<<3 +: 8] = p_reg2[i<<3 +: 8] ^ k_reg[i<<3 +: 8];
    // end
    // mix_matrix3[0 +: 8] = gf_2_8_mul(const_matrix[0+:8], shifted_matrix3[0+:8]) ^ gf_2_8_mul(const_matrix[32+:8],shifted_matrix3[8+:8]) ^ gf_2_8_mul(const_matrix[64+:8],shifted_matrix3[16+:8]) ^ gf_2_8_mul(const_matrix[96+:8],shifted_matrix3[24+:8]);
    // mix_matrix3[8 +: 8] = gf_2_8_mul(const_matrix[8+:8],shifted_matrix3[0+:8]) ^ gf_2_8_mul(const_matrix[40+:8],shifted_matrix3[8+:8]) ^ gf_2_8_mul(const_matrix[72+:8],shifted_matrix3[16+:8] ) ^ gf_2_8_mul(const_matrix[104+:8],shifted_matrix3[24+:8]);
    // mix_matrix3[16 +: 8] = gf_2_8_mul(const_matrix[16+:8],shifted_matrix3[0+:8]) ^ gf_2_8_mul(const_matrix[48+:8],shifted_matrix3[8+:8]) ^ gf_2_8_mul(const_matrix[80+:8],shifted_matrix3[16+:8]) ^ gf_2_8_mul(const_matrix[112+:8],shifted_matrix3[24+:8]);
    // mix_matrix3[24 +: 8] = gf_2_8_mul(const_matrix[24+:8],shifted_matrix3[0+:8]) ^ gf_2_8_mul(const_matrix[56+:8],shifted_matrix3[8+:8]) ^ gf_2_8_mul(const_matrix[88+:8],shifted_matrix3[16+:8] )^ gf_2_8_mul(const_matrix[120+:8],shifted_matrix3[24+:8]);
end

// third round
always @ (*) begin
    {p_reg3[127 -: 8], p_reg3[95 -: 8], p_reg3[63 -: 8], p_reg3[31 -: 8]} = {sub_byte(p_in3[127 -: 8]), sub_byte(p_in3[95 -: 8]), sub_byte(p_in3[63 -: 8]), sub_byte(p_in3[31 -: 8])};
    {p_reg3[119 -: 8], p_reg3[87 -: 8], p_reg3[55 -: 8], p_reg3[23 -: 8]} = {sub_byte(p_in3[87 -: 8]), sub_byte(p_in3[55 -: 8]), sub_byte(p_in3[23 -: 8]), sub_byte(p_in3[119 -: 8])};
    {p_reg3[111 -: 8], p_reg3[79 -: 8], p_reg3[47 -: 8], p_reg3[15 -: 8]} = {sub_byte(p_in3[47 -: 8]), sub_byte(p_in3[15 -: 8]), sub_byte(p_in3[111 -: 8]), sub_byte(p_in3[79 -: 8])};
    {p_reg3[103 -: 8], p_reg3[71 -: 8], p_reg3[39 -: 8], p_reg3[7 -: 8]} = {sub_byte(p_in3[7 -: 8]), sub_byte(p_in3[103 -: 8]), sub_byte(p_in3[71 -: 8]), sub_byte(p_in3[39 -: 8])};
    // then mix_columns //
    {p_reg3[7: 0], p_reg3[15 : 8], p_reg3[23: 16], p_reg3[31: 24]} = {
        gf_2_8_mul(2, p_reg3[7 :0]) ^ p_reg3[15 :8] ^ p_reg3[23 :16] ^ gf_2_8_mul(3, p_reg3[31 :24]), 
        gf_2_8_mul(3, p_reg3[7: 0]) ^ gf_2_8_mul(2, p_reg3[15: 8]) ^ p_reg3[23 :16] ^ p_reg3[31: 24],
        gf_2_8_mul(3, p_reg3[15: 8]) ^ gf_2_8_mul(2, p_reg3[23: 16]) ^ p_reg3[31: 24] ^ p_reg3[7: 0], 
        gf_2_8_mul(3, p_reg3[23: 16]) ^ gf_2_8_mul(2, p_reg3[31: 24]) ^ p_reg3[7: 0] ^ p_reg3[15: 8] 
    };
    {p_reg3[39: 32], p_reg3[47: 40], p_reg3[55: 48], p_reg3[63: 56]} = {
        gf_2_8_mul(2, p_reg3[39: 32]) ^ p_reg3[47: 40] ^ p_reg3[55: 48] ^ gf_2_8_mul(3, p_reg3[63: 56]), 
        gf_2_8_mul(3, p_reg3[39: 32]) ^ gf_2_8_mul(2, p_reg3[47: 40]) ^ p_reg3[55: 48] ^ p_reg3[63: 56],
        gf_2_8_mul(3, p_reg3[47: 40]) ^ gf_2_8_mul(2, p_reg3[55: 48]) ^ p_reg3[63: 56] ^ p_reg3[39: 32], 
        gf_2_8_mul(3, p_reg3[55: 48]) ^ gf_2_8_mul(2, p_reg3[63: 56]) ^ p_reg3[39: 32] ^ p_reg3[47: 40] 
    };
    {p_reg3[71: 64], p_reg3[79: 72], p_reg3[87: 80], p_reg3[95: 88]} = {
        gf_2_8_mul(2, p_reg3[71: 64]) ^ p_reg3[79: 72] ^ p_reg3[87: 80] ^ gf_2_8_mul(3, p_reg3[95: 88]), 
        gf_2_8_mul(3, p_reg3[71: 64]) ^ gf_2_8_mul(2, p_reg3[79: 72]) ^ p_reg3[87: 80] ^ p_reg3[95: 88],
        gf_2_8_mul(3, p_reg3[79: 72]) ^ gf_2_8_mul(2, p_reg3[87: 80]) ^ p_reg3[95: 88] ^ p_reg3[71: 64], 
        gf_2_8_mul(3, p_reg3[87: 80]) ^ gf_2_8_mul(2, p_reg3[95: 88]) ^ p_reg3[71: 64] ^ p_reg3[79: 72] 
    };
    {p_reg3[103: 96], p_reg3[111: 104], p_reg3[119: 112], p_reg3[127: 120]} = {
        gf_2_8_mul(2, p_reg3[103: 96]) ^ p_reg3[111: 104] ^ p_reg3[119: 112] ^ gf_2_8_mul(3, p_reg3[127: 120]), 
        gf_2_8_mul(3, p_reg3[103: 96]) ^ gf_2_8_mul(2, p_reg3[111: 104]) ^ p_reg3[119: 112] ^ p_reg3[127: 120],
        gf_2_8_mul(3, p_reg3[111: 104]) ^ gf_2_8_mul(2, p_reg3[119: 112]) ^ p_reg3[127: 120] ^ p_reg3[103: 96], 
        gf_2_8_mul(3, p_reg3[119: 112]) ^ gf_2_8_mul(2, p_reg3[127: 120]) ^ p_reg3[103: 96] ^ p_reg3[111: 104] 
    };
end

// fourth round //
always @ (*) begin
    {p_reg4[127 -: 8], p_reg4[95 -: 8], p_reg4[63 -: 8], p_reg4[31 -: 8]} = {sub_byte(p_in4[127 -: 8]), sub_byte(p_in4[95 -: 8]), sub_byte(p_in4[63 -: 8]), sub_byte(p_in4[31 -: 8])};
    {p_reg4[119 -: 8], p_reg4[87 -: 8], p_reg4[55 -: 8], p_reg4[23 -: 8]} = {sub_byte(p_in4[87 -: 8]), sub_byte(p_in4[55 -: 8]), sub_byte(p_in4[23 -: 8]), sub_byte(p_in4[119 -: 8])};
    {p_reg4[111 -: 8], p_reg4[79 -: 8], p_reg4[47 -: 8], p_reg4[15 -: 8]} = {sub_byte(p_in4[47 -: 8]), sub_byte(p_in4[15 -: 8]), sub_byte(p_in4[111 -: 8]), sub_byte(p_in4[79 -: 8])};
    {p_reg4[103 -: 8], p_reg4[71 -: 8], p_reg4[39 -: 8], p_reg4[7 -: 8]} = {sub_byte(p_in4[7 -: 8]), sub_byte(p_in4[103 -: 8]), sub_byte(p_in4[71 -: 8]), sub_byte(p_in4[39 -: 8])};
    // then mix_columns //
    {p_reg4[7: 0], p_reg4[15 : 8], p_reg4[23: 16], p_reg4[31: 24]} = {
        gf_2_8_mul(2, p_reg4[7 :0]) ^ p_reg4[15 :8] ^ p_reg4[23 :16] ^ gf_2_8_mul(3, p_reg4[31 :24]), 
        gf_2_8_mul(3, p_reg4[7: 0]) ^ gf_2_8_mul(2, p_reg4[15: 8]) ^ p_reg4[23 :16] ^ p_reg4[31: 24],
        gf_2_8_mul(3, p_reg4[15: 8]) ^ gf_2_8_mul(2, p_reg4[23: 16]) ^ p_reg4[31: 24] ^ p_reg4[7: 0], 
        gf_2_8_mul(3, p_reg4[23: 16]) ^ gf_2_8_mul(2, p_reg4[31: 24]) ^ p_reg4[7: 0] ^ p_reg4[15: 8] 
    };
    {p_reg4[39: 32], p_reg4[47: 40], p_reg4[55: 48], p_reg4[63: 56]} = {
        gf_2_8_mul(2, p_reg4[39: 32]) ^ p_reg4[47: 40] ^ p_reg4[55: 48] ^ gf_2_8_mul(3, p_reg4[63: 56]), 
        gf_2_8_mul(3, p_reg4[39: 32]) ^ gf_2_8_mul(2, p_reg4[47: 40]) ^ p_reg4[55: 48] ^ p_reg4[63: 56],
        gf_2_8_mul(3, p_reg4[47: 40]) ^ gf_2_8_mul(2, p_reg4[55: 48]) ^ p_reg4[63: 56] ^ p_reg4[39: 32], 
        gf_2_8_mul(3, p_reg4[55: 48]) ^ gf_2_8_mul(2, p_reg4[63: 56]) ^ p_reg4[39: 32] ^ p_reg4[47: 40] 
    };
    {p_reg4[71: 64], p_reg4[79: 72], p_reg4[87: 80], p_reg4[95: 88]} = {
        gf_2_8_mul(2, p_reg4[71: 64]) ^ p_reg4[79: 72] ^ p_reg4[87: 80] ^ gf_2_8_mul(3, p_reg4[95: 88]), 
        gf_2_8_mul(3, p_reg4[71: 64]) ^ gf_2_8_mul(2, p_reg4[79: 72]) ^ p_reg4[87: 80] ^ p_reg4[95: 88],
        gf_2_8_mul(3, p_reg4[79: 72]) ^ gf_2_8_mul(2, p_reg4[87: 80]) ^ p_reg4[95: 88] ^ p_reg4[71: 64], 
        gf_2_8_mul(3, p_reg4[87: 80]) ^ gf_2_8_mul(2, p_reg4[95: 88]) ^ p_reg4[71: 64] ^ p_reg4[79: 72] 
    };
    {p_reg4[103: 96], p_reg4[111: 104], p_reg4[119: 112], p_reg4[127: 120]} = {
        gf_2_8_mul(2, p_reg4[103: 96]) ^ p_reg4[111: 104] ^ p_reg4[119: 112] ^ gf_2_8_mul(3, p_reg4[127: 120]), 
        gf_2_8_mul(3, p_reg4[103: 96]) ^ gf_2_8_mul(2, p_reg4[111: 104]) ^ p_reg4[119: 112] ^ p_reg4[127: 120],
        gf_2_8_mul(3, p_reg4[111: 104]) ^ gf_2_8_mul(2, p_reg4[119: 112]) ^ p_reg4[127: 120] ^ p_reg4[103: 96], 
        gf_2_8_mul(3, p_reg4[119: 112]) ^ gf_2_8_mul(2, p_reg4[127: 120]) ^ p_reg4[103: 96] ^ p_reg4[111: 104] 
    };
end

// fifth round //
always @ (*) begin
    {p_reg5[127 -: 8], p_reg5[95 -: 8], p_reg5[63 -: 8], p_reg5[31 -: 8]} = {sub_byte(p_in5[127 -: 8]), sub_byte(p_in5[95 -: 8]), sub_byte(p_in5[63 -: 8]), sub_byte(p_in5[31 -: 8])};
    {p_reg5[119 -: 8], p_reg5[87 -: 8], p_reg5[55 -: 8], p_reg5[23 -: 8]} = {sub_byte(p_in5[87 -: 8]), sub_byte(p_in5[55 -: 8]), sub_byte(p_in5[23 -: 8]), sub_byte(p_in5[119 -: 8])};
    {p_reg5[111 -: 8], p_reg5[79 -: 8], p_reg5[47 -: 8], p_reg5[15 -: 8]} = {sub_byte(p_in5[47 -: 8]), sub_byte(p_in5[15 -: 8]), sub_byte(p_in5[111 -: 8]), sub_byte(p_in5[79 -: 8])};
    {p_reg5[103 -: 8], p_reg5[71 -: 8], p_reg5[39 -: 8], p_reg5[7 -: 8]} = {sub_byte(p_in5[7 -: 8]), sub_byte(p_in5[103 -: 8]), sub_byte(p_in5[71 -: 8]), sub_byte(p_in5[39 -: 8])};
    // then mix_columns //
    {p_reg5[7: 0], p_reg5[15 : 8], p_reg5[23: 16], p_reg5[31: 24]} = {
        gf_2_8_mul(2, p_reg5[7 :0]) ^ p_reg5[15 :8] ^ p_reg5[23 :16] ^ gf_2_8_mul(3, p_reg5[31 :24]), 
        gf_2_8_mul(3, p_reg5[7: 0]) ^ gf_2_8_mul(2, p_reg5[15: 8]) ^ p_reg5[23 :16] ^ p_reg5[31: 24],
        gf_2_8_mul(3, p_reg5[15: 8]) ^ gf_2_8_mul(2, p_reg5[23: 16]) ^ p_reg5[31: 24] ^ p_reg5[7: 0], 
        gf_2_8_mul(3, p_reg5[23: 16]) ^ gf_2_8_mul(2, p_reg5[31: 24]) ^ p_reg5[7: 0] ^ p_reg5[15: 8] 
    };
    {p_reg5[39: 32], p_reg5[47: 40], p_reg5[55: 48], p_reg5[63: 56]} = {
        gf_2_8_mul(2, p_reg5[39: 32]) ^ p_reg5[47: 40] ^ p_reg5[55: 48] ^ gf_2_8_mul(3, p_reg5[63: 56]), 
        gf_2_8_mul(3, p_reg5[39: 32]) ^ gf_2_8_mul(2, p_reg5[47: 40]) ^ p_reg5[55: 48] ^ p_reg5[63: 56],
        gf_2_8_mul(3, p_reg5[47: 40]) ^ gf_2_8_mul(2, p_reg5[55: 48]) ^ p_reg5[63: 56] ^ p_reg5[39: 32], 
        gf_2_8_mul(3, p_reg5[55: 48]) ^ gf_2_8_mul(2, p_reg5[63: 56]) ^ p_reg5[39: 32] ^ p_reg5[47: 40] 
    };
    {p_reg5[71: 64], p_reg5[79: 72], p_reg5[87: 80], p_reg5[95: 88]} = {
        gf_2_8_mul(2, p_reg5[71: 64]) ^ p_reg5[79: 72] ^ p_reg5[87: 80] ^ gf_2_8_mul(3, p_reg5[95: 88]), 
        gf_2_8_mul(3, p_reg5[71: 64]) ^ gf_2_8_mul(2, p_reg5[79: 72]) ^ p_reg5[87: 80] ^ p_reg5[95: 88],
        gf_2_8_mul(3, p_reg5[79: 72]) ^ gf_2_8_mul(2, p_reg5[87: 80]) ^ p_reg5[95: 88] ^ p_reg5[71: 64], 
        gf_2_8_mul(3, p_reg5[87: 80]) ^ gf_2_8_mul(2, p_reg5[95: 88]) ^ p_reg5[71: 64] ^ p_reg5[79: 72] 
    };
    {p_reg5[103: 96], p_reg5[111: 104], p_reg5[119: 112], p_reg5[127: 120]} = {
        gf_2_8_mul(2, p_reg5[103: 96]) ^ p_reg5[111: 104] ^ p_reg5[119: 112] ^ gf_2_8_mul(3, p_reg5[127: 120]), 
        gf_2_8_mul(3, p_reg5[103: 96]) ^ gf_2_8_mul(2, p_reg5[111: 104]) ^ p_reg5[119: 112] ^ p_reg5[127: 120],
        gf_2_8_mul(3, p_reg5[111: 104]) ^ gf_2_8_mul(2, p_reg5[119: 112]) ^ p_reg5[127: 120] ^ p_reg5[103: 96], 
        gf_2_8_mul(3, p_reg5[119: 112]) ^ gf_2_8_mul(2, p_reg5[127: 120]) ^ p_reg5[103: 96] ^ p_reg5[111: 104] 
    };
end

// sixth round //
always @ (*) begin
    {p_reg6[127 -: 8], p_reg6[95 -: 8], p_reg6[63 -: 8], p_reg6[31 -: 8]} = {sub_byte(p_in6[127 -: 8]), sub_byte(p_in6[95 -: 8]), sub_byte(p_in6[63 -: 8]), sub_byte(p_in6[31 -: 8])};
    {p_reg6[119 -: 8], p_reg6[87 -: 8], p_reg6[55 -: 8], p_reg6[23 -: 8]} = {sub_byte(p_in6[87 -: 8]), sub_byte(p_in6[55 -: 8]), sub_byte(p_in6[23 -: 8]), sub_byte(p_in6[119 -: 8])};
    {p_reg6[111 -: 8], p_reg6[79 -: 8], p_reg6[47 -: 8], p_reg6[15 -: 8]} = {sub_byte(p_in6[47 -: 8]), sub_byte(p_in6[15 -: 8]), sub_byte(p_in6[111 -: 8]), sub_byte(p_in6[79 -: 8])};
    {p_reg6[103 -: 8], p_reg6[71 -: 8], p_reg6[39 -: 8], p_reg6[7 -: 8]} = {sub_byte(p_in6[7 -: 8]), sub_byte(p_in6[103 -: 8]), sub_byte(p_in6[71 -: 8]), sub_byte(p_in6[39 -: 8])};
    // then mix_columns //
    {p_reg6[7: 0], p_reg6[15 : 8], p_reg6[23: 16], p_reg6[31: 24]} = {
        gf_2_8_mul(2, p_reg6[7 :0]) ^ p_reg6[15 :8] ^ p_reg6[23 :16] ^ gf_2_8_mul(3, p_reg6[31 :24]), 
        gf_2_8_mul(3, p_reg6[7: 0]) ^ gf_2_8_mul(2, p_reg6[15: 8]) ^ p_reg6[23 :16] ^ p_reg6[31: 24],
        gf_2_8_mul(3, p_reg6[15: 8]) ^ gf_2_8_mul(2, p_reg6[23: 16]) ^ p_reg6[31: 24] ^ p_reg6[7: 0], 
        gf_2_8_mul(3, p_reg6[23: 16]) ^ gf_2_8_mul(2, p_reg6[31: 24]) ^ p_reg6[7: 0] ^ p_reg6[15: 8] 
    };
    {p_reg6[39: 32], p_reg6[47: 40], p_reg6[55: 48], p_reg6[63: 56]} = {
        gf_2_8_mul(2, p_reg6[39: 32]) ^ p_reg6[47: 40] ^ p_reg6[55: 48] ^ gf_2_8_mul(3, p_reg6[63: 56]), 
        gf_2_8_mul(3, p_reg6[39: 32]) ^ gf_2_8_mul(2, p_reg6[47: 40]) ^ p_reg6[55: 48] ^ p_reg6[63: 56],
        gf_2_8_mul(3, p_reg6[47: 40]) ^ gf_2_8_mul(2, p_reg6[55: 48]) ^ p_reg6[63: 56] ^ p_reg6[39: 32], 
        gf_2_8_mul(3, p_reg6[55: 48]) ^ gf_2_8_mul(2, p_reg6[63: 56]) ^ p_reg6[39: 32] ^ p_reg6[47: 40] 
    };
    {p_reg6[71: 64], p_reg6[79: 72], p_reg6[87: 80], p_reg6[95: 88]} = {
        gf_2_8_mul(2, p_reg6[71: 64]) ^ p_reg6[79: 72] ^ p_reg6[87: 80] ^ gf_2_8_mul(3, p_reg6[95: 88]), 
        gf_2_8_mul(3, p_reg6[71: 64]) ^ gf_2_8_mul(2, p_reg6[79: 72]) ^ p_reg6[87: 80] ^ p_reg6[95: 88],
        gf_2_8_mul(3, p_reg6[79: 72]) ^ gf_2_8_mul(2, p_reg6[87: 80]) ^ p_reg6[95: 88] ^ p_reg6[71: 64], 
        gf_2_8_mul(3, p_reg6[87: 80]) ^ gf_2_8_mul(2, p_reg6[95: 88]) ^ p_reg6[71: 64] ^ p_reg6[79: 72] 
    };
    {p_reg6[103: 96], p_reg6[111: 104], p_reg6[119: 112], p_reg6[127: 120]} = {
        gf_2_8_mul(2, p_reg6[103: 96]) ^ p_reg6[111: 104] ^ p_reg6[119: 112] ^ gf_2_8_mul(3, p_reg6[127: 120]), 
        gf_2_8_mul(3, p_reg6[103: 96]) ^ gf_2_8_mul(2, p_reg6[111: 104]) ^ p_reg6[119: 112] ^ p_reg6[127: 120],
        gf_2_8_mul(3, p_reg6[111: 104]) ^ gf_2_8_mul(2, p_reg6[119: 112]) ^ p_reg6[127: 120] ^ p_reg6[103: 96], 
        gf_2_8_mul(3, p_reg6[119: 112]) ^ gf_2_8_mul(2, p_reg6[127: 120]) ^ p_reg6[103: 96] ^ p_reg6[111: 104] 
    };
end

// seventh round //
always @ (*) begin
    {p_reg7[127 -: 8], p_reg7[95 -: 8], p_reg7[63 -: 8], p_reg7[31 -: 8]} = {sub_byte(p_in7[127 -: 8]), sub_byte(p_in7[95 -: 8]), sub_byte(p_in7[63 -: 8]), sub_byte(p_in7[31 -: 8])};
    {p_reg7[119 -: 8], p_reg7[87 -: 8], p_reg7[55 -: 8], p_reg7[23 -: 8]} = {sub_byte(p_in7[87 -: 8]), sub_byte(p_in7[55 -: 8]), sub_byte(p_in7[23 -: 8]), sub_byte(p_in7[119 -: 8])};
    {p_reg7[111 -: 8], p_reg7[79 -: 8], p_reg7[47 -: 8], p_reg7[15 -: 8]} = {sub_byte(p_in7[47 -: 8]), sub_byte(p_in7[15 -: 8]), sub_byte(p_in7[111 -: 8]), sub_byte(p_in7[79 -: 8])};
    {p_reg7[103 -: 8], p_reg7[71 -: 8], p_reg7[39 -: 8], p_reg7[7 -: 8]} = {sub_byte(p_in7[7 -: 8]), sub_byte(p_in7[103 -: 8]), sub_byte(p_in7[71 -: 8]), sub_byte(p_in7[39 -: 8])};
    // then mix_columns //
    {p_reg7[7: 0], p_reg7[15 : 8], p_reg7[23: 16], p_reg7[31: 24]} = {
        gf_2_8_mul(2, p_reg7[7 :0]) ^ p_reg7[15 :8] ^ p_reg7[23 :16] ^ gf_2_8_mul(3, p_reg7[31 :24]), 
        gf_2_8_mul(3, p_reg7[7: 0]) ^ gf_2_8_mul(2, p_reg7[15: 8]) ^ p_reg7[23 :16] ^ p_reg7[31: 24],
        gf_2_8_mul(3, p_reg7[15: 8]) ^ gf_2_8_mul(2, p_reg7[23: 16]) ^ p_reg7[31: 24] ^ p_reg7[7: 0], 
        gf_2_8_mul(3, p_reg7[23: 16]) ^ gf_2_8_mul(2, p_reg7[31: 24]) ^ p_reg7[7: 0] ^ p_reg7[15: 8] 
    };
    {p_reg7[39: 32], p_reg7[47: 40], p_reg7[55: 48], p_reg7[63: 56]} = {
        gf_2_8_mul(2, p_reg7[39: 32]) ^ p_reg7[47: 40] ^ p_reg7[55: 48] ^ gf_2_8_mul(3, p_reg7[63: 56]), 
        gf_2_8_mul(3, p_reg7[39: 32]) ^ gf_2_8_mul(2, p_reg7[47: 40]) ^ p_reg7[55: 48] ^ p_reg7[63: 56],
        gf_2_8_mul(3, p_reg7[47: 40]) ^ gf_2_8_mul(2, p_reg7[55: 48]) ^ p_reg7[63: 56] ^ p_reg7[39: 32], 
        gf_2_8_mul(3, p_reg7[55: 48]) ^ gf_2_8_mul(2, p_reg7[63: 56]) ^ p_reg7[39: 32] ^ p_reg7[47: 40] 
    };
    {p_reg7[71: 64], p_reg7[79: 72], p_reg7[87: 80], p_reg7[95: 88]} = {
        gf_2_8_mul(2, p_reg7[71: 64]) ^ p_reg7[79: 72] ^ p_reg7[87: 80] ^ gf_2_8_mul(3, p_reg7[95: 88]), 
        gf_2_8_mul(3, p_reg7[71: 64]) ^ gf_2_8_mul(2, p_reg7[79: 72]) ^ p_reg7[87: 80] ^ p_reg7[95: 88],
        gf_2_8_mul(3, p_reg7[79: 72]) ^ gf_2_8_mul(2, p_reg7[87: 80]) ^ p_reg7[95: 88] ^ p_reg7[71: 64], 
        gf_2_8_mul(3, p_reg7[87: 80]) ^ gf_2_8_mul(2, p_reg7[95: 88]) ^ p_reg7[71: 64] ^ p_reg7[79: 72] 
    };
    {p_reg7[103: 96], p_reg7[111: 104], p_reg7[119: 112], p_reg7[127: 120]} = {
        gf_2_8_mul(2, p_reg7[103: 96]) ^ p_reg7[111: 104] ^ p_reg7[119: 112] ^ gf_2_8_mul(3, p_reg7[127: 120]), 
        gf_2_8_mul(3, p_reg7[103: 96]) ^ gf_2_8_mul(2, p_reg7[111: 104]) ^ p_reg7[119: 112] ^ p_reg7[127: 120],
        gf_2_8_mul(3, p_reg7[111: 104]) ^ gf_2_8_mul(2, p_reg7[119: 112]) ^ p_reg7[127: 120] ^ p_reg7[103: 96], 
        gf_2_8_mul(3, p_reg7[119: 112]) ^ gf_2_8_mul(2, p_reg7[127: 120]) ^ p_reg7[103: 96] ^ p_reg7[111: 104] 
    };
end

// eighth round //
always @ (*) begin
    {p_reg8[127 -: 8], p_reg8[95 -: 8], p_reg8[63 -: 8], p_reg8[31 -: 8]} = {sub_byte(p_in8[127 -: 8]), sub_byte(p_in8[95 -: 8]), sub_byte(p_in8[63 -: 8]), sub_byte(p_in8[31 -: 8])};
    {p_reg8[119 -: 8], p_reg8[87 -: 8], p_reg8[55 -: 8], p_reg8[23 -: 8]} = {sub_byte(p_in8[87 -: 8]), sub_byte(p_in8[55 -: 8]), sub_byte(p_in8[23 -: 8]), sub_byte(p_in8[119 -: 8])};
    {p_reg8[111 -: 8], p_reg8[79 -: 8], p_reg8[47 -: 8], p_reg8[15 -: 8]} = {sub_byte(p_in8[47 -: 8]), sub_byte(p_in8[15 -: 8]), sub_byte(p_in8[111 -: 8]), sub_byte(p_in8[79 -: 8])};
    {p_reg8[103 -: 8], p_reg8[71 -: 8], p_reg8[39 -: 8], p_reg8[7 -: 8]} = {sub_byte(p_in8[7 -: 8]), sub_byte(p_in8[103 -: 8]), sub_byte(p_in8[71 -: 8]), sub_byte(p_in8[39 -: 8])};
    // then mix_columns //
    {p_reg8[7: 0], p_reg8[15 : 8], p_reg8[23: 16], p_reg8[31: 24]} = {
        gf_2_8_mul(2, p_reg8[7 :0]) ^ p_reg8[15 :8] ^ p_reg8[23 :16] ^ gf_2_8_mul(3, p_reg8[31 :24]), 
        gf_2_8_mul(3, p_reg8[7: 0]) ^ gf_2_8_mul(2, p_reg8[15: 8]) ^ p_reg8[23 :16] ^ p_reg8[31: 24],
        gf_2_8_mul(3, p_reg8[15: 8]) ^ gf_2_8_mul(2, p_reg8[23: 16]) ^ p_reg8[31: 24] ^ p_reg8[7: 0], 
        gf_2_8_mul(3, p_reg8[23: 16]) ^ gf_2_8_mul(2, p_reg8[31: 24]) ^ p_reg8[7: 0] ^ p_reg8[15: 8] 
    };
    {p_reg8[39: 32], p_reg8[47: 40], p_reg8[55: 48], p_reg8[63: 56]} = {
        gf_2_8_mul(2, p_reg8[39: 32]) ^ p_reg8[47: 40] ^ p_reg8[55: 48] ^ gf_2_8_mul(3, p_reg8[63: 56]), 
        gf_2_8_mul(3, p_reg8[39: 32]) ^ gf_2_8_mul(2, p_reg8[47: 40]) ^ p_reg8[55: 48] ^ p_reg8[63: 56],
        gf_2_8_mul(3, p_reg8[47: 40]) ^ gf_2_8_mul(2, p_reg8[55: 48]) ^ p_reg8[63: 56] ^ p_reg8[39: 32], 
        gf_2_8_mul(3, p_reg8[55: 48]) ^ gf_2_8_mul(2, p_reg8[63: 56]) ^ p_reg8[39: 32] ^ p_reg8[47: 40] 
    };
    {p_reg8[71: 64], p_reg8[79: 72], p_reg8[87: 80], p_reg8[95: 88]} = {
        gf_2_8_mul(2, p_reg8[71: 64]) ^ p_reg8[79: 72] ^ p_reg8[87: 80] ^ gf_2_8_mul(3, p_reg8[95: 88]), 
        gf_2_8_mul(3, p_reg8[71: 64]) ^ gf_2_8_mul(2, p_reg8[79: 72]) ^ p_reg8[87: 80] ^ p_reg8[95: 88],
        gf_2_8_mul(3, p_reg8[79: 72]) ^ gf_2_8_mul(2, p_reg8[87: 80]) ^ p_reg8[95: 88] ^ p_reg8[71: 64], 
        gf_2_8_mul(3, p_reg8[87: 80]) ^ gf_2_8_mul(2, p_reg8[95: 88]) ^ p_reg8[71: 64] ^ p_reg8[79: 72] 
    };
    {p_reg8[103: 96], p_reg8[111: 104], p_reg8[119: 112], p_reg8[127: 120]} = {
        gf_2_8_mul(2, p_reg8[103: 96]) ^ p_reg8[111: 104] ^ p_reg8[119: 112] ^ gf_2_8_mul(3, p_reg8[127: 120]), 
        gf_2_8_mul(3, p_reg8[103: 96]) ^ gf_2_8_mul(2, p_reg8[111: 104]) ^ p_reg8[119: 112] ^ p_reg8[127: 120],
        gf_2_8_mul(3, p_reg8[111: 104]) ^ gf_2_8_mul(2, p_reg8[119: 112]) ^ p_reg8[127: 120] ^ p_reg8[103: 96], 
        gf_2_8_mul(3, p_reg8[119: 112]) ^ gf_2_8_mul(2, p_reg8[127: 120]) ^ p_reg8[103: 96] ^ p_reg8[111: 104] 
    };
end

// ninth round //
always @ (*) begin
    {p_reg9[127 -: 8], p_reg9[95 -: 8], p_reg9[63 -: 8], p_reg9[31 -: 8]} = {sub_byte(p_in9[127 -: 8]), sub_byte(p_in9[95 -: 8]), sub_byte(p_in9[63 -: 8]), sub_byte(p_in9[31 -: 8])};
    {p_reg9[119 -: 8], p_reg9[87 -: 8], p_reg9[55 -: 8], p_reg9[23 -: 8]} = {sub_byte(p_in9[87 -: 8]), sub_byte(p_in9[55 -: 8]), sub_byte(p_in9[23 -: 8]), sub_byte(p_in9[119 -: 8])};
    {p_reg9[111 -: 8], p_reg9[79 -: 8], p_reg9[47 -: 8], p_reg9[15 -: 8]} = {sub_byte(p_in9[47 -: 8]), sub_byte(p_in9[15 -: 8]), sub_byte(p_in9[111 -: 8]), sub_byte(p_in9[79 -: 8])};
    {p_reg9[103 -: 8], p_reg9[71 -: 8], p_reg9[39 -: 8], p_reg9[7 -: 8]} = {sub_byte(p_in9[7 -: 8]), sub_byte(p_in9[103 -: 8]), sub_byte(p_in9[71 -: 8]), sub_byte(p_in9[39 -: 8])};
    // then mix_columns //
    {p_reg9[7: 0], p_reg9[15 : 8], p_reg9[23: 16], p_reg9[31: 24]} = {
        gf_2_8_mul(2, p_reg9[7 :0]) ^ p_reg9[15 :8] ^ p_reg9[23 :16] ^ gf_2_8_mul(3, p_reg9[31 :24]), 
        gf_2_8_mul(3, p_reg9[7: 0]) ^ gf_2_8_mul(2, p_reg9[15: 8]) ^ p_reg9[23 :16] ^ p_reg9[31: 24],
        gf_2_8_mul(3, p_reg9[15: 8]) ^ gf_2_8_mul(2, p_reg9[23: 16]) ^ p_reg9[31: 24] ^ p_reg9[7: 0], 
        gf_2_8_mul(3, p_reg9[23: 16]) ^ gf_2_8_mul(2, p_reg9[31: 24]) ^ p_reg9[7: 0] ^ p_reg9[15: 8] 
    };
    {p_reg9[39: 32], p_reg9[47: 40], p_reg9[55: 48], p_reg9[63: 56]} = {
        gf_2_8_mul(2, p_reg9[39: 32]) ^ p_reg9[47: 40] ^ p_reg9[55: 48] ^ gf_2_8_mul(3, p_reg9[63: 56]), 
        gf_2_8_mul(3, p_reg9[39: 32]) ^ gf_2_8_mul(2, p_reg9[47: 40]) ^ p_reg9[55: 48] ^ p_reg9[63: 56],
        gf_2_8_mul(3, p_reg9[47: 40]) ^ gf_2_8_mul(2, p_reg9[55: 48]) ^ p_reg9[63: 56] ^ p_reg9[39: 32], 
        gf_2_8_mul(3, p_reg9[55: 48]) ^ gf_2_8_mul(2, p_reg9[63: 56]) ^ p_reg9[39: 32] ^ p_reg9[47: 40] 
    };
    {p_reg9[71: 64], p_reg9[79: 72], p_reg9[87: 80], p_reg9[95: 88]} = {
        gf_2_8_mul(2, p_reg9[71: 64]) ^ p_reg9[79: 72] ^ p_reg9[87: 80] ^ gf_2_8_mul(3, p_reg9[95: 88]), 
        gf_2_8_mul(3, p_reg9[71: 64]) ^ gf_2_8_mul(2, p_reg9[79: 72]) ^ p_reg9[87: 80] ^ p_reg9[95: 88],
        gf_2_8_mul(3, p_reg9[79: 72]) ^ gf_2_8_mul(2, p_reg9[87: 80]) ^ p_reg9[95: 88] ^ p_reg9[71: 64], 
        gf_2_8_mul(3, p_reg9[87: 80]) ^ gf_2_8_mul(2, p_reg9[95: 88]) ^ p_reg9[71: 64] ^ p_reg9[79: 72] 
    };
    {p_reg9[103: 96], p_reg9[111: 104], p_reg9[119: 112], p_reg9[127: 120]} = {
        gf_2_8_mul(2, p_reg9[103: 96]) ^ p_reg9[111: 104] ^ p_reg9[119: 112] ^ gf_2_8_mul(3, p_reg9[127: 120]), 
        gf_2_8_mul(3, p_reg9[103: 96]) ^ gf_2_8_mul(2, p_reg9[111: 104]) ^ p_reg9[119: 112] ^ p_reg9[127: 120],
        gf_2_8_mul(3, p_reg9[111: 104]) ^ gf_2_8_mul(2, p_reg9[119: 112]) ^ p_reg9[127: 120] ^ p_reg9[103: 96], 
        gf_2_8_mul(3, p_reg9[119: 112]) ^ gf_2_8_mul(2, p_reg9[127: 120]) ^ p_reg9[103: 96] ^ p_reg9[111: 104] 
    };
end

// tenth round //
always @ (*) begin
    {p_reg10[127 -: 8], p_reg10[95 -: 8], p_reg10[63 -: 8], p_reg10[31 -: 8]} = {sub_byte(p_in10[127 -: 8]), sub_byte(p_in10[95 -: 8]), sub_byte(p_in10[63 -: 8]), sub_byte(p_in10[31 -: 8])};
    {p_reg10[119 -: 8], p_reg10[87 -: 8], p_reg10[55 -: 8], p_reg10[23 -: 8]} = {sub_byte(p_in10[87 -: 8]), sub_byte(p_in10[55 -: 8]), sub_byte(p_in10[23 -: 8]), sub_byte(p_in10[119 -: 8])};
    {p_reg10[111 -: 8], p_reg10[79 -: 8], p_reg10[47 -: 8], p_reg10[15 -: 8]} = {sub_byte(p_in10[47 -: 8]), sub_byte(p_in10[15 -: 8]), sub_byte(p_in10[111 -: 8]), sub_byte(p_in10[79 -: 8])};
    {p_reg10[103 -: 8], p_reg10[71 -: 8], p_reg10[39 -: 8], p_reg10[7 -: 8]} = {sub_byte(p_in10[7 -: 8]), sub_byte(p_in10[103 -: 8]), sub_byte(p_in10[71 -: 8]), sub_byte(p_in10[39 -: 8])};
end

// save first key // 
always @ (*) begin
    k_reg0 = K;
end

// first key expansion //
always @ (*) begin
    k_reg = k_in0;
    // rot word and sub word (first time) //
    tmp_key = {sub_byte(k_reg[23:16])^8'h01, sub_byte(k_reg[15:8]), sub_byte(k_reg[7:0]) , sub_byte(k_reg[31:24])};
    // rcon //
    k_reg[127 -: 32] = tmp_key ^ k_reg[127 -: 32];
    k_reg[95 -: 32] = k_reg[95 -: 32] ^ k_reg[127 -: 32];
    k_reg[63 -: 32] = k_reg[63 -: 32] ^ k_reg[95 -: 32];
    k_reg[31 -: 32] = k_reg[31 -: 32] ^ k_reg[63 -: 32];    
end

// second key expansion //
always @ (*) begin
    k_reg2 = k_in2;
    // rot word and sub word (second time) //
    tmp_key2 = {sub_byte(k_reg2[23:16])^8'h02, sub_byte(k_reg2[15:8]), sub_byte(k_reg2[7:0]) , sub_byte(k_reg2[31:24])};
    // rcon //
    k_reg2[127 -: 32] = tmp_key2 ^ k_reg2[127 -: 32];
    k_reg2[95 -: 32] = k_reg2[95 -: 32] ^ k_reg2[127 -: 32];
    k_reg2[63 -: 32] = k_reg2[63 -: 32] ^ k_reg2[95 -: 32];
    k_reg2[31 -: 32] = k_reg2[31 -: 32] ^ k_reg2[63 -: 32];    
end

// third key expansion //
always @ (*) begin
    k_reg3 = k_in3;
    // rot word and sub word (third time) //
    tmp_key3 = {sub_byte(k_reg3[23:16])^8'h04, sub_byte(k_reg3[15:8]), sub_byte(k_reg3[7:0]) , sub_byte(k_reg3[31:24])};
    // rcon //
    k_reg3[127 -: 32] = tmp_key3 ^ k_reg3[127 -: 32];
    k_reg3[95 -: 32] = k_reg3[95 -: 32] ^ k_reg3[127 -: 32];
    k_reg3[63 -: 32] = k_reg3[63 -: 32] ^ k_reg3[95 -: 32];
    k_reg3[31 -: 32] = k_reg3[31 -: 32] ^ k_reg3[63 -: 32];    
    // k_reg = {k_reg[95:0], k_reg[127:96]};
    // // sub word //
    // k_reg[127 -: 32] = {sub_byte(k_reg[127 -: 8]), sub_byte(k_reg[119 -: 8]), sub_byte(k_reg[111 -: 8]), sub_byte(k_reg[103 -: 8])};
end

// fourth key expansion //
always @ (*) begin
    k_reg4 = k_in4;
    // rot word and sub word (fourth time) //
    tmp_key4 = {sub_byte(k_reg4[23:16])^8'h08, sub_byte(k_reg4[15:8]), sub_byte(k_reg4[7:0]) , sub_byte(k_reg4[31:24])};
    // rcon //
    k_reg4[127 -: 32] = tmp_key4 ^ k_reg4[127 -: 32];
    k_reg4[95 -: 32] = k_reg4[95 -: 32] ^ k_reg4[127 -: 32];
    k_reg4[63 -: 32] = k_reg4[63 -: 32] ^ k_reg4[95 -: 32];
    k_reg4[31 -: 32] = k_reg4[31 -: 32] ^ k_reg4[63 -: 32];    
    // k_reg = {k_reg[95:0], k_reg[127:96]};
    // // sub word //
    // k_reg[127 -: 32] = {sub_byte(k_reg[127 -: 8]), sub_byte(k_reg[119 -: 8]), sub_byte(k_reg[111 -: 8]), sub_byte(k_reg[103 -: 8])};
end

// fifth key expansion //
always @ (*) begin
    k_reg5 = k_in5;
    // rot word and sub word (fifth time) //
    tmp_key5 = {sub_byte(k_reg5[23:16])^8'h10, sub_byte(k_reg5[15:8]), sub_byte(k_reg5[7:0]) , sub_byte(k_reg5[31:24])};
    // rcon //
    k_reg5[127 -: 32] = tmp_key5 ^ k_reg5[127 -: 32];
    k_reg5[95 -: 32] = k_reg5[95 -: 32] ^ k_reg5[127 -: 32];
    k_reg5[63 -: 32] = k_reg5[63 -: 32] ^ k_reg5[95 -: 32];
    k_reg5[31 -: 32] = k_reg5[31 -: 32] ^ k_reg5[63 -: 32];    
    // k_reg = {k_reg[95:0], k_reg[127:96]};
    // // sub word //
    // k_reg[127 -: 32] = {sub_byte(k_reg[127 -: 8]), sub_byte(k_reg[119 -: 8]), sub_byte(k_reg[111 -: 8]), sub_byte(k_reg[103 -: 8])};
end

// sixth key expansion //
always @ (*) begin
    k_reg6 = k_in6;
    // rot word and sub word (sixth time) //
    tmp_key6 = {sub_byte(k_reg6[23:16])^8'h20, sub_byte(k_reg6[15:8]), sub_byte(k_reg6[7:0]) , sub_byte(k_reg6[31:24])};
    // rcon //
    k_reg6[127 -: 32] = tmp_key6 ^ k_reg6[127 -: 32];
    k_reg6[95 -: 32] = k_reg6[95 -: 32] ^ k_reg6[127 -: 32];
    k_reg6[63 -: 32] = k_reg6[63 -: 32] ^ k_reg6[95 -: 32];
    k_reg6[31 -: 32] = k_reg6[31 -: 32] ^ k_reg6[63 -: 32];    
    // k_reg = {k_reg[95:0], k_reg[127:96]};
    // // sub word //
    // k_reg[127 -: 32] = {sub_byte(k_reg[127 -: 8]), sub_byte(k_reg[119 -: 8]), sub_byte(k_reg[111 -: 8]), sub_byte(k_reg[103 -: 8])};
end

// seventh key expansion //
always @ (*) begin
    k_reg7 = k_in7;
    // rot word and sub word (seventh time) //
    tmp_key7 = {sub_byte(k_reg7[23:16])^8'h40, sub_byte(k_reg7[15:8]), sub_byte(k_reg7[7:0]) , sub_byte(k_reg7[31:24])};
    // rcon //
    k_reg7[127 -: 32] = tmp_key7 ^ k_reg7[127 -: 32];
    k_reg7[95 -: 32] = k_reg7[95 -: 32] ^ k_reg7[127 -: 32];
    k_reg7[63 -: 32] = k_reg7[63 -: 32] ^ k_reg7[95 -: 32];
    k_reg7[31 -: 32] = k_reg7[31 -: 32] ^ k_reg7[63 -: 32];    
    // k_reg = {k_reg[95:0], k_reg[127:96]};
    // // sub word //
    // k_reg[127 -: 32] = {sub_byte(k_reg[127 -: 8]), sub_byte(k_reg[119 -: 8]), sub_byte(k_reg[111 -: 8]), sub_byte(k_reg[103 -: 8])};
end

// eighth key expansion //
always @ (*) begin
    k_reg8 = k_in8;
    // rot word and sub word (eighth time) //
    tmp_key8 = {sub_byte(k_reg8[23:16])^8'h80, sub_byte(k_reg8[15:8]), sub_byte(k_reg8[7:0]) , sub_byte(k_reg8[31:24])};
    // rcon //
    k_reg8[127 -: 32] = tmp_key8 ^ k_reg8[127 -: 32];
    k_reg8[95 -: 32] = k_reg8[95 -: 32] ^ k_reg8[127 -: 32];
    k_reg8[63 -: 32] = k_reg8[63 -: 32] ^ k_reg8[95 -: 32];
    k_reg8[31 -: 32] = k_reg8[31 -: 32] ^ k_reg8[63 -: 32];    
    // k_reg = {k_reg[95:0], k_reg[127:96]};
    // // sub word //
    // k_reg[127 -: 32] = {sub_byte(k_reg[127 -: 8]), sub_byte(k_reg[119 -: 8]), sub_byte(k_reg[111 -: 8]), sub_byte(k_reg[103 -: 8])};
end

// ninth key expansion //
always @ (*) begin
    k_reg9 = k_in9;
    // rot word and sub word (ninth time) //
    tmp_key9 = {sub_byte(k_reg9[23:16])^8'h1b, sub_byte(k_reg9[15:8]), sub_byte(k_reg9[7:0]) , sub_byte(k_reg9[31:24])};
    // rcon //
    k_reg9[127 -: 32] = tmp_key9 ^ k_reg9[127 -: 32];
    k_reg9[95 -: 32] = k_reg9[95 -: 32] ^ k_reg9[127 -: 32];
    k_reg9[63 -: 32] = k_reg9[63 -: 32] ^ k_reg9[95 -: 32];
    k_reg9[31 -: 32] = k_reg9[31 -: 32] ^ k_reg9[63 -: 32];    
    // k_reg = {k_reg[95:0], k_reg[127:96]};
    // // sub word //
    // k_reg[127 -: 32] = {sub_byte(k_reg[127 -: 8]), sub_byte(k_reg[119 -: 8]), sub_byte(k_reg[111 -: 8]), sub_byte(k_reg[103 -: 8])};
end

// tenth key expansion //
always @ (*) begin
    k_reg10 = k_in10;
    // rot word and sub word (tenth time) //
    tmp_key10 = {sub_byte(k_reg10[23:16])^8'h36, sub_byte(k_reg10[15:8]), sub_byte(k_reg10[7:0]) , sub_byte(k_reg10[31:24])};
    // rcon //
    k_reg10[127 -: 32] = tmp_key10 ^ k_reg10[127 -: 32];
    k_reg10[95 -: 32] = k_reg10[95 -: 32] ^ k_reg10[127 -: 32];
    k_reg10[63 -: 32] = k_reg10[63 -: 32] ^ k_reg10[95 -: 32];
    k_reg10[31 -: 32] = k_reg10[31 -: 32] ^ k_reg10[63 -: 32];    
    // k_reg = {k_reg[95:0], k_reg[127:96]};
    // // sub word //
    // k_reg[127 -: 32] = {sub_byte(k_reg[127 -: 8]), sub_byte(k_reg[119 -: 8]), sub_byte(k_reg[111 -: 8]), sub_byte(k_reg[103 -: 8])};
end

// integer counter;
always @ (posedge clk) begin
    if (rst) begin
        counter = 0;
    end
    else begin
        counter = counter + 1;
    end
end

// assign pipeline input and output //
always @ (posedge clk) begin
    if (rst) begin
        // p_reg = 128'h0;
        // p_reg2 = 128'h0;
        C = 128'h0;
    end
    else begin
        p_in0 <= p_reg0;
        k_in0 <= k_reg0;
        p_in2 <= p_reg ^ k_reg;
        k_in2 <= k_reg;
        p_in3 <= p_reg2 ^ k_reg2;
        k_in3 <= k_reg2;
        p_in4 <= p_reg3 ^ k_reg3;
        k_in4 <= k_reg3;
        p_in5 <= p_reg4 ^ k_reg4;
        k_in5 <= k_reg4;
        p_in6 <= p_reg5 ^ k_reg5;
        k_in6 <= k_reg5;
        p_in7 <= p_reg6 ^ k_reg6;
        k_in7 <= k_reg6;
        p_in8 <= p_reg7 ^ k_reg7;
        k_in8 <= k_reg7;
        p_in9 <= p_reg8 ^ k_reg8;
        k_in9 <= k_reg8;
        p_in10 <= p_reg9 ^ k_reg9;
        k_in10 <= k_reg9;
        C <= p_reg10 ^ k_reg10;
    end
end

always @ (*) begin
    valid = (counter > 11)? 1 : 0;
end
// assign valid = (counter == 3)? 1 : 0;



// always @ (posedge clk) begin
//     if (rst) begin
//         p_reg = 128'h0;
//     end
//     else begin
//         p_reg2 <= p_reg;
//     end
// end

// // state transition logic //
// always @(*) begin
//     case(state)
//         IDLE: begin
//             if (valid) begin
//                 next_state = ADD_ROUND_KEY;
//             end
//             else begin
//                 next_state = IDLE;
//             end
//         end
//         ADD_ROUND_KEY: begin
//             next_state = SUB_BYTES;
//         end
//         SUB_BYTES: begin
//             next_state = SHIFT_ROWS;
//         end
//         SHIFT_ROWS: begin
//             next_state = MIX_COLUMNS;
//         end
//         MIX_COLUMNS: begin
//             next_state = IDLE;
//         end
//         default: begin
//             next_state = IDLE;
//         end
//     endcase
// end

// // state register //
// always @(posedge clk) begin
//     if (rst) begin
//         state <= IDLE;
//     end
//     else begin
//         state <= next_state;
//     end    
// end

// // datapath //
// always @(posedge clk) begin
//     case(state)
//         IDLE: begin
//             p_reg <= P;
//             k_reg <= K;
//             valid <= 0;
//         end
//         ADD_ROUND_KEY: begin
//             C <= p_reg ^ k_reg;
//             valid <= 1;
//         end
//         SUB_BYTES: begin
//             C <= p_reg;
//             valid <= 1;
//         end
//         SHIFT_ROWS: begin
//             C <= p_reg;
//             valid <= 1;
//         end
//         MIX_COLUMNS: begin
//             C <= p_reg;
//             valid <= 1;
//         end
//         default: begin
//             C <= p_reg;
//             valid <= 1;
//         end
//     endcase
// end

// assign p_reg_test = p_reg;
// assign k_reg_test = k_reg;
endmodule