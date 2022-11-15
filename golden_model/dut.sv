`ifndef SYNTHESIS
`define IDLE             3'b000
`define DOWNLOAD_SRAM    3'b001
`define COMPUTE_OUTPUT   3'b010
`define WRITE_OUTPUT     3'b011
`define COMPLETE         3'b100

let max(a,b) = (a > b) ? a : b;


module MyDesign (
//---------------------------------------------------------------------------
//Control signals
  input   wire dut_run                    , 
  output  reg dut_busy                   ,
  input   wire reset_b                    ,  
  input   wire clk                        ,
 
//---------------------------------------------------------------------------
//input SRAM interface
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
//weights SRAM interface                                                       
  output reg        weights_sram_write_enable    ,
  output reg [11:0] weights_sram_write_addresss  ,
  output reg [15:0] weights_sram_write_data      ,
  output reg [11:0] weights_sram_read_address    ,
  input wire [15:0] weights_sram_read_data       

);


  string class_name = "464";
  string run_type = "extra";
  reg input_sram_download_complete;
  reg weights_sram_download_complete;
  reg write_output_sram_complete;
  reg download_config_complete;
  reg [2:0] system_state;
  reg kernel_download;

  localparam INPUT_N          = 64;
  localparam KERNEL_N         = 3;
  localparam WEIGHTS_N        = 62;
  localparam OUTPUT_N         = 62;
  localparam NUM_OF_WEIGHTS_MEM = (((WEIGHTS_N*WEIGHTS_N-1)/2)+1);
  localparam NUM_OF_KERNEL_MEM = (((KERNEL_N*KERNEL_N-1)/2)+1);
  localparam NUM_OF_INPUT_MEM   = (((INPUT_N*INPUT_N-1)/2)+1);
  localparam NUM_OF_OUTPUT_MEM   = (((OUTPUT_N*OUTPUT_N-1)/2)+1);

  reg signed [7:0] input_data [0:INPUT_N-1][0:INPUT_N-1];
  reg [15:0] input_mem [0:NUM_OF_INPUT_MEM-1];
  reg signed [7:0] kernel_data [0:KERNEL_N-1][0:KERNEL_N-1];
  reg signed [7:0] weights_data [0:WEIGHTS_N-1][0:WEIGHTS_N-1];
  reg [15:0] weights_mem [0:NUM_OF_WEIGHTS_MEM-1];
  reg [15:0] kernel_mem [0:NUM_OF_KERNEL_MEM-1];
  reg signed [7:0] max_pooling_data [0:OUTPUT_N-1][0:OUTPUT_N-1];
  reg signed [7:0] output_data [0:OUTPUT_N-1][0:OUTPUT_N-1];
  reg signed [31:0] output_base_data [0:OUTPUT_N-1][0:OUTPUT_N-1];
  reg [15:0] output_mem [0:NUM_OF_OUTPUT_MEM-1];
  reg [15:0] output_max_base_mem [0:NUM_OF_INPUT_MEM-1];
  reg [15:0] output_base_mem [0:NUM_OF_INPUT_MEM-1];
  reg signed [19:0] temp;
  integer input_row,input_col;
  integer weights_row,weights_col;
  integer output_row,output_col;
  integer temp_weights_index;
  integer temp_input_index;
  //integer output_col_index1,output_col_index2,output_row_index1,output_row_index2;
  integer global_input_address;
  integer global_weights_address;
  integer global_output_address;
  reg [15:0] config_N;

  always@(posedge clk)
  begin
    case({~reset_b,system_state})
      {1'b0,`IDLE}                   : system_state <= dut_run                       ? `DOWNLOAD_SRAM  : `IDLE; 
      {1'b0,`DOWNLOAD_SRAM}          : system_state <= (config_N != 16'hffff ) ? input_sram_download_complete & weights_sram_download_complete ?  `COMPUTE_OUTPUT : `DOWNLOAD_SRAM : `IDLE ; 
      {1'b0,`COMPUTE_OUTPUT}         : system_state <= `WRITE_OUTPUT;
      {1'b0,`WRITE_OUTPUT}           : system_state <=  write_output_sram_complete  ? (class_name == "564") ? `DOWNLOAD_SRAM : `IDLE : `WRITE_OUTPUT ;  
      default                        : system_state <= `IDLE;    
    endcase
  end



  always@(posedge clk)
      dut_busy = ~((system_state === `IDLE));

  task get_config;
    output [31:0] config_size;
    begin
      if(class_name == "564")
      begin
        input_sram_read_address = global_input_address;
        @(posedge clk);
        global_input_address = global_input_address + 1;
        @(posedge clk);
        config_size = input_sram_read_data;
      end
      else
      begin
        config_size=16;
      end
    end
  endtask


  task download_input;
    input [31:0] N;
    integer i,input_bound;
    begin
      input_bound = (((N*N-1)/2)+1);
      for(i=0;i<input_bound;i=i+1)
      begin
          input_sram_read_address=i+global_input_address;
          @(posedge clk);
          input_mem[i-1] = input_sram_read_data; 
      end
      @(posedge clk);
      input_mem[i-1] = input_sram_read_data; 
      if(class_name == "564")
      begin
        global_input_address=global_input_address+input_bound;
      end
    end
  endtask

  task download_kernel;
    integer i;
    begin
      for(i=0;i<NUM_OF_KERNEL_MEM;i=i+1)
      begin
          weights_sram_read_address=i;
          @(posedge clk);
          kernel_mem[i-1] = weights_sram_read_data; 
      end
      @(posedge clk);
      kernel_mem[i-1] = weights_sram_read_data; 
      global_weights_address=NUM_OF_KERNEL_MEM;
    end
  endtask

  task download_weights;
    input [31:0] N;
    integer i,weights_bound;
    begin
      weights_bound = (((N*N-1)/2)+1);
      for(i=0;i<weights_bound;i=i+1)
      begin
          weights_sram_read_address=i+global_weights_address;
          @(posedge clk);
          weights_mem[i-1] = weights_sram_read_data; 
      end
      @(posedge clk);
      weights_mem[i-1] = weights_sram_read_data; 
      global_weights_address=global_weights_address+weights_bound;
    end
  endtask

  task translate_input_mem;
    input [31:0] N;
    integer i,j,global_idx;
    global_idx=0;
    begin
      for(i=0;i<N;i=i+1)
      begin
        for(j=0;j<N;j=j+1)
        begin
          input_data[i][j] = input_mem[global_idx >> 1] >> (((global_idx %2) == 0) ? 8 : 0) ;
          global_idx=global_idx+1;
        end
      end
    end
  endtask

  task translate_kernel_mem;
  integer i,j,global_idx;
  begin
    global_idx=0;
    for(i=0;i<3;i=i+1)
    begin
      for(j=0;j<3;j=j+1)
      begin
        kernel_data[i][j] = kernel_mem[global_idx >> 1] >> (((global_idx %2) == 0) ? 8 : 0) ;
        global_idx=global_idx+1;
      end
    end
  end
  endtask
  
  task translate_weights_mem;
  input [31:0] N;
  integer i,j,global_idx;
  begin
    global_idx=0;
    for(i=0;i<N;i=i+1)
    begin
      for(j=0;j<N;j=j+1)
      begin
        weights_data[i][j] = weights_mem[global_idx >> 1] >> (((global_idx %2) == 0) ? 8 : 0) ;
        global_idx=global_idx+1;
      end
    end
  end
  endtask


  task compute_convolution_with_relu_activation;
  input [31:0] N;
  integer row, k_row, col, k_col;
  begin
    for(row=0;row<N;row=row+1)
    begin
      for(col=0;col<N;col=col+1)
      begin
        temp=0;
        for(k_row=0;k_row<3;k_row=k_row+1)
        begin
          for(k_col=0;k_col<3;k_col=k_col+1)
          begin
            temp = kernel_data[k_row][k_col] * input_data[k_row+row][k_col+col]  + temp; 
          end
        end
        output_data[row][col] = temp < 0 ? 'h0 : temp > 20'd127 ? 8'd127 : temp ;
        output_base_data[row][col] = {{12{temp[19]}},temp};
      end
    end
  end
  endtask

  task compute_fully_connected_with_relu_activation;
  input [31:0] N;
  integer row, col, i, test, test2,test3;
  begin
    for(row=0;row<N;row=row+1)
    begin
      for(col=0;col<N;col=col+1)
      begin
        temp=0;
        for(i=0;i<N;i=i+1)
        begin
          test = max_pooling_data[i][col];
          test2 = weights_data[row][i];
          test3 = weights_data[row][i] * max_pooling_data[i][col]; 
          temp =temp + weights_data[row][i] * max_pooling_data[i][col] ; 
        end
        output_data[row][col] = temp < 0 ? 'h0 : temp > 20'd127 ? 8'd127 : temp ;
      end
    end
  end
  endtask

  task max_pooling;
  input [31:0] N;
  integer row, local_row, col, local_col, row_pos, col_pos, look;
  begin
    for(row=0;row<N;row=row+1)
    begin
      for(col=0;col<N;col=col+1)
      begin
        max_pooling_data[row][col] = 0;
      end
    end
    for(row=0;row<N;row=row+1)
    begin
      for(col=0;col<N;col=col+1)
      begin
        for(local_row=0;local_row<2;local_row=local_row+1)
        begin
          for(local_col=0;local_col<2;local_col=local_col+1)
          begin
            row_pos = row*2+local_row;
            col_pos = col*2+local_col;
            look = output_data[row*2+local_row][col*2+local_col];
            max_pooling_data[row][col] = max_pooling_data[row][col] < output_data[row*2+local_row][col*2+local_col] ? output_data[row*2+local_row][col*2+local_col] : max_pooling_data[row][col];
          end
        end
      end
    end
  end
  endtask

  task translate_32bits_output;
  input [31:0] N;
  integer output_bound,i;
  integer row_idx, col_idx;
  begin
    row_idx=0;
    col_idx=0;
    output_bound = N*N*2;
    for(i=0;i<output_bound;i=i+1)
    begin
      output_base_mem[i*2] = output_base_data[row_idx][col_idx][15:0]; 
      output_base_mem[i*2+1] = output_base_data[row_idx][col_idx][31:16]; 
      if(col_idx == N-1)
      begin
        col_idx = 0;
        row_idx = row_idx+1;
      end
      else
        col_idx = col_idx+1;
    end
  end
  endtask

  task translate_max_output;
  input [31:0] N;
  integer output_bound,i;
  integer row_idx1, row_idx2;
  integer col_idx1, col_idx2;
  begin
    row_idx1=0;
    row_idx2=0;
    col_idx1=0;
    col_idx2=1;
    output_bound = (((N*N-1)/2)+1);
    for(i=0;i<output_bound;i=i+1)
    begin
      output_max_base_mem[i] = {max_pooling_data[row_idx1][col_idx1],max_pooling_data[row_idx2][col_idx2]}; 
      col_idx1=col_idx1+2;
      col_idx2=col_idx2+2;
      if(col_idx1 == N)
      begin
        col_idx1 = 0;
        col_idx2 = 1;
        row_idx1 = row_idx1+1;
        row_idx2 = row_idx2+1;
      end 
      else if(col_idx2 == N)
      begin
        col_idx2 = 0;
        row_idx2 = row_idx2+1;
      end
      if(col_idx1 > N)
      begin
        col_idx1=1;
        row_idx1 = row_idx1+1;
      end
    end 
    if(((N) %2) == 1)
    begin
      output_max_base_mem[i-1] = output_max_base_mem[i-1] & 16'hff00;
    end
  end
  endtask

  task translate_output;
  input [31:0] N;
  integer output_bound,i;
  integer row_idx1, row_idx2;
  integer col_idx1, col_idx2;
  begin
    row_idx1=0;
    row_idx2=0;
    col_idx1=0;
    col_idx2=1;
    output_bound = (((N*N-1)/2)+1);
    for(i=0;i<output_bound;i=i+1)
    begin
      output_mem[i] = {output_data[row_idx1][col_idx1],output_data[row_idx2][col_idx2]}; 
      col_idx1=col_idx1+2;
      col_idx2=col_idx2+2;
      if(col_idx1 == N)
      begin
        col_idx1 = 0;
        col_idx2 = 1;
        row_idx1 = row_idx1+1;
        row_idx2 = row_idx2+1;
      end 
      else if(col_idx2 == N)
      begin
        col_idx2 = 0;
        row_idx2 = row_idx2+1;
      end
      if(col_idx1 > N)
      begin
        col_idx1=1;
        row_idx1 = row_idx1+1;
      end
    end 
    if(((N) %2) == 1)
    begin
      output_mem[i-1] = output_mem[i-1] & 16'hff00;
    end
  end
  endtask

  task upload_output;
  input [31:0] N;
  integer output_bound,i;
  begin
    output_bound = (((N*N-1)/2)+1);
    //$display("output_bound: %d",output_bound);
    for(i=0;i<output_bound;i=i+1)
    begin
        output_sram_write_addresss = i+global_output_address;
        output_sram_write_data = output_mem[i];
        @(posedge clk);
    end
    if(class_name == "564")
    begin
      global_output_address = global_output_address + output_bound;
    end
  end
  endtask

  task upload_max_output;
  input [31:0] N;
  integer output_bound,i;
  begin
    output_bound = (((N*N-1)/2)+1);
    for(i=0;i<output_bound;i=i+1)
    begin
        output_sram_write_addresss = i+global_output_address;
        output_sram_write_data = output_max_base_mem[i];
        @(posedge clk);
    end
    if(class_name == "564")
    begin
      global_output_address = global_output_address + output_bound;
    end
  end
  endtask

  task upload_32bit_output;
  input [31:0] N;
  integer output_bound,i;
  begin
    output_bound = 2*N*N;
    for(i=0;i<output_bound;i=i+1)
    begin
        output_sram_write_addresss = i+global_output_address;
        output_sram_write_data = output_base_mem[i];
        @(posedge clk);
    end
  end
  endtask


  initial
  begin
    #1;
    if($value$plusargs("CLASS=%s",class_name));
    if($value$plusargs("RUN_TYPE=%s",run_type));
    config_N=0;
    fork
      begin
        forever
        begin
          input_sram_write_enable     = 1'b0;  
          input_sram_write_addresss   = 12'b0;
          input_sram_write_data       = 16'b0;
          input_sram_read_address     = 12'b0;
          input_sram_download_complete = 1'b0;
          download_config_complete = 0;
          wait (system_state == `DOWNLOAD_SRAM);
          get_config(config_N);
          if(config_N != 16'hffff)
          begin
            download_config_complete = 1;
            download_input(config_N);
            translate_input_mem(config_N);
            input_sram_download_complete = 1'b1;
          end
          wait (system_state != `DOWNLOAD_SRAM);
          if(config_N == 16'hffff)
          begin
            config_N = 0;
          end
        end
      end
      begin
        kernel_download = 1;
        forever
        begin
          weights_sram_write_enable       = 1'b0;  
          weights_sram_write_addresss     = 12'b0;
          weights_sram_write_data         = 16'b0;
          weights_sram_read_address       = 12'b0;
          weights_sram_download_complete  = 1'b0;
          wait (system_state == `DOWNLOAD_SRAM);
          wait (download_config_complete === 1'b1);
          if(kernel_download === 1)
          begin
            download_kernel();
            kernel_download=0;
            translate_kernel_mem();
          end
          if(class_name == "564")
          begin
            download_weights((config_N-2)/2);
            translate_weights_mem((config_N-2)/2);
          end
          weights_sram_download_complete  = 1'b1;
          wait (system_state != `DOWNLOAD_SRAM);
        end
      end
      begin
        forever
        begin
          wait (system_state == `COMPUTE_OUTPUT);
          compute_convolution_with_relu_activation(config_N-2);
          if(class_name == "564")
          begin
            max_pooling((config_N-2)/2);
            compute_fully_connected_with_relu_activation((config_N-2)/2);
          end
          wait (system_state != `COMPUTE_OUTPUT);
        end
      end
      begin
        forever
        begin
          output_sram_write_enable     = 1'b0;  
          output_sram_write_addresss   = 12'b0;
          output_sram_write_data       = 16'b0;
          output_sram_read_address     = 12'b0;
          write_output_sram_complete = 1'b0;
          wait (system_state == `WRITE_OUTPUT);
          if(class_name == "564")
          begin
            translate_output((config_N-2)/2);
            translate_max_output((config_N-2)/2);
            output_sram_write_enable=1;
            if(run_type == "base")
              upload_max_output((config_N-2)/2);
            else
              upload_output((config_N-2)/2);
          end
          else
          begin
            translate_output(config_N-2);
            translate_32bits_output(config_N-2);
            output_sram_write_enable=1;
            if(run_type == "base")
              upload_32bit_output(config_N-2);
            else
              upload_output(config_N-2);
          end
          output_sram_write_enable=0;
          write_output_sram_complete = 1'b1;
          wait (system_state != `WRITE_OUTPUT);
        end
      end
      begin
        forever
        begin
          wait(system_state == `IDLE);
          global_input_address =0;
          global_weights_address =0;
          global_output_address=0;
          kernel_download = 1;
          wait(system_state != `IDLE);
        end
      end
    join
  end


endmodule
`endif
