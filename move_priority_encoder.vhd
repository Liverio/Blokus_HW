library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.types.ALL;

entity move_priority_encoder is
	port (----------------
			---- INPUTS ----
			----------------
			move_vector : in STD_LOGIC_VECTOR(127-1 downto 0);
			-----------------
			---- OUTPUTS ----
			-----------------
			move_pos : out STD_LOGIC_VECTOR(7-1 downto 0);
			no_move	: out STD_LOGIC
	);
end move_priority_encoder;

architecture move_priority_encoderArch of move_priority_encoder is		
begin
	process(move_vector)
	begin
		move_pos <= conv_std_logic_vector(0, 7);
		no_move <= '1';
		for i in 126 downto 0 loop
			if move_vector(i) = '1' then
				no_move <= '0';
				move_pos <= conv_std_logic_vector(i, 7);
			end if;
		end loop;
	end process;
end move_priority_encoderArch;