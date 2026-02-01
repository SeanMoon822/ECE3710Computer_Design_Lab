# Create project in build directory
file mkdir build
cd build
project_new -overwrite ece3710
cd ..

# Set device
set_global_assignment -name FAMILY "Cyclone V"
set_global_assignment -name DEVICE 5CSEMA5F31C6
set_global_assignment -name BOARD "DE1-SoC Board"

# Configure project
set_global_assignment -name NUM_PARALLEL_PROCESSORS ALL
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
set_global_assignment -name EDA_SIMULATION_TOOL "Questa Intel FPGA (Verilog)"
set_global_assignment -name EDA_TIME_SCALE "1 ps" -section_id eda_simulation
set_global_assignment -name EDA_OUTPUT_DATA_FORMAT "VERILOG HDL" -section_id eda_simulation
set_global_assignment -name EDA_GENERATE_FUNCTIONAL_NETLIST OFF -section_id eda_board_design_timing
set_global_assignment -name EDA_GENERATE_FUNCTIONAL_NETLIST OFF -section_id eda_board_design_symbol
set_global_assignment -name EDA_GENERATE_FUNCTIONAL_NETLIST OFF -section_id eda_board_design_signal_integrity
set_global_assignment -name EDA_GENERATE_FUNCTIONAL_NETLIST OFF -section_id eda_board_design_boundary_scan

# Set top-level entity
set_global_assignment -name TOP_LEVEL_ENTITY top_de1soc
set_global_assignment -name SDC_FILE ../top_de1soc.sdc
set_global_assignment -name VERILOG_FILE ../verilog/top_de1soc.v

# Add design files
set_global_assignment -name HEX_FILE ../program.hex
set_global_assignment -name HEX_FILE ../verilog/font8x8.hex
set_global_assignment -name VERILOG_FILE ../verilog/VGA_bitgen.v
set_global_assignment -name VERILOG_FILE ../verilog/VGA_controller.v
set_global_assignment -name VERILOG_FILE ../verilog/alu.v
set_global_assignment -name VERILOG_FILE ../verilog/alu_flags.v
set_global_assignment -name VERILOG_FILE ../verilog/alu_opcodes.v
set_global_assignment -name VERILOG_FILE ../verilog/bram.v
set_global_assignment -name VERILOG_FILE ../verilog/char_grid.v
set_global_assignment -name VERILOG_FILE ../verilog/condcheck.v
set_global_assignment -name VERILOG_FILE ../verilog/control.v
set_global_assignment -name VERILOG_FILE ../verilog/datapath.v
set_global_assignment -name VERILOG_FILE ../verilog/decode.v
set_global_assignment -name VERILOG_FILE ../verilog/decrement.v
set_global_assignment -name VERILOG_FILE ../verilog/font_rom.v
set_global_assignment -name VERILOG_FILE ../verilog/hex_to_sev_seg.v
set_global_assignment -name VERILOG_FILE ../verilog/hori_counter.v
set_global_assignment -name VERILOG_FILE ../verilog/imm_extend.v
set_global_assignment -name VERILOG_FILE ../verilog/increment.v
set_global_assignment -name VERILOG_FILE ../verilog/mapped_bram.v
set_global_assignment -name VERILOG_FILE ../verilog/mapped_register.v
set_global_assignment -name VERILOG_FILE ../verilog/mux_2_to_1.v
set_global_assignment -name VERILOG_FILE ../verilog/mux_4_to_1.v
set_global_assignment -name VERILOG_FILE ../verilog/pc_add.v
set_global_assignment -name VERILOG_FILE ../verilog/ps2_interface.v
set_global_assignment -name VERILOG_FILE ../verilog/ps2_scancode_decoder.v
set_global_assignment -name VERILOG_FILE ../verilog/regfile.v
set_global_assignment -name VERILOG_FILE ../verilog/register.v
set_global_assignment -name VERILOG_FILE ../verilog/text_mem.v
set_global_assignment -name VERILOG_FILE ../verilog/top.v
set_global_assignment -name VERILOG_FILE ../verilog/vert_counter.v

# add FPU files
set_global_assignment -name VERILOG_FILE ../fpu/FPU.v
set_global_assignment -name VERILOG_FILE ../fpu/FPUdefines.v
set_global_assignment -name VERILOG_FILE ../fpu/decoder_logarithmic.v
set_global_assignment -name VERILOG_FILE ../fpu/encoder_logarithmic.v
set_global_assignment -name VERILOG_FILE ../fpu/takum16_to_l.v
set_global_assignment -name VERILOG_FILE ../fpu/tb_takum16_to_l.v
set_global_assignment -name VERILOG_FILE ../fpu/takum16_from_l.v
set_global_assignment -name VERILOG_FILE ../fpu/tb_takum16_from_l.v
set_global_assignment -name VERILOG_FILE ../fpu/takum16_encode_decode.v
set_global_assignment -name VERILOG_FILE ../fpu/tb_takum16_encode_decode.v
set_global_assignment -name VERILOG_FILE ../fpu/FloatingCompare.v
set_global_assignment -name VERILOG_FILE ../fpu/FloatingAddition.v

