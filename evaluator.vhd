library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity evaluator is
	generic (bits_score : positive := 10);
    port (----------------
		  ---- INPUTS ----
		  ----------------
		  end_game_node : in STD_LOGIC;
		  -- End-game nodes
		  tiles_available_hero, tiles_available_rival : in STD_LOGIC_VECTOR(21-1 downto 0);
		  -- Non end-game nodes
		  accessibility_hero, accessibility_rival : in STD_LOGIC_VECTOR(7-1 downto 0);
          -----------------
		  ---- OUTPUTS ----
		  -----------------
		  score : out STD_LOGIC_VECTOR(bits_score-1 downto 0)
	);
end evaluator;

architecture evaluatorArch of evaluator is
	component endGameScoring
		port (----------------
			  ---- INPUTS ----
			  ----------------
			  tiles_available_hero, tiles_available_rival : in STD_LOGIC_VECTOR(21-1 downto 0);
			  -----------------
			  ---- OUTPUTS ----
			  -----------------
			  output_hero, output_rival: out STD_LOGIC_VECTOR(7-1 downto 0)
		);
	end component;
	
	signal endGameScore_hero, endGameScore_rival: STD_LOGIC_VECTOR(7-1 downto 0);
	signal score_multiplier: STD_LOGIC_VECTOR(5-1 downto 0); 
begin
	 score_multiplier <= "00010";
	 
	  --  End game scoring using non used tiles
	  endGameScoring_I: endGameScoring port map(tiles_available_hero, tiles_available_rival, endGameScore_hero, endGameScore_rival);
	 	  
	  -- Evaluation function
	  process(end_game_node, endGameScore_hero, endGameScore_rival, accessibility_hero, accessibility_rival)
	  begin
			if end_game_node = '1' then
				-- Winners
				if endGameScore_hero > endGameScore_rival then					
					score <= conv_std_logic_vector(900 + conv_integer(endGameScore_hero) - conv_integer(endGameScore_rival), bits_score);				
				-- Draw
				elsif endGameScore_hero = endGameScore_rival then
					score <= conv_std_logic_vector(400, bits_score);				
				-- Loosers (si perdemos de mas de 50 da igual todo)
				else
					score <= conv_std_logic_vector(50 + conv_integer(endGameScore_hero) - conv_integer(endGameScore_rival), bits_score);
				end if;
			else
				score <= conv_std_logic_vector(conv_integer(score_multiplier)*conv_integer(endGameScore_hero) - conv_integer(score_multiplier)*conv_integer(endGameScore_rival) +
											   conv_integer(accessibility_hero) - conv_integer(accessibility_rival) + 400, bits_score);
			end if;
	  end process;
end evaluatorArch;