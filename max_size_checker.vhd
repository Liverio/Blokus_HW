library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.types.ALL;

entity max_size_checker is
	port (----------------
			---- INPUTS ----
			----------------
			moves_vector : in STD_LOGIC_VECTOR(127-1 downto 0);
			-----------------
			---- OUTPUTS ----
			-----------------
			max_size : out STD_LOGIC_VECTOR(3-1 downto 0)
	);
end max_size_checker;

architecture max_size_checkerArch of max_size_checker is	
begin		
	max_size <= conv_std_logic_vector(5, 3) when moves_vector(91 downto 0)   /= conv_std_logic_vector(0, 92) else
					conv_std_logic_vector(4, 3) when moves_vector(116 downto 92) /= conv_std_logic_vector(0, 25) else
					conv_std_logic_vector(0, 3);
end max_size_checkerArch;