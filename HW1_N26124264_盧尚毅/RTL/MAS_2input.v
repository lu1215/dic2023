// 
// Designer: N26124264 
//

`include "ALU.v"
`include "comparator.v"

module MAS_2input(
    input signed [4:0]Din1,
    input signed [4:0]Din2,
    input [1:0]Sel,
    input signed[4:0]Q,
    output [1:0]Tcmp,
    output signed [4:0]TDout,
    output signed [3:0]Dout
);

wire [1:0] comp_out;
wire signed [4:0] alu1_out, alu2_out;

alu alu1(
    .Din1(Din1),
    .Din2(Din2),
    .Sel(Sel),
    .out(alu1_out)
);

comp comp1(
    .Din1(alu1_out),
    .Q(Q),
    .out(comp_out)
);

alu alu2(
    .Din1(alu1_out),
    .Din2(Q),
    .Sel(comp_out),
    .out(alu2_out)
);

assign Tcmp = comp_out;
assign TDout = alu1_out;
assign Dout = alu2_out[3:0];

/*Write your design here*/

endmodule