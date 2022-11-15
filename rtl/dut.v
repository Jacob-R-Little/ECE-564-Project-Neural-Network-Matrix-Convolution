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

reg [15:0][127:0] input_flops;            // 4 x 4 x 8 flops
reg [8:0][7:0] kernel_flops;              // 3 x 3 x 8 flops
signed reg [3:0][19:0] mul_accum_flops;   // 4 x 20 flops

reg [3:0] accum_counter;                  // must be reset
reg start_accum, accum_done;              // must be reset

reg [7:0] output_flops;
reg output_wait;                          // must be reset

reg [11:0] output_sram_pointer;           // must be reset


//---------------------------------------------------------------------------
// Nets and Registers

signed wire [3:0][7:0] input_stride;
signed wire [7:0] kernel_stride;

signed wire [3:0][19:0] pool_in;
signed wire [1:0][19:0] pool_mid;
signed wire [19:0] pool_out;

signed wire [7:0] ReLU_mid, ReLU_out;


//---------------------------------------------------------------------------
// State Parameters

always@(posedge clk)
begin
  if (/* ready to begin accumulating */)
  begin
    start_accum <= 1;
    accum_counter <= 0;
  end
  if (accum_counter == 8)
  begin
    accum_done;
    accum_counter <= accum_counter;
  end
end


assign input_stride[0] = input_flops[accum_counter + (accum_counter < 3) + (accum_counter < 6)];
assign input_stride[1] = input_flops[accum_counter + 1 + (accum_counter < 3) + (accum_counter < 6)];
assign input_stride[2] = input_flops[accum_counter + 4 + (accum_counter < 3) + (accum_counter < 6)];
assign input_stride[3] = input_flops[accum_counter + 5 + (accum_counter < 3) + (accum_counter < 6)];

assign kernel_stride = kernel_flops[accum_counter];


// multiply accumulate
always@(posedge clk)
begin
  casex ({start_accum, accum_done})
  1x:
  begin
    mul_accum_flops[0] <= input_stride[0] * kernel_stride;
    mul_accum_flops[1] <= input_stride[1] * kernel_stride;
    mul_accum_flops[2] <= input_stride[2] * kernel_stride;
    mul_accum_flops[3] <= input_stride[3] * kernel_stride;
  end
  01:
  begin
    mul_accum_flops[0] <= mul_accum_flops[0];
    mul_accum_flops[1] <= mul_accum_flops[1];
    mul_accum_flops[2] <= mul_accum_flops[2];
    mul_accum_flops[3] <= mul_accum_flops[3];
  end
  default:
  begin
    mul_accum_flops[0] <= mul_accum_flops[0] + input_stride[0] * kernel_stride;
    mul_accum_flops[1] <= mul_accum_flops[1] + input_stride[1] * kernel_stride;
    mul_accum_flops[2] <= mul_accum_flops[2] + input_stride[2] * kernel_stride;
    mul_accum_flops[3] <= mul_accum_flops[3] + input_stride[3] * kernel_stride;
  end
  endcase
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
  casex({accum_done, /* last val */, output_wait})
		11x:
		begin
      output_sram_write_data <= {ReLU_out, 8'd0};
      output_sram_write_enable <= 1;
      output_sram_pointer <= output_sram_pointer + 1;
      output_flops <= output_flops;
      output_wait <= 0;
		end
    101:
    begin
      output_sram_write_data <= {output_flops, ReLU_out};
      output_sram_write_enable <= 1;
      output_sram_pointer <= output_sram_pointer + 1;
      output_flops <= output_flops;
      output_wait <= 0;
		end
		100:
		begin
      output_sram_write_data <= output_sram_write_data;
      output_sram_write_enable <= 0;
      output_sram_pointer <= output_sram_pointer + 1;
      output_flops <= ReLU_out;
      output_wait <= 1;
		end
		default:
		begin
      output_sram_write_data <= output_sram_write_data;
      output_sram_write_enable <= 0;
      output_sram_pointer <= output_sram_pointer + 1;
      output_flops <= output_flops;
      output_wait <= output_wait;
		end
	endcase
end

assign output_sram_write_addresss = output_sram_pointer;

endmodule

