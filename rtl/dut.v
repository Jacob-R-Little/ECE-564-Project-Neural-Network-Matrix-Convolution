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

reg [3:0] state;

reg [5:0] N_1;  // N shifted by 1

reg [11:0] frame_pointer;

reg [2:0] read_count;
reg [5:0] row;
reg [5:0] col;

reg signed [7:0] IN_REG [15:0];
reg signed [7:0] K_REG [8:0];

reg signed [19:0] MAC [3:0];
reg [3:0] MAC_count;

reg signed [7:0] OUT_REG;
reg OUT_wait;

//---------------------------------------------------------------------------
// Nets and Registers

reg [3:0] next_state;

wire [5:0] frame_offset [2:0];
wire frame_offset_1;

reg [7:0] IN_net [15:0];
reg [7:0] K_net [8:0];

wire signed [15:0] mult [3:0];

wire signed [7:0] pool_mid [1:0];
wire signed pool_out;

wire signed [7:0] ReLU_mid, ReLU_out;

//---------------------------------------------------------------------------
// For Loop Iterable

integer i;

//---------------------------------------------------------------------------
// State Parameters

parameter
		S_reset = 4'd0,
    S_run = 4'd1,
    S_read_K = 4'd2,
    S_update_FP = 4'd3,
    S_read_IN = 4'd4,
    S_update_pos = 4'd5,
    S_MAC = 4'd6,
    S_OUT = 4'd7;

always@(posedge clk)	// synchronous reset clock
begin
	if (!reset_b) state <= S_reset;	// reset to state S0
	else state <= next_state;	// update state if no reset

  if ((state == S_reset) || (state == S_run)) dut_busy <= 0;
  else dut_busy <= 1;
end

always@(*)
begin
  casex(state)
    S_reset:
    begin
      next_state = S_run;
    end
    S_run:
    begin
      if (dut_run) next_state = S_read_K;
      else next_state = S_run;
    end
    S_read_K:
    begin
      if (read_count == 4) next_state = S_update_FP;
      else next_state = S_read_K;
    end
    S_update_FP:
    begin
      next_state = S_read_IN;
    end
    S_read_IN:
    begin
      if (read_count == 7) next_state = S_update_pos;
      else next_state = S_read_IN;
    end
    S_update_pos:
    begin
      next_state = S_MAC;
    end
    S_MAC:
    begin
      if (MAC_count == 8) next_state = S_OUT;
      else next_state = S_MAC;
    end
    S_OUT:
    begin
      if ((row == (N_1 - 2)) && (col == (N_1 - 2))) next_state = S_run;
      next_state = S_update_FP;
    end
  endcase
end

// calculate input read address
assign frame_offset[0] = (read_count > 1) ? N_1 : 0;
assign frame_offset[1] = (read_count > 3) ? N_1 : 0;
assign frame_offset[2] = (read_count > 5) ? N_1 : 0;
assign frame_offset_1 = (read_count[1]) ? 1 : 0;

always@(*)
begin
  input_sram_write_enable = 0;
  weights_sram_write_enable = 0;
  if (state == S_OUT) output_sram_write_enable = 1;
  else output_sram_write_enable = 0;

  weights_sram_read_address = read_count;
  input_sram_read_address = frame_pointer + frame_offset[0] + frame_offset[1] + frame_offset[2] + frame_offset_1;
end

// input and kernel flop management
always@(*)
begin
  if (state == S_read_K)
  begin
    if (read_count < 4)
    begin
      K_net[read_count << 1] = weights_sram_read_data[15:8];
      K_net[(read_count << 1) + 1] = weights_sram_read_data[7:0];
    end
    else if (read_count == 4)
    begin
      K_net[read_count << 1] = weights_sram_read_data[15:8];
    end    
  end

  if (state == S_read_IN)
  begin
      IN_net[read_count << 1] = input_sram_read_data[15:8];
      IN_net[(read_count << 1) + 1] = input_sram_read_data[7:0];
  end
end


