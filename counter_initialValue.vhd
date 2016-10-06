library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity counter_initValue is
	 generic (initialValue : natural; numBits : positive);
	 port (clk : in  STD_LOGIC;
          rst : in STD_LOGIC;
			 rst2 : in STD_LOGIC;
			 inc : in  STD_LOGIC;
          count : out  STD_LOGIC_VECTOR (numBits-1 downto 0));
end counter_initValue;

architecture counter_initValueArch of counter_initValue is

signal cs, ns : std_logic_vector(numBits-1 downto 0 ); 
begin
	state:
   process(clk)
     begin
        if clk'event and clk='1' then 			 
			 if rst = '1' then 
				cs <= conv_std_logic_vector(initialValue, numBits);
			 else
				cs <= ns;
			 end if;
        end if;
   end process;

   next_state:
   process(cs, inc, rst2)
      begin
			if rst2 = '1' then
				ns <= conv_std_logic_vector(initialValue, numBits);
         elsif inc = '1' then 
--			 ns <= cs + 2;
			 ns <= cs + 1;	
         else 
			  ns <= cs;
         end if;
   end process;

   moore_output: count <= cs;
end counter_initValueArch;

