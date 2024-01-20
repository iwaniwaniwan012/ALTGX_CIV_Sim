library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.ALL;

entity TB_ALTGX_ALL is
end entity;

architecture behavioral of TB_ALTGX_ALL is

constant T 				: time := 20 ns;
constant T_Reconfig 	: time := 25 ns;


signal Clk 				: std_logic := '0';
signal Reconfig_Clk	: std_logic := '0';
signal Reset			: std_logic := '1';

component ALTGX_CIV
	PORT (
		cal_blk_clk			: IN STD_LOGIC ;
		gxb_powerdown		: IN STD_LOGIC_VECTOR (0 DOWNTO 0);
		pll_areset			: IN STD_LOGIC_VECTOR (0 DOWNTO 0);
		pll_configupdate	: IN STD_LOGIC_VECTOR (0 DOWNTO 0);
		pll_inclk			: IN STD_LOGIC_VECTOR (0 DOWNTO 0);
		pll_scanclk			: IN STD_LOGIC_VECTOR (0 DOWNTO 0);
		pll_scanclkena		: IN STD_LOGIC_VECTOR (0 DOWNTO 0);
		pll_scandata		: IN STD_LOGIC_VECTOR (0 DOWNTO 0);
		reconfig_clk		: IN STD_LOGIC ;
		reconfig_togxb		: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		rx_analogreset		: IN STD_LOGIC_VECTOR (0 DOWNTO 0);
		rx_datain			: IN STD_LOGIC_VECTOR (0 DOWNTO 0);
		rx_digitalreset	: IN STD_LOGIC_VECTOR (0 DOWNTO 0);
		tx_datain			: IN STD_LOGIC_VECTOR (19 DOWNTO 0);
		tx_digitalreset	: IN STD_LOGIC_VECTOR (0 DOWNTO 0);
		pll_reconfig_done	: OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
		pll_scandataout	: OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
		pll_locked			: OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
		reconfig_fromgxb	: OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
		rx_freqlocked		: OUT STD_LOGIC_VECTOR(0 downto 0);
		rx_clkout			: OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
		rx_dataout			: OUT STD_LOGIC_VECTOR (19 DOWNTO 0);
		tx_clkout			: OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
		tx_dataout			: OUT STD_LOGIC_VECTOR (0 DOWNTO 0)
	);
end component;

component ALTGX_RECONFIG_CIV
	PORT (
		reconfig_clk				: IN STD_LOGIC ;
		reconfig_data				: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		reconfig_fromgxb			: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		reconfig_reset				: IN STD_LOGIC ;
		write_all					: IN STD_LOGIC ;
		busy							: OUT STD_LOGIC ;
		channel_reconfig_done	: OUT STD_LOGIC ;
		error							: OUT STD_LOGIC ;
		reconfig_address_en		: OUT STD_LOGIC ;
		reconfig_address_out		: OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
		reconfig_togxb				: OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
	);
end component;

component ALTPLL_RECONFIG_CIV
	PORT (
		clock					: IN STD_LOGIC ;
		counter_param		: IN STD_LOGIC_VECTOR (2 DOWNTO 0);
		counter_type		: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		data_in				: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
		pll_areset_in		: IN STD_LOGIC  := '0';
		pll_scandataout	: IN STD_LOGIC ;
		pll_scandone		: IN STD_LOGIC ;
		read_param			: IN STD_LOGIC ;
		reconfig				: IN STD_LOGIC ;
		reset					: IN STD_LOGIC ;
		reset_rom_address	: IN STD_LOGIC  := '0';
		rom_data_in			: IN STD_LOGIC  := '0';
		write_from_rom		: IN STD_LOGIC  := '0';
		write_param			: IN STD_LOGIC ;
		busy					: OUT STD_LOGIC ;
		data_out				: OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
		pll_areset			: OUT STD_LOGIC ;
		pll_configupdate	: OUT STD_LOGIC ;
		pll_scanclk			: OUT STD_LOGIC ;
		pll_scanclkena		: OUT STD_LOGIC ;
		pll_scandata		: OUT STD_LOGIC ;
		rom_address_out	: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		write_rom_ena		: OUT STD_LOGIC 
	);
