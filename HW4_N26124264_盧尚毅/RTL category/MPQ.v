///////////////////
// N26124264    //
// Name: 盧尚毅 //
/////////////////

module MPQ(clk,rst,data_valid,data,cmd_valid,cmd,index,value,busy,RAM_valid,RAM_A,RAM_D,done);
input clk;
input rst;
input data_valid;
input [7:0] data;
input cmd_valid;
input [2:0] cmd;
input [7:0] index;
input [7:0] value;
output reg busy;
output reg RAM_valid;
output reg[7:0]RAM_A;
output reg [7:0]RAM_D;
output reg done;

//// variables declaration
parameter idle = 0, recieve = 1, heapify_change_value = 2, build_queue = 3, extract_max = 4, increase_value = 5, insert_data = 6, write = 7, write_done = 8, heapify = 9, swap = 10, swap_detect = 11, heapify_largest_detect = 12;
reg [7:0] queue [12:0];
reg [3:0] heap_index;
reg [4:0] right;
reg [4:0] left;
reg [4:0] largest;
reg [3:0] queue_number;
reg [7:0] tmp_value;
reg [4:0] state;
reg [4:0] next_state;
reg last_state; // to detect whether to go back to build_queue or not
reg [4:0] write_index;
reg [4:0] build_index;
reg [4:0] swap_index;
// reg cmd_reg;
reg one_more_heapify;
reg swap_sign;
wire swap_sign_w;

// assign swap_sign_w = (swap_index > 1) & (queue[swap_index-1] > queue[(swap_index >> 1)-1]);
// wire cond1 = ((left-1) <= (queue_number - 1)) & (queue[left-1] > queue[heap_index-1]);
// wire cond2 = ((right-1) <= (queue_number - 1)) & (queue[right-1] > queue[largest-1]);
//// state register
always @(posedge clk or posedge rst) begin
    if (rst)
        state <= idle;
    else
        state <= next_state;
end

