library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity max_reg is
	generic(bits : positive := 128; init_value : natural);
	port (clk, rst: in STD_LOGIC;
			rst2 : in STD_LOGIC;
			ld : in STD_LOGIC;
			din  : in STD_LOGIC_VECTOR(bits-1 downto 0);
			dout : out STD_LOGIC_VECTOR(bits-1 downto 0)
	);
end max_reg;

architecture max_regrArch of max_reg is
   signal cs, ns: STD_LOGIC_VECTOR(bits-1 downto 0);
begin			
	state:
	process(clk)
		begin
			if clk'event AND clk = '1' then
			  if rst='1' then
				 cs <= conv_std_logic_vector(init_value, bits);
			  else					
				cs <= ns;
			  end if;
			end if;
	end process;
				
	next_state:
	process(cs, ld, rst2, din)
		begin
			if rst2 = '1' then 
			  ns <= conv_std_logic_vector(init_value, bits);
			elsif ld = '1' AND din > cs then
			  ns <= din;
			else 
			  ns <= cs;
			end if;
	end process;				
		
	dout <= cs;
end max_regrArch;