end component;

signal wire_gx_cal_blk_clk 					: std_logic := '0';
signal wire_gx_gxb_powerdown					: std_logic_vector(0 downto 0) := (others => '0');
signal wire_gx_pll_areset						: std_logic_vector(0 downto 0) := (others => '0');
signal wire_gx_pll_configupdate				: std_logic_vector(0 downto 0) := (others => '0');
signal wire_gx_pll_inclk						: std_logic_vector(0 downto 0) := (others => '0');
signal wire_gx_pll_scanclk						: std_logic_vector(0 downto 0) := (others => '0');
signal wire_gx_pll_scanclkena					: std_logic_vector(0 downto 0) := (others => '0');
signal wire_gx_pll_scandata					: std_logic_vector(0 downto 0) := (others => '0');
signal wire_gx_reconfig_clk					: std_logic := '0';
signal wire_gx_reconfig_togxb					: std_logic_vector(3 downto 0) := (others => '0');
signal wire_gx_rx_analogreset					: std_logic_vector(0 downto 0) := (others => '0');
signal wire_gx_rx_datain						: std_logic_vector(0 downto 0) := (others => '0');
signal wire_gx_rx_digitalreset				: std_logic_vector(0 downto 0) := (others => '0');
signal wire_gx_tx_datain						: std_logic_vector(19 downto 0) := "10101010101010101010";--:= (others => '0');
signal wire_gx_tx_digitalreset				: std_logic_vector(0 downto 0) := (others => '0');
signal wire_gx_pll_locked						: std_logic_vector(0 downto 0) := (others => '0');
signal wire_gx_pll_reconfig_done				: std_logic_vector(0 downto 0) := (others => '0');
signal wire_gx_pll_scandataout				: std_logic_vector(0 downto 0) := (others => '0');
signal wire_gx_reconfig_fromgxb				: std_logic_vector(4 downto 0) := (others => '0');
signal wire_gx_rx_freqlocked					: std_logic_vector(0 downto 0) := (others => '0');
signal wire_gx_rx_clkout						: std_logic_vector(0 downto 0) := (others => '0');
signal wire_gx_rx_dataout						: std_logic_vector(19 downto 0) := (others => '0');
signal wire_gx_tx_clkout						: std_logic_vector(0 downto 0) := (others => '0');
signal wire_gx_tx_dataout						: std_logic_vector(0 downto 0) := (others => '0');

signal wire_gx_rcfg_reconfig_clk				: std_logic := '0';
signal wire_gx_rcfg_reconfig_data			: std_logic_vector(15 downto 0) := (others => '0');
signal wire_gx_rcfg_reconfig_fromgxb		: std_logic_vector(4 downto 0) := (others => '0');
signal wire_gx_rcfg_reconfig_reset			: std_logic := '0';
signal wire_gx_rcfg_write_all					: std_logic := '0';
signal wire_gx_rcfg_busy						: std_logic := '0';
signal wire_gx_rcfg_channel_reconfig_done	: std_logic := '0';
signal wire_gx_rcfg_error						: std_logic := '0';
signal wire_gx_rcfg_reconfig_address_en	: std_logic := '0';
signal wire_gx_rcfg_reconfig_address_out	: std_logic_vector(5 downto 0) := (others => '0');
signal wire_gx_rcfg_reconfig_togxb			: std_logic_vector(3 downto 0) := (others => '0');