//// datapath
always @ (posedge clk or posedge rst) begin
    if (rst) begin
        busy = 0;
        RAM_valid = 0;
        // RAM_A = 0;
        // RAM_D = 0;
        done = 0;
        heap_index = 0;
    end
    else begin
        case (next_state)
            idle: begin
                busy <= 0;
                RAM_valid <= 0;
                RAM_A <= 0;
                RAM_D <= 0;
                done <= 0;
                heap_index <= 0;
            end
            recieve: begin
                queue[queue_number] <= data;
                busy <= 1;
            end
            heapify: begin
                left = heap_index << 1;
                right = left + 1;
                if (((left-1) <= (queue_number - 1)) & ((queue[left-1] > queue[heap_index-1]))) begin
                    largest = left;
                end
                else begin
                    largest = heap_index;
                end
            end
            heapify_largest_detect: begin
                // largest = ((left-1) <= (queue_number - 1) && (queue[left-1] > queue[heap_index-1])) ? left : heap_index;
                if (((right-1) <= (queue_number - 1)) & (queue[right-1] > queue[largest-1])) begin
                    largest = right;
                end
                ////////////////////////////////////////////////////////////////////////////////////
                // largest = heap_index;
                // if ((right-1) <= (queue_number - 1) && (queue[right-1] > queue[largest-1])) begin
                //     largest = right;
                // end
                // else if ((left-1) <= (queue_number - 1) && (queue[left-1] > queue[heap_index-1])) begin
                //     largest = left;
                // end
            end
            heapify_change_value: begin
                // one_more_heapify <= (largest != heap_index)? 1 : 0;
                
                if (largest != heap_index) begin
                    // tmp_value = queue[heap_index-1];
                    // queue[heap_index-1] = queue[largest-1];
                    // queue[largest-1] = tmp_value;
                    queue[heap_index-1] <= queue[largest-1];
                    queue[largest-1] <= queue[heap_index-1];
                    heap_index <= largest;
                    // one_more_heapify <= 1;
                end
                else begin
                    if (build_index == 1) begin
                        // one_more_heapify <= 0;
                        busy <= 0;
                        // busy <= ~(build_index == 1);
                    end
                    else begin
                        // one_more_heapify <= 1;
                        heap_index <= build_index - 1;
                        build_index <= build_index - 1;
                    end
                end
            end
            build_queue: begin
                busy = 1;
                last_state = 1;
                // build_index = (state != idle) ? build_index-1 : queue_number;
                build_index = queue_number;
                // if (state != idle )
                //     build_index = build_index - 1;
                // else
                //     build_index = queue_number;
                heap_index = build_index;
            end
            extract_max: begin
                busy <= 1;
                queue[0] <= queue[queue_number-1];
                heap_index <= 1;
            end
            increase_value: begin
                busy <= 1;
                swap_index = (state == insert_data) ? queue_number : index;
                queue[swap_index-1] = (state == insert_data) ? tmp_value: value;
                // swap_index <= (state == insert_data) ? queue_number : index;
                // queue[index-1] <= value;
                // swap_sign = (swap_index > 1) && (queue[swap_index-1] > queue[(swap_index >> 1)-1]);
                // swap_sign = (swap_index > 1) && (queue[swap_index-1] > queue[(swap_index >> 1)-1]);
                // swap_index = swap_index;
                // if(state == insert_data) begin
                //     queue[queue_number-1] = tmp_value;
                //     swap_sign = (queue_number > 1) && (queue[queue_number-1] > queue[(queue_number >> 1)-1]);
                //     swap_index = queue_number;
                // end
                // else begin
                //     // queue[index-1] = value;
                //     queue[index-1] = value;
                //     swap_sign = (index > 1) && (queue[index-1] > queue[(index >> 1)-1]);
                //     swap_index = index;
                // end
            end
            insert_data: begin
                busy <= 1;
                tmp_value = value;
                // swap_index <= queue_number + 1;
                // queue[queue_number] <= value;
                // queue[queue_number-1] = value;
                // queue[index-1] = value;
                // swap_sign = (queue_number > 1) && (queue[queue_number-1] > queue[(queue_number >> 1)-1]);
                // swap_index = queue_number;
                // swap_sign = (queue_number > 1) && (queue[queue_number] > queue[(queue_number >> 1)-1]);
                // swap_index = queue_number;
            end
            swap: begin
                // tmp_value = queue[swap_index-1];
                // queue[swap_index-1] = queue[(swap_index >> 1)-1];
                // queue[(swap_index >> 1)-1] = tmp_value;
                // swap_index = swap_index >> 1;
                // swap_sign = (swap_index > 1) && (queue[swap_index-1] > queue[(swap_index >> 1)-1]);

                queue[swap_index-1] <= queue[(swap_index >> 1)-1];
                queue[(swap_index >> 1)-1] <= queue[swap_index-1];
                swap_index <= swap_index >> 1;
            end
            // swap_detect: begin
            //     swap_sign <= (swap_index > 1) & (queue[swap_index-1] > queue[(swap_index >> 1)-1]);
            // end
            write: begin
                busy <= 1;
                RAM_valid <= 1;
                RAM_A <= write_index;
                RAM_D <= queue[write_index];
                // done <= 0;
            end
            write_done: begin
                done <= 1;
            end
            default: begin
                // busy <= 0;
                // RAM_valid <= 0;
                // RAM_A <= 0;
                // RAM_D <= 0;
                // done <= 0;
            end
        endcase
    end
end

