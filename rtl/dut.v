module MyDesign (
//---------------------------------------------------------------------------
//Control signals
  input   wire dut_run                    , 
  output  reg dut_busy                   ,
  input   wire reset_b                    ,  
  input   wire clk                        ,
 
//---------------------------------------------------------------------------
//Input SRAM interface
  output reg        input_sram_write_enable    ,
  output reg [11:0] input_sram_write_addresss  ,
  output reg [15:0] input_sram_write_data      ,
  output reg [11:0] input_sram_read_address    ,
  input wire [15:0] input_sram_read_data       ,

//---------------------------------------------------------------------------
//Output SRAM interface
  output reg        output_sram_write_enable    ,
  output reg [11:0] output_sram_write_addresss  ,
  output reg [15:0] output_sram_write_data      ,
  output reg [11:0] output_sram_read_address    ,
  input wire [15:0] output_sram_read_data       ,

//---------------------------------------------------------------------------
//Scratchpad SRAM interface
  output reg        scratchpad_sram_write_enable    ,
  output reg [11:0] scratchpad_sram_write_addresss  ,
  output reg [15:0] scratchpad_sram_write_data      ,
  output reg [11:0] scratchpad_sram_read_address    ,
  input wire [15:0] scratchpad_sram_read_data       ,

//---------------------------------------------------------------------------
//Weights SRAM interface                                                       
  output reg        weights_sram_write_enable    ,
  output reg [11:0] weights_sram_write_addresss  ,
  output reg [15:0] weights_sram_write_data      ,
  output reg [11:0] weights_sram_read_address    ,
  input wire [15:0] weights_sram_read_data       

);

//---------------------------------------------------------------------------
// Explicitly Declared Flops

reg [3:0] accum_counter;                  // must be reset
reg accumulate;                           // must be reset
reg busy;                                 // must be reset
reg [6:0] N;                              // must be reset
reg [2:0] read_counter;                   // must be reset
reg [5:0] row_counter, col_counter;       // must be reset

reg [15:0][127:0] input_flops;            // 4 x 4 x 8 flops
reg [8:0][7:0] kernel_flops;              // (3 x 3) x 8 flops
signed reg [3:0][19:0] mul_accum_flops;   // 4 x 20 flops

reg [7:0] output_flops;
reg output_wait;                          // must be reset

reg [11:0] output_sram_pointer, frame_pointer;           // must be reset


//---------------------------------------------------------------------------
// Nets and Registers

wire accum_done;
wire new_row, not_new_row, row_return, col_return;
wire N_1; // N shifted by 1

wire frame_offset[2:0][5:0];
wire frame_offset_1;

signed wire [3:0][7:0] input_stride;
signed wire [7:0] kernel_stride;
signed wire [3:0][7:0] conv_stride;

signed wire [3:0][19:0] pool_in;
signed wire [1:0][19:0] pool_mid;
signed wire [19:0] pool_out;

signed wire [7:0] ReLU_mid, ReLU_out;


//---------------------------------------------------------------------------
// State Parameters


assign soft_reset = !reset_b || dut_run;

assign dut_busy = busy;

// memory handling
assign input_sram_write_enable = 0;
assign weights_sram_write_enable = 0;

assign weights_sram_read_address = read_counter;
assign output_sram_write_addresss = output_sram_pointer;

assign wait_accum = accumulate && (new_row || not_new_row) 
assign col_return = (row_counter == ((N >> 1) - 1)) && (row_counter == ((N >> 1) - 1)) && (read_counter == 4)
assign row_return = (row_counter == ((N >> 1) - 1)) && (read_counter == 4)
assign new_row = (row_counter == 0) && (read_counter == 8);
assign not_new_row = (row_counter != 0) && (read_counter == 4);
assign new_row_accum = (row_counter == 0) && (read_counter >= 3);
assign not_new_row_accum = (row_counter != 0) && (read_counter >= 2);




