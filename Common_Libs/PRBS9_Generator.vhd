library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.ALL;

entity PRBS9_Generator is
	port (
		Clk		: in std_logic;
		Reset		: in std_logic;
		DataOut	: out std_logic_vector(19 downto 0)
	);
end entity;

architecture behavioral of PRBS9_Generator is
begin
   process(Clk, Reset)
      variable vCurrentVal : std_logic_vector(8 downto 0) := (others => '1');
		variable vXorBit		: std_logic := '0';
   begin
		if Reset = '1' then
			DataOut 		<= (others => '0');
			vCurrentVal := (others => '1');
      elsif Rising_Edge(Clk) then
			for i in 0 to 19 loop
				DataOut(i)	<= vCurrentVal(8);	
				vXorBit 		:= vCurrentVal(8) xor vCurrentVal(4);
				vCurrentVal := vCurrentVal(7 downto 0) & vXorBit;
			end loop;
		end if;
   end process;
end behavioral; 