signal wire_pll_rcfg_clock						: std_logic := '0';
signal wire_pll_rcfg_counter_param			: std_logic_vector(2 downto 0) := (others => '0');
signal wire_pll_rcfg_counter_type			: std_logic_vector(3 downto 0) := (others => '0');
signal wire_pll_rcfg_data_in					: std_logic_vector(8 downto 0) := (others => '0');
signal wire_pll_rcfg_pll_areset_in			: std_logic := '0';
signal wire_pll_rcfg_pll_scandataout		: std_logic := '0';
signal wire_pll_rcfg_pll_scandone			: std_logic := '0';
signal wire_pll_rcfg_read_param				: std_logic := '0';
signal wire_pll_rcfg_reconfig					: std_logic := '0';
signal wire_pll_rcfg_reset						: std_logic := '0';
signal wire_pll_rcfg_reset_rom_address		: std_logic := '0';
signal wire_pll_rcfg_rom_data_in				: std_logic := '0';
signal wire_pll_rcfg_write_from_rom			: std_logic := '0';
signal wire_pll_rcfg_write_param				: std_logic := '0';
signal wire_pll_rcfg_busy						: std_logic := '0';
signal wire_pll_rcfg_data_out					: std_logic_vector(8 downto 0) := (others => '0');
signal wire_pll_rcfg_pll_areset				: std_logic := '0';
signal wire_pll_rcfg_pll_configupdate		: std_logic := '0';
signal wire_pll_rcfg_pll_scanclk				: std_logic := '0';
signal wire_pll_rcfg_pll_scanclkena			: std_logic := '0';
signal wire_pll_rcfg_pll_scandata			: std_logic := '0';
signal wire_pll_rcfg_rom_address_out		: std_logic_vector(7 downto 0) := (others => '0');
signal wire_pll_rcfg_write_rom_ena			: std_logic := '0';

signal wire_gx_user_rcfg_clk					: std_logic := '0';
signal wire_gx_user_rcfg_reset				: std_logic := '0';
signal wire_gx_user_rcfg_speed_req			: std_logic := '0';
signal wire_gx_user_rcfg_speed				: std_logic := '0';
signal wire_gx_user_rcfg_done					: std_logic := '0';
signal wire_gx_user_rcfg_addr					: std_logic_vector(5 downto 0) := (others => '0');
signal wire_gx_user_rcfg_data					: std_logic_vector(15 downto 0) := (others => '0');
signal wire_gx_user_rcfg_write				: std_logic := '0';
signal wire_gx_user_rcfg_read					: std_logic := '0';
signal wire_gx_user_rcfg_error				: std_logic := '0';
signal wire_gx_user_rcfg_busy					: std_logic := '0';
signal wire_gx_user_rcfg_done_gx				: std_logic := '0';

signal wire_pll_user_rcfg_clk					: std_logic := '0';
signal wire_pll_user_rcfg_reset				: std_logic := '0';
signal wire_pll_user_rcfg_speed_req			: std_logic := '0';
signal wire_pll_user_rcfg_speed				: std_logic := '0';
signal wire_pll_user_rcfg_done				: std_logic := '0';
signal wire_pll_user_rcfg_addr				: std_logic_vector(7 downto 0) := (others => '0');
signal wire_pll_user_rcfg_data				: std_logic := '0';
signal wire_pll_user_rcfg_write_from_rom	: std_logic := '0';
signal wire_pll_user_rcfg_reconfig			: std_logic := '0';
signal wire_pll_user_rcfg_reset_address	: std_logic := '1';
signal wire_pll_user_rcfg_read				: std_logic := '0';
signal wire_pll_user_rcfg_busy				: std_logic := '0';
signal wire_pll_user_rcfg_configupdate		: std_logic := '0';
signal dwire_pll_rcfg_pll_configupdate		: std_logic := '0';

signal wire_prbs_gen_clk				: std_logic := '0';
signal wire_prbs_gen_reset				: std_logic	:= '0';
signal wire_prbs_gen_data_out			: std_logic_vector(19 downto 0) := (others => '0');

signal wire_prbs_check_clk				: std_logic := '0';
signal wire_prbs_check_reset			: std_logic := '0';
signal wire_prbs_check_data_in		: std_logic_vector(19 downto 0) := (others => '0');
signal wire_prbs_check_data_err 		: std_logic := '0';

signal Counter_Rcfg 	: std_logic_vector(15 downto 0) := (others => '0');
signal Wait_4_Rcfg	: std_logic := '0';
signal Rcfg_Reset		: std_logic := '0';
signal Rcfg_Done		: std_logic_vector(1 downto 0) := (others => '0');