always@(posedge clk)
begin

  if (state == S_read_K) N_1 <= input_sram_read_data >> 1;
  else N_1 <= N_1;

  if ((state == S_reset) || (state == S_run)) frame_pointer <= 0;
  else if (state == S_update_FP)
  begin
    if ((row == (N_1 - 2)) && (col == (N_1 - 2))) frame_pointer <= frame_pointer + N_1 + N_1 + N_1 + 2;
    if (col == (N_1 - 2)) frame_pointer <= frame_pointer + N_1 + 2;
    else frame_pointer <= frame_pointer + 1;
  end
  else frame_pointer <= frame_pointer;

  if ((state == S_read_K) || (state == S_read_IN))
    read_count <= read_count + 1;
  else read_count <= 0;
  
  if ((state == S_reset) || (state == S_run))
  begin
    row <= 0;
    col <= 0;
  end
  if (state == S_update_pos)
  begin
    if ((row == (N_1 - 2)) && (col == (N_1 - 2))) col <= 0;
    else if (col == (N_1 - 2)) row <= row + 1;
    else row <= row;

    if (col == (N_1 - 2)) col <= 0;
    else col <= col + 1;
  end
  else
  begin
    row <= row;
    col <= col;
  end

  if (state == S_read_K)
    for (i = 0; i < 9; i = i + 1) K_REG[i] <= K_net[i];
  else
    for (i = 0; i < 9; i = i + 1) K_REG[i] <= K_REG[i];
  if (state == S_read_IN)
    for (i = 0; i < 16; i = i + 1) IN_REG[i] <= IN_net[i];
  else
    for (i = 0; i < 16; i = i + 1) IN_REG[i] <= IN_REG[i];
end


// 4 multipliers
assign mult[0] = IN_REG[MAC_count +     (MAC_count > 2) + (MAC_count > 5)] * K_REG[MAC_count];
assign mult[1] = IN_REG[MAC_count + 1 + (MAC_count > 2) + (MAC_count > 5)] * K_REG[MAC_count];
assign mult[2] = IN_REG[MAC_count + 4 + (MAC_count > 2) + (MAC_count > 5)] * K_REG[MAC_count];
assign mult[3] = IN_REG[MAC_count + 5 + (MAC_count > 2) + (MAC_count > 5)] * K_REG[MAC_count];

// accumulator
always@(posedge clk)
begin
  if (state == S_MAC)
  begin
    MAC_count = MAC_count + 1;
    for (i = 0; i < 4; i = i + 1) MAC[i] <= MAC[i] + mult[i];
  end
  else
  begin
    MAC_count = 0;
    for (i = 0; i < 4; i = i + 1) MAC[i] <= 0;
  end
end

// pooling
assign pool_mid[0] = (MAC[0] > MAC[1]) ? MAC[0] : MAC[1];
assign pool_mid[1] = (MAC[2] > MAC[3]) ? MAC[2] : MAC[3];
assign pool_out = (pool_mid[0] > pool_mid[1]) ? pool_mid[0] : pool_mid[1];

// ReLU
assign ReLU_mid = (pool_out < 8'sd0) ? 8'sd0 : pool_out; 
assign ReLU_out = (ReLU_mid > 8'sd127) ? 8'sd127 : ReLU_mid;


// Capture and Write Output
always@(posedge clk)
begin
  if ((state == S_reset) || (state == S_run))
  begin
    output_sram_write_data <= 0;
    output_sram_write_addresss <= 0;
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
    end
    else if ((row == (N_1 - 2)) && (col == (N_1 - 2)))
    begin
      output_sram_write_data <= {ReLU_out, 8'd0};
      OUT_REG <= 0;
      OUT_wait <= 0;
    end
    else
    begin
      output_sram_write_data <= output_sram_write_data;
      OUT_REG <= ReLU_out;
      OUT_wait <= 1;
    end
    if ((row == 0) && (col == 0)) output_sram_write_addresss <= output_sram_write_addresss + 1;
      
  end
  else
  begin
    output_sram_write_data <= output_sram_write_data;
    output_sram_write_addresss <= output_sram_write_addresss;
    OUT_REG <= OUT_REG;
    OUT_wait <= OUT_wait;
  end
end

endmodule

