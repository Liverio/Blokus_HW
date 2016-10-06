library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.types.ALL;

entity next_move_finder is
	port (----------------
			---- INPUTS ----
			----------------
			move_vector : in STD_LOGIC_VECTOR(127-1 downto 0);
			last_move	: in STD_LOGIC_VECTOR(7-1 downto 0);	-- Vector position of the last explored move (127 = unexplored vector)
			-----------------
			---- OUTPUTS ----
			-----------------
			next_move : out STD_LOGIC_VECTOR(7-1 downto 0);
			no_move	 : out STD_LOGIC
	);
end next_move_finder;

architecture next_move_finderArch of next_move_finder is
	component move_vector_masker
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
	end component;
	
	component move_priority_encoder
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
	end component;
	
	signal move_vector_masked: STD_LOGIC_VECTOR(127-1 downto 0);
begin
	-- Sets explored moves to '0'
	move_vector_masker_I: move_vector_masker
		port map(---- INPUTS ----
					move_vector => move_vector,
					last_move	=> last_move,
					---- OUTPUTS ----
					move_vector_masked => move_vector_masked);
					
	-- Select the next move (if exists)
	move_priority_encoder_I: move_priority_encoder
		port map(---- INPUTS ----
					move_vector => move_vector_masked,
					---- OUTPUTS ----
					move_pos	=> next_move,
					no_move 	=> no_move);
end next_move_finderArch;