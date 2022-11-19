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

reg [2:0] state;

reg [5:0] N_1;  // N shifted by 1

reg [11:0] frame_pointer;

reg [3:0] counter;
reg [5:0] row;
reg [5:0] col;

reg signed [7:0] IN_REG [0:15];
reg signed [7:0] K_REG [0:8];

reg signed [19:0] MAC [0:3];

reg signed [7:0] OUT_REG;
reg OUT_wait;

//---------------------------------------------------------------------------
// Nets and Registers

reg [2:0] next_state;

wire [5:0] frame_offset [0:2];
wire frame_offset_1;

reg [7:0] IN_net [0:15];
reg [7:0] K_net [0:8];

wire signed [15:0] mult [0:3];

wire signed [19:0] pool_mid [0:1];
wire signed [19:0] pool_out;

wire signed [19:0] ReLU_mid;
wire signed [7:0] ReLU_out;

//---------------------------------------------------------------------------
// For Loop Iterable

integer i;

//---------------------------------------------------------------------------
// State Parameters

parameter
	S_reset = 3'd0,
  S_read_K = 3'd1,
	S_get_N = 3'd2,
	S_read_IN = 3'd3,
	S_update_pos = 3'd4,
	S_MAC = 3'd5,
	S_OUT = 3'd6,
  S_update_FP = 3'd7;


