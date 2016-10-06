library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.types.ALL;

entity size_filter is
	port (----------------
			---- INPUTS ----
			----------------
			moves_vector	: in STD_LOGIC_VECTOR(127-1 downto 0);
			size_suggested	: in STD_LOGIC_VECTOR(3-1 downto 0);
			-----------------
			---- OUTPUTS ----
			-----------------
			moves_filtered	: out STD_LOGIC_VECTOR(127-1 downto 0);
			-- Overlapping restriction will be disabled if it is more restrictive than this value
			min_size_to_explore : out STD_LOGIC_VECTOR(3-1 downto 0)
	);
end size_filter;

architecture size_filterArch of size_filter is
	component max_size_checker
		port (----------------
				---- INPUTS ----
				----------------
				moves_vector : in STD_LOGIC_VECTOR(127-1 downto 0);
				-----------------
				---- OUTPUTS ----
				-----------------
				max_size : out STD_LOGIC_VECTOR(3-1 downto 0)
		);
	end component;
	
	-- Masks
	signal mask_5, mask_4: STD_LOGIC_VECTOR(127-1 downto 0);
	-- Moves filtered
	signal moves_filtered_5, moves_filtered_4: STD_LOGIC_VECTOR(127-1 downto 0);
	-- Max size available in the current vertex
	signal max_size: STD_LOGIC_VECTOR(3-1 downto 0);
begin	
	max_size_checker_I: max_size_checker
		port map(---- INPUTS ----
					moves_vector,
					---- OUTPUTS ----
					max_size
		);
	
	-- Mask for size 5
	mask_size_5: for i in 0 to 127-1 generate
					not_mask: if i < 92 generate 
						mask_5(i) <= '1';
					end generate;
					mask: if i >= 92 generate 
						mask_5(i) <= '0';
					end generate;
	end generate;
	
	-- Mask for size >=4
	mask_size_4: for i in 0 to 127-1 generate
					not_mask: if i < 117 generate 
						mask_4(i) <= '1';
					end generate;
					mask: if i >= 117 generate 
						mask_4(i) <= '0';
					end generate;
	end generate;
	
	-- Apply mask to moves vector
	mask: for i in 0 to 127-1 generate
				moves_filtered_5(i) <= moves_vector(i) AND mask_5(i);
				moves_filtered_4(i) <= moves_vector(i) AND mask_4(i);
	end generate;	

	-- Vector selector based suggested max_size and actual max_size
	moves_filtered <= moves_filtered_5 when size_suggested = 5 AND max_size  = 5 else							
							moves_filtered_4 when size_suggested = 4 AND max_size >= 4 else
							moves_vector;
	
	-- Overlapping restriction will be disabled if it is more restrictive than this value
	min_size_to_explore <= conv_std_logic_vector(5, 3) when size_suggested = 5 AND max_size  = 5 else
								  conv_std_logic_vector(4, 3) when size_suggested = 4 AND max_size >= 4 else
								  conv_std_logic_vector(1, 3);
end size_filterArch;