type States is (WAIT_PLL_RECONFIG, WAIT_XCVR_RECONFIG);
signal State : States := WAIT_PLL_RECONFIG;
signal dwire_gx_rcfg_channel_reconfig_done	: std_logic := '0';
signal Counter : std_logic := '0';

begin

wire_gx_user_rcfg_clk 		<= Reconfig_Clk;
wire_gx_user_rcfg_reset		<= Reset;
wire_gx_rcfg_write_all		<= wire_gx_user_rcfg_write;
wire_gx_user_rcfg_done_gx	<= wire_gx_rcfg_channel_reconfig_done;
wire_gx_user_rcfg_busy		<= wire_gx_rcfg_busy;
wire_gx_user_rcfg_addr		<= wire_gx_rcfg_reconfig_address_out;
wire_gx_rcfg_reconfig_data	<= wire_gx_user_rcfg_data;
wire_gx_user_rcfg_read		<= wire_gx_rcfg_reconfig_address_en;

Clk 				<= not Clk after T/2;
Reconfig_Clk 	<= not Reconfig_Clk after T_Reconfig/2;
Reset 			<= '1', '0' after T*10;

wire_gx_cal_blk_clk				<= Clk;
wire_gx_reconfig_clk				<= Reconfig_Clk;
wire_gx_pll_inclk(0)				<= Clk;
wire_gx_gxb_powerdown(0)		<= Reset or Rcfg_Reset;
wire_gx_rx_digitalreset(0) 	<= Reset or Rcfg_Reset;
wire_gx_rx_analogreset(0) 		<= Reset or Rcfg_Reset;
wire_gx_tx_digitalreset(0) 	<= Reset or Rcfg_Reset;
wire_gx_rx_datain 				<= wire_gx_tx_dataout;
wire_gx_pll_areset(0) 			<= wire_pll_rcfg_pll_areset;
wire_gx_pll_scanclk(0)			<= wire_pll_rcfg_pll_scanclk;
wire_gx_pll_scanclkena(0)		<= wire_pll_rcfg_pll_scanclkena;
wire_gx_pll_scandata(0)			<= wire_pll_rcfg_pll_scandata;
wire_gx_reconfig_togxb			<= wire_gx_rcfg_reconfig_togxb;
wire_gx_pll_configupdate(0)	<= wire_pll_rcfg_pll_configupdate;

wire_pll_rcfg_pll_scandataout <= wire_gx_pll_scandataout(0);
wire_pll_rcfg_pll_scandone		<= wire_gx_pll_reconfig_done(0);


	m_ALTGX_CIV: ALTGX_CIV 
		PORT MAP (
			cal_blk_clk	 		=> wire_gx_cal_blk_clk,
			gxb_powerdown		=> wire_gx_gxb_powerdown,
			pll_areset	 		=> wire_gx_pll_areset,
			pll_configupdate	=> wire_gx_pll_configupdate,
			pll_inclk	 		=> wire_gx_pll_inclk,
			pll_scanclk	 		=> wire_gx_pll_scanclk,
			pll_scanclkena	 	=> wire_gx_pll_scanclkena,
			pll_scandata	 	=> wire_gx_pll_scandata,
			reconfig_clk	 	=> wire_gx_reconfig_clk,
			reconfig_togxb	 	=> wire_gx_reconfig_togxb,
			rx_analogreset	 	=> wire_gx_rx_analogreset,
			rx_datain	 		=> wire_gx_rx_datain,
			rx_digitalreset	=> wire_gx_rx_digitalreset,
			tx_datain	 		=> wire_gx_tx_datain,
			tx_digitalreset	=> wire_gx_tx_digitalreset,
			pll_locked	 		=> wire_gx_pll_locked,
			pll_reconfig_done	=> wire_gx_pll_reconfig_done,
			pll_scandataout	=> wire_gx_pll_scandataout,
			reconfig_fromgxb	=> wire_gx_reconfig_fromgxb,
			rx_freqlocked	 	=> wire_gx_rx_freqlocked,
			rx_clkout	 		=> wire_gx_rx_clkout,
			rx_dataout	 		=> wire_gx_rx_dataout,
			tx_clkout	 		=> wire_gx_tx_clkout,
			tx_dataout	 		=> wire_gx_tx_dataout
		);

