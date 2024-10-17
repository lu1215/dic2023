`timescale 1ns/10ps
module MM( in_data, col_end, row_end, is_legal, out_data, rst, clk , change_row,valid,busy);
input           clk;
input           rst;
input           col_end;
input           row_end;
input      [7:0]     in_data;

output reg signed [19:0]   out_data;
output is_legal;
output reg change_row,valid,busy;

// variable declaration
reg [127:0] m1;
reg [127:0] m2;
// reg [7:0] m1[0:3][0:3];
// reg [7:0] m2[];
// m1 counter
reg [2:0] m1_row_counter;
reg [2:0] m1_col_counter;
// m2 counter
reg [2:0] m2_row_counter;
reg [2:0] m2_col_counter;
// signal declaration
// reg busy_signal;
reg error_signal;
// state machine
parameter idle = 0, data_to_matrix1 = 1, data_to_matrix1_end = 2,  data_to_matrix2 = 3, data_to_matrix2_end = 4,check = 5, change_row_st = 6, multiply = 7, multiply_done = 8;
reg [3:0] state, next_state;
// tmp register
reg [4:0] m1_num;
reg [4:0] m2_num;
reg [4:0] out_data_num;
reg [2:0] row_index;
reg [2:0] col_index;
// reg [2:0] i = 0;
// reg [7:0] tmp;
// reg [7:0] tmp2;
// reg [7:0] tmp3;
// reg [7:0] tmp4;


// state transition logic
always @(*) begin
    case(state)
        idle: begin
            if(col_end == 1 && row_end == 1)
                next_state = data_to_matrix1_end;
            else
                next_state = data_to_matrix1;
        end
        data_to_matrix1: begin
            if(col_end == 1 && row_end == 1)
                next_state = data_to_matrix1_end;
            else
                next_state = data_to_matrix1;
        end
        data_to_matrix1_end: begin
            if(col_end == 1 && row_end == 1) begin
                next_state = data_to_matrix2_end;
            end
            else 
                next_state = data_to_matrix2;
        end
        data_to_matrix2: begin
            if(col_end == 1 && row_end == 1) begin
                next_state = data_to_matrix2_end;
            end
            else 
                next_state = data_to_matrix2;
        end
        data_to_matrix2_end: begin
            next_state = check;
        end
        check: begin
            if(error_signal == 0) begin
                next_state = multiply;
            end
            else begin
                next_state = idle;
            end
        end
        // multiply_ready: begin
        //     next_state = multiply;
        // end

        multiply: begin
            if (out_data_num == 0)
                next_state = multiply_done;
            else
                next_state = multiply;
        end
        multiply_done: begin
            // next_state = idle;
            // if number of matrix is 1, then data1_to_m1_end state
            if(col_end == 1 && row_end == 1)
                next_state = data_to_matrix1_end;
            else
                next_state = data_to_matrix1;
            // next_state = data_to_matrix1;
        end
    endcase
end

//state register
always @(posedge clk or posedge rst) begin
    if(rst)
        state <= idle;
    else
        state <= next_state;
end

// row counter logic
always @ (posedge clk or posedge rst) begin
    if(rst) begin
        m1_row_counter <= 0;
        m2_row_counter <= 0;
    end
    else if(next_state == idle) begin
        m1_row_counter <= 0;
        m2_row_counter <= 0;
    end
    else if((next_state == data_to_matrix1 || next_state == data_to_matrix1_end) && col_end == 1) begin
        m1_row_counter <= m1_row_counter + 1;
    end
    else if((next_state == data_to_matrix2 || next_state == data_to_matrix2_end) && col_end == 1) begin
        m2_row_counter <= m2_row_counter + 1;
    end
    else if(next_state == multiply_done) begin
        m1_row_counter <= 0;
        m2_row_counter <= 0;
    end
    else begin
        m1_row_counter <= m1_row_counter;
        m2_row_counter <= m2_row_counter;
    end
end

// column counter logic
always @ (posedge clk or posedge rst) begin
    if(rst) begin
        m1_col_counter <= 0;
        m2_col_counter <= 0;
    end
    else if (col_end == 1 && row_end != 1) begin
        if (next_state == data_to_matrix1 || next_state == data_to_matrix1_end)
            m1_col_counter <= 0;
        else if (next_state == data_to_matrix2 || next_state == data_to_matrix2_end)
            m2_col_counter <= 0;
        // m1_col_counter <= 0;
        // m2_col_counter <= 0;
    end
    else begin
        case (next_state)
            idle: begin
                m1_col_counter <= 0;
                m2_col_counter <= 0;
            end
            data_to_matrix1: begin
                m1_col_counter <= m1_col_counter + 1;
            end
            data_to_matrix1_end: begin
                if (row_end == 1)
                    m1_col_counter <= m1_col_counter + 1;
                else
                    m1_col_counter <= m1_col_counter + 1;
            end
            data_to_matrix2: begin
                m2_col_counter <= m2_col_counter + 1;
            end
            data_to_matrix2_end: begin
                if (row_end == 1)
                    m2_col_counter <= m2_col_counter + 1;
                else
                    m2_col_counter <= m2_col_counter + 1;
            end
            multiply_done: begin
                m1_col_counter <= 0;
                m2_col_counter <= 0;
            end
            default: begin
                m1_col_counter <= m1_col_counter;
                m2_col_counter <= m2_col_counter;
            end
        endcase
    end
end

// total num of matrix counter
always @ (posedge clk or posedge rst) begin
    if(rst) begin
        m1_num <= 0;
        m2_num <= 0;
        row_index <= 0;
    end
    else begin
        case(next_state)
            idle: begin
                m1_num <= 0;
                m2_num <= 0;
            end
            data_to_matrix1: begin
                m1_num <= m1_num + 1;
            end
            data_to_matrix1_end: begin
                m1_num <= m1_num + 1;
            end
            data_to_matrix2: begin
                m2_num <= m2_num + 1;
            end
            data_to_matrix2_end: begin
                m2_num <= m2_num + 1;
            end
            default: begin
                m1_num <= m1_num;
                m2_num <= m2_num;
            end
            multiply: begin
                row_index <= row_index + 1;
                if (row_index == m2_col_counter - 1) begin
                    m1_num <= m1_num - m1_col_counter;
                    row_index <= 0;
                end
            end
            multiply_done: begin
                m1_num <= 0;
                m2_num <= 0;
                row_index <= 0;
            end
        endcase
    end
end

// output data num counter
always @ (posedge clk or posedge rst) begin
    if(rst) begin
        out_data_num <= 0;
    end
    else begin
        case(next_state)
            check: begin
                out_data_num = m1_row_counter * m2_col_counter;
            end
            // multiply_ready: begin
            //     out_data_num <= out_data_num - 1;
            // end
            multiply: begin
                out_data_num <= out_data_num - 1;
            end
            default: begin
                out_data_num <= out_data_num;
            end
        endcase
    end
end

// matrix multiplication counter
// always @ (posedge clk or posedge rst) begin
//     if(rst) begin
//         out_data <= 0;
//     end
//     else begin
//         case(next_state)
//             multiply: begin
//                 if (m1_col_counter == 1) begin
//                     out_data = m1[0: 7] * m2[0: 7];
//                 end
//                 else if (m1_col_counter == 2) begin
//                     out_data = m1[0: 7] * m2[0: 7] + m1[8: 15] * m2[16: 23];
//                 end
//                 else if (m1_col_counter == 3) begin
//                     out_data = m1[0: 7] * m2[0: 7] + m1[8: 15] * m2[16: 23] + m1[16: 23] * m2[32: 39];
//                 end
//                 else begin
//                     out_data = m1[0: 7] * m2[0: 7] + m1[8: 15] * m2[16: 23] + m1[16: 23] * m2[32: 39] + m1[24: 31] * m2[40: 47];
//                 end
//             end
//             default: begin
//                 out_data = 0;
//             end
//         endcase
//     end
// end 

// datapath
always @ (posedge clk or posedge rst) begin
    if(rst) begin
        m1 <= 0;
        m2 <= 0;
        busy <= 0;
        valid <= 0;
        // m1_col_counter <= 0;
        // m2_col_counter <= 0;
        // m1_row_counter <= 0;
        // m2_row_counter <= 0;
    end
    else begin
        case(next_state)
            idle: begin
                // if(state == idle) begin
                out_data <= 0;
                m1 <= 0;
                m2 <= 0;
                busy = 0;
                valid = 0;
                change_row = 0;
                // m1_col_counter <= 0;
                // m2_col_counter <= 0;
                // m1_row_counter <= 0;
                // m2_row_counter <= 0;
                // end
            end
            // start from here 0501
            data_to_matrix1: begin
                m1 <= { m1[119: 0], in_data};
            end
            data_to_matrix1_end: begin
                m1 <= { m1[119: 0], in_data};
            end
            data_to_matrix2: begin
                m2 <=  { m2[119: 0], in_data};
            end
            data_to_matrix2_end: begin
                m2 <=  { m2[119: 0], in_data};
            end
            check: begin
                busy <= 1;
                // check if two matrix can be multiplied and total num of matrix is correct 
                error_signal = (m1_col_counter == m2_row_counter) && (m1_num == m1_col_counter*m1_row_counter) && (m2_num== m2_row_counter*m2_col_counter)? 0: 1;
                if (error_signal) 
                    valid = 1;
            end
            multiply: begin
                // row_index = out_data_num / m1_row_counter;
                // i = 0
                if (row_index == m2_col_counter - 1)
                    change_row = 1;
                else
                    change_row = 0;
                valid = 1;
                out_data = 0;
                // col_index <= out_data_num % m2_col_counter;
                // tmp2 =  m2[(((m2_num - row_index)<<3) - 1) -: 8];
                // tmp = m1[(((m1_num-i) << 3) - 1) -: 8];
                // tmp2 = 0;
                // tmp3 = 0;
                // tmp4 = 0;

                //// new test code
                if (m1_col_counter == 1)
                    out_data <= $signed(m1[((m1_num << 3) -1) -: 8]) * $signed(m2[(((m2_num - row_index)<<3) -1) -: 8]);
                else if(m1_col_counter == 2)
                    out_data <= $signed(m1[((m1_num << 3) -1) -: 8]) * $signed(m2[(((m2_num - row_index)<<3) -1) -: 8]) + $signed(m1[(((m1_num-1) << 3)-1) -: 8]) * $signed(m2[(((m2_num - row_index - m2_col_counter)<<3)-1) -: 8]);
                else if (m1_col_counter == 3)
                    out_data <= $signed(m1[((m1_num << 3) -1) -: 8]) * $signed(m2[(((m2_num - row_index)<<3) -1) -: 8]) + $signed(m1[(((m1_num-1) << 3)-1) -: 8]) * $signed(m2[(((m2_num - row_index - m2_col_counter)<<3)-1) -: 8]) + $signed(m1[(((m1_num-2)<<3)-1) -: 8]) * $signed(m2[(((m2_num - row_index - (m2_col_counter<<1))<<3)-1) -: 8]);
                else 
                    out_data <= $signed(m1[((m1_num << 3) -1) -: 8]) * $signed(m2[(((m2_num - row_index)<<3) -1) -: 8]) + $signed(m1[(((m1_num-1) << 3)-1) -: 8]) * $signed(m2[(((m2_num - row_index - m2_col_counter)<<3)-1) -: 8]) + $signed(m1[(((m1_num-2)<<3)-1) -: 8]) * $signed(m2[(((m2_num - row_index - (m2_col_counter<<1))<<3)-1) -: 8]) + $signed(m1[(((m1_num-3)<<3)-1) -: 8]) * $signed(m2[(((m2_num - row_index - ((m2_col_counter<<2)- m2_col_counter))<<3)-1) -: 8]);

                //// original code
                // if (m1_col_counter >= 1) begin
                //     out_data = $signed(m1[((m1_num << 3) -1) -: 8]) * $signed(m2[(((m2_num - row_index)<<3) -1) -: 8]) + out_data;
                //     // tmp2 =  m2[(((m2_num - row_index)<<3) - 1) -: 8];
                // end
                // if (m1_col_counter >= 2) begin
                //     out_data = $signed(m1[(((m1_num-1) << 3)-1) -: 8]) * $signed(m2[(((m2_num - row_index - m2_col_counter)<<3)-1) -: 8]) + out_data;
                //     // tmp3 = m2[(((m2_num - row_index - m2_col_counter)<<3)-1) -: 8];
                //     // tmp2 = m2[(((m2_num - row_index - col_index*m2_col_counter)<<3)-1) -: 8];
                // end
                // if (m1_col_counter >= 3) begin
                //     out_data = $signed(m1[(((m1_num-2)<<3)-1) -: 8]) * $signed(m2[(((m2_num - row_index - (m2_col_counter<<1))<<3)-1) -: 8]) + out_data;
                //     // tmp4 = m2[(((m2_num - row_index - (m2_col_counter<<1))<<3)-1) -: 8];
                // end
                // if (m1_col_counter >= 4) begin
                //     out_data = $signed(m1[(((m1_num-3)<<3)-1) -: 8]) * $signed(m2[(((m2_num - row_index - ((m2_col_counter<<2)- m2_col_counter))<<3)-1) -: 8]) + out_data;
                // end
                // for (i = 0; i< m1_col_counter; i = i+1) begin
                //     out_data = m1[((m1_num-i)*8-1) -: 8] * m2[((m2_num - col_index*i*m2_col_counter)*8-1) -: 8] + out_data;
                // end
                
                // out_data = m1[row_index*8 +: 8] * m2[col_index*8 +: 8] + out_data;
            end
            multiply_done: begin
                change_row = 0;
                m1 <= 0;
                m2 <= 0;
                // m2_row_counter <= 0;
                // m1_row_counter <= 0;
                // m1_col_counter <= 0;
                // m2_col_counter <= 0;
                out_data <= 0;
                busy = 0;
                valid = 0;
            end
        endcase
    end 
end

assign is_legal = (state == check)? ((error_signal)? 0 : 1) : 1'bx;
// assign change_row = (state == multiply)? ((row_index == 0)? 1 : 0) : 0;
// assign out_data = (state == multiply)?  : 20'b0;
endmodule
