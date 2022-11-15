`include "sram.sv"
module tb_top();


  parameter CLK_PHASE=5;
  parameter ADDR_464=12'h000;
  parameter MAX_ROUNDS=200;
  //parameter ADDR_564=12'h01f;
  //parameter num_results_464=72;
  //parameter num_results_564=32;
  
  //time computeCycle[rounds];
  time computeCycle;
  //event computeStart[rounds];
  event computeStart;
  //event computeEnd[rounds];
  event computeEnd;
  //event checkFinish[rounds];
  event checkFinish;
  //time startTime[rounds];
  time startTime;
  //time endTime[rounds];
  time endTime;

  event simulationStart;

  string class_name = "464";
  string run_type = "extra";
  integer rounds=1;
  integer timeout=100000000;

  integer num_results=72;
  int correctResult[MAX_ROUNDS];
  reg [15:0] result_array[int];
  reg [15:0] golden_result_array[int];
  int i;
  int j;
  int k;
  int q;
  int p;
  //---------------------------------------------------------------------------
  // General
  //
  reg                                   clk            ;
  reg                                   reset_b        ;
  reg                                   dut_run        ;
  wire                                  dut_busy       ;
  
  //--------------------------------------------------------------------------
  //---------------------- output sram ---------------------------------------------
  wire            output_sram_write_enable        ;
  wire [11:0]     output_sram_write_addresss      ;
  wire [15:0]     output_sram_write_data          ;
  wire [11:0]     output_sram_read_address        ; 
  wire [15:0]     output_sram_read_data           ;
  //---------------------- input sram --------------------------------------------
  wire            input_sram_write_enable        ;
  wire [11:0]     input_sram_write_addresss      ;
  wire [15:0]     input_sram_write_data          ;
  wire [11:0]     input_sram_read_address        ; 
  wire [15:0]     input_sram_read_data           ;
  //------------------ scratchpad sram --------------------------------------------
  wire            scratchpad_sram_write_enable    ;
  wire [11:0]     scratchpad_sram_write_addresss  ;
  wire [15:0]     scratchpad_sram_write_data      ;
  wire [11:0]     scratchpad_sram_read_address    ; 
  wire [15:0]     scratchpad_sram_read_data       ;
  //----------------------- weights ------------------------------------------                                         
  wire            weights_sram_write_enable       ;
  wire [11:0]     weights_sram_write_addresss     ;
  wire [15:0]     weights_sram_write_data         ;
  wire [11:0]     weights_sram_read_address       ; 
  wire [15:0]     weights_sram_read_data          ;
  
  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------
  //SRAM
  //sram for inputs
  sram  #(.ADDR_WIDTH    (12),
          .DATA_WIDTH    (16),
          .MEM_INIT_FILE ("input_sram.dat"        ))
          input_mem  (
          .write_enable ( input_sram_write_enable      ),
          .write_address( input_sram_write_addresss    ),
          .write_data   ( input_sram_write_data        ), 
          .read_address ( input_sram_read_address      ),
          .read_data    ( input_sram_read_data         ),
	  .reset        ( reset_b		       ),
          .clock        ( clk                          )
         );
		 
  //sram for weights
  sram  #(.ADDR_WIDTH    (12),
          .DATA_WIDTH    (16),
          .MEM_INIT_FILE ("weight_sram.dat"           ))
          weight_mem  (
          .write_enable ( weights_sram_write_enable     ),
          .write_address( weights_sram_write_addresss   ),
          .write_data   ( weights_sram_write_data       ), 
          .read_address ( weights_sram_read_address     ),
          .read_data    ( weights_sram_read_data        ), 
	  .reset        ( reset_b		       ),
          .clock        ( clk                          )
         );  

  //sram for scratchpad
  sram  #(.ADDR_WIDTH    (12),
          .DATA_WIDTH    (16),
          .MEM_INIT_FILE (""                          ))
          scratchpad_mem  (
          .write_enable ( scratchpad_sram_write_enable     ),
          .write_address( scratchpad_sram_write_addresss   ),
          .write_data   ( scratchpad_sram_write_data       ), 
          .read_address ( scratchpad_sram_read_address     ),
          .read_data    ( scratchpad_sram_read_data        ), 
	  .reset        ( reset_b		       ),
          .clock        ( clk                          )
         );  
  
  //sram for outputs
  sram  #(.ADDR_WIDTH    (12),
          .DATA_WIDTH    (16),
          .MEM_INIT_FILE ("output_sram.dat"        ))
          output_mem  (
          .write_enable ( output_sram_write_enable     ),
          .write_address( output_sram_write_addresss   ),
          .write_data   ( output_sram_write_data       ), 
          .read_address ( output_sram_read_address     ),
          .read_data    ( output_sram_read_data        ),
	  .reset        ( reset_b		       ),
          .clock        ( clk                          )
         );

		 
//---------------------------------------------------------------------------
// DUT 
//---------------------------------------------------------------------------
  MyDesign dut(
//---------------------------------------------------------------------------
//Control signals
          .dut_run                    (dut_run                      ), 
          .dut_busy                   (dut_busy                     ),
          .reset_b                    (reset_b                      ),  
          .clk                        (clk                          ),
 
//---------------------------------------------------------------------------
//input SRAM interface
          .input_sram_write_enable        (input_sram_write_enable      ),
          .input_sram_write_addresss      (input_sram_write_addresss    ),
          .input_sram_write_data          (input_sram_write_data        ),
          .input_sram_read_address        (input_sram_read_address      ),
          .input_sram_read_data           (input_sram_read_data         ),

//---------------------------------------------------------------------------
//Output SRAM interface
          .output_sram_write_enable       (output_sram_write_enable     ),
          .output_sram_write_addresss     (output_sram_write_addresss   ),
          .output_sram_write_data         (output_sram_write_data       ),
          .output_sram_read_address       (output_sram_read_address     ),
          .output_sram_read_data          (output_sram_read_data        ),

//---------------------------------------------------------------------------
//scratchpad SRAM interface                                                       
          .scratchpad_sram_write_enable   (scratchpad_sram_write_enable    ),
          .scratchpad_sram_write_addresss (scratchpad_sram_write_addresss  ),
          .scratchpad_sram_write_data     (scratchpad_sram_write_data      ),
          .scratchpad_sram_read_address   (scratchpad_sram_read_address    ),
          .scratchpad_sram_read_data      (scratchpad_sram_read_data       ),

//---------------------------------------------------------------------------
//weights SRAM interface                                                       
          .weights_sram_write_enable      (weights_sram_write_enable    ),
          .weights_sram_write_addresss    (weights_sram_write_addresss  ),
          .weights_sram_write_data        (weights_sram_write_data      ),
          .weights_sram_read_address      (weights_sram_read_address    ),
          .weights_sram_read_data         (weights_sram_read_data       )
         );

       
  //---------------------------------------------------------------------------
  //  clk
  initial 
    begin
        clk                     = 1'b0;
        forever # CLK_PHASE clk = ~clk;
    end

  //---------------------------------------------------------------------------
  // Read in args 
  initial
  begin
    #1;
    //if($test$plusargs("CLASS"))
    //begin
    //  $value$plusargs("CLASS=%s",class_name);
    //  //$getstr$plusargs("CLASS=",class_name);
    //end
    if(!$value$plusargs("CLASS=%s",class_name)) class_name = "464";
    if($value$plusargs("ROUNDS=%d",rounds));
    if($value$plusargs("TIMEOUT=%d",timeout));
    if($value$plusargs("RUN_TYPE=%s",run_type));
    $display("+CLASS+%s",class_name);
    $display("+RUN_TYPE+%s",run_type);

    repeat (5) @(posedge clk);
    ->simulationStart;
  end
  
		 
  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------
  // Stimulus
  initial 
  begin
    wait(simulationStart);
    $display("-------------------------------start_simulation-------------------------------\n");
    reset_b=1;
    repeat(25) @(posedge clk); 
    reset_b=0;
    dut_run=0;
    repeat(25) @(posedge clk);
    reset_b=1;
    for(j=0;j<rounds;j=j+1) 
    begin
      //if(j!=0) wait(checkFinish[j-1]);
      if(j!=0) wait(checkFinish);
      //input_mem.loadInitFile($sformatf("../464/input_sram_464.dat"));
      //weight_mem.loadInitFile($sformatf("../464/weight_sram_464.dat"));
      input_mem.loadInitFile($sformatf("../%s/input_%0d/input_sram_%s.dat",class_name,j,class_name));
      weight_mem.loadInitFile($sformatf("../%s/input_%0d/weight_sram_%s.dat",class_name,j,class_name));

      repeat(5) @(posedge clk);
      wait(dut_busy==0);
      @(posedge clk);
      dut_run=1; // DUT starts computing
      //->computeStart[j];
      ->computeStart;
      $display("-------------------------------Round %0d start-------------------------------\n",j);
      wait(dut_busy==1);
      @(posedge clk);
      dut_run=0;
      wait(dut_busy==0);
      //->computeEnd[j];
      ->computeEnd;
    end
  end
  
  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------
  // Timer
  //
  initial 
  begin
    //for(k=0;k<rounds;k=k+1) begin 
    forever
    begin
      //wait(computeStart[k]);
      wait(computeStart);
      //startTime[k]=$time;
      startTime=$time;
      //wait(computeEnd[k]);
      wait(computeEnd);
      //endTime[k]=$time;
      endTime=$time;
      //computeCycle[k]=endTime-startTime;
      computeCycle=endTime-startTime;
    end
  end

  initial
  begin
    forever
    begin
      if($time > timeout)
      begin
        $display("---------------------------------------------------------------------------------\n");
        $display("Timeout after %0d cycles",($time/(2*CLK_PHASE)));
        $display("---------------------------------------------------------------------------------\n");
        $finish;
      end
      @(posedge clk);
    end
  end  


  //---------------------------------------------------------------------------
  // Result collector 
  // Collect your compute results 

  initial 
  begin
    for(q=0;q<rounds;q=q+1) 
    begin
      wait(computeEnd);
      repeat(10) @(posedge clk);
      $display("-------------------------------Round %0d check start-------------------------------\n",q);
      $display("-------------------------------store results to g_result.dat-------------------------------\n");

      //if (q==0)
      $writememh($sformatf("input_%0d/result.dat",q),output_mem.mem,0);
      repeat(10) @(posedge clk);

      //---------------------------------------------------------------------------
      //---------------------------------------------------------------------------
      // Result comparator 
      // Compare your compute results with the results computed by Python script
      $display("-------------------------------load results to output_array-------------------------------\n");
      $readmemh($sformatf("input_%0d/result.dat",q),result_array);

      golden_result_array.delete();
      $display("-------------------------------load results to golden_output_array-------------------------------\n");
      if(run_type == "base")
      begin
        $display("INFO::%m::readmem : %s ", $sformatf("../%s/input_%0d/golden_base_outputs_%s.dat",class_name,q,class_name));
        $readmemh($sformatf("../%s/input_%0d/golden_base_outputs_%s.dat",class_name,q,class_name),golden_result_array);
      end
      else
      begin
        $display("INFO::%m::readmem : %s ", $sformatf("../%s/input_%0d/golden_outputs_%s.dat",class_name,q,class_name));
        $readmemh($sformatf("../%s/input_%0d/golden_outputs_%s.dat",class_name,q,class_name),golden_result_array);
      end
      $display("-------------------------------Round %0d start compare -------------------------------\n",q);
      begin
        for(i=0;i<golden_result_array.size();i=i+1) 
        begin
          if(result_array[i]==golden_result_array[i]) 
            correctResult[q]=correctResult[q]+1;
          else
            $display("result_array[%d]:%d\t!= golden_result_array[%d]:%d",i,result_array[i],i,golden_result_array[i]);
        end
      end

      $display("-------------------------------Round %0d Your report-------------------------------\n",q);
      //if(q==0)
      $display("Check 1 : Correct g results = %0d/%0d",correctResult[q],golden_result_array.size());
      //$display("Check 1 : Correct g results = %0d/%0d",correctResult[q],num_results_564);

      //else
      //	$display("Check 1 : Correct g results = %0d/%0d",correctResult[q],num_results_one);

      //$display("computeCycle=%0d",computeCycle[q]/(2*CLK_PHASE));
      $display("computeCycle=%0d",computeCycle/(2*CLK_PHASE));
      $display("---------------------------------------------------------------------------------\n");
      @(posedge clk);
      //->checkFinish[q];
      ->checkFinish;
    end 
    $finish;
  end
  
endmodule
