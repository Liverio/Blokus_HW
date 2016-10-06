library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity endGameScoring is
	port (----------------
		  ---- INPUTS ----
		  ----------------
		  tiles_available_hero, tiles_available_rival : in STD_LOGIC_VECTOR(21-1 downto 0);
		  -----------------
		  ---- OUTPUTS ----
		  -----------------
		  output_hero, output_rival: out STD_LOGIC_VECTOR(7-1 downto 0)
	);
end endGameScoring;

architecture endGameScoringArch of endGameScoring is
	subtype tile_score is STD_LOGIC_VECTOR(3-1 downto 0);
	type tile_score_array is array(0 to 21-1) of tile_score;
	
	signal tile_hero, tile_rival: tile_score_array;
	signal score_hero, score_rival: STD_LOGIC_VECTOR(7-1 downto 0);
begin			
	-- U T S R Q P O N M L K J
	size5: for i in 0 to 11 generate
		tile_hero(i)  <= conv_std_logic_vector(5, 3) when tiles_available_hero(i)  = '0' else conv_std_logic_vector(0, 3);
		tile_rival(i) <= conv_std_logic_vector(5, 3) when tiles_available_rival(i) = '0' else conv_std_logic_vector(0, 3);
	end generate;
	
	-- I H G F E
	size4: for i in 12 to 16 generate
		tile_hero(i)  <= conv_std_logic_vector(4, 3) when tiles_available_hero(i)  = '0' else conv_std_logic_vector(0, 3);
		tile_rival(i) <= conv_std_logic_vector(4, 3) when tiles_available_rival(i) = '0' else conv_std_logic_vector(0, 3);
	end generate;
	
	-- D C
	size3: for i in 17 to 18 generate
		tile_hero(i)  <= conv_std_logic_vector(3, 3) when tiles_available_hero(i)  = '0' else conv_std_logic_vector(0, 3);
		tile_rival(i) <= conv_std_logic_vector(3, 3) when tiles_available_rival(i) = '0' else conv_std_logic_vector(0, 3);
	end generate;
	
	-- B
	tile_hero(19)  <= conv_std_logic_vector(2, 3) when tiles_available_hero(19)  = '0' else conv_std_logic_vector(0, 3);
	tile_rival(19) <= conv_std_logic_vector(2, 3) when tiles_available_rival(19) = '0' else conv_std_logic_vector(0, 3);
	
	-- A
	tile_hero(20)  <= conv_std_logic_vector(1, 3) when tiles_available_hero(20)  = '0' else conv_std_logic_vector(0, 3);
	tile_rival(20) <= conv_std_logic_vector(1, 3) when tiles_available_rival(20) = '0' else conv_std_logic_vector(0, 3);
	
	
	score_hero  <= conv_std_logic_vector(conv_integer(tile_hero(0))  + conv_integer(tile_hero(1))   + conv_integer(tile_hero(2))   +
										 conv_integer(tile_hero(3))  + conv_integer(tile_hero(4))   + conv_integer(tile_hero(5))   +
										 conv_integer(tile_hero(6))  + conv_integer(tile_hero(7))   + conv_integer(tile_hero(8))   +
										 conv_integer(tile_hero(9))  + conv_integer(tile_hero(10))  + conv_integer(tile_hero(11))  +
										 conv_integer(tile_hero(12)) + conv_integer(tile_hero(13))  + conv_integer(tile_hero(14))  +
										 conv_integer(tile_hero(15)) + conv_integer(tile_hero(16))  + conv_integer(tile_hero(17))  +
										 conv_integer(tile_hero(18)) + conv_integer(tile_hero(19))  + conv_integer(tile_hero(20)), 7);
	
	score_rival <= conv_std_logic_vector(conv_integer(tile_rival(0))  + conv_integer(tile_rival(1))   + conv_integer(tile_rival(2))   +
										 conv_integer(tile_rival(3))  + conv_integer(tile_rival(4))   + conv_integer(tile_rival(5))   +
										 conv_integer(tile_rival(6))  + conv_integer(tile_rival(7))   + conv_integer(tile_rival(8))   +
										 conv_integer(tile_rival(9))  + conv_integer(tile_rival(10))  + conv_integer(tile_rival(11))  +
										 conv_integer(tile_rival(12)) + conv_integer(tile_rival(13))  + conv_integer(tile_rival(14))  +
										 conv_integer(tile_rival(15)) + conv_integer(tile_rival(16))  + conv_integer(tile_rival(17))  +
										 conv_integer(tile_rival(18)) + conv_integer(tile_rival(19))  + conv_integer(tile_rival(20)), 7);
	
	output_hero <= score_hero;
	output_rival <= score_rival;	
end endGameScoringArch;