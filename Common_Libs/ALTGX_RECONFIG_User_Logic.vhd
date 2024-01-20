library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.ALL;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

entity ALTGX_RECONFIG_User_Logic is
	port (
		Clk					: in std_logic;
		Reset					: in std_logic;
		
		Speed_Req			: in std_logic;
		Speed					: in std_logic;
		Rcfg_Done			: out std_logic;
		
		gx_rcfg_addr		: in std_logic_vector(5 downto 0);
		gx_rcfg_data		: out std_logic_vector(15 downto 0);
		gx_rcfg_write		: out std_logic := '0';
		gx_rcfg_read		: in std_logic;
		gx_rcfg_error		: in std_logic;
		gx_rcfg_busy		: in std_logic;
		gx_rcfg_done_gx	: in std_logic
	);
end entity;

architecture behavioral of ALTGX_RECONFIG_User_Logic is

type States is (IDLE, WAIT_ADDR_CHANGE, READ_FROM_ROM, WRITE_DATA, WAIT_NOT_BUSY);
signal State : States := IDLE;
signal Speed_Local	: std_logic := '0';

signal wire_gx_rcfg_1000mbps_address	: std_logic_vector(5 downto 0) := (others => '0');
signal wire_gx_rcfg_1000mbps_clock		: std_logic := '0';
signal wire_gx_rcfg_1000mbps_rden		: std_logic := '0';
signal wire_gx_rcfg_1000mbps_dataout	: std_logic_vector(15 downto 0) := (others => '0');
signal wire_gx_rcfg_2000mbps_address	: std_logic_vector(5 downto 0) := (others => '0');
signal wire_gx_rcfg_2000mbps_clock		: std_logic := '0';
signal wire_gx_rcfg_2000mbps_rden		: std_logic := '0';
signal wire_gx_rcfg_2000mbps_dataout	: std_logic_vector(15 downto 0) := (others => '0');

signal rd_rom				: std_logic := '0';
signal dgx_rcfg_busy		: std_logic := '0';
signal Data_Accepted		: std_logic := '0';

begin

	Speed_Local <= Speed when Speed_Req = '1' and Rising_Edge(Clk);
	
	wire_gx_rcfg_1000mbps_clock 	<= Clk;
	wire_gx_rcfg_2000mbps_clock 	<= Clk;
	
	wire_gx_rcfg_1000mbps_address <= gx_rcfg_addr;
	wire_gx_rcfg_1000mbps_rden 	<= '1' when Speed_Local = '0' and rd_rom = '1' else '0';
	wire_gx_rcfg_2000mbps_address <= gx_rcfg_addr;
	wire_gx_rcfg_2000mbps_rden 	<= '1' when Speed_Local = '1' and rd_rom = '1' else '0';
	
	gx_rcfg_data	<= wire_gx_rcfg_1000mbps_dataout when Speed_Local = '0' else wire_gx_rcfg_2000mbps_dataout when Speed_Local = '1';
	
	Data_Accepted <= '1' when dgx_rcfg_busy = '1' and gx_rcfg_busy = '0' else '0';

	process(Clk) begin
		if Rising_Edge(Clk) then
			if Reset = '1' then
				State <= IDLE;
				Rcfg_Done <= '0';
			else
				dgx_rcfg_busy <= gx_rcfg_busy;
				case State is
					when IDLE =>
						if Speed_Req = '1' then
							State <= READ_FROM_ROM;
						else
							State <= IDLE;
						end if;
						Rcfg_Done <= '0';
					when WAIT_ADDR_CHANGE =>
						if gx_rcfg_read = '1' and gx_rcfg_busy = '0' then
							State <= READ_FROM_ROM;
						else
							State <= WAIT_ADDR_CHANGE;
						end if;
						gx_rcfg_write <= '0';
					when READ_FROM_ROM =>
						State 	<= WRITE_DATA;
						rd_rom 	<= '1';
					when WRITE_DATA =>
						if gx_rcfg_busy = '0' then
							if gx_rcfg_addr = "101111" then
								State <= WAIT_NOT_BUSY;
							else
								State <= WAIT_ADDR_CHANGE;
							end if;
							gx_rcfg_write <= '1';
						else
							gx_rcfg_write <= '0';
						end if;
						
					when WAIT_NOT_BUSY =>
						gx_rcfg_write <= '0';
						if Data_Accepted = '1' then
							State <= IDLE;
							Rcfg_Done <= '1';
						else
							State <= WAIT_NOT_BUSY;
						end if;
						
--					when WAIT_RECONFIG =>
--						if then
--						else
--						end if;
					when others =>
						NULL;
				end case;
			end if;
		end if;
	end process;
	
	m_gx_rcfg_rom_1000mbps : altsyncram
		GENERIC MAP (
			address_aclr_a 			=> "NONE",
			clock_enable_input_a 	=> "BYPASS",
			clock_enable_output_a 	=> "BYPASS",
			init_file 					=> "MIF/ALTGX_CIV_1000mbps.mif",
			intended_device_family 	=> "Cyclone IV GX",
			lpm_hint 					=> "ENABLE_RUNTIME_MOD=NO",
			lpm_type 					=> "altsyncram",
			numwords_a 					=> 48,
			operation_mode 			=> "ROM",
			outdata_aclr_a 			=> "NONE",
			outdata_reg_a 				=> "UNREGISTERED",
			widthad_a 					=> 6,
			width_a 						=> 16,
			width_byteena_a 			=> 1
		)
		PORT MAP (
			address_a 	=> wire_gx_rcfg_1000mbps_address,
			clock0 		=> wire_gx_rcfg_1000mbps_clock,
			rden_a 		=> wire_gx_rcfg_1000mbps_rden,
			q_a 			=> wire_gx_rcfg_1000mbps_dataout
		);
		
	m_gx_rcfg_rom_2000mbps : altsyncram
		GENERIC MAP (
			address_aclr_a 			=> "NONE",
			clock_enable_input_a 	=> "BYPASS",
			clock_enable_output_a 	=> "BYPASS",
			init_file 					=> "MIF/ALTGX_CIV_2000mbps.mif",
			intended_device_family 	=> "Cyclone IV GX",
			lpm_hint 					=> "ENABLE_RUNTIME_MOD=NO",
			lpm_type 					=> "altsyncram",
			numwords_a 					=> 48,
			operation_mode 			=> "ROM",
			outdata_aclr_a 			=> "NONE",
			outdata_reg_a 				=> "UNREGISTERED",
			widthad_a 					=> 6,
			width_a 						=> 16,
			width_byteena_a 			=> 1
		)
		PORT MAP (
			address_a 	=> wire_gx_rcfg_2000mbps_address,
			clock0 		=> wire_gx_rcfg_2000mbps_clock,
			rden_a 		=> wire_gx_rcfg_2000mbps_rden,
			q_a 			=> wire_gx_rcfg_2000mbps_dataout
		);
		
end behavioral;
