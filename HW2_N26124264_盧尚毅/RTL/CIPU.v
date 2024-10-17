//N26124264 盧尚毅//
module CIPU(
input       clk, 
input       rst,
input       [7:0]people_thing_in,
input       ready_fifo,
input       ready_lifo,
input       [7:0]thing_in,
input       [3:0]thing_num,
output      valid_fifo,
output      valid_lifo,
output      valid_fifo2,
output      [7:0]people_thing_out,
output      [7:0]thing_out,
output      done_thing,
output      done_fifo,
output      done_lifo,
output      done_fifo2);
// size parameter of FIFO, LIFO and element length
parameter FIFO_len = 16, LIFO_len = 16, ele_ment_len = 8;

///// FSM1(passenger FIFO)
// output check in people 
reg [ FIFO_len * ele_ment_len - 1 :0] people_fifo;
parameter idle = 0, input_people = 1, in_people_end = 2, out_people_ready = 3, out_people = 4, out_people_end = 5, out_people_done = 6;
// because data will be output in the next cycle, so we need to use a out_people state to  the output data
reg [3:0] stage_pa_fifo, next_pa_fifo;
reg [4:0] people_num_counter;
reg [7:0] people_thing_out_reg;
// stage transition logic
always @ (*) begin
    case(stage_pa_fifo)
        idle: next_pa_fifo = (ready_fifo) ? input_people: idle;
        // if input is 0x24($), then go to in_people_end
        input_people: next_pa_fifo = (people_thing_in == 8'h24) ? in_people_end: input_people;
        // ready to output people
        in_people_end: next_pa_fifo = out_people_ready;
        // prepare first output people
        out_people_ready: next_pa_fifo = (people_num_counter == 1) ? out_people_end: out_people;
        // output people, if people_num_counter == 0, then go to out_people_end
        out_people: next_pa_fifo = (people_num_counter == 1) ? out_people_end: out_people;
        // output the last people and ready to output done signal(because output will be sent in the next cycle)
        out_people_end: next_pa_fifo = out_people_done;
        // done signal output, and clear the FIFO
        out_people_done: next_pa_fifo = idle;
    endcase
end
// state register
always @(posedge clk) begin
    if(rst) begin
        stage_pa_fifo <= idle;
    end
    else begin
        stage_pa_fifo <= next_pa_fifo;
    end
end

// people num counter
always @ (posedge clk) begin
    if (rst) begin
        people_num_counter <= 0;
    end
    else begin
        case(stage_pa_fifo)
            input_people: begin
                // if people_thing_in is between 0x41(A) and 0x5A(Z) (passenger), then counter + 1
                if ((people_thing_in >=  8'h41 && people_thing_in <= 8'h5A) && people_num_counter <= 16) begin
                    people_num_counter <= people_num_counter + 1;
                end
                else
                    people_num_counter <= people_num_counter;
            end
            // out_people_ready prepare first output data, so we need to make counter -1
            out_people_ready: people_num_counter <= people_num_counter - 1;
            out_people: people_num_counter <= people_num_counter - 1;
        endcase
    end
end

// action in each state
always @ (posedge clk) begin
    case(stage_pa_fifo)
        input_people: begin
            if (people_thing_in >=  8'h41 && people_thing_in <= 8'h5A) begin
                people_fifo <= {people_fifo[(FIFO_len * ele_ment_len - 1) - 8:0], people_thing_in};
            end
            else
                people_fifo <= people_fifo;
        end
        // because data will be output in the next cycle, so we need to use a out_people_ready to prepare first output data
        out_people_ready: begin
            people_thing_out_reg <= people_fifo[people_num_counter * ele_ment_len - 1 -: 8];
        end
        out_people: begin
            people_thing_out_reg <= people_fifo[people_num_counter * ele_ment_len - 1 -: 8];
        end
        // if people_num_counter == 0, we need to output the last data and ready to output done signal, and we need to clear the FIFO
        default: begin
            people_fifo <= people_fifo;
        end
    endcase
end
assign valid_fifo = (stage_pa_fifo == out_people || stage_pa_fifo == out_people_end) ? 1: 0;
assign people_thing_out = (stage_pa_fifo == out_people || stage_pa_fifo == out_people_end) ? people_thing_out_reg: 8'hx;
assign done_fifo = (stage_pa_fifo == out_people_done) ? 1: 0;

///// FSM2(Thing LIFO)
//declaration
reg [ LIFO_len * ele_ment_len - 1 :0] thing_lifo;
reg [4:0] thing_num_reg;
reg [7:0] thing_out_reg;
reg [ FIFO_len * ele_ment_len - 1 :0] thing_fifo;
integer thing_fifo_num = 0;
// integer  thing_in_fifo;

// state define
parameter input_thing = 1, in_thing_end = 2, pop_thing_ready = 3, pop_thing = 4, pop_thing_end = 5, pop_thing_done = 6, pop_none = 7, d_lifo = 8;
reg [3:0] stage_th_lifo, next_th_lifo;

// state transition logic
always @ (*) begin
    case(stage_th_lifo)
        idle: next_th_lifo = (ready_lifo) ? input_thing: idle;
        input_thing: next_th_lifo = (thing_in == 8'h24)? d_lifo: (thing_in == 8'h3b) ?  in_thing_end: input_thing;
        // make last thing can be put in lifo correctly
        in_thing_end: next_th_lifo = (thing_num_reg == 4'b0)? pop_none: pop_thing_ready;
        pop_thing_ready: next_th_lifo =  (thing_num_reg == 4'b1) ? pop_thing_end: pop_thing;
        pop_none: next_th_lifo = pop_thing_end;
        pop_thing: next_th_lifo = (thing_num_reg == 4'b1) ? pop_thing_end: pop_thing;
        pop_thing_end: next_th_lifo = pop_thing_done;
        pop_thing_done: next_th_lifo =  input_thing;
        d_lifo: next_th_lifo = idle;
    endcase
end

// state register
always @(posedge clk) begin
    if(rst) begin
        stage_th_lifo <= idle;
    end
    else begin
        stage_th_lifo <= next_th_lifo;
    end
end

// thing num counter
always @ (posedge clk) begin
    if (rst) begin
        thing_num_reg <= 0;
    end
    else begin
        case(stage_th_lifo)
            input_thing: begin
                if (thing_in == 8'h3b) begin
                    thing_num_reg <= thing_num_reg;
                end
                else begin
                    thing_num_reg <= thing_num;
                end
            end
            pop_thing_ready: begin
                thing_num_reg <= thing_num_reg - 1;
            end
            pop_thing: begin
                thing_num_reg <= thing_num_reg - 1;
            end
        endcase
    end
end

// action in each state
always @ (posedge clk) begin
    if(rst) begin
        thing_lifo <= {LIFO_len*{8'hx}};
    end
    else begin
        case(stage_th_lifo)
            input_thing: begin
                if (thing_in != 8'h24 && thing_in != 8'h3b)
                    thing_lifo = {thing_lifo[(LIFO_len * ele_ment_len - 1) - 8:0], thing_in};
                else 
                    thing_lifo = thing_lifo;
            end
            pop_thing_ready: begin
                thing_out_reg = thing_lifo[7-:8];
                thing_lifo = {LIFO_len*{8'hx}, thing_lifo[(LIFO_len * ele_ment_len - 1) : 8]};
                // store the output data in the FIFO
                thing_fifo = {thing_out_reg, thing_fifo[(FIFO_len * ele_ment_len - 1): 8]};
            end
            pop_thing: begin
                thing_out_reg = thing_lifo[7-:8];
                thing_lifo = {LIFO_len*{8'hx}, thing_lifo[(LIFO_len * ele_ment_len -1) : 8]};
                // store the output data in the FIFO
                thing_fifo = {thing_out_reg, thing_fifo[(FIFO_len * ele_ment_len - 1): 8]};
            end
            pop_none: begin
                thing_out_reg = 8'h30;
            end
            default: begin
                thing_lifo <= thing_lifo;
            end
        endcase
    end
end


assign valid_lifo = (stage_th_lifo == pop_thing || stage_th_lifo == pop_thing_end) ? 1: 0;
assign done_lifo = (stage_th_lifo == d_lifo) ? 1: 0;

//// FSM3(Thing FIFO)
// //declaration
reg [2:0] thing_fifo_stage, thing_fifo_next;
reg [7:0] thing_fifo_output;
// // state define (idle = 0)
parameter out_thing_fifo_ready = 2, out_thing_fifo = 3, out_thing_fifo_end = 4, out_thing_fifo_done = 5, stack_num_check = 6;

// fifo counter
always @ (posedge clk) begin
    if (rst) begin
        thing_fifo_num <= 0;
    end
    else begin
        if (stage_th_lifo == input_thing ) begin
            if (thing_in == 8'h24 || thing_in == 8'h3b || thing_fifo_num == 16)
                thing_fifo_num <= thing_fifo_num;
            else
                thing_fifo_num <= thing_fifo_num + 1;
        end
        else if ((stage_th_lifo == pop_thing_ready || stage_th_lifo == pop_thing || thing_fifo_stage ==out_thing_fifo_ready || thing_fifo_stage ==out_thing_fifo)) begin
            thing_fifo_num <= thing_fifo_num - 1;
        end
        else
            thing_fifo_num <= thing_fifo_num;
    end
end


// state transition logic
always @ (*) begin
    case(thing_fifo_stage)
        idle: thing_fifo_next = (stage_th_lifo == d_lifo) ? out_thing_fifo_ready: idle;
        out_thing_fifo_ready: thing_fifo_next = (thing_fifo_num == 4'b1) ? out_thing_fifo_end: out_thing_fifo;
        out_thing_fifo: thing_fifo_next = (thing_fifo_num == 4'd1) ? out_thing_fifo_end: out_thing_fifo;
        out_thing_fifo_end: thing_fifo_next = out_thing_fifo_done;
        out_thing_fifo_done: thing_fifo_next = idle;
    endcase
end

// state register
always @(posedge clk) begin
    if(rst) begin
        thing_fifo_stage <= idle;
    end
    else begin
        thing_fifo_stage <= thing_fifo_next;
    end
end

// action in each state
always @ (posedge clk) begin
    case(thing_fifo_stage)
        default: begin
            thing_fifo <= thing_fifo;
        end
        out_thing_fifo_ready: begin
            thing_fifo_output <= thing_lifo[(8 * (thing_fifo_num) -1) -: 8];
        end
        out_thing_fifo: begin
            thing_fifo_output <= thing_lifo[(8 * (thing_fifo_num) -1) -: 8];
        end
        out_thing_fifo_end: begin
            thing_fifo_output <= 8'h30;
        end
    endcase
end

assign valid_fifo2 = (thing_fifo_stage == out_thing_fifo || thing_fifo_stage == out_thing_fifo_end) ? 1: 0;
assign done_fifo2 = (thing_fifo_stage == out_thing_fifo_done) ? 1: 0;
assign thing_out = (stage_th_lifo == pop_thing  || stage_th_lifo == pop_thing_end ) ? thing_out_reg:(thing_fifo_stage == out_thing_fifo || thing_fifo_stage == out_thing_fifo_end) ? thing_fifo_output: 8'hx;
assign done_thing = (stage_th_lifo == pop_thing_done) ? 1: 0;
endmodule