wire_gx_rcfg_reconfig_clk 			<= Reconfig_Clk ;
wire_gx_rcfg_reconfig_reset		<= '1' when ((dwire_gx_rcfg_channel_reconfig_done = '0' and wire_gx_rcfg_channel_reconfig_done = '1')) and Rising_Edge(Clk) else
												'0' when Rising_Edge(Clk);
wire_gx_rcfg_reconfig_fromgxb		<= wire_gx_reconfig_fromgxb;

	m_ALTGX_RECONFIG_CIV : ALTGX_RECONFIG_CIV
		PORT MAP (
			reconfig_clk	 			=> wire_gx_rcfg_reconfig_clk,
			reconfig_data	 			=> wire_gx_rcfg_reconfig_data,
			reconfig_fromgxb	 		=> wire_gx_rcfg_reconfig_fromgxb,
			reconfig_reset	 			=> wire_gx_rcfg_reconfig_reset,
			write_all	 				=> wire_gx_rcfg_write_all,
			busy	 						=> wire_gx_rcfg_busy,
			channel_reconfig_done	=> wire_gx_rcfg_channel_reconfig_done,
			error	 						=> wire_gx_rcfg_error,
			reconfig_address_en		=> wire_gx_rcfg_reconfig_address_en,
			reconfig_address_out	 	=> wire_gx_rcfg_reconfig_address_out,
			reconfig_togxb	 			=> wire_gx_rcfg_reconfig_togxb
		);
	
wire_pll_rcfg_clock 						<= Reconfig_Clk;
wire_pll_rcfg_reset						<= Reset;
wire_pll_rcfg_pll_areset_in			<= Reset;
dwire_pll_rcfg_pll_configupdate 		<= wire_pll_rcfg_pll_configupdate when Rising_Edge(Reconfig_Clk);
dwire_gx_rcfg_channel_reconfig_done	<= wire_gx_rcfg_channel_reconfig_done when Rising_Edge(Reconfig_Clk);

	m_ALTPLL_RECONFIG_CIV : ALTPLL_RECONFIG_CIV
		PORT MAP (
			clock	 					=> wire_pll_rcfg_clock,
			counter_param	 		=> wire_pll_rcfg_counter_param,
			counter_type	 		=> wire_pll_rcfg_counter_type,
			data_in	 				=> wire_pll_rcfg_data_in,
			pll_areset_in	 		=> wire_pll_rcfg_pll_areset_in,
			pll_scandataout	 	=> wire_pll_rcfg_pll_scandataout,
			pll_scandone			=> wire_pll_rcfg_pll_scandone,
			read_param	 			=> wire_pll_rcfg_read_param,
			reconfig	 				=> wire_pll_rcfg_reconfig,
			reset	 					=> wire_pll_rcfg_reset,
			reset_rom_address	 	=> wire_pll_rcfg_reset_rom_address,
			rom_data_in	 			=> wire_pll_rcfg_rom_data_in,
			write_from_rom	 		=> wire_pll_rcfg_write_from_rom,
			write_param	 			=> wire_pll_rcfg_write_param,
			busy	 					=> wire_pll_rcfg_busy,
			data_out	 				=> wire_pll_rcfg_data_out,
			pll_areset	 			=> wire_pll_rcfg_pll_areset,
			pll_configupdate	 	=> wire_pll_rcfg_pll_configupdate,
			pll_scanclk	 			=> wire_pll_rcfg_pll_scanclk,
			pll_scanclkena	 		=> wire_pll_rcfg_pll_scanclkena,
			pll_scandata	 		=> wire_pll_rcfg_pll_scandata,
			rom_address_out	 	=> wire_pll_rcfg_rom_address_out,
			write_rom_ena	 		=> wire_pll_rcfg_write_rom_ena
		);
	
