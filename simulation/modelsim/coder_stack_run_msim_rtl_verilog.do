transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+E:/Courses/ECE559/coder-stack/int {E:/Courses/ECE559/coder-stack/int/interleaver_fsm_new.v}
vlog -vlog01compat -work work +incdir+E:/Courses/ECE559/coder-stack/int {E:/Courses/ECE559/coder-stack/int/interleaver.v}
vlog -vlog01compat -work work +incdir+E:/Courses/ECE559/coder-stack/int {E:/Courses/ECE559/coder-stack/int/counter2.v}
vlog -vlog01compat -work work +incdir+E:/Courses/ECE559/coder-stack/int {E:/Courses/ECE559/coder-stack/int/counter1.v}
vlog -vlog01compat -work work +incdir+E:/Courses/ECE559/coder-stack/int {E:/Courses/ECE559/coder-stack/int/counter_wrapper2.v}
vlog -vlog01compat -work work +incdir+E:/Courses/ECE559/coder-stack/int {E:/Courses/ECE559/coder-stack/int/counter_wrapper1.v}
vlog -vlog01compat -work work +incdir+E:/Courses/ECE559/coder-stack/int {E:/Courses/ECE559/coder-stack/int/pi1_small_bit7.v}
vlog -vlog01compat -work work +incdir+E:/Courses/ECE559/coder-stack/int {E:/Courses/ECE559/coder-stack/int/pi1_small_bit6.v}
vlog -vlog01compat -work work +incdir+E:/Courses/ECE559/coder-stack/int {E:/Courses/ECE559/coder-stack/int/pi1_small_bit5.v}
vlog -vlog01compat -work work +incdir+E:/Courses/ECE559/coder-stack/int {E:/Courses/ECE559/coder-stack/int/pi1_small_bit4.v}
vlog -vlog01compat -work work +incdir+E:/Courses/ECE559/coder-stack/int {E:/Courses/ECE559/coder-stack/int/pi1_small_bit3.v}
vlog -vlog01compat -work work +incdir+E:/Courses/ECE559/coder-stack/int {E:/Courses/ECE559/coder-stack/int/pi1_small_bit2.v}
vlog -vlog01compat -work work +incdir+E:/Courses/ECE559/coder-stack/int {E:/Courses/ECE559/coder-stack/int/pi1_small_bit1.v}
vlog -vlog01compat -work work +incdir+E:/Courses/ECE559/coder-stack/int {E:/Courses/ECE559/coder-stack/int/pi1_small_bit0.v}
vlog -vlog01compat -work work +incdir+E:/Courses/ECE559/coder-stack/int {E:/Courses/ECE559/coder-stack/int/pi1_large_bit7.v}
vlog -vlog01compat -work work +incdir+E:/Courses/ECE559/coder-stack/int {E:/Courses/ECE559/coder-stack/int/pi1_large_bit6.v}
vlog -vlog01compat -work work +incdir+E:/Courses/ECE559/coder-stack/int {E:/Courses/ECE559/coder-stack/int/pi1_large_bit5.v}
vlog -vlog01compat -work work +incdir+E:/Courses/ECE559/coder-stack/int {E:/Courses/ECE559/coder-stack/int/pi1_large_bit4.v}
vlog -vlog01compat -work work +incdir+E:/Courses/ECE559/coder-stack/int {E:/Courses/ECE559/coder-stack/int/pi1_large_bit3.v}
vlog -vlog01compat -work work +incdir+E:/Courses/ECE559/coder-stack/int {E:/Courses/ECE559/coder-stack/int/pi1_large_bit2.v}
vlog -vlog01compat -work work +incdir+E:/Courses/ECE559/coder-stack/int {E:/Courses/ECE559/coder-stack/int/pi1_large_bit1.v}
vlog -vlog01compat -work work +incdir+E:/Courses/ECE559/coder-stack/int {E:/Courses/ECE559/coder-stack/int/pi1_large_bit0.v}
vlog -vlog01compat -work work +incdir+E:/Courses/ECE559/coder-stack/int {E:/Courses/ECE559/coder-stack/int/bit_ram.v}
vlog -vlog01compat -work work +incdir+E:/Courses/ECE559/coder-stack/cdseg/IP {E:/Courses/ECE559/coder-stack/cdseg/IP/fifo_11bits.v}
vlog -vlog01compat -work work +incdir+E:/Courses/ECE559/coder-stack {E:/Courses/ECE559/coder-stack/coder_stack_top.v}
vlog -vlog01compat -work work +incdir+E:/Courses/ECE559/coder-stack/cdseg/IP {E:/Courses/ECE559/coder-stack/cdseg/IP/shiftreg.v}
vlog -vlog01compat -work work +incdir+E:/Courses/ECE559/coder-stack/cdseg/IP {E:/Courses/ECE559/coder-stack/cdseg/IP/register_8bits.v}
vlog -vlog01compat -work work +incdir+E:/Courses/ECE559/coder-stack/cdseg/IP {E:/Courses/ECE559/coder-stack/cdseg/IP/register_2bits.v}
vlog -vlog01compat -work work +incdir+E:/Courses/ECE559/coder-stack/cdseg/IP {E:/Courses/ECE559/coder-stack/cdseg/IP/register_1bit.v}
vlog -vlog01compat -work work +incdir+E:/Courses/ECE559/coder-stack/cdseg/IP {E:/Courses/ECE559/coder-stack/cdseg/IP/mux_ip.v}
vlog -vlog01compat -work work +incdir+E:/Courses/ECE559/coder-stack/cdseg/IP {E:/Courses/ECE559/coder-stack/cdseg/IP/fifo14.v}
vlog -vlog01compat -work work +incdir+E:/Courses/ECE559/coder-stack/cdseg/IP {E:/Courses/ECE559/coder-stack/cdseg/IP/fifo12.v}
vlog -vlog01compat -work work +incdir+E:/Courses/ECE559/coder-stack/cdseg/IP {E:/Courses/ECE559/coder-stack/cdseg/IP/fifo_tb.v}
vlog -vlog01compat -work work +incdir+E:/Courses/ECE559/coder-stack/cdseg/IP {E:/Courses/ECE559/coder-stack/cdseg/IP/fifo_10bits.v}
vlog -vlog01compat -work work +incdir+E:/Courses/ECE559/coder-stack/cdseg/IP {E:/Courses/ECE559/coder-stack/cdseg/IP/crc_shift_mux.v}
vlog -vlog01compat -work work +incdir+E:/Courses/ECE559/coder-stack/cdseg/IP {E:/Courses/ECE559/coder-stack/cdseg/IP/counter_10bits.v}
vlog -vlog01compat -work work +incdir+E:/Courses/ECE559/coder-stack/cdseg/src {E:/Courses/ECE559/coder-stack/cdseg/src/top_module.v}
vlog -vlog01compat -work work +incdir+E:/Courses/ECE559/coder-stack/cdseg/src {E:/Courses/ECE559/coder-stack/cdseg/src/data_path_control.v}
vlog -vlog01compat -work work +incdir+E:/Courses/ECE559/coder-stack/cdseg/src {E:/Courses/ECE559/coder-stack/cdseg/src/crc24.v}
vlog -vlog01compat -work work +incdir+E:/Courses/ECE559/coder-stack/enc {E:/Courses/ECE559/coder-stack/enc/byte_fifo.v}
vlog -vlog01compat -work work +incdir+E:/Courses/ECE559/coder-stack/enc {E:/Courses/ECE559/coder-stack/enc/my_counter.v}
vlog -vlog01compat -work work +incdir+E:/Courses/ECE559/coder-stack/enc {E:/Courses/ECE559/coder-stack/enc/fsm.v}
vlog -vlog01compat -work work +incdir+E:/Courses/ECE559/coder-stack/enc {E:/Courses/ECE559/coder-stack/enc/fifoFSM.v}
vlog -vlog01compat -work work +incdir+E:/Courses/ECE559/coder-stack/enc {E:/Courses/ECE559/coder-stack/enc/delay.v}
vlog -vlog01compat -work work +incdir+E:/Courses/ECE559/coder-stack/enc {E:/Courses/ECE559/coder-stack/enc/counter.v}
vlog -vlog01compat -work work +incdir+E:/Courses/ECE559/coder-stack/tb {E:/Courses/ECE559/coder-stack/tb/htb_coder_stack.v}
vlog -vlog01compat -work work +incdir+E:/Courses/ECE559/coder-stack/tb/IP {E:/Courses/ECE559/coder-stack/tb/IP/test_input.v}
vlog -vlog01compat -work work +incdir+E:/Courses/ECE559/coder-stack/tb/IP {E:/Courses/ECE559/coder-stack/tb/IP/ref_small.v}
vlog -vlog01compat -work work +incdir+E:/Courses/ECE559/coder-stack/tb/IP {E:/Courses/ECE559/coder-stack/tb/IP/delay3.v}
vlog -vlog01compat -work work +incdir+E:/Courses/ECE559/coder-stack/enc {E:/Courses/ECE559/coder-stack/enc/encoder_parallel.v}
vlog -vlog01compat -work work +incdir+E:/Courses/ECE559/coder-stack/enc {E:/Courses/ECE559/coder-stack/enc/tailBitsGenerator_parallel.v}
vlog -vlog01compat -work work +incdir+E:/Courses/ECE559/coder-stack/enc {E:/Courses/ECE559/coder-stack/enc/encoder_top_parallel.v}
vlog -vlog01compat -work work +incdir+E:/Courses/ECE559/coder-stack/tb/IP {E:/Courses/ECE559/coder-stack/tb/IP/ref_large.v}
vlog -sv -work work +incdir+E:/Courses/ECE559/coder-stack/cdseg/src {E:/Courses/ECE559/coder-stack/cdseg/src/CRC_size.sv}

vlog -vlog01compat -work work +incdir+E:/Courses/ECE559/coder-stack/tb {E:/Courses/ECE559/coder-stack/tb/tb_htb_coder_stack.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  tb_mem_htb

add wave *
view structure
view signals
run 100 us