always@(posedge clk)
begin
  if (!reset_b)
  begin
    input_sram_pointer <= 0;
    read_input <= 0;
    read_counter <= 0;
    row_counter <= 0;
    col_counter <= 0;
    busy <= 0;
    N <= 0;
    accumulate <= 0;
  end
  else if (dut_run) 
  begin
    input_sram_pointer <= 1;
    read_input <= 1;
    read_counter <= 0;
    row_counter <= 0;
    col_counter <= 0;
    busy <= 1;
    N <= input_sram_read_data[6:0];
    accumulate <= 0;
  end
  else if (!busy)
  begin
    input_sram_pointer <= 0;
    read_input <= 0;
    read_counter <= 0;
    row_counter <= 0;
    col_counter <= 0;
    busy <= 0;
    N <= 0;
    accumulate <= 0;
  end
  else if (wait_accum)
  begin
    input_sram_pointer <= input_sram_pointer;
    read_input <= 0;
    read_counter <= read_counter;
    row_counter <= row_counter;
    col_counter <= col_counter;
    busy <= 1;
    N <= N;
    if (accum_done) accumulate <= 0;
    else accumulate <= 1; 
  end
  else if (col_return)
  begin
    input_sram_pointer <= input_sram_pointer + 1;
    read_input <= 1;
    read_counter <= 0;
    row_counter <= 0;
    col_counter <= 0;
    if (input_sram_read_data[15:0] == 16'hFF) busy <= 0;
    N <= input_sram_read_data[6:0];
    accumulate <= 0;
  end
  else if (row_return)
  begin
    input_sram_pointer <= input_sram_pointer + 1;
    read_input <= 1;
    read_counter <= 0;
    row_counter <= 0;
    col_counter <= col_counter
    busy <= 1;
    N <= N;
    accumulate <= 0;
  end
  else if (new_row)
  begin
    input_sram_pointer <= input_sram_pointer + 1;
    read_input <= 1;
    read_counter <= 0;
    row_counter <= row_counter + 1;
    col_counter <= col_counter;
    busy <= 1;
    N <= N;
    accumulate <= 0;
  end
  else if (not_new_row)
  begin
    input_sram_pointer <= input_sram_pointer + 1;
    read_input <= 1;
    read_counter <= 0;
    row_counter <= row_counter + 1;
    col_counter <= col_counter;
    busy <= 1;
    N <= N;
    accumulate <= 0;
  end
  else if (new_row_accum)
  begin
    input_sram_pointer <= input_sram_pointer + 1;
    read_input <= 1;
    read_counter <= read_counter + 1;
    row_counter <= row_counter;
    col_counter <= col_counter;
    busy <= 1;
    N <= N;
    accumulate <= 1;
  end
  else if (not_new_row_accum)
  begin
    input_sram_pointer <= input_sram_pointer + 1;
    read_input <= 1;
    read_counter <= read_counter + 1;
    row_counter <= row_counter;
    col_counter <= col_counter;
    busy <= 1;
    N <= N;
    accumulate <= 1;
  end
  else
  begin
    input_sram_pointer <= input_sram_pointer + 1;
    read_input <= 1;
    read_counter <= read_counter + 1;
    row_counter <= row_counter;
    col_counter <= col_counter;
    busy <= 1;
    N <= N;
    accumulate <= 0;
  end

  if (accumulate) accum_counter <= accum_counter + 1;
  else accum_counter <= 0;
end

assign N_1 = N >> 1;

assign frame_offset[0] = ((row_counter == 0) ? (read_counter > 1) : (read_counter > 0)) ? N_1 : 0;
assign frame_offset[1] = ((row_counter == 0) ? (read_counter > 3) : (read_counter > 1)) ? N_1 : 0;
assign frame_offset[2] = ((row_counter == 0) ? (read_counter > 5) : (read_counter > 2)) ? N_1 : 0;
assign frame_offset_1 = ((row_counter != 0) || read_counter[1]) ? 1 : 0;
assign input_sram_read_address = frame_pointer + frame_offset[0] + frame_offset[1] + frame_offset[2]; + frame_offset_1;

// input and kernel flop management
always@(posedge clk)
begin
  kernel_flops = kernel_flops;
  input_flops = input_flops;
  if (read_input)
  begin
    // read kernel
    if (read_counter < 4)
    begin
      kernel_flops[read_counter << 1] = weights_sram_read_data[15:8];
      kernel_flops[(read_counter << 1) + 1] = weights_sram_read_data[7:0];
    end
    else if (read_counter == 4)
    begin
      kernel_flops[read_counter << 1] = weights_sram_read_data[15:8];
    end    
    // read input
    if (row_counter == 0)
    begin
      input_flops[read_counter << 1] = input_sram_read_data[15:8];
      input_flops[(read_counter << 1) + 1] = input_sram_read_data[7:0];
    end
    else
    begin
      input_flops[(read_counter << 2)] = input_flops[(read_counter << 2) + 2];
      input_flops[(read_counter << 2) + 1] = input_flops[(read_counter << 2) + 3];
      input_flops[(read_counter << 2) + 2] = input_sram_read_data[15:8];
      input_flops[(read_counter << 2) + 3] = input_sram_read_data[7:0];
    end
  end
end


assign accum_done = (accum_counter == 8);


// muxing for multiply accumulate
assign input_stride[0] = input_flops[accum_counter +     (accum_counter < 3) + (accum_counter < 6)];
assign input_stride[1] = input_flops[accum_counter + 1 + (accum_counter < 3) + (accum_counter < 6)];
assign input_stride[2] = input_flops[accum_counter + 4 + (accum_counter < 3) + (accum_counter < 6)];
assign input_stride[3] = input_flops[accum_counter + 5 + (accum_counter < 3) + (accum_counter < 6)];

assign kernel_stride = kernel_flops[accum_counter];


// multipliers
assign conv_stride[0] = input_stride[0] * kernel_stride;
assign conv_stride[1] = input_stride[1] * kernel_stride;
assign conv_stride[2] = input_stride[2] * kernel_stride;
assign conv_stride[3] = input_stride[3] * kernel_stride;


// accumulator
always@(posedge clk)
begin
  if (accumulate)
  begin
    mul_accum_flops[0] <= mul_accum_flops[0] + conv_stride[0];
    mul_accum_flops[1] <= mul_accum_flops[1] + conv_stride[1];
    mul_accum_flops[2] <= mul_accum_flops[2] + conv_stride[2];
    mul_accum_flops[3] <= mul_accum_flops[3] + conv_stride[3];
  end
  else
  begin
    mul_accum_flops[0] <= 0;
    mul_accum_flops[1] <= 0;
    mul_accum_flops[2] <= 0;
    mul_accum_flops[3] <= 0;
  end
end


// pooling
assign pool_mid[0] = (mul_accum_flops[0] > mul_accum_flops[1]) ? mul_accum_flops[0] : mul_accum_flops[1];
assign pool_mid[1] = (mul_accum_flops[2] > mul_accum_flops[3]) ? mul_accum_flops[2] : mul_accum_flops[3];
assign pool_out = (pool_mid[0] > pool_mid[1]) ? pool_mid[0] : pool_mid[1];


// ReLU
assign ReLU_mid = (pool_out < 8'sd0) ? 8'sd0 : pool_out; 
assign ReLU_out = (pool_out > 8'sd127) ? 8'sd127 : pool_out;


// Capture and Write Output
always@(posedge clk)
begin
  casex({soft_reset, accum_done, /* last val */, output_wait})
		4'b1xxx:
		begin
      output_sram_write_data <= 0;
      output_sram_write_enable <= 0;
      output_sram_pointer <= 0;
      output_flops <= 0;
      output_wait <= 0;
		end
    4'b011x:
		begin
      output_sram_write_data <= {ReLU_out, 8'd0};
      output_sram_write_enable <= 1;
      output_sram_pointer <= output_sram_pointer + 1;
      output_flops <= output_flops;
      output_wait <= 0;
		end
    4'b0101:
    begin
      output_sram_write_data <= {output_flops, ReLU_out};
      output_sram_write_enable <= 1;
      output_sram_pointer <= output_sram_pointer + 1;
      output_flops <= output_flops;
      output_wait <= 0;
		end
		4'b0100:
		begin
      output_sram_write_data <= output_sram_write_data;
      output_sram_write_enable <= 0;
      output_sram_pointer <= output_sram_pointer;
      output_flops <= ReLU_out;
      output_wait <= 1;
		end
		default:
		begin
      output_sram_write_data <= output_sram_write_data;
      output_sram_write_enable <= 0;
      output_sram_pointer <= output_sram_pointer;
      output_flops <= output_flops;
      output_wait <= output_wait;
		end
	endcase
end

endmodule

