onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider FIFO_tb
add wave -noupdate /fifo_tb/clk
add wave -noupdate /fifo_tb/rst_a
add wave -noupdate /fifo_tb/rst_s
add wave -noupdate -divider DUV
add wave -noupdate -divider BUS
add wave -noupdate /fifo_tb/duv/bus/clk
add wave -noupdate /fifo_tb/duv/bus/rst_a
add wave -noupdate /fifo_tb/duv/bus/rst_s
add wave -noupdate /fifo_tb/duv/bus/lleno
add wave -noupdate /fifo_tb/duv/bus/vacio
add wave -noupdate /fifo_tb/duv/bus/rd_en
add wave -noupdate /fifo_tb/duv/bus/wr_en
add wave -noupdate /fifo_tb/duv/bus/use_dw
add wave -noupdate /fifo_tb/duv/bus/data_in
add wave -noupdate /fifo_tb/duv/bus/data_out
add wave -noupdate -divider px
add wave -noupdate /fifo_tb/bus/px/data_out
add wave -noupdate /fifo_tb/bus/px/data_in
add wave -noupdate /fifo_tb/bus/px/use_dw
add wave -noupdate /fifo_tb/bus/px/wr_en
add wave -noupdate /fifo_tb/bus/px/rd_en
add wave -noupdate /fifo_tb/bus/px/vacio
add wave -noupdate /fifo_tb/bus/px/lleno
add wave -noupdate /fifo_tb/bus/px/rst_s
add wave -noupdate /fifo_tb/bus/px/rst_a
add wave -noupdate /fifo_tb/bus/px/px_event
add wave -noupdate -divider tx
add wave -noupdate /fifo_tb/bus/tx/wr_en
add wave -noupdate /fifo_tb/bus/tx/rd_en
add wave -noupdate /fifo_tb/bus/tx/data_in
add wave -noupdate /fifo_tb/bus/tx/rst_s
add wave -noupdate /fifo_tb/bus/tx/tx_event
add wave -noupdate -divider neg_event
add wave -noupdate /fifo_tb/bus/neg_event/rst_a
add wave -noupdate /fifo_tb/bus/neg_event/neg_event_event
add wave -noupdate -divider FIFO_DUV
add wave -noupdate /fifo_tb/duv/fifo_duv/CLOCK
add wave -noupdate /fifo_tb/duv/fifo_duv/RESET_N
add wave -noupdate /fifo_tb/duv/fifo_duv/CLEAR_N
add wave -noupdate /fifo_tb/duv/fifo_duv/DATA_IN
add wave -noupdate /fifo_tb/duv/fifo_duv/READ
add wave -noupdate /fifo_tb/duv/fifo_duv/WRITE
add wave -noupdate /fifo_tb/duv/fifo_duv/DATA_OUT
add wave -noupdate /fifo_tb/duv/fifo_duv/USE_DW
add wave -noupdate /fifo_tb/duv/fifo_duv/F_EMPTY_N
add wave -noupdate /fifo_tb/duv/fifo_duv/F_FULL_N
add wave -noupdate /fifo_tb/duv/fifo_duv/state
add wave -noupdate /fifo_tb/duv/fifo_duv/enableR
add wave -noupdate /fifo_tb/duv/fifo_duv/enableW
add wave -noupdate /fifo_tb/duv/fifo_duv/enableDW
add wave -noupdate /fifo_tb/duv/fifo_duv/UpDownDW
add wave -noupdate /fifo_tb/duv/fifo_duv/data_RAM
add wave -noupdate /fifo_tb/duv/fifo_duv/cableR
add wave -noupdate /fifo_tb/duv/fifo_duv/cableW
add wave -noupdate /fifo_tb/duv/fifo_duv/bypass
add wave -noupdate /fifo_tb/duv/fifo_duv/dato_bypass
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 144
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
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
WaveRestoreZoom {0 ps} {10720500 ps}
