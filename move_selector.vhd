library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.types.ALL;

entity move_selector is
	port (----------------
			---- INPUTS ----
			----------------
			-- Data to decide the next move
			window			 : in tpProcessingWindow;
			vertex_type 	 : in STD_LOGIC_VECTOR(2-1 downto 0);
			last_move_num	 : in STD_LOGIC_VECTOR(7-1 downto 0);
			tiles_available : in STD_LOGIC_VECTOR(21-1 downto 0);
			-- Size filter
			size_suggested	: in STD_LOGIC_VECTOR(3-1 downto 0);
			-----------------
			---- OUTPUTS ----
			-----------------
			next_move_num	: out STD_LOGIC_VECTOR(7-1 downto 0);
			move_not_found	: out STD_LOGIC;
			-- Overlapping restriction will be disabled if it is more restrictive than this value
			min_size_to_explore : out STD_LOGIC_VECTOR(3-1 downto 0)
	);
end move_selector;

architecture move_selectorArch of move_selector is
	-----------------------------------------------
	---------------- MOVE CHECKERS ----------------
	-----------------------------------------------
	component moveChecker_vertex0 is
		port (----------------
				---- INPUTS ----
				----------------
				window 			 : in tpProcessingWindow;
				tiles_available : in STD_LOGIC_VECTOR(21-1 downto 0);
				-----------------
				---- OUTPUTS ----
				-----------------
				moves : out STD_LOGIC_VECTOR(v0a00 downto v0u00));
	end component;
	
	component moveChecker_vertex1 is
		port (----------------
				---- INPUTS ----
				----------------
				window 			 : in tpProcessingWindow;
				tiles_available : in STD_LOGIC_VECTOR(21-1 downto 0);
				-----------------
				---- OUTPUTS ----
				-----------------
				moves : out STD_LOGIC_VECTOR(v1a00 downto v1u00));
	end component;
	
	component moveChecker_vertex2 is
		port (----------------
				---- INPUTS ----
				----------------
				window 			 : in tpProcessingWindow;
				tiles_available : in STD_LOGIC_VECTOR(21-1 downto 0);
				-----------------
				---- OUTPUTS ----
				-----------------
				moves : out STD_LOGIC_VECTOR(v2a00 downto v2u00));
	end component;
	
	component moveChecker_vertex3 is
		port (----------------
				---- INPUTS ----
				----------------
				window 			 : in tpProcessingWindow;
				tiles_available : in STD_LOGIC_VECTOR(21-1 downto 0);
				-----------------
				---- OUTPUTS ----
				-----------------
				moves : out STD_LOGIC_VECTOR(v3a00 downto v3u00));
	end component;
	
	-------------------------------------------------
	------------------ SIZE FILTER ------------------
	-------------------------------------------------
	component size_filter
		port (----------------
				---- INPUTS ----
				----------------
				moves_vector 	: in STD_LOGIC_VECTOR(127-1 downto 0);
				size_suggested	: in STD_LOGIC_VECTOR(3-1 downto 0);
				-----------------
				---- OUTPUTS ----
				-----------------
				moves_filtered	: out STD_LOGIC_VECTOR(127-1 downto 0);
				-- Overlapping restriction will be disabled if it is more restrictive than this value
				min_size_to_explore : out STD_LOGIC_VECTOR(3-1 downto 0)
		);
	end component;
	
	-------------------------------------------------
	----------------- MOVE SELECTOR -----------------
	-------------------------------------------------	
	component next_move_finder
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
	end component;	
	
	-- Move checkers
	signal moves_vertex0, moves_vertex1, moves_vertex2, moves_vertex3: STD_LOGIC_VECTOR(127-1 downto 0);
	
	-- Size filter
	signal moves_filtered: STD_LOGIC_VECTOR(127-1 downto 0);
	
	-- Move selector
	signal moves_vector: STD_LOGIC_VECTOR(127-1 downto 0);
	
	-- Move translation
	signal move: STD_LOGIC_VECTOR(10-1 downto 0);
begin	
	-----------------------------------------------
	---------------- MOVE CHECKERS ----------------
	-----------------------------------------------
	moveChecker_vertex0_I: moveChecker_vertex0
		port map(---- INPUTS ----
					window, tiles_available,
					---- OUTPUTS ----
					moves_vertex0);
	
	moveChecker_vertex1_I: moveChecker_vertex1
		port map(---- INPUTS ----
					window, tiles_available,
					---- OUTPUTS ----
					moves_vertex1);
	
	moveChecker_vertex2_I: moveChecker_vertex2
		port map(---- INPUTS ----
					window, tiles_available,
					---- OUTPUTS ----
					moves_vertex2);
	
	moveChecker_vertex3_I: moveChecker_vertex3
		port map(---- INPUTS ----
					window, tiles_available,
					---- OUTPUTS ----
					moves_vertex3);
	
	-- Vector selector based on vertex type
	moves_vector <= moves_vertex0 when vertex_type = "00" else
						 moves_vertex1 when vertex_type = "01" else
						 moves_vertex2 when vertex_type = "10" else
						 moves_vertex3;
	
	-------------------------------------------------
	------------------ SIZE FILTER ------------------
	-------------------------------------------------
	size_filter_I: size_filter
		port map(---- INPUTS ----
					moves_vector, size_suggested,
					---- OUTPUTS ----
					moves_filtered,
					min_size_to_explore);
	
	
	-------------------------------------------------
	----------------- MOVE SELECTOR -----------------
	-------------------------------------------------
	next_move_finder_I: next_move_finder
		port map(---- INPUTS ----
				 moves_filtered, last_move_num,				 
				 ---- OUTPUTS ----
				 next_move_num, move_not_found);	
end move_selectorArch;