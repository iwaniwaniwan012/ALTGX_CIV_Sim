library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.ALL;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

entity ALTPLL_RECONFIG_User_Logic is
	port (
		Clk					: in std_logic;
		Reset					: in std_logic;
		
		Speed_Req			: in std_logic;
		Speed					: in std_logic;
		Rcfg_Done			: out std_logic;
		
		pll_rcfg_addr				: in std_logic_vector(7 downto 0);
		pll_rcfg_data				: out std_logic;
		pll_rcfg_write_from_rom	: out std_logic := '0';
		pll_rcfg_reconfig			: out std_logic := '0';
		pll_rcfg_reset_address	: out std_logic := '1';
		pll_rcfg_read				: in std_logic;
		pll_rcfg_busy				: in std_logic;
		pll_rcfg_configupdate	: in std_logic
	);
	
end entity;

architecture behavioral of ALTPLL_RECONFIG_User_Logic is

type States is (IDLE, BEGIN_ROM_STREAMING, WAIT_ROM_STREAMING, BEGIN_PLL_RECONFIG, WAIT_PLL_RECONFIG, PRE_BEGIN_PLL_RECONFIG);
signal State 				: States := IDLE;
signal Speed_Local		: std_logic := '0';
signal dpll_rcfg_busy	: std_logic := '0';

signal wire_pll_rcfg_1000mbps_address	: std_logic_vector(7 downto 0) := (others => '0');
signal wire_pll_rcfg_1000mbps_clock		: std_logic := '0';
signal wire_pll_rcfg_1000mbps_rden		: std_logic := '0';
signal wire_pll_rcfg_1000mbps_dataout	: std_logic_vector(0 downto 0) := (others => '0');
signal wire_pll_rcfg_2000mbps_address	: std_logic_vector(7 downto 0) := (others => '0');
signal wire_pll_rcfg_2000mbps_clock		: std_logic := '0';
signal wire_pll_rcfg_2000mbps_rden		: std_logic := '0';
signal wire_pll_rcfg_2000mbps_dataout	: std_logic_vector(0 downto 0) := (others => '0');

signal dpll_rcfg_read : std_logic := '0';

begin

	wire_pll_rcfg_1000mbps_clock 	<= Clk;
	wire_pll_rcfg_2000mbps_clock 	<= Clk;
	
	wire_pll_rcfg_1000mbps_address 	<= pll_rcfg_addr;
	wire_pll_rcfg_1000mbps_rden 		<= pll_rcfg_read when Speed_Local = '0' else '0';
	wire_pll_rcfg_2000mbps_address 	<= pll_rcfg_addr;
	wire_pll_rcfg_2000mbps_rden 		<= pll_rcfg_read when Speed_Local = '1' else '0';
	pll_rcfg_data							<= wire_pll_rcfg_1000mbps_dataout(0) when Speed_Local = '0' and Rising_Edge(Clk) else wire_pll_rcfg_2000mbps_dataout(0) when Rising_Edge(Clk);
	
	process(Clk) begin
		if Rising_Edge(Clk) then
			if Reset = '1' then
				State <= IDLE;
				pll_rcfg_write_from_rom <= '0';
				pll_rcfg_reconfig 		<= '0';
				pll_rcfg_reset_address 	<= '1';
			else
				dpll_rcfg_busy <= pll_rcfg_busy;
				case State is
					when IDLE =>
						Rcfg_Done <= '0';
						if Speed_Req = '1' then
							Speed_Local <= Speed;
							State <= BEGIN_ROM_STREAMING;
							pll_rcfg_reset_address <= '0';
						else
							State <= IDLE;
							pll_rcfg_reset_address <= '1';
						end if;
					when BEGIN_ROM_STREAMING =>
						State <= WAIT_ROM_STREAMING;
						pll_rcfg_write_from_rom <= '1';
					when WAIT_ROM_STREAMING =>
						pll_rcfg_write_from_rom <= '0';
						if pll_rcfg_busy = '0' and dpll_rcfg_busy = '1' then
							State <= PRE_BEGIN_PLL_RECONFIG;
						else
							State <= WAIT_ROM_STREAMING;
						end if;
					when PRE_BEGIN_PLL_RECONFIG =>
						State <= BEGIN_PLL_RECONFIG;
					when BEGIN_PLL_RECONFIG =>
						pll_rcfg_reconfig <= '1';
						State <= WAIT_PLL_RECONFIG;
					when WAIT_PLL_RECONFIG =>
						pll_rcfg_reconfig <= '0';
						if pll_rcfg_configupdate = '1' then
							STATE <= IDLE;
							Rcfg_Done <= '1';
						else
							State <= WAIT_PLL_RECONFIG;
						end if;
					when others =>
						State <= IDLE;
				end case;
			end if;
		end if;
	end process;
	
	m_pll_rcfg_rom_1000mbps : altsyncram
		GENERIC MAP (
			address_aclr_a 			=> "NONE",
			clock_enable_input_a 	=> "BYPASS",
			clock_enable_output_a 	=> "BYPASS",
			init_file 					=> "MIF/ALTGX_CIV_pll_1000mbps.mif",
			intended_device_family 	=> "Cyclone IV GX",
			lpm_hint 					=> "ENABLE_RUNTIME_MOD=YES",
			lpm_type 					=> "altsyncram",
			numwords_a 					=> 144,
			operation_mode 			=> "ROM",
			outdata_aclr_a 			=> "NONE",
			outdata_reg_a 				=> "UNREGISTERED",
			widthad_a 					=> 8,
			width_a 						=> 1,
			width_byteena_a 			=> 1
		)
		PORT MAP (
			address_a 	=> wire_pll_rcfg_1000mbps_address,
			clock0 		=> wire_pll_rcfg_1000mbps_clock,
			rden_a 		=> wire_pll_rcfg_1000mbps_rden,
			q_a 			=> wire_pll_rcfg_1000mbps_dataout
		);
		
	m_pll_rcfg_rom_2000mbps : altsyncram
		GENERIC MAP (
			address_aclr_a 			=> "NONE",
			clock_enable_input_a 	=> "BYPASS",
			clock_enable_output_a 	=> "BYPASS",
			init_file 					=> "MIF/ALTGX_CIV_pll_2000mbps.mif",
			intended_device_family 	=> "Cyclone IV GX",
			lpm_hint 					=> "ENABLE_RUNTIME_MOD=YES",
			lpm_type 					=> "altsyncram",
			numwords_a 					=> 144,
			operation_mode 			=> "ROM",
			outdata_aclr_a 			=> "NONE",
			outdata_reg_a 				=> "UNREGISTERED",
			widthad_a 					=> 8,
			width_a 						=> 1,
			width_byteena_a 			=> 1
		)
		PORT MAP (
			address_a 	=> wire_pll_rcfg_2000mbps_address,
			clock0 		=> wire_pll_rcfg_2000mbps_clock,
			rden_a 		=> wire_pll_rcfg_2000mbps_rden,
			q_a 			=> wire_pll_rcfg_2000mbps_dataout
		);
		
end behavioral;
