---------------------------------------------- ***** Features ***** ----------------------------------------------
-- - Stores the current working board
-- - Supplies a 9x9 processing window for each player
-- - Allows full board readings and writings
-- - Move writting: updates the movement square and its four surrounding squares (up, down, left, right)
-- - NEW: Supplies a vertices map for each player
------------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use work.types.all;

entity board is
    port (----------------
		  ---- INPUTS ----
		  ----------------
		  clk 	  : in STD_LOGIC;
		  rst 	  : in STD_LOGIC;
		  -- Move writings
		  write_move	  : in STD_LOGIC;
		  player		  : in tpPlayer;
		  tile_x_pos	  : in tpPiecesPositions;
		  tile_y_pos	  : in tpPiecesPositions;
		  piece_valid	  : in STD_LOGIC_VECTOR(5-1 downto 0);
		  forbidden_x_pos : in tpForbiddenPositions;
		  forbidden_y_pos : in tpForbiddenPositions;
		  forbidden_valid : in STD_LOGIC_VECTOR(12-1 downto 0);
		  -- Full board transactions
		  write_board 		: in STD_LOGIC;
		  swap_board        : in STD_LOGIC;
		  board_input 		: in tpBoard;
		  board_color_input : in tpBoard;
		  -- Proccesing windows centers
		  window_x_hero,  window_y_hero  : in STD_LOGIC_VECTOR(4-1 downto 0);
		  window_x_rival, window_y_rival : in STD_LOGIC_VECTOR(4-1 downto 0);
		  -----------------
	      ---- OUTPUTS ----
		  -----------------
		  -- Full board transactions
		  board_output 		 : out tpBoard;
		  board_color_output : out tpBoard;
		  -- Processing windows
		  window_hero  : out tpProcessingWindow;
		  window_rival : out tpProcessingWindow;
		  -- Vertices maps
		  vertices_map_hero  : out tpVertices_map;
		  vertices_map_rival : out tpVertices_map;
		  vertices_type_map_hero  : out tpVertices_type_map;
		  vertices_type_map_rival : out tpVertices_type_map
    );
end board;

architecture boardArch of board is
	component board_reg
		port (----------------
				---- INPUTS ----
				----------------
				clk, rst : in STD_LOGIC;
				write_move  : in STD_LOGIC;
				write_board	: in STD_LOGIC;
				swap_board  : in STD_LOGIC;
				-- Data from board_updater
				new_board 		: in tpBoard;
				new_board_color : in tpBoard;
				-- Data from boards BRAMs
				board_input 	  : in tpBoard;
				board_color_input : in tpBoard;
				-----------------
				---- OUTPUTS ----
				-----------------
				board 		: out tpBoard;	-- Forbidden info
				board_color : out tpBoard	-- Color info
		);
	end component;
	
	component board_updater
		port (----------------
				---- INPUTS ----
				----------------			
				-- Movement info
				player			 : in tpPlayer;
				tile_x_pos		 : in tpPiecesPositions;
				tile_y_pos		 : in tpPiecesPositions;
				piece_valid		 : in STD_LOGIC_VECTOR(5-1 downto 0);
				forbidden_x_pos : in tpForbiddenPositions;
				forbidden_y_pos : in tpForbiddenPositions;
				forbidden_valid : in STD_LOGIC_VECTOR(12-1 downto 0);
				-- Forbiddens board
				board : in tpBoard;
				-- Color board
				board_color : in tpBoard;
				-----------------
				---- OUTPUTS ----
				-----------------			
				new_board 		 : out tpBoard;
				new_board_color : out tpBoard
		);
	end component;
	
	component vertices_map
		generic (player: tpPlayer := HERO);
		port (----------------
				---- INPUTS ----
				----------------
				board	 		: in tpBoard;
				board_color : in tpBoard;
				-----------------
				---- OUTPUTS ----
				-----------------
				vertices_map		: out tpVertices_map;
				vertices_type_map : out tpVertices_type_map
		);
	end component;
	
	component processing_window
		generic (player : tpPlayer := HERO);
		port (----------------
				---- INPUTS ----
				----------------
				-- Current board
				board : in tpBoard;
				-- Vertex coordinates (processing window center) and vertex type
				window_x, window_y : in STD_LOGIC_VECTOR(4-1 downto 0);			
				-----------------
				---- OUTPUTS ----
				-----------------			
				-- Processing window
				window : out tpProcessingWindow
		);
	end component;
	
	signal board, new_board: tpBoard;
	signal board_color, new_board_color: tpBoard;
begin
	-- OUTPUTS
	board_output <= board;
	board_color_output <= board_color;
	
	board_reg_I: board_reg
		port map(---- INPUTS ----
					clk => clk,
					rst => rst,
					write_move	=> write_move,
					write_board => write_board,
					swap_board  => swap_board,
					-- Data from board_updater
					new_board		 => new_board,
					new_board_color => new_board_color,
					-- Data from boards BRAMs
					board_input			=> board_input,
					board_color_input => board_color_input,
					-----------------
					---- OUTPUTS ----
					-----------------
					board			=> board,
					board_color => board_color);
	
	board_updater_I: board_updater
		port map(---- INPUTS ----					 
					-- Movement info
					player 	 	 	 => player,
					tile_x_pos		 => tile_x_pos,
					tile_y_pos		 => tile_y_pos,
					piece_valid		 => piece_valid,
					forbidden_x_pos => forbidden_x_pos,
					forbidden_y_pos => forbidden_y_pos,
					forbidden_valid => forbidden_valid,
					-- Current boards
					board			=> board,					 
					board_color => board_color,
					---- OUTPUTS ----
					new_board 		 => new_board,
					new_board_color => new_board_color);
					 
	vertices_map_hero_I: vertices_map generic map(HERO)
		port map(---- INPUTS ----
					board			 => board,
					board_color	 => board_color,
					---- OUTPUTS ----
					vertices_map		=> vertices_map_hero,
					vertices_type_map => vertices_type_map_hero);
					 
	vertices_map_rival_I: vertices_map generic map(RIVAL)
		port map(---- INPUTS ----
					board			 => board,
					board_color	 => board_color,
					---- OUTPUTS ----
					vertices_map		=> vertices_map_rival,
					vertices_type_map => vertices_type_map_rival);
					
	window_hero_I: processing_window generic map(HERO)
		port map(---- INPUTS ----
					-- Current board
					board	=> board,
					-- Vertex coordinates (processing window center) and vertex type
					window_x => window_x_hero,
					window_y => window_y_hero,
					---- OUTPUTS ----
					-- Processing window
					window => window_hero);
		
	window_rival_I: processing_window generic map(RIVAL)
		port map(---- INPUTS ----
					-- Current board
					board	=> board,
					-- Vertex coordinates (processing window center) and vertex type
					window_x => window_x_rival,
					window_y => window_y_rival,
					---- OUTPUTS ----
					-- Processing window
					window => window_rival);	
end boardArch;