# Add DE1-Soc pin assignments
set_location_assignment PIN_AF14 -to clk_50MHz
set_location_assignment PIN_AA14 -to key[0]
set_location_assignment PIN_AA15 -to key[1]
set_location_assignment PIN_W15 -to key[2]
set_location_assignment PIN_Y16 -to key[3]
set_location_assignment PIN_AB12 -to sw[0]
set_location_assignment PIN_AC12 -to sw[1]
set_location_assignment PIN_AF9 -to sw[2]
set_location_assignment PIN_AF10 -to sw[3]
set_location_assignment PIN_AD11 -to sw[4]
set_location_assignment PIN_AD12 -to sw[5]
set_location_assignment PIN_AE11 -to sw[6]
set_location_assignment PIN_AC9 -to sw[7]
set_location_assignment PIN_AD10 -to sw[8]
set_location_assignment PIN_AE12 -to sw[9]
set_location_assignment PIN_V16 -to led[0]
set_location_assignment PIN_W16 -to led[1]
set_location_assignment PIN_V17 -to led[2]
set_location_assignment PIN_V18 -to led[3]
set_location_assignment PIN_W17 -to led[4]
set_location_assignment PIN_W19 -to led[5]
set_location_assignment PIN_Y19 -to led[6]
set_location_assignment PIN_W20 -to led[7]
set_location_assignment PIN_W21 -to led[8]
set_location_assignment PIN_Y21 -to led[9]
set_location_assignment PIN_AE26 -to seg_0[0]
set_location_assignment PIN_AE27 -to seg_0[1]
set_location_assignment PIN_AE28 -to seg_0[2]
set_location_assignment PIN_AG27 -to seg_0[3]
set_location_assignment PIN_AF28 -to seg_0[4]
set_location_assignment PIN_AG28 -to seg_0[5]
set_location_assignment PIN_AH28 -to seg_0[6]
set_location_assignment PIN_AJ29 -to seg_1[0]
set_location_assignment PIN_AH29 -to seg_1[1]
set_location_assignment PIN_AH30 -to seg_1[2]
set_location_assignment PIN_AG30 -to seg_1[3]
set_location_assignment PIN_AF29 -to seg_1[4]
set_location_assignment PIN_AF30 -to seg_1[5]
set_location_assignment PIN_AD27 -to seg_1[6]
set_location_assignment PIN_AB23 -to seg_2[0]
set_location_assignment PIN_AE29 -to seg_2[1]
set_location_assignment PIN_AD29 -to seg_2[2]
set_location_assignment PIN_AC28 -to seg_2[3]
set_location_assignment PIN_AD30 -to seg_2[4]
set_location_assignment PIN_AC29 -to seg_2[5]
set_location_assignment PIN_AC30 -to seg_2[6]
set_location_assignment PIN_AD26 -to seg_3[0]
set_location_assignment PIN_AC27 -to seg_3[1]
set_location_assignment PIN_AD25 -to seg_3[2]
set_location_assignment PIN_AC25 -to seg_3[3]
set_location_assignment PIN_AB28 -to seg_3[4]
set_location_assignment PIN_AB25 -to seg_3[5]
set_location_assignment PIN_AB22 -to seg_3[6]
set_location_assignment PIN_AA24 -to seg_4[0]
set_location_assignment PIN_Y23 -to seg_4[1]
set_location_assignment PIN_Y24 -to seg_4[2]
set_location_assignment PIN_W22 -to seg_4[3]
set_location_assignment PIN_W24 -to seg_4[4]
set_location_assignment PIN_V23 -to seg_4[5]
set_location_assignment PIN_W25 -to seg_4[6]
set_location_assignment PIN_V25 -to seg_5[0]
set_location_assignment PIN_AA28 -to seg_5[1]
set_location_assignment PIN_Y27 -to seg_5[2]
set_location_assignment PIN_AB27 -to seg_5[3]
set_location_assignment PIN_AB26 -to seg_5[4]
set_location_assignment PIN_AA26 -to seg_5[5]
set_location_assignment PIN_AA25 -to seg_5[6]
set_location_assignment PIN_AD7 -to ps2_clk[0]
set_location_assignment PIN_AD9 -to ps2_clk[1]
set_location_assignment PIN_AE7 -to ps2_dat[0]
set_location_assignment PIN_AE9 -to ps2_dat[1]
set_location_assignment PIN_A13 -to vga_r[0]
set_location_assignment PIN_C13 -to vga_r[1]
set_location_assignment PIN_E13 -to vga_r[2]
set_location_assignment PIN_B12 -to vga_r[3]
set_location_assignment PIN_C12 -to vga_r[4]
set_location_assignment PIN_D12 -to vga_r[5]
set_location_assignment PIN_E12 -to vga_r[6]
set_location_assignment PIN_F13 -to vga_r[7]
set_location_assignment PIN_J9 -to vga_g[0]
set_location_assignment PIN_J10 -to vga_g[1]
set_location_assignment PIN_H12 -to vga_g[2]
set_location_assignment PIN_G10 -to vga_g[3]
set_location_assignment PIN_G11 -to vga_g[4]
set_location_assignment PIN_G12 -to vga_g[5]
set_location_assignment PIN_F11 -to vga_g[6]
set_location_assignment PIN_E11 -to vga_g[7]
set_location_assignment PIN_B13 -to vga_b[0]
set_location_assignment PIN_G13 -to vga_b[1]
set_location_assignment PIN_H13 -to vga_b[2]
set_location_assignment PIN_F14 -to vga_b[3]
set_location_assignment PIN_H14 -to vga_b[4]
set_location_assignment PIN_F15 -to vga_b[5]
set_location_assignment PIN_G15 -to vga_b[6]
set_location_assignment PIN_J14 -to vga_b[7]
set_location_assignment PIN_A11 -to vga_clk
set_location_assignment PIN_F10 -to vga_blank_n
set_location_assignment PIN_B11 -to vga_hs
set_location_assignment PIN_D11 -to vga_vs
set_location_assignment PIN_C10 -to vga_sync_n

# Save and close project
project_close
