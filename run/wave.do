onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_top/dut/dut_run
add wave -noupdate /tb_top/dut/dut_busy
add wave -noupdate /tb_top/dut/reset_b
add wave -noupdate /tb_top/dut/clk
add wave -noupdate /tb_top/dut/input_sram_write_enable
add wave -noupdate /tb_top/dut/weights_sram_write_enable
add wave -noupdate /tb_top/dut/weights_sram_read_address
add wave -noupdate /tb_top/dut/weights_sram_read_data
add wave -noupdate /tb_top/dut/i
add wave -noupdate -color Gray65 -height 40 /tb_top/dut/state
add wave -noupdate /tb_top/dut/next_state
add wave -noupdate -color Cyan /tb_top/dut/counter
add wave -noupdate /tb_top/dut/N_1
add wave -noupdate /tb_top/dut/row
add wave -noupdate /tb_top/dut/col
add wave -noupdate /tb_top/dut/K_REG
add wave -noupdate /tb_top/dut/frame_offset
add wave -noupdate /tb_top/dut/frame_offset_1
add wave -noupdate /tb_top/dut/frame_pointer
add wave -noupdate /tb_top/dut/input_sram_read_address
add wave -noupdate /tb_top/dut/input_sram_read_data
add wave -noupdate -childformat {{{/tb_top/dut/IN_REG[0]} -radix decimal} {{/tb_top/dut/IN_REG[1]} -radix decimal} {{/tb_top/dut/IN_REG[2]} -radix decimal} {{/tb_top/dut/IN_REG[3]} -radix decimal} {{/tb_top/dut/IN_REG[4]} -radix decimal} {{/tb_top/dut/IN_REG[5]} -radix decimal} {{/tb_top/dut/IN_REG[6]} -radix decimal} {{/tb_top/dut/IN_REG[7]} -radix decimal} {{/tb_top/dut/IN_REG[8]} -radix decimal} {{/tb_top/dut/IN_REG[9]} -radix decimal} {{/tb_top/dut/IN_REG[10]} -radix decimal} {{/tb_top/dut/IN_REG[11]} -radix decimal} {{/tb_top/dut/IN_REG[12]} -radix decimal} {{/tb_top/dut/IN_REG[13]} -radix decimal} {{/tb_top/dut/IN_REG[14]} -radix decimal} {{/tb_top/dut/IN_REG[15]} -radix decimal}} -expand -subitemconfig {{/tb_top/dut/IN_REG[0]} {-color Gold -height 16 -radix decimal} {/tb_top/dut/IN_REG[1]} {-color Gold -height 16 -radix decimal} {/tb_top/dut/IN_REG[2]} {-color Gold -height 16 -radix decimal} {/tb_top/dut/IN_REG[3]} {-color Gold -height 16 -radix decimal} {/tb_top/dut/IN_REG[4]} {-color Gold -height 16 -radix decimal} {/tb_top/dut/IN_REG[5]} {-color Gold -height 16 -radix decimal} {/tb_top/dut/IN_REG[6]} {-color Gold -height 16 -radix decimal} {/tb_top/dut/IN_REG[7]} {-color Gold -height 16 -radix decimal} {/tb_top/dut/IN_REG[8]} {-color Gold -height 16 -radix decimal} {/tb_top/dut/IN_REG[9]} {-color Gold -height 16 -radix decimal} {/tb_top/dut/IN_REG[10]} {-color Gold -height 16 -radix decimal} {/tb_top/dut/IN_REG[11]} {-color Gold -height 16 -radix decimal} {/tb_top/dut/IN_REG[12]} {-color Gold -height 16 -radix decimal} {/tb_top/dut/IN_REG[13]} {-color Gold -height 16 -radix decimal} {/tb_top/dut/IN_REG[14]} {-color Gold -height 16 -radix decimal} {/tb_top/dut/IN_REG[15]} {-color Gold -height 16 -radix decimal}} /tb_top/dut/IN_REG
add wave -noupdate /tb_top/dut/mult
add wave -noupdate -expand -subitemconfig {{/tb_top/dut/MAC[0]} {-color Magenta -height 16} {/tb_top/dut/MAC[1]} {-color Magenta -height 16} {/tb_top/dut/MAC[2]} {-color Magenta -height 16} {/tb_top/dut/MAC[3]} {-color Magenta -height 16}} /tb_top/dut/MAC
add wave -noupdate /tb_top/dut/pool_mid
add wave -noupdate /tb_top/dut/pool_out
add wave -noupdate /tb_top/dut/ReLU_mid
add wave -noupdate /tb_top/dut/ReLU_out
add wave -noupdate /tb_top/dut/OUT_REG
add wave -noupdate /tb_top/dut/OUT_wait
add wave -noupdate /tb_top/dut/output_sram_write_enable
add wave -noupdate /tb_top/dut/output_sram_write_addresss
add wave -noupdate /tb_top/dut/output_sram_write_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {10005 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 317
configure wave -valuecolwidth 125
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
WaveRestoreZoom {11383 ns} {11567 ns}
