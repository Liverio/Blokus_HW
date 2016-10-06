--------------------------------
-- Masks the explored vertices --
--------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.types.ALL;

entity move_vector_masker is
	port (----------------
			---- INPUTS ----
			----------------
			move_vector : in STD_LOGIC_VECTOR(127-1 downto 0);
			last_move	: in STD_LOGIC_VECTOR(7-1 downto 0);
			-----------------
			---- OUTPUTS ----
			-----------------
			move_vector_masked : out STD_LOGIC_VECTOR(127-1 downto 0)
	);
end move_vector_masker;

architecture move_vector_maskerArch of move_vector_masker is	
begin
	
	masking: for i in 0 to 127-1 generate 	 -- Not unexplored move vector
			move_vector_masked(i) <= '0' when last_move /= "1111111" 	  AND
														 -- Positions previous to the last move
														 i <= conv_integer(last_move)
											 else move_vector(i);
	end generate masking;
end move_vector_maskerArch;