library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.ALL;

entity PRBS9_Checker is
	port (
		Clk			: in std_logic;
		Reset			: in std_logic;
		DataIn		: in std_logic_vector(19 downto 0);
		DataError	: out std_logic
	);
end entity;

architecture behavioral of PRBS9_Checker is
signal dDataIn : std_logic_vector(19 downto 0) := (others => '0'); 
begin
   process(Clk, Reset) 
      variable vCurrentVal : std_logic_vector(8 downto 0) := (others => '1');
		variable vXorBit		: std_logic := '0';
      variable vErr        : std_logic := '0';
		variable vXorRes		: std_logic := '0';
   begin
		if Reset = '1' then
			DataError <= '1';
			vCurrentVal	:= (others => '1');
      elsif Rising_Edge(Clk) then
			dDataIn <= DataIn;
			vErr := '0';
			for i in 0 to 19 loop
				vXorBit 		:= vCurrentVal(8) xor vCurrentVal(4);
				vCurrentVal := vCurrentVal(7 downto 0) & DataIn(i);
				if DataIn(i) /= vXorBit then
					vErr := '1';
				end if;
			end loop;
			if vErr = '1' then
				DataError <= '1';
			else
				DataError <= '0';
			end if;
      end if;
   end process;
end behavioral;