always@(*)
begin

	// Finite State Machine
  casex(state)
    S_reset:
			if (dut_run) next_state = S_read_K;
      else next_state = S_reset;
    S_read_K:
			if (counter == 5) next_state = S_get_N;
      else next_state = S_read_K;
		S_get_N:
      if (counter < 1) next_state = S_get_N;
			else if (input_sram_read_data == 16'hFFFF) next_state = S_reset;
			else next_state = S_read_IN;
    S_read_IN:
			if (((col != 0) && (counter == 4)) || (counter == 8)) next_state = S_update_pos;
			else next_state = S_read_IN;
    S_update_pos:
			next_state = S_MAC;
    S_MAC:
			if (counter == 8) next_state = S_OUT;
			else next_state = S_MAC;
    S_OUT:
      next_state = S_update_FP;
    S_update_FP:
      if ((row == 0) && (col == 0)) next_state = S_get_N;
			else next_state = S_read_IN;
  endcase

	// Write Enable Assertions
  input_sram_write_enable = 0;
  weights_sram_write_enable = 0;
  output_sram_write_enable = 1;

	// Read Address Assertions
  weights_sram_read_address = counter;
  if (state == S_reset) input_sram_read_address = 0;
  else if (next_state == S_get_N) input_sram_read_address = frame_pointer;
  else input_sram_read_address = frame_pointer + frame_offset[0] + frame_offset[1] + frame_offset[2] + frame_offset_1;

end

// flop management
always@(posedge clk)
begin

	// synchronous reset
	if (!reset_b) state <= S_reset;
	else state <= next_state;

	// busy signal
  if (state == S_reset) dut_busy <= 0;
  else dut_busy <= 1;

	// state counter
  if (state == next_state) counter <= counter + 1;
  else counter <= 0;

	// kernel read and N >> 1
	if (state == S_read_K)
  begin

    if ((counter > 0) && (counter < 5))
    begin
      K_REG[(counter - 1) << 1] = weights_sram_read_data[15:8];
      K_REG[((counter - 1) << 1) + 1] = weights_sram_read_data[7:0];
    end
    else if (counter == 5) K_REG[(counter - 1) << 1] = weights_sram_read_data[15:8];
  end

  // N >> 1
	if (state == S_get_N) N_1 <= input_sram_read_data[6:0] >> 1;

	// frame pointer
  if (state == S_reset) frame_pointer <= 0;
	else if (state == S_get_N && counter == 0) frame_pointer <= frame_pointer + 1;
  else if (state == S_update_FP)
	begin
    if ((frame_pointer > 1) && (row == 0) && (col == 0)) frame_pointer <= frame_pointer + N_1 + N_1 + N_1 + 2;
    else if ((frame_pointer > 1) && (col == 0)) frame_pointer <= frame_pointer + N_1 + 2;
    else frame_pointer <= frame_pointer + 1;
	end

	// input read
  if ((state == S_read_IN) && (counter > 0))
  begin
      if (col == 0)
      begin
        IN_REG[(counter - 1) << 1] = input_sram_read_data[15:8];
        IN_REG[((counter - 1) << 1) + 1] = input_sram_read_data[7:0];
      end
      else
      begin
        IN_REG[((counter - 1) << 2)] = IN_REG[((counter - 1) << 2) + 2];
        IN_REG[((counter - 1) << 2) + 1] = IN_REG[((counter - 1) << 2) + 3];
        IN_REG[((counter - 1) << 2) + 2] = input_sram_read_data[15:8];
        IN_REG[((counter - 1) << 2) + 3] = input_sram_read_data[7:0];
      end

  end
  
	// rows and columns
  if (state == S_reset)
  begin
    row <= 0;
    col <= 0;
  end
  if (state == S_update_pos)
  begin
    if ((row == (N_1 - 2)) && (col == (N_1 - 2))) row <= 0;
    else if (col == (N_1 - 2)) row <= row + 1;
    else row <= row;

    if (col == (N_1 - 2)) col <= 0;
    else col <= col + 1;
  end

	// Multiply Accumulator
	if (state == S_MAC)
    for (i = 0; i < 4; i = i + 1) MAC[i] <= MAC[i] + mult[i];
  else
    for (i = 0; i < 4; i = i + 1) MAC[i] <= 0;

	// Capture and Write Output
	if (state == S_reset)
  begin
    output_sram_write_data <= 0;
    output_sram_write_addresss <= -1;
    OUT_REG <= 0;
    OUT_wait <= 0;
  end
  else if (state == S_OUT)
  begin
    if (OUT_wait)
    begin
      output_sram_write_data <= {OUT_REG, ReLU_out};
      OUT_REG <= 0;
      OUT_wait <= 0;
      output_sram_write_addresss <= output_sram_write_addresss + 1;
    end
    else if ((row == 0) && (col == 0))
    begin
      output_sram_write_data <= {ReLU_out, 8'd0};
      OUT_REG <= 0;
      OUT_wait <= 0;
      output_sram_write_addresss <= output_sram_write_addresss + 1;
    end
    else
    begin
      output_sram_write_data <= output_sram_write_data;
      OUT_REG <= ReLU_out;
      OUT_wait <= 1;
    end
  end
end

// calculate offsets from frame pointer for input read address
assign frame_offset[0] = ((col == 0) ? (counter > 1) : (counter > 0)) ? N_1 : 0;
assign frame_offset[1] = ((col == 0) ? (counter > 3) : (counter > 1)) ? N_1 : 0;
assign frame_offset[2] = ((col == 0) ? (counter > 5) : (counter > 2)) ? N_1 : 0;
assign frame_offset_1 = (col != 0) ? 1 : counter[0];

// 4 multipliers
assign mult[0] = IN_REG[counter +     (counter > 2) + (counter > 5)] * K_REG[counter];
assign mult[1] = IN_REG[counter + 1 + (counter > 2) + (counter > 5)] * K_REG[counter];
assign mult[2] = IN_REG[counter + 4 + (counter > 2) + (counter > 5)] * K_REG[counter];
assign mult[3] = IN_REG[counter + 5 + (counter > 2) + (counter > 5)] * K_REG[counter];

// pooling
assign pool_mid[0] = (MAC[0] > MAC[1]) ? MAC[0] : MAC[1];
assign pool_mid[1] = (MAC[2] > MAC[3]) ? MAC[2] : MAC[3];
assign pool_out = (pool_mid[0] > pool_mid[1]) ? pool_mid[0] : pool_mid[1];

// ReLU
assign ReLU_mid = (pool_out < 8'sd0) ? 8'sd0 : pool_out; 
assign ReLU_out = (ReLU_mid > 8'sd127) ? 8'sd127 : ReLU_mid;

endmodule
