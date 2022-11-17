onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -height 24 /tb_top/dut/clk
add wave -noupdate -height 24 /tb_top/dut/soft_reset
add wave -noupdate -height 24 /tb_top/dut/reset_b
add wave -noupdate -height 24 /tb_top/dut/dut_run
add wave -noupdate -height 24 /tb_top/dut/dut_busy
add wave -noupdate -height 24 /tb_top/dut/busy
add wave -noupdate -height 24 /tb_top/dut/wait_accum
add wave -noupdate -height 24 /tb_top/dut/col_return
add wave -noupdate -height 24 /tb_top/dut/row_return
add wave -noupdate -height 24 /tb_top/dut/new_row
add wave -noupdate -height 24 /tb_top/dut/not_new_row
add wave -noupdate -height 24 /tb_top/dut/new_row_accum
add wave -noupdate -height 24 /tb_top/dut/not_new_row_accum
add wave -noupdate -height 24 /tb_top/dut/read_input
add wave -noupdate -height 24 /tb_top/dut/accumulate
add wave -noupdate -height 24 /tb_top/dut/input_sram_write_enable
add wave -noupdate -height 24 /tb_top/dut/input_sram_read_address
add wave -noupdate -height 24 /tb_top/dut/input_sram_read_data
add wave -noupdate -height 24 /tb_top/dut/weights_sram_write_enable
add wave -noupdate -height 24 /tb_top/dut/weights_sram_read_address
add wave -noupdate -height 24 /tb_top/dut/weights_sram_read_data
add wave -noupdate -height 24 /tb_top/dut/N_1
add wave -noupdate -height 24 /tb_top/dut/accum_counter
add wave -noupdate -height 24 /tb_top/dut/read_counter
add wave -noupdate -height 24 /tb_top/dut/row_counter
add wave -noupdate -height 24 /tb_top/dut/col_counter
add wave -noupdate -height 24 /tb_top/dut/output_wait
add wave -noupdate -height 24 /tb_top/dut/accum_done
add wave -noupdate -height 24 /tb_top/dut/frame_pointer
add wave -noupdate -height 24 /tb_top/dut/frame_offset
add wave -noupdate -height 24 /tb_top/dut/frame_offset_1
add wave -noupdate -height 24 -expand /tb_top/dut/input_flops
add wave -noupdate -height 24 -expand /tb_top/dut/kernel_flops
add wave -noupdate -height 24 -expand /tb_top/dut/input_stride
add wave -noupdate -height 24 /tb_top/dut/kernel_stride
add wave -noupdate -height 24 -expand /tb_top/dut/conv_stride
add wave -noupdate -height 24 -expand /tb_top/dut/mul_accum_flops
add wave -noupdate -height 24 /tb_top/dut/pool_in
add wave -noupdate -height 24 /tb_top/dut/pool_mid
add wave -noupdate -height 24 /tb_top/dut/pool_out
add wave -noupdate -height 24 /tb_top/dut/ReLU_mid
add wave -noupdate -height 24 /tb_top/dut/ReLU_out
add wave -noupdate -height 24 /tb_top/dut/output_flops
add wave -noupdate -height 24 /tb_top/dut/output_sram_write_enable
add wave -noupdate -height 24 /tb_top/dut/output_sram_pointer
add wave -noupdate -height 24 /tb_top/dut/output_sram_write_addresss
add wave -noupdate -height 24 /tb_top/dut/output_sram_write_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {554 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 279
configure wave -valuecolwidth 84
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {558 ns} {799 ns}
