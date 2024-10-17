// 
// Designer: N26124264 
//

module comp(
    input signed [4:0] Din1,
    input signed [4:0] Q,
    output signed[1:0] out
);
    // reg [1:0] out_reg;
    // always @ (*) begin
    //     // ex 7 mod 5 = 2
    //     if (Din1 >= Q ) begin
    //         out_reg = 2'b11;
    //     end
    //     // Q > Din1 > 0 ex 3 mod 5 = 3
    //     else if (Din1 >= 0) begin
    //         out_reg = 2'b01;
    //     end
    //     // < 0 ex -3 mod 5 = 2
    //     else begin
    //         out_reg = 2'b00;
    //     end
    // end
    // assign out = out_reg;
    assign out = { (Din1 >= Q), (Din1 >= 0)};
    // assign out = (Din1 >= Q) ? 2'b11 : (Din1 >= 0) ? 2'b01 : 2'b00;
endmodule