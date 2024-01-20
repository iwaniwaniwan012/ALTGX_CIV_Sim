if ![info exists QUARTUS_INSTALL_DIR] { 
  set QUARTUS_INSTALL_DIR "/home/dev/intelFPGA_lite/21.1/quartus/"
} 

proc ensure_lib { lib } { if ![file isdirectory $lib] { vlib $lib } }

ensure_lib ./work/
vmap work ./work/
ensure_lib ./hw_libs/

if ![ string match "*ModelSim ALTERA*" [ vsim -version ] ] {
  ensure_lib            ./hw_libs/altera_ver/       
  vmap altera_ver       ./hw_libs/altera_ver/       
  ensure_lib            ./hw_libs/lpm_ver/          
  vmap lpm_ver          ./hw_libs/lpm_ver/          
  ensure_lib            ./hw_libs/sgate_ver/        
  vmap sgate_ver        ./hw_libs/sgate_ver/        
  ensure_lib            ./hw_libs/altera_mf_ver/    
  vmap altera_mf_ver    ./hw_libs/altera_mf_ver/
  ensure_lib            ./hw_libs/altera_lnsim_ver/    
  vmap altera_lnsim_ver ./hw_libs/altera_lnsim_ver/
  ensure_lib            ./hw_libs/altera/           
  vmap altera           ./hw_libs/altera/           
  ensure_lib            ./hw_libs/lpm/              
  vmap lpm              ./hw_libs/lpm/              
  ensure_lib            ./hw_libs/sgate/            
  vmap sgate            ./hw_libs/sgate/            
  ensure_lib            ./hw_libs/altera_mf/        
  vmap altera_mf        ./hw_libs/altera_mf/
  ensure_lib            ./hw_libs/altera_lnsim/
  vmap altera_lnsim     ./hw_libs/altera_lnsim/
  ensure_lib            ./hw_libs/cycloneiv/
  vmap cycloneiv        ./hw_libs/cycloneiv/
  ensure_lib            ./hw_libs/cycloneiv_hssi/
  vmap cycloneiv_hssi   ./hw_libs/cycloneiv_hssi/
  ensure_lib            ./hw_libs/cycloneiv_pcie_hip/
  vmap cycloneiv_pcie_hip   ./hw_libs/cycloneiv_pcie_hip/
}

#alias dev_com {
#  echo "\[exec\] dev_com"
  if ![ string match "*ModelSim ALTERA*" [ vsim -version ] ] {
    eval  vlog "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_primitives.v"                 -work altera_ver       
    eval  vlog "$QUARTUS_INSTALL_DIR/eda/sim_lib/220model.v"                          -work lpm_ver          
    eval  vlog "$QUARTUS_INSTALL_DIR/eda/sim_lib/sgate.v"                             -work sgate_ver        
    eval  vlog "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_mf.v"                         -work altera_mf_ver    
    eval  vlog -sv "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_lnsim.sv"                 -work altera_lnsim_ver 
    eval  vcom   "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_syn_attributes.vhd"           -work altera           
    eval  vcom   "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_standard_functions.vhd"       -work altera           
    eval  vcom   "$QUARTUS_INSTALL_DIR/eda/sim_lib/alt_dspbuilder_package.vhd"          -work altera           
    eval  vcom   "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_europa_support_lib.vhd"       -work altera           
    eval  vcom   "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_primitives_components.vhd"    -work altera           
    eval  vcom   "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_primitives.vhd"               -work altera           
    eval  vcom   "$QUARTUS_INSTALL_DIR/eda/sim_lib/220pack.vhd"                         -work lpm              
    eval  vcom   "$QUARTUS_INSTALL_DIR/eda/sim_lib/220model.vhd"                        -work lpm              
    eval  vcom   "$QUARTUS_INSTALL_DIR/eda/sim_lib/sgate_pack.vhd"                      -work sgate            
    eval  vcom   "$QUARTUS_INSTALL_DIR/eda/sim_lib/sgate.vhd"                           -work sgate
    eval  vcom   "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_mf_components.vhd"            -work altera_mf        
    eval  vcom   "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_mf.vhd"                       -work altera_mf
    eval  vcom   "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_mf.vhd"                       -work altera_mf
    eval  vlog -sv   "$QUARTUS_INSTALL_DIR/eda/sim_lib/mentor/altera_lnsim_for_vhdl.sv"     -work altera_lnsim    
    eval  vcom   "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_lnsim_components.vhd"         -work altera_lnsim 
    eval  vcom   "$QUARTUS_INSTALL_DIR/eda/sim_lib/cycloneiv_atoms.vhd"                 -work cycloneiv
    eval  vcom   "$QUARTUS_INSTALL_DIR/eda/sim_lib/cycloneiv_components.vhd"            -work cycloneiv
    eval  vcom "$QUARTUS_INSTALL_DIR/eda/sim_lib/cycloneiv_hssi_components.vhd"       -work cycloneiv_hssi
    eval  vcom "$QUARTUS_INSTALL_DIR/eda/sim_lib/cycloneiv_hssi_atoms.vhd"            -work cycloneiv_hssi
    eval  vcom "$QUARTUS_INSTALL_DIR/eda/sim_lib/cycloneiv_pcie_hip_components.vhd"   -work cycloneiv_pcie_hip
    eval  vcom "$QUARTUS_INSTALL_DIR/eda/sim_lib/cycloneiv_pcie_hip_atoms.vhd"        -work cycloneiv_pcie_hip
  }
#}

vcom -2008 ./ip_cores/ALTGX/ALTGX_CIV.vhd
vcom -2008 ./ip_cores/ALTGX_RECONFIG/ALTGX_RECONFIG_CIV.vhd
vcom -2008 ./ip_cores/ALTPLL_RECONFIG/ALTPLL_RECONFIG_CIV.vhd

vcom -2008 ./Common_Libs/ALTGX_RECONFIG_User_Logic.vhd
vcom -2008 ./Common_Libs/ALTPLL_RECONFIG_User_Logic.vhd
vcom -2008 ./Common_Libs/PRBS9_Generator.vhd
vcom -2008 ./Common_Libs/PRBS9_Checker.vhd

vcom -2008 ./TB_ALTGX_ALL.vhd

vsim -voptargs=+acc -t ps work.tb_altgx_all
add wave -position insertpoint  \
sim:/tb_altgx_all/Clk \
sim:/tb_altgx_all/Reconfig_Clk \
sim:/tb_altgx_all/Reset \
sim:/tb_altgx_all/wire_gx_cal_blk_clk \
sim:/tb_altgx_all/wire_gx_gxb_powerdown \
sim:/tb_altgx_all/wire_gx_pll_areset \
sim:/tb_altgx_all/wire_gx_pll_configupdate \
sim:/tb_altgx_all/wire_gx_pll_inclk \
sim:/tb_altgx_all/wire_gx_pll_scanclk \
sim:/tb_altgx_all/wire_gx_pll_scanclkena \
sim:/tb_altgx_all/wire_gx_pll_scandata \
sim:/tb_altgx_all/wire_gx_reconfig_clk \
sim:/tb_altgx_all/wire_gx_reconfig_togxb \
sim:/tb_altgx_all/wire_gx_rx_analogreset \
sim:/tb_altgx_all/wire_gx_rx_datain \
sim:/tb_altgx_all/wire_gx_rx_digitalreset \
sim:/tb_altgx_all/wire_gx_tx_datain \
sim:/tb_altgx_all/wire_gx_tx_digitalreset \
sim:/tb_altgx_all/wire_gx_pll_locked \
sim:/tb_altgx_all/wire_gx_pll_reconfig_done \
sim:/tb_altgx_all/wire_gx_pll_scandataout \
sim:/tb_altgx_all/wire_gx_reconfig_fromgxb \
sim:/tb_altgx_all/wire_gx_rx_freqlocked \
sim:/tb_altgx_all/wire_gx_rx_clkout \
sim:/tb_altgx_all/wire_gx_rx_dataout \
sim:/tb_altgx_all/wire_gx_tx_clkout \
sim:/tb_altgx_all/wire_gx_tx_dataout \
sim:/tb_altgx_all/wire_gx_rcfg_reconfig_clk \
sim:/tb_altgx_all/wire_gx_rcfg_reconfig_data \
sim:/tb_altgx_all/wire_gx_rcfg_reconfig_fromgxb \
sim:/tb_altgx_all/wire_gx_rcfg_reconfig_reset \
sim:/tb_altgx_all/wire_gx_rcfg_write_all \
sim:/tb_altgx_all/wire_gx_rcfg_busy \
sim:/tb_altgx_all/wire_gx_rcfg_channel_reconfig_done \
sim:/tb_altgx_all/wire_gx_rcfg_error \
sim:/tb_altgx_all/wire_gx_rcfg_reconfig_address_en \
sim:/tb_altgx_all/wire_gx_rcfg_reconfig_address_out \
sim:/tb_altgx_all/wire_gx_rcfg_reconfig_togxb \
sim:/tb_altgx_all/wire_pll_rcfg_clock \
sim:/tb_altgx_all/wire_pll_rcfg_counter_param \
sim:/tb_altgx_all/wire_pll_rcfg_counter_type \
sim:/tb_altgx_all/wire_pll_rcfg_data_in \
sim:/tb_altgx_all/wire_pll_rcfg_pll_areset_in \
sim:/tb_altgx_all/wire_pll_rcfg_pll_scandataout \
sim:/tb_altgx_all/wire_pll_rcfg_pll_scandone \
sim:/tb_altgx_all/wire_pll_rcfg_read_param \
sim:/tb_altgx_all/wire_pll_rcfg_reconfig \
sim:/tb_altgx_all/wire_pll_rcfg_reset \
sim:/tb_altgx_all/wire_pll_rcfg_reset_rom_address \
sim:/tb_altgx_all/wire_pll_rcfg_rom_data_in \
sim:/tb_altgx_all/wire_pll_rcfg_write_from_rom \
sim:/tb_altgx_all/wire_pll_rcfg_write_param \
sim:/tb_altgx_all/wire_pll_rcfg_busy \
sim:/tb_altgx_all/wire_pll_rcfg_data_out \
sim:/tb_altgx_all/wire_pll_rcfg_pll_areset \
sim:/tb_altgx_all/wire_pll_rcfg_pll_configupdate \
sim:/tb_altgx_all/wire_pll_rcfg_pll_scanclk \
sim:/tb_altgx_all/wire_pll_rcfg_pll_scanclkena \
sim:/tb_altgx_all/wire_pll_rcfg_pll_scandata \
sim:/tb_altgx_all/wire_pll_rcfg_rom_address_out \
sim:/tb_altgx_all/wire_pll_rcfg_write_rom_ena \
sim:/tb_altgx_all/wire_gx_user_rcfg_clk \
sim:/tb_altgx_all/wire_gx_user_rcfg_reset \
sim:/tb_altgx_all/wire_gx_user_rcfg_speed_req \
sim:/tb_altgx_all/wire_gx_user_rcfg_speed \
sim:/tb_altgx_all/wire_gx_user_rcfg_done \
sim:/tb_altgx_all/wire_gx_user_rcfg_addr \
sim:/tb_altgx_all/wire_gx_user_rcfg_data \
sim:/tb_altgx_all/wire_gx_user_rcfg_write \
sim:/tb_altgx_all/wire_gx_user_rcfg_read \
sim:/tb_altgx_all/wire_gx_user_rcfg_error \
sim:/tb_altgx_all/wire_gx_user_rcfg_busy \
sim:/tb_altgx_all/wire_gx_user_rcfg_done_gx \
sim:/tb_altgx_all/wire_pll_user_rcfg_clk \
sim:/tb_altgx_all/wire_pll_user_rcfg_reset \
sim:/tb_altgx_all/wire_pll_user_rcfg_speed_req \
sim:/tb_altgx_all/wire_pll_user_rcfg_speed \
sim:/tb_altgx_all/wire_pll_user_rcfg_done \
sim:/tb_altgx_all/wire_pll_user_rcfg_addr \
sim:/tb_altgx_all/wire_pll_user_rcfg_data \
sim:/tb_altgx_all/wire_pll_user_rcfg_write_from_rom \
sim:/tb_altgx_all/wire_pll_user_rcfg_reconfig \
sim:/tb_altgx_all/wire_pll_user_rcfg_reset_address \
sim:/tb_altgx_all/wire_pll_user_rcfg_read \
sim:/tb_altgx_all/wire_pll_user_rcfg_busy \
sim:/tb_altgx_all/wire_pll_user_rcfg_configupdate \
sim:/tb_altgx_all/dwire_pll_rcfg_pll_configupdate \
sim:/tb_altgx_all/Counter_Rcfg \
sim:/tb_altgx_all/Wait_4_Rcfg \
sim:/tb_altgx_all/Rcfg_Reset \
sim:/tb_altgx_all/Rcfg_Done \
sim:/tb_altgx_all/State \
sim:/tb_altgx_all/dwire_gx_rcfg_channel_reconfig_done \
sim:/tb_altgx_all/Counter \
sim:/tb_altgx_all/T \
sim:/tb_altgx_all/T_Reconfig \
sim:/tb_altgx_all/wire_prbs_gen_clk \
sim:/tb_altgx_all/wire_prbs_gen_reset \
sim:/tb_altgx_all/wire_prbs_gen_data_out \
sim:/tb_altgx_all/wire_prbs_check_clk \
sim:/tb_altgx_all/wire_prbs_check_reset \
sim:/tb_altgx_all/wire_prbs_check_data_in \
sim:/tb_altgx_all/wire_prbs_check_data_err

run -all