--	process(wire_gx_tx_clkout(0)) begin
--		if Rising_Edge(wire_gx_tx_clkout(0)) then
--			Counter <= not Counter;
--			if Counter = '0' then
--				wire_gx_tx_datain <= "01010101010101010101";
--			else
--				wire_gx_tx_datain <= "01010101010101010101";
--			end if;
--		end if;
--	end process;
	
	wire_pll_user_rcfg_clk 			<= Reconfig_Clk;
	wire_pll_user_rcfg_reset 		<= Reset;
	wire_pll_user_rcfg_addr 		<= wire_pll_rcfg_rom_address_out;
	
	wire_pll_rcfg_rom_data_in			<= wire_pll_user_rcfg_data;
	wire_pll_rcfg_write_from_rom		<= wire_pll_user_rcfg_write_from_rom;
	wire_pll_rcfg_reconfig				<= wire_pll_user_rcfg_reconfig;
	wire_pll_rcfg_reset_rom_address	<= wire_pll_user_rcfg_reset_address;
	wire_pll_user_rcfg_read 			<= wire_pll_rcfg_write_rom_ena;
	wire_pll_user_rcfg_busy 			<= wire_pll_rcfg_busy;
	wire_pll_user_rcfg_configupdate	<= wire_pll_rcfg_pll_configupdate;
	
	m_ALTGX_RECONFIG_User_Logic: entity work.ALTGX_RECONFIG_User_Logic
		port map (
			Clk					=> wire_gx_user_rcfg_clk,			--: in std_logic;
			Reset					=> wire_gx_user_rcfg_reset,		--: in std_logic;
			Speed_Req			=> wire_gx_user_rcfg_speed_req,	--: in std_logic;
			Speed					=> wire_gx_user_rcfg_speed,		--: in std_logic;
			Rcfg_Done			=> wire_gx_user_rcfg_done,			--: out std_logic;
			gx_rcfg_addr		=> wire_gx_user_rcfg_addr,			--: in std_logic_vector(5 downto 0);
			gx_rcfg_data		=> wire_gx_user_rcfg_data,			--: out std_logic_vector(15 downto 0);
			gx_rcfg_write		=> wire_gx_user_rcfg_write,		--: out std_logic := '0';
			gx_rcfg_read		=> wire_gx_user_rcfg_read,			--: in std_logic;
			gx_rcfg_error		=> wire_gx_user_rcfg_error,		--: in std_logic;
			gx_rcfg_busy		=> wire_gx_user_rcfg_busy,			--: in std_logic;
			gx_rcfg_done_gx	=>	wire_gx_user_rcfg_done_gx		--: in std_logic
		);
	
	m_ALTPLL_RECONFIG_User_Logic: entity work.ALTPLL_RECONFIG_User_Logic
		port map (
			Clk							=> wire_pll_user_rcfg_clk,					--: in std_logic;
			Reset							=> wire_pll_user_rcfg_reset,				--: in std_logic;
			Speed_Req					=> wire_pll_user_rcfg_speed_req,			--: in std_logic;
			Speed							=> wire_pll_user_rcfg_speed,				--: in std_logic;
			Rcfg_Done					=> wire_pll_user_rcfg_done,				--: out std_logic;
			pll_rcfg_addr				=> wire_pll_user_rcfg_addr,				--: in std_logic_vector(7 downto 0);
			pll_rcfg_data				=> wire_pll_user_rcfg_data,				--: out std_logic;
			pll_rcfg_write_from_rom	=> wire_pll_user_rcfg_write_from_rom,	--: out std_logic;
			pll_rcfg_reconfig			=> wire_pll_user_rcfg_reconfig,			--: out std_logic;
			pll_rcfg_reset_address	=> wire_pll_user_rcfg_reset_address,	--: out std_logic := '1';
			pll_rcfg_read				=> wire_pll_user_rcfg_read,				--: in std_logic;
			pll_rcfg_busy				=> wire_pll_user_rcfg_busy,				--: in std_logic;
			pll_rcfg_configupdate	=> wire_pll_user_rcfg_configupdate		--: in std_logic;
		);
	
	m_PRBS9_Generator: entity work.PRBS9_Generator
		port map (
			Clk			=> wire_prbs_gen_clk,		--: in std_logic;
			Reset			=> wire_prbs_gen_reset,		--: in std_logic;
			DataOut		=> wire_prbs_gen_data_out	--: out std_logic_vector(19 downto 0)
		);
		
	wire_prbs_gen_clk 	<= wire_gx_tx_clkout(0);
	wire_prbs_gen_reset	<= Reset or Wait_4_Rcfg;
	wire_gx_tx_datain		<= wire_prbs_gen_data_out;
		
	m_PRBS9_Checker: entity work.PRBS9_Checker
		port map (
			Clk			=> wire_prbs_check_clk, 		--: in std_logic;
			Reset			=> wire_prbs_check_reset, 		--: in std_logic;
			DataIn		=> wire_prbs_check_data_in, 	--: in std_logic_vector(19 downto 0);
			DataError	=> wire_prbs_check_data_err 	--: out std_logic
		);
	
	wire_prbs_check_clk			<= wire_gx_rx_clkout(0);
	wire_prbs_check_reset		<= Reset or Wait_4_Rcfg;
	wire_prbs_check_data_in		<= wire_gx_rx_dataout;
	--wire_prbs_check_data_err	<= ;
	
	process(Reconfig_Clk) begin
		if Rising_Edge(Reconfig_Clk) then
			if Reset = '1' then
				Counter_Rcfg <= (others => '0');
				wire_gx_user_rcfg_speed_req	<= '0';
				wire_gx_user_rcfg_speed			<= '0';
				wire_pll_user_rcfg_speed_req	<= '0';
				wire_pll_user_rcfg_speed		<= '0';
				State <= WAIT_PLL_RECONFIG;
			else
				if Counter_Rcfg /= x"07FF" then
					Counter_Rcfg 	<= Counter_Rcfg + '1';
					Wait_4_Rcfg 	<= '0';
					Rcfg_Reset 		<= '0';
				else
					if Wait_4_Rcfg = '1' then
						wire_gx_user_rcfg_speed_req	<= '0';
						wire_pll_user_rcfg_speed_req	<= '0';
						case State is
							when WAIT_PLL_RECONFIG =>
								if wire_pll_user_rcfg_done = '1' then
									State 			<= WAIT_XCVR_RECONFIG;
									--Wait_4_Rcfg 	<= '0';
									--Rcfg_Reset 		<= '1';
									--Counter_Rcfg 	<= (others => '0');
									wire_gx_user_rcfg_speed_req	<= '1';
								else
									State <= WAIT_PLL_RECONFIG;
								end if;
							when WAIT_XCVR_RECONFIG =>
								--Rcfg_Reset 		<= '1';
								if wire_gx_user_rcfg_done = '1' then --wire_gx_user_rcfg_done = '1' then
									State <= WAIT_PLL_RECONFIG;
									--wire_pll_user_rcfg_speed_req	<= '1';
									Wait_4_Rcfg 	<= '0';
									Rcfg_Reset 		<= '1';
									Counter_Rcfg 	<= (others => '0');
								else
									State <= WAIT_XCVR_RECONFIG;
								end if;
							when others => NULL;
						end case;
--						if wire_gx_user_rcfg_done = '1' then
--							Rcfg_Done(0) <= '1';
--						end if;
--						if Rcfg_Done(0)
--						if wire_pll_user_rcfg_done = '1' then
--							Rcfg_Done(1) <= '1';
--						end if;
--						if Rcfg_Done = "11" then
--							Wait_4_Rcfg <= '0';
--							Rcfg_Reset <= '0';
--							Counter_Rcfg 	<= (others => '0');
--						else
--							Rcfg_Reset <= '1';
--						end if;
					else
						State <= WAIT_PLL_RECONFIG;
						Rcfg_Done 							<= "00";
						Rcfg_Reset 							<= '0';
						Wait_4_Rcfg 						<= '1';
						--wire_gx_user_rcfg_speed_req	<= '1';
						wire_pll_user_rcfg_speed_req	<= '1';
						wire_pll_user_rcfg_speed		<= not wire_pll_user_rcfg_speed;
						wire_gx_user_rcfg_speed 		<= not wire_gx_user_rcfg_speed;
					end if;
				end if;
			end if;
		end if;
	end process;
	
end behavioral;