//// next state logic
always @ (*) begin
    case (state)
        idle: begin
            if (cmd_valid) begin
                case(cmd)
                    3'b000: next_state <= build_queue;
                    3'b001: next_state <= extract_max;
                    3'b010: next_state <= increase_value;
                    3'b011: next_state <= insert_data;
                    3'b100: next_state <= write;
                    default: next_state <= idle;
                endcase
                // below code become above case statement will reduce about 10 logic elements
                // if more than 3 conditions and no priority, case statement is better
                // if (cmd == 3'b000)
                //     next_state <= build_queue;
                // else if (cmd == 3'b001)
                //     next_state <= extract_max;
                // else if (cmd == 3'b010)
                //     next_state <= increase_value;
                // else if (cmd == 3'b011)
                //     next_state <= insert_data;
                // else if (cmd == 3'b100)
                //     next_state <= write;
                // else if (data_valid)
                //     next_state <= recieve;
            end
            else if (data_valid)
                next_state <= recieve;
            else
                next_state <= idle;
        end
        recieve: begin
            next_state <= (data_valid) ? recieve : idle;
            // if (data_valid)
            //     next_state <= recieve;
            // else 
            //     next_state <= idle;
        end
        increase_value: begin
            // if (swap_sign)
            //     next_state <= swap;
            // else
            //     next_state <= idle;
            // next_state <= swap_detect;
            next_state <= (swap_index > 1) & (queue[swap_index-1] > queue[(swap_index >> 1)-1])? swap : idle;
        end
        swap: begin
            // next_state <= swap_detect;
            next_state <= (swap_index > 1) & (queue[swap_index-1] > queue[(swap_index >> 1)-1])? swap : idle;

            // if (swap_sign)
            //     next_state <= swap;
            // else
            //     next_state <= idle;
        end
        swap_detect: begin
            next_state <= (swap_sign) ? swap : idle;
            // if (swap_sign)
            //     next_state <= swap;
            // else
            //     next_state <= idle;
        end
        insert_data: begin
            // if (swap_sign)
            //     next_state <= swap;
            // else
            //     next_state <= idle;
            next_state <= increase_value;
            // next_state <= (swap_index > 1) & (queue[swap_index-1] > queue[(swap_index >> 1)-1])? swap : idle;
        end
        write: begin
            next_state <= (write_index == queue_number) ? write_done : write;
            // if (write_index == queue_number)
            //     next_state <= write_done;
            // else
            //     next_state <= write;
        end
        write_done: begin
            next_state <= idle;
        end
        // command: begin
        //     if (cmd_reg == 3'b000)
        //         next_state <= build_queue;
        //     else if (cmd_reg == 3'b001)
        //         next_state <= extract_max;
        //     else if (cmd_reg == 3'b010)
        //         next_state <= increase_value;
        //     else if (cmd_reg == 3'b011)
        //         next_state <= insert_data;
        //     else if (cmd_reg == 3'b100)
        //         next_state <= write;
        //     else
        //         next_state <= idle;
        // end
        build_queue: begin
            // next_state <= (heap_index == 0) ? idle : heapify;
            next_state <= heapify;
            // if (heap_index == 0) begin
            //     next_state <= idle;
            // end
            // else
            //     next_state <= heapify;
        end
        heapify: begin
            // case(cmd)
            //     3'b000: next_state <= heapify_largest_detect;
            //     3'b001: next_state <= extract_max;
            //     3'b010: next_state <= increase_value;
            //     3'b011: next_state <= insert_data;
            //     3'b100: next_state <= write;
            //     default: next_state <= idle;
            // endcase
            next_state <= heapify_largest_detect;
        end
        heapify_largest_detect: begin
            next_state <= heapify_change_value;
        end
        heapify_change_value: begin
            // if(one_more_heapify)
            //     next_state <= heapify;
            // else if (last_state == build_queue)
            //     next_state <= build_queue;
            // else
            //     next_state <= idle;
            // if (one_more_heapify)
            //     next_state <= heapify;
            // else begin
            case(cmd)
                3'b000: next_state <= heapify;
                3'b001: next_state <= extract_max;
                3'b010: next_state <= increase_value;
                3'b011: next_state <= insert_data;
                3'b100: next_state <= write;
                default: next_state <= idle;
            endcase
            // end
            // next_state <= (one_more_heapify) ? heapify : (last_state == 1) ? build_queue : idle;
        end
        extract_max: begin
            next_state <= heapify;
        end
        default: begin
            next_state <= idle;
        end
    endcase
end

// queue number counter
// always @(posedge clk or posedge rst) begin
//     if (rst)
//         queue_number <= 0;
//     else if (data_valid)
//         queue_number <= queue_number + 1;
//     else if (next_state == extract_max)
//         queue_number <= queue_number - 1;
//     else if (next_state == insert_data)
//         queue_number <= queue_number + 1;
//     else
//         queue_number <= queue_number;
// end 

// queue number test counter
always @(posedge clk or posedge rst) begin
    if (rst)
        queue_number <= 0;
    else begin
        case(next_state)
            recieve: begin
                queue_number <= queue_number + 1;
            end
            insert_data: begin
                queue_number <= queue_number + 1;
            end
            extract_max: begin
                queue_number <= queue_number - 1;
            end
            default: begin
                queue_number <= queue_number;
            end
        endcase
    end
end

// write index counter
// always @(posedge clk or posedge rst) begin
//     if (rst)
//         write_index <= 0;
//     else if (state == idle)
//         write_index = 0;
//     else if (state == write)
//         write_index = write_index + 1;
//     else
//         write_index = write_index;
// end

// write index test counter
always @(posedge clk or posedge rst) begin
    if (rst)
        write_index <= 0;
    else begin
        // write_index <= (state == idle) ? 0 : (state == write) ? write_index + 1 : write_index;
        case(state)
            idle: begin
                write_index <= 0;
            end
            write: begin
                write_index <= write_index + 1;
            end
            default: begin
                write_index <= write_index;
            end
        endcase
    end
end

// build index counter
// always @(posedge clk or posedge rst) begin
//     if (rst)
//         heap_index <= 0;
//     else if (state == command && cmd == 3'b000)
//         heap_index = queue_number >> 1;
//     else if (state == build_queue)
//         heap_index = heap_index - 1;
//     else if (state == extract_max)
//         heap_index = 1;
//     else
//         heap_index = heap_index;
// end
// assign done = (state == build_queue && heap_index == 0) ? 1 : 0;
// assign done = (state == write_done) ? 1 : 0;
endmodule