// 
// Designer: N26124264
//
module alu(
    input signed [4:0] Din1,
    input signed [4:0] Din2,
    input [1:0] Sel,
    output signed [4:0] out
);
    reg [4:0] cal_result;
    always @ (*) begin
        case (Sel)
            2'b00: cal_result = Din1 + Din2;
            2'b11: cal_result = Din1 - Din2;
            default: cal_result = Din1;
        endcase
    end
    assign out = cal_result;
endmodule