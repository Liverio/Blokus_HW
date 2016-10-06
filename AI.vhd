library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;
use ieee.math_real.log2;
use work.types.ALL;

entity AI is
	generic (max_level: positive := 10; bits_level: positive := 4; timeout: positive := 1; iterativa: natural := 0; simulation : natural := 0);
    port (----------------
          ---- INPUTS ----
		  ----------------
          clk, rst : in STD_LOGIC;
		  new_move : in STD_LOGIC;
		  depth : in STD_LOGIC_VECTOR(3-1 downto 0);
		  -----------------
		  ---- OUTPUTS ----
		  -----------------			
		  game_over : out STD_LOGIC;
		  pass_hero : out STD_LOGIC;
		  moveFound : out STD_LOGIC;
		  x_hero, y_hero : out STD_LOGIC_VECTOR(4-1 downto 0);
		  tile_hero      : out STD_LOGIC_VECTOR(5-1 downto 0);
		  rotation_hero  : out STD_LOGIC_VECTOR(3-1 downto 0);
		  -- DEBUG
		  debug_current_max_level: out STD_LOGIC_VECTOR(3-1 downto 0);
		  -- Performance monitoring
		  monitoring_num_boards : out STD_LOGIC_VECTOR(32-1 downto 0));
end AI;

architecture AIArch of AI is	
	component min_max_manager
		generic (max_level : positive := 10;
					bits_level : positive := 4);
		port (----------------
			  ---- INPUTS ----
			  ----------------	
			  clk	  : in  STD_LOGIC;
			  rst 	  : in  STD_LOGIC;
			  -- Tree control
			  new_level 	: in STD_LOGIC;
			  close_level : in STD_LOGIC;
			  clean_level	: in STD_LOGIC;
			  evaluating	: in STD_LOGIC;				
			  -- Best move
			  move : in STD_LOGIC_VECTOR(16-1 downto 0);
			  -- Score from evaluator
			  score : in STD_LOGIC_VECTOR(10-1 downto 0);
			  -----------------
			  ---- OUTPUTS ----
			  -----------------
			  level			  : out STD_LOGIC_VECTOR(bits_level-1 downto 0);
		  	  current_max_level : out STD_LOGIC_VECTOR(bits_level-1 downto 0);
			  prune			  : out STD_LOGIC;
			  move_to_sort	  : out tp_array_movements;
			  score_to_sort	  : out STD_LOGIC_VECTOR(10-1 downto 0);
			  best_move		  : out STD_LOGIC_VECTOR(16-1 downto 0);
			  -- Info for prunes memory
			  prune_L3		  : out STD_LOGIC;
			  prune_L4		  : out STD_LOGIC;
			  prune_mem_move_L1 : out STD_LOGIC_VECTOR(15 downto 0);
			  prune_mem_move_L2 : out STD_LOGIC_VECTOR(15 downto 0);
			  prune_mem_move_L3 : out STD_LOGIC_VECTOR(15 downto 0);
			  prune_mem_move_L4 : out STD_LOGIC_VECTOR(15 downto 0)
		);
	end component;
	
	component board
		port (----------------
			  ---- INPUTS ----
			  ----------------
			  clk : in STD_LOGIC;
			  rst : in STD_LOGIC;
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
			  window_hero	 : out tpProcessingWindow;
			  window_rival : out tpProcessingWindow;
			  -- Vertices maps
			  vertices_map_hero  : out tpVertices_map;
			  vertices_map_rival : out tpVertices_map;
			  vertices_type_map_hero	: out tpVertices_type_map;
			  vertices_type_map_rival	: out tpVertices_type_map
		);
	end component;
	
	component board_memory_manager
		port (----------------
				---- INPUTS ----
				----------------
				clk : in STD_LOGIC;
				load_real_board : in STD_LOGIC;
				store_board 	 : in STD_LOGIC;
				level				 : in STD_LOGIC_VECTOR(4-1 downto 0);
				-- From Board Register
				board_input 		: in tpBoard;
				board_color_input : in tpBoard;			
				-----------------
				---- OUTPUTS ----
				-----------------
				board_output 		 : out tpBoard;
				board_color_output : out tpBoard			
		);
	end component;
	
	component tiles_placement
		port (----------------
				---- INPUTS ----
				----------------
				-- Center
				x, y 		 : in STD_LOGIC_VECTOR(4-1 downto 0);
				tile 		 : in STD_LOGIC_VECTOR(5-1 downto 0);			
				rotation  : in STD_LOGIC_VECTOR(3-1 downto 0);			
				-----------------
				---- OUTPUTS ----
				-----------------	
				-- Tile info
				tile_x_pos	: out tpPiecesPositions;
				tile_y_pos	: out tpPiecesPositions;
				piece_valid	: out STD_LOGIC_VECTOR(5-1 downto 0);
				-- Forbiddens info
				forbidden_x_pos : out tpForbiddenPositions;
				forbidden_y_pos : out tpForbiddenPositions;
				forbidden_valid : out STD_LOGIC_VECTOR(12-1 downto 0)
		);
	end component;
	
	
	component available_tiles
		generic (max_level  : positive := 10;
					bits_level : positive := 4);
		port (----------------
				---- INPUTS ----
				----------------
				clk : in  STD_LOGIC;
				rst : in  STD_LOGIC;			
				swap_players : in STD_LOGIC;
				remove_tile  : in STD_LOGIC;
				restore_tile : in STD_LOGIC;			
				player	 	 : in tpPlayer;
				tile		 	 : in STD_LOGIC_VECTOR(5-1 downto 0);
				level			 : in STD_LOGIC_VECTOR(bits_level-1 downto 0);
				-----------------
				---- OUTPUTS ----
				-----------------
				-- Tiles available for the current search branch and player
				tiles_available_hero	 : out STD_LOGIC_VECTOR(21-1 downto 0);
				tiles_available_rival : out STD_LOGIC_VECTOR(21-1 downto 0));
	end component;
	
	
	component legalMoves
		generic (max_level  : positive := 10;
					bits_level : positive := 4);
		port (----------------
				---- INPUTS ----
				----------------
				clk 	  : in  STD_LOGIC;
				rst 	  : in  STD_LOGIC;
				timeout : in  STD_LOGIC;
				-- Move request
				move_request : in STD_LOGIC;
				level			 : in STD_LOGIC_VECTOR(bits_level-1 downto 0);
				current_max_level : in STD_LOGIC_VECTOR(bits_level-1 downto 0);
				-- Find moves to check if the current board is end-game
				check_end_game : in STD_LOGIC;
				-- Current player vertices map
				vertices_map 		: in tpVertices_map;
				vertices_type_map	: in tpVertices_type_map;
				-- Window centered in the current vertex for moves detection 
				window : in tpProcessingWindow;
				-- Current board
				board	: in tpBoard;
				-- Tiles available vector for the player who is moving
				tiles_available : in STD_LOGIC_VECTOR(21-1 downto 0);
				-- Current vertex must be skipped because of overlapping
				skip_vertex : in STD_LOGIC;
				-- Clear the status of the current level
				clear : in STD_LOGIC;
				-- Moves memory
				sort_move	  : in STD_LOGIC;
				move_to_sort  : in tp_array_movements;
				score_to_sort : in STD_LOGIC_VECTOR(10-1 downto 0);
				sort_rst_intramove : in STD_LOGIC;
				sort_rst_intermove : in STD_LOGIC;
				-- Move number to manage openings and to set suggested min size to explore
				move_count	: in STD_LOGIC_VECTOR(6-1 downto 0);
				-- When checking end-game while reading best chain, this info is necessary to know wether to return the memory move just after end-game is checked or not
				check_overlapping : in STD_LOGIC;
				-- Info for prunes_L3_memory
				clear_hash			: in STD_LOGIC;
				write_prune_L3		: in STD_LOGIC;
				write_prune_L4		: in STD_LOGIC;
				prune_mem_move_L1 : in STD_LOGIC_VECTOR(16-1 downto 0);
				prune_mem_move_L2 : in STD_LOGIC_VECTOR(16-1 downto 0);
				prune_mem_move_L3 : in STD_LOGIC_VECTOR(16-1 downto 0);
				prune_mem_move_L4 : in STD_LOGIC_VECTOR(16-1 downto 0);
				-----------------
				---- OUTPUTS ----
				-----------------
				-- Hash cleaning between games
				hash_cleared: out STD_LOGIC;
				-- Data to center the window while searching a move
				window_x, window_y: out STD_LOGIC_VECTOR(4-1 downto 0);
				-- Vertex data for overlapping filter
				vertex_x, vertex_y : out STD_LOGIC_VECTOR(4-1 downto 0);
				vertex_type_out	 : out STD_LOGIC_VECTOR(2-1 downto 0);
				-- Move finding results
				move_found : out STD_LOGIC;
				x, y 	   : out STD_LOGIC_VECTOR(4-1 downto 0);
				tile 	   : out STD_LOGIC_VECTOR(5-1 downto 0);
				rotation   : out STD_LOGIC_VECTOR(3-1 downto 0);
				-- No more moves
				move_not_found : out STD_LOGIC;
				-- Node without moves
				no_moves			: out STD_LOGIC;
				-- Memory is ready to be written
				sort_ready_out : out STD_LOGIC;
				-- Overlapping restriction will be disabled if it is more restrictive than this value
				min_size_to_explore : out STD_LOGIC_VECTOR(3-1 downto 0)				
		);
	end component;	
	
	component accessibility_map
		generic (player: tpPlayer := HERO;
					bits_level : positive := 4);
		port (----------------
				---- INPUTS ----
				----------------			
				clk, rst	: in STD_LOGIC;
				timeout	: in STD_LOGIC;
				level	  	: in STD_LOGIC_VECTOR(bits_level-1 downto 0);
				-- Info from board module to carry out vertex selection
				vertices_map 		: in tpVertices_map;
				vertices_type_map	: in tpVertices_type_map;
				-- Info from board module
				board : in tpBoard;
				-- Info from board module to build the accessibility map			
				tiles_available : in STD_LOGIC_VECTOR(21-1 downto 0);
				-- Create a new map
				create_map : in STD_LOGIC;
				work_mode  : in tpWorkMode_accessibilityMap;
				-----------------
				---- OUTPUTS ----
				-----------------
				-- Accessibility output
				map_created 		: out STD_LOGIC;				
				accessibility_count : out STD_LOGIC_VECTOR(7-1 downto 0);
				overlapping_map_out : out tpAccessibility_map
		);
	end component;
	
	component overlapping
		generic (max_level  : positive := 5;
					bits_level : positive := 4);
		port (----------------
				---- INPUTS ----
				----------------
				clk, rst	: in STD_LOGIC;
				-- Move to be checked
				tile_x_pos 			: in tpPiecesPositions;
				tile_y_pos 			: in tpPiecesPositions;
				tile_pos_valid 	: in STD_LOGIC_VECTOR(5-1 downto 0);
				-- New overlapping map created
				load_map : in STD_LOGIC;
				-- New map to be stored where level indicates
				overlapping_map: in tpAccessibility_map;
				-- Overlapping filter
				vertex_x 	: in STD_LOGIC_VECTOR(4-1 downto 0);
				vertex_y 	: in STD_LOGIC_VECTOR(4-1 downto 0);
				vertex_type : in STD_LOGIC_VECTOR(2-1 downto 0);
				-- Info to set threshold (level input also to know which map to choose in updates)
				move_count	: in STD_LOGIC_VECTOR(6-1 downto 0);
				level			: in STD_LOGIC_VECTOR(bits_level-1 downto 0);
				-- Overlapping restriction will be disabled if it is more restrictive than this value
				min_size_to_explore	: in STD_LOGIC_VECTOR(3-1 downto 0);
				-----------------
				---- OUTPUTS ----
				-----------------
				-- Overlapping is active
				check_overlapping : out STD_LOGIC;
				-- Overlapping set to 4 and no possible move overlapped enough
				skip_vertex	: out STD_LOGIC;
				move_overlapped : out STD_LOGIC
		);
	end component;
	
	component evaluator
		generic (bits_score : positive := 10);
		port(----------------
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
				score : out STD_LOGIC_VECTOR(10-1 downto 0)
		);
	end component;
	
	component counter
		generic (bits: positive);
		port (clk, rst: in STD_LOGIC;
				rst2 : in STD_LOGIC;
				inc : in STD_LOGIC;
				count : out STD_LOGIC_VECTOR(bits-1 downto 0)
		);
	end component;
	
	
    type states is (IDLE, CLEANING_HASH,
                    CREATE_OVERLAPPING_MAP, CREATE_OVERLAPPING_MAP_2,
					GENERATE_NODE, GENERATE_NODE_2,
					CHECK_END_GAME_NODE, CHECK_END_GAME_NODE_2, CHECK_END_GAME_NODE_3, CHECK_END_GAME_NODE_4,
					EVALUATE_NODE, EVALUATING_NODE, EVALUATING_NODE_WAITING_HERO, EVALUATING_NODE_WAITING_RIVAL, EVALUATE_NON_END_GAME_NODE, WAIT_MEM_READY, EVALUATE_END_GAME_NODE, WAIT_MEM_READY_2, 
					LOAD_BOARD_INTO_REG, DONE, SWAPPING_PLAYERS, CHECK_GAME_OVER, CHECK_GAME_OVER_2);
		
	-- Common
	signal player: tpPlayer;
	signal rst_game: STD_LOGIC;
	
	-- Min-max manager
	signal new_level: STD_LOGIC;
	signal close_level: STD_LOGIC;
	signal clean_level: STD_LOGIC;
	signal evaluating: STD_LOGIC;
	signal move: STD_LOGIC_VECTOR(16-1 downto 0);
	signal score: STD_LOGIC_VECTOR(10-1 downto 0);
	signal level: STD_LOGIC_VECTOR(bits_level-1 downto 0);
	signal current_max_level: STD_LOGIC_VECTOR(bits_level-1 downto 0);
	signal prune: STD_LOGIC;
	signal move_to_sort: tp_array_movements;
	signal score_to_sort: STD_LOGIC_VECTOR(10-1 downto 0);
	signal best_move: STD_LOGIC_VECTOR(16-1 downto 0);		
	signal prune_L3, prune_L4: STD_LOGIC;
	signal prune_mem_move_L1, prune_mem_move_L2, prune_mem_move_L3, prune_mem_move_L4: STD_LOGIC_VECTOR(16-1 downto 0);
	
	-- Move counter
	signal move_count: STD_LOGIC_VECTOR(6-1 downto 0);
	
	-- Tiles placement
	signal tiles_placement_x, tiles_placement_y: STD_LOGIC_VECTOR(4-1 downto 0);
	signal tiles_placement_tile: STD_LOGIC_VECTOR(5-1 downto 0);
	signal tiles_placement_rotation: STD_LOGIC_VECTOR(3-1 downto 0);
	signal tiles_placement_x_pos, tiles_placement_y_pos: tpPiecesPositions;
	signal tiles_placement_piece_valid: STD_LOGIC_VECTOR(5-1 downto 0);
	signal tiles_placement_forbidden_x_pos, tiles_placement_forbidden_y_pos: tpForbiddenPositions;
	signal tiles_placement_forbidden_valid: STD_LOGIC_VECTOR(12-1 downto 0);

	-- Board
	signal write_move: STD_LOGIC;	
	signal write_board: STD_LOGIC;	
	signal board_input, board_color_input: tpBoard;
	signal window_x_hero, window_y_hero, window_x_rival, window_y_rival: STD_LOGIC_VECTOR(4-1 downto 0);	
	signal board_output,	board_color_output: tpBoard;
	signal window_hero, window_rival: tpProcessingWindow;
	signal vertices_map_hero, vertices_map_rival: tpVertices_map;
	signal vertices_type_map_hero, vertices_type_map_rival: tpVertices_type_map;
	
	-- Boards memory manager
	signal load_real_board, store_board: STD_LOGIC;
	
	-- Tiles available
	signal restore_tile: STD_LOGIC;
	signal available_tiles_player: tpPlayer;
	signal available_tiles_tile: STD_LOGIC_VECTOR(5-1 downto 0);
	signal tiles_available_hero, tiles_available_rival: STD_LOGIC_VECTOR(21-1 downto 0);
	
	-- Legal moves
	signal move_request: STD_LOGIC;
	signal move_next_vertex_request: STD_LOGIC;
	signal vertices_map_input: tpVertices_map;
	signal vertices_type_map: tpVertices_type_map;
	signal window: tpProcessingWindow;
	signal tiles_available: STD_LOGIC_VECTOR(21-1 downto 0);
	signal legal_moves_window_x, legal_moves_window_y: STD_LOGIC_VECTOR(4-1 downto 0);
	signal legal_move_found, legal_move_not_found, no_legal_moves: STD_LOGIC;
	signal legal_move_x, legal_move_y: STD_LOGIC_VECTOR(4-1 downto 0);
	signal legal_move_tile: STD_LOGIC_VECTOR(5-1 downto 0);
	signal legal_move_rotation: STD_LOGIC_VECTOR(3-1 downto 0);
	signal clear_legal_moves_status: STD_LOGIC;
	signal legal_move_vertex_x, legal_move_vertex_y: STD_LOGIC_VECTOR(4-1 downto 0);
	signal legal_move_vertex_type: STD_LOGIC_VECTOR(2-1 downto 0);
	signal min_size_to_explore: STD_LOGIC_VECTOR(3-1 downto 0);
	signal sort_move: STD_LOGIC;
	signal check_end_game: STD_LOGIC;
	signal sort_ready_out: STD_LOGIC;	
	signal write_prune_L4: STD_LOGIC;
	signal clear_hash: STD_LOGIC;
	signal hash_cleared: STD_LOGIC;
	
	-- Accessibility maps
	signal create_map_hero, create_map_rival: STD_LOGIC;
	signal accessibility_map_work_mode: tpWorkMode_accessibilityMap;
	signal map_created_hero, map_created_rival: STD_LOGIC;
	signal accessibility_hero, accessibility_rival: STD_LOGIC_VECTOR(7-1 downto 0);		
	signal window_x_accessibility_hero, window_y_accessibility_hero, window_x_accessibility_rival, window_y_accessibility_rival: STD_LOGIC_VECTOR(4-1 downto 0);
	signal new_map_hero, new_map_rival, update_map_hero, update_map_rival: STD_LOGIC;
	signal overlapping_map_hero, overlapping_map_rival: tpAccessibility_map;
	
	-- Overlapping
	signal load_overlapping_map: STD_LOGIC;
	signal overlapping_map: tpAccessibility_map;
	signal check_overlapping: STD_LOGIC;
	signal skip_vertex: STD_LOGIC;
	signal move_overlapped: STD_LOGIC;
	
	-- Evaluator		
	signal end_game_node: STD_LOGIC;
	
	-- State machine control signals	
	signal currentState, nextState: states;	
	signal move_source: move_source;
		-- Legal moves
		signal reset_legal_moves_status: STD_LOGIC;
		
	-- Tree control
	signal expanded_node_ns, expanded_node_cs: STD_LOGIC_VECTOR(max_level-1 downto 0);
	signal expanded_node: STD_LOGIC;	
	signal unset_overlapping_ns, unset_overlapping_cs: STD_LOGIC_VECTOR(max_level-1 downto 0);
	signal unset_overlapping: STD_LOGIC;
	signal sort_rst_intramove, sort_rst_intermove: STD_LOGIC;
	
	signal hard_rst: STD_LOGIC;
	
	signal timeout_reached: STD_LOGIC;
	signal swap_players: STD_LOGIC;
begin	
        -- DEBUG
        debug_current_max_level <= current_max_level(2 downto 0);
        -- DEBUG
        
        monitoring_num_boards_I : counter generic map(32)		
            port map(clk, rst, new_move, new_level, monitoring_num_boards);
            		
		timeout_reached <= '0';
		
		-- Game reset: Prepare for a new game
		hard_rst <= rst OR rst_game;		
		
		-- Have to know how many movements have been done in order to explore all tiles or not
		moveCounter: counter generic map(6)
            port map(clk, rst, rst_game, new_move, move_count);
		
		-- Min_max_manager inputs
		move <= legal_move_x & legal_move_y & legal_move_tile & legal_move_rotation;

		min_max_manager_I: min_max_manager generic map(max_level, bits_level)
			port map(---- INPUTS ----
						clk, rst,
						-- Tree control
						new_level, close_level, clean_level, evaluating,
						-- Best move
						move,
						-- Score from evaluator
						score,
						---- OUTPUTS ----
						level, current_max_level, prune, move_to_sort, score_to_sort, best_move,
						-- Info for prunes memory
						prune_L3, prune_L4,
						prune_mem_move_L1, prune_mem_move_L2, prune_mem_move_L3, prune_mem_move_L4);
				 
		
		tiles_placement_I: tiles_placement
			port map(---- INPUTS ----
						-- Center
						tiles_placement_x, tiles_placement_y, tiles_placement_tile, tiles_placement_rotation,
						---- OUTPUTS ----
						-- Tile info
						tiles_placement_x_pos, tiles_placement_y_pos, tiles_placement_piece_valid,
						-- Forbidden info
						tiles_placement_forbidden_x_pos, tiles_placement_forbidden_y_pos, tiles_placement_forbidden_valid);
		
		board_I: board		
				port map(---- INPUTS ----
						 clk, hard_rst,
						 -- Move writing
						 write_move, player, tiles_placement_x_pos, tiles_placement_y_pos, tiles_placement_piece_valid, tiles_placement_forbidden_x_pos, tiles_placement_forbidden_y_pos, tiles_placement_forbidden_valid,
						 -- Full board transactions
						 write_board, swap_players, board_input, board_color_input,
						 -- Processing windows transactions
						 window_x_hero, window_y_hero, window_x_rival, window_y_rival,
						 ---- OUTPUTS ----
						 -- Full board transactions
						 board_output, board_color_output,
						 -- Processing windows
						 window_hero, window_rival,
						 -- Vertices maps
						 vertices_map_hero, vertices_map_rival, vertices_type_map_hero, vertices_type_map_rival);	
	
		board_memory_manager_I: board_memory_manager
			port map(---- INPUTS ----
					 clk,
					 load_real_board, store_board, level,
					 -- From Board Register
					 board_output, board_color_output,
					 ---- OUTPUTS ----
					 -- To Board Register
					 board_input, board_color_input);
		
		
		restore_tile <= '1' when (close_level = '1' OR clean_level = '1') AND level > 0 AND expanded_node_cs(conv_integer(level-1)) = '1' else '0';
		
		available_tiles_player <= RIVAL when (write_move = '1' AND level(0) = '1') OR (restore_tile = '1' AND level(0) = '0') else HERO;
		tiles_available_I: available_tiles generic map(max_level)
			port map(---- INPUTS ----
						clk => clk,
						rst => hard_rst,
						swap_players => swap_players,
						remove_tile	 => write_move,
						restore_tile => restore_tile,
						player		 => available_tiles_player,
						tile			 => available_tiles_tile,
						level			 => level,
						---- OUTPUTS ----
						tiles_available_hero	 => tiles_available_hero,
						tiles_available_rival => tiles_available_rival);
		
		
		-- Inputs for legal_moves
		window				 <= window_hero 				when player = HERO else window_rival;
		tiles_available 	 <= tiles_available_hero 	when player = HERO else tiles_available_rival;		
		vertices_map_input <= vertices_map_hero 		when player = HERO else vertices_map_rival;
		vertices_type_map  <= vertices_type_map_hero when player = HERO else vertices_type_map_rival;
		
		legalMoves_I: legalMoves generic map(max_level, bits_level)
			port map(---- INPUTS ----
						clk, hard_rst, timeout_reached,
						-- Move request
						move_request, level, current_max_level,					
						-- Find moves to check if the current board is end-game
						check_end_game,
						-- Current player vertices map
						vertices_map_input, vertices_type_map,
						-- Window centered in the current vertex for moves detection 
						window,
						-- Board
						board_output,
						-- Tiles available vector for the player who is moving
						tiles_available,
						-- Current vertex must be skipped because of overlapping
						move_next_vertex_request,
						-- Clear the status of the current level						
						clear_legal_moves_status,
						-- Moves memory
						sort_move, move_to_sort, score_to_sort,
						sort_rst_intramove, sort_rst_intermove,
						-- Move number to manage openings and to set suggested min size to explore
						move_count,
						-- When checking end-game while reading best chain, this info is necessary to know wether to return the memory move just after end-game is checked or not
						check_overlapping,
						-- Info for prunes memory
						clear_hash,
						prune_L3, write_prune_L4,
						prune_mem_move_L1, prune_mem_move_L2, prune_mem_move_L3, prune_mem_move_L4,
						---- OUTPUTS ----
						-- Hash cleaning between games
						hash_cleared,
						-- Data to center the window while searching a move
						legal_moves_window_x, legal_moves_window_y,
						-- Vertex data for overlapping filter
						legal_move_vertex_x, legal_move_vertex_y, legal_move_vertex_type,
						-- Move finding results
						legal_move_found, legal_move_x, legal_move_y, legal_move_tile, legal_move_rotation, legal_move_not_found, no_legal_moves,
						-- Memory is ready to be written
						sort_ready_out,
						-- Overlapping restriction will be disabled if it is more restrictive than this value
						min_size_to_explore
			);
		clear_legal_moves_status <= reset_legal_moves_status OR close_level;	
	
		accessibility_map_I_hero: accessibility_map generic map(HERO, bits_level)			
			port map(---- INPUTS ----
						clk, hard_rst, timeout_reached, level,
						-- Info from board module to carry out vertex selection
						vertices_map_hero, vertices_type_map_hero,
						-- Info from board module to initialize map with forbidden_rival positions
						board_output,
						-- Info from board module to build the accessibility map
						tiles_available_hero,
						-- Create a new map
						create_map_hero, accessibility_map_work_mode,
						---- OUTPUTS ----						
						-- Accessibility output
						map_created_hero, accessibility_hero,
						-- Info for overlapping_maps module
						overlapping_map_hero
			);
		
		accessibility_map_I_rival: accessibility_map generic map(RIVAL, bits_level)
			port map(---- INPUTS ----
						clk, hard_rst, timeout_reached, level,
						-- Info from board module to carry out vertex selection
						vertices_map_rival, vertices_type_map_rival,
						-- Info from board module to initialize map with forbidden_rival positions
						board_output,
						-- Info from board module to build the accessibility map
						tiles_available_rival,
						-- Create a new map
						create_map_rival, accessibility_map_work_mode,
						---- OUTPUTS ----
						-- Accessibility output
						map_created_rival, accessibility_rival,
						-- Info for overlapping_maps module
						overlapping_map_rival
			);
		
		
		-- Inputs for overlapping from accessibility_maps
		load_overlapping_map	<= '1' when (accessibility_map_work_mode = OVERLAPPING_MODE AND map_created_rival = '1' AND level(0) = '0') OR
													(accessibility_map_work_mode = OVERLAPPING_MODE AND map_created_hero  = '1' AND level(0) = '1') else
										'0';		
		overlapping_map 		<= overlapping_map_rival when level(0) = '0' else overlapping_map_hero;		
		
		overlapping_I: overlapping generic map(5)
			port map(---- INPUTS ----
						clk, rst,
						-- Move to be checked
						tiles_placement_x_pos, tiles_placement_y_pos, tiles_placement_piece_valid,
						-- New overlapping map created
						load_overlapping_map,
						-- Overlapping map
						overlapping_map,
						-- Overlapping filter data
						legal_move_vertex_x, legal_move_vertex_y, legal_move_vertex_type,
						-- Info to set threshold
						move_count, level,
						-- Overlapping restriction will be disabled if it is more restrictive than this value
						min_size_to_explore,
						---- OUTPUTS ----						
						-- Overlapping is active
						check_overlapping,
						-- Overlapping set to 4 and no possible move overlapped enough
						skip_vertex, move_overlapped
			);
						
		evaluator_I: evaluator generic map(10)
			port map(---- INPUTS ----
						end_game_node,
						-- End-game nodes
						tiles_available_hero, tiles_available_rival,
						-- Non end-game nodes
						accessibility_hero, accessibility_rival,
						---- OUTPUTS ----
						score
			);
	
		-- Mux for move writtings
		move_writtings: process(move_count, move_source, 
								legal_move_x, legal_move_y, legal_move_tile, legal_move_rotation, 
								best_move)
		begin
			-- Blue's first move
			if move_count = 1 then
				tiles_placement_x 		 <= conv_std_logic_vector(5, 4);
                tiles_placement_y        <= conv_std_logic_vector(4, 4);
                tiles_placement_tile     <= tile_u;
                tiles_placement_rotation <= conv_std_logic_vector(0, 3);
			-- Green's first move
			elsif move_count = 2 then
                tiles_placement_x 		 <= conv_std_logic_vector(8, 4);
                tiles_placement_y 		 <= conv_std_logic_vector(9, 4);
                tiles_placement_tile 	 <= tile_u;
                tiles_placement_rotation <= conv_std_logic_vector(0, 3);
			elsif move_source = TREE_MOVE then
				tiles_placement_x		 <= legal_move_x;
				tiles_placement_y  		 <= legal_move_y;
				tiles_placement_tile	 <= legal_move_tile;
				tiles_placement_rotation <= legal_move_rotation;
			elsif move_source = CHOSEN_MOVE then
				tiles_placement_x		 <= best_move(15 downto 12);
				tiles_placement_y  		 <= best_move(11 downto 8);
				tiles_placement_tile	 <= best_move(7 downto 3);
				tiles_placement_rotation <= best_move(2 downto 0);			
			else
				tiles_placement_x		 <= (OTHERS=>'0');
				tiles_placement_y  		 <= (OTHERS=>'0');		
				tiles_placement_tile	 <= (OTHERS=>'0');
				tiles_placement_rotation <= (OTHERS=>'0');
			end if;
		end process;	
		
		control_signals: for i in 0 to max_level-1 generate
			expanded_node_ns(i)		<= '0' when (close_level = '1' OR clean_level = '1') AND level = i else 
												'1' when expanded_node = '1' AND level = i else
												expanded_node_cs(i);
			unset_overlapping_ns(i)	<= '0' when (close_level = '1' OR clean_level = '1') AND level = i else 
												'1' when unset_overlapping = '1' AND level = i else
												unset_overlapping_cs(i);												
		end generate;
		
		-- Tree manager FSM
        controlUnit: process(currentState, legal_moves_window_x, legal_moves_window_y, best_move, tiles_placement_tile,																	-- Defaults
                             new_move, move_count, check_overlapping, 														                                                            -- IDLE                             
                             level,																																						-- CREATE_OVERLAPPING_MAP
                             window_x_accessibility_hero, window_y_accessibility_hero, window_x_accessibility_rival, window_y_accessibility_rival, map_created_hero, map_created_rival, -- CREATE_OVERLAPPING_MAP_2
                             prune, prune_L3,																																			-- GENERATE_NODE
                             legal_move_found, unset_overlapping_cs, move_overlapped, legal_move_not_found, expanded_node_cs, current_max_level, no_legal_moves, skip_vertex,			-- GENERATE_NODE_2
                             accessibility_hero, accessibility_rival,																													-- EVALUATING_NODE
                             sort_ready_out																																				-- EVALUATE_NON_END_GAME_NODE
                             ) is
		begin
                -- Defaults			  
				-- Board
				write_board <= '0';			  
				-- Legal moves
				write_move <= '0';
				move_source <= TREE_MOVE;
				player <= level(0);	-- even levels -> hero; odd levels -> rival
				move_request <= '0';
				reset_legal_moves_status <= '0';
				window_x_hero  <= legal_moves_window_x;
				window_y_hero  <= legal_moves_window_y;
				window_x_rival <= legal_moves_window_x;
				window_y_rival <= legal_moves_window_y;
				check_end_game <= '0';
				-- Accesibility map
				create_map_rival <= '0';
				create_map_hero  <= '0';							
				accessibility_map_work_mode <= EVALUATION_MODE;
				-- IA Outputs
				pass_hero <= '0';			  
				moveFound <= '0';
				-- Evaluation selector ('0' for end game nodes)
				end_game_node <= '0';
				-- Best move output
				x_hero 			<= best_move(15 downto 12);
				y_hero 			<= best_move(11 downto 8);
				tile_hero		<= best_move(7 downto 3);
				rotation_hero	<= best_move(2 downto 0);				
				-- Boards memory manager
				store_board <= '0';
				load_real_board <= '0';
				-- Tiles available
				available_tiles_tile <= tiles_placement_tile;
				-- Flow Control
				new_level			<= '0';
				close_level 		<= '0';
				clean_level			<= '0';
				expanded_node		<= '0';
				unset_overlapping	<= '0';
				evaluating 			<= '0';
			
				-- Reordering
				sort_move <= '0';
				sort_rst_intramove <= '0';
				sort_rst_intermove <= '0';
			
				move_next_vertex_request <= '0';
				
				-- Prunes memory
				clear_hash <= '0';				
				write_prune_L4 <= '0';
				
			    swap_players <= '0';
			    rst_game <= '0';
			    game_over <= '0';
				
			  case currentState is
					when IDLE =>
						if new_move = '1' then
                            -- New game: clear hashes and return 65u0
                            if move_count = 0 then
                                clear_hash <= '1';
                                nextState <= CLEANING_HASH;
                            -- First Green's move: return 9au0
                            elsif move_count = 1 then
                                nextState <= DONE;
							elsif check_overlapping = '0' then								
								nextState <= GENERATE_NODE;
							else
								nextState <= CREATE_OVERLAPPING_MAP;								
							end if;					
						else
							nextState <= IDLE;
						end if;
					
					when CLEANING_HASH =>
						-- Only care about L4 (is the biggest one) 
						if hash_cleared = '1' then
							nextState <= DONE;
						else
							nextState <= CLEANING_HASH;
						end if;
					
					-----------------------------------------
					-------------- Overlapping --------------
					-----------------------------------------
					when CREATE_OVERLAPPING_MAP =>
						if level(0) = '0' then
							create_map_rival <= '1';
						else
							create_map_hero <= '1';
						end if;
						accessibility_map_work_mode <= OVERLAPPING_MODE;
						nextState <= CREATE_OVERLAPPING_MAP_2;
						
					
					-- 1) Initialize rival accessibility map with all his forbbiden squares, because we are also interested in placing there
					-- 2) Create accessibility map for the non-moving player
					when CREATE_OVERLAPPING_MAP_2 =>						
						accessibility_map_work_mode <= OVERLAPPING_MODE;
						
						-- Set the window center from accessibility module (actually only one is necessary, depending on the level)
						window_x_hero <= window_x_accessibility_hero;
						window_y_hero <= window_y_accessibility_hero;
						window_x_rival <= window_x_accessibility_rival;
						window_y_rival <= window_y_accessibility_rival;						
						
						if (level(0) = '0' AND map_created_rival = '1') OR (level(0) = '1' AND map_created_hero  = '1') then							
							nextState <= GENERATE_NODE;
						else
							nextState <= CREATE_OVERLAPPING_MAP_2;
						end if;						
										
					when GENERATE_NODE =>
						-- Prune
						if prune = '1' then
							-- Reset current level								
							close_level <= '1';
							-- Store movement in reordering memory
							if level = 1 then
								sort_move <= '1';
							end if;							
							if prune_L4 = '1' then
								write_prune_L4 <= '1';
							end if;
							-- Have to load the upper level board into the board register							
							nextState <= LOAD_BOARD_INTO_REG;
						-- New node
						else
							-- New move request
							move_request <= '1';
							nextState <= GENERATE_NODE_2;
						end if;
					
					-- Waits until a legal move is found or there are not legal moves anymore
					when GENERATE_NODE_2 =>						
						-- Check if the new legal move found has to be explored
						if legal_move_found = '1' AND unset_overlapping_cs(conv_integer(level)) = '0' AND check_overlapping = '1' then
							-- Fighting for a shared area: process legal move	
							if move_overlapped = '1' then
								-- Copy the current board to BRAM
								store_board <= '1';								
								-- Update board register with the new move
								write_move <= '1';							
								-- Mark the current level node as expanded
								expanded_node <= '1';
								new_level <= '1';
								-- Check first if terminal node due to max level reached because it is faster than checking whether it is end game or not
								if level+1 = current_max_level then									
									nextState <= EVALUATE_NODE;
								-- Not last level, check if end game node
								else
									-- Check first moves of the player who moves in the current level
									nextState <= CHECK_END_GAME_NODE;
								end if;
							-- Not an interesting area: discard the legal move and try to find another one
							else							
								-- Try to generate a new move
								nextState <= GENERATE_NODE;
							end if;
						-- 2 equivalent scenarios:
						--		* Overlapping_threshold is set to 0
						--		* Analysing the moves once again because the first time we found legal moves, but none of them were overlapped enough
						elsif legal_move_found = '1' then
							-- Copy the current board to BRAM
							store_board <= '1';								
							-- Update board register with the new move
							write_move <= '1';							
							-- Mark the current level node as expanded
							expanded_node <= '1';
							new_level <= '1';
							-- Check first if terminal node due to max level reached because it is faster than checking whether it is end game or not
							if level+1 = current_max_level then								
								nextState <= EVALUATE_NODE;
							-- Not last level, check if end game node
							else
								-- Check first moves of the player who moves in the current level
								nextState <= CHECK_END_GAME_NODE;
							end if;
						-- Node with legal moves but none of them are overlapped enough: unset overlapping checking and find legal moves again						
						elsif legal_move_not_found = '1' AND expanded_node_cs(conv_integer(level)) = '0' then
							unset_overlapping	<= '1';
							nextState <= GENERATE_NODE;
						-- All legal moves explored: close level
						elsif legal_move_not_found = '1' AND expanded_node_cs(conv_integer(level)) = '1' then
							-- Tree fully explored but max_level not reached
							if level = 0 AND current_max_level < depth then
								close_level <= '1';
								sort_rst_intramove <= '1';
								nextState <= GENERATE_NODE;	-- Accessibilty map for level 0 never changes, so go straight to GENERATE_NODE									
							-- Tree fully explored and max_level reach: End
							elsif level = 0 AND current_max_level = depth then
								--close_level <= '1';
								clean_level <= '1';
								nextState <= DONE;									
							-- One level up and try to generate a new node
							else									
								close_level <= '1';
								if level = 1 then
									sort_move <= '1';
								end if;								
								-- Have to load the upper level board into the board register								
								nextState <= LOAD_BOARD_INTO_REG;
							end if;
						-- Node without legal moves already explored: close level
						elsif no_legal_moves = '1' then
							-- Pass turn
							if conv_integer(level) = 0 then
								sort_rst_intermove <= '1';								
								nextState <= CHECK_GAME_OVER;
							else
								close_level <= '1';
								if level = 1 then
									sort_move <= '1';
								end if;								
								-- Have to load the upper level board into the board register							
								nextState <= LOAD_BOARD_INTO_REG;
							end if;
						-- Threshold set to 4 and current vertex with no 4-overlapped moves: jump to the next vertex
						elsif skip_vertex = '1' AND unset_overlapping_cs(conv_integer(level)) = '0' then
							move_next_vertex_request <= '1';
							nextState <= GENERATE_NODE_2;
						else
							nextState <= GENERATE_NODE_2;
						end if;						
					
					-- Request a move for the player who moves in the current level
					when CHECK_END_GAME_NODE =>
						check_end_game <= '1';
						nextState <= CHECK_END_GAME_NODE_2;						
						
					-- Checking moves of the player who moves in the current level
					when CHECK_END_GAME_NODE_2 =>
						-- Not end game nor last level: generate new node
						if legal_move_found = '1' then
							-- We must use this movement to generate a new node
							if check_overlapping = '0' then
								-- Copy the current board to BRAM
								store_board <= '1';								
								-- Update board register with the new move
								write_move <= '1';
								new_level <= '1';
								-- Mark the current level node as expanded
								expanded_node <= '1';
								-- Check first if terminal node due to max level reached because it is faster than checking whether it is end game or not
								if level+1 = current_max_level then
									-- Create accessibility maps to evaluate the non end-game node
									nextState <= EVALUATE_NODE;
								-- Not last level, check if end game node
								else
									-- Check first moves of the player who moves in the next level
									nextState <= CHECK_END_GAME_NODE;
								end if;								
							-- If overlapping_map is required, reset legal moves to find it again later after overlapping map is created
							else
								reset_legal_moves_status <= '1';
								nextState <= CREATE_OVERLAPPING_MAP;
							end if;
						-- Player of current level has no moves. Check now the legal moves for the other player
						elsif no_legal_moves = '1' then
--							node_without_moves_ns(conv_integer(level)) <= '1';	-- REVIEW THIS. THIS COULD SPEEDUP END-GAME SOLVING
							nextState <= CHECK_END_GAME_NODE_3;
						else
							nextState <= CHECK_END_GAME_NODE_2;
						end if;						
						
					-- Here we are looking for a legal move for the player who moves in the current level	
					when CHECK_END_GAME_NODE_3 =>
						player <= NOT(level(0));
						check_end_game <= '1';						
						nextState <= CHECK_END_GAME_NODE_4;						
					
					-- Player who moves in the current level has not legal moves. Checking now the other player
					when CHECK_END_GAME_NODE_4 =>
						player <= NOT(level(0));
						-- Not end game nor last level: generate new node
						if legal_move_found = '1' then
							reset_legal_moves_status <= '1';
							-- Not an end game node but the player who moves has not legal moves: save the board in BRAM
							store_board <= '1';
							new_level <= '1';
							-- Check first if terminal node due to max level reached
							if level+1 = current_max_level then
								-- Create accessibility maps to evaluate the non end-game node
								nextState <= EVALUATE_NODE;
							-- Try to create a new node
							else							
								nextState <= GENERATE_NODE;
							end if;
						-- End game node
						elsif no_legal_moves = '1' then							
							nextState <= EVALUATE_END_GAME_NODE;
						else
							nextState <= CHECK_END_GAME_NODE_4;
						end if;						
							
					-- Send order to create both Hero and Rival accessibility maps
					when EVALUATE_NODE =>
						create_map_hero <= '1';
						create_map_rival <= '1';
						nextState <= EVALUATING_NODE;						
					
					-- Creating accessibility maps
					when EVALUATING_NODE =>
						-- Set the window center from accessibility module
						window_x_hero <= window_x_accessibility_hero;
						window_y_hero <= window_y_accessibility_hero;
						window_x_rival <= window_x_accessibility_rival;
						window_y_rival <= window_y_accessibility_rival;
						-- Wait until both maps are created
						if map_created_hero = '1' AND map_created_rival = '1' then
							if accessibility_hero = 0 AND accessibility_rival = 0 then
								nextState <= EVALUATE_END_GAME_NODE;
							else
								nextState <= EVALUATE_NON_END_GAME_NODE;
							end if;
						elsif map_created_hero = '1' then
							nextState <= EVALUATING_NODE_WAITING_RIVAL;
						elsif map_created_rival = '1' then
							nextState <= EVALUATING_NODE_WAITING_HERO;
						else
							nextState <= EVALUATING_NODE;
						end if;
					
					when EVALUATING_NODE_WAITING_HERO =>
						-- Set the window center from accessibility module
						window_x_hero <= window_x_accessibility_hero;
						window_y_hero <= window_y_accessibility_hero;						
						-- Rival map is already created. Wait until hero map is also created
						if map_created_hero = '1' then
							if accessibility_hero = 0 AND accessibility_rival = 0 then
								nextState <= EVALUATE_END_GAME_NODE;
							else
								nextState <= EVALUATE_NON_END_GAME_NODE;
							end if;
						else
							nextState <= EVALUATING_NODE_WAITING_HERO;
						end if;
					
					when EVALUATING_NODE_WAITING_RIVAL =>
						-- Set the window center from accessibility module						
						window_x_rival <= window_x_accessibility_rival;
						window_y_rival <= window_y_accessibility_rival;
						-- Hero map is already created. Wait until rival map is also created
						if map_created_rival = '1' then
							if accessibility_hero = 0 AND accessibility_rival = 0 then
								nextState <= EVALUATE_END_GAME_NODE;
							else
								nextState <= EVALUATE_NON_END_GAME_NODE;
							end if;
						else
							nextState <= EVALUATING_NODE_WAITING_RIVAL;
						end if;					
					
					when EVALUATE_NON_END_GAME_NODE =>
						evaluating <= '1';
						if level = 2 AND sort_ready_out = '1' then
							sort_move <= '1';
							nextState <= WAIT_MEM_READY;							
						elsif level = 2 AND sort_ready_out = '0' then
							nextState <= EVALUATE_NON_END_GAME_NODE;
						else
							close_level <= '1';
							-- Have to load the upper level board into the board register
							nextState <= LOAD_BOARD_INTO_REG;
						end if;
					
					when WAIT_MEM_READY =>
						evaluating <= '1';
						if sort_ready_out = '1' then							
							close_level <= '1';
							-- Have to load the upper level board into the board register
							nextState <= LOAD_BOARD_INTO_REG;
						else
							nextState <= WAIT_MEM_READY;
						end if;			
					
					when EVALUATE_END_GAME_NODE =>
						end_game_node <= '1';						
                        evaluating <= '1';                    
                        if level <= 2 AND sort_ready_out = '1' then
                            sort_move <= '1';
                            nextState <= WAIT_MEM_READY_2;                            
                        elsif level <= 2 AND sort_ready_out = '0' then
                            nextState <= EVALUATE_END_GAME_NODE;
                        else
                            close_level <= '1';
                            -- Have to load the upper level board into the board register
                            nextState <= LOAD_BOARD_INTO_REG;
                        end if;
                    
                    when WAIT_MEM_READY_2 =>
                        evaluating <= '1';
                        end_game_node <= '1';
                        if sort_ready_out = '1' then                            
                            close_level <= '1';
                            -- Have to load the upper level board into the board register
                            nextState <= LOAD_BOARD_INTO_REG;
                        else
                            nextState <= WAIT_MEM_READY_2;
                        end if;
					
					when LOAD_BOARD_INTO_REG =>
						-- Write board from BRAM into board reg and restore current level tile
						write_board <= '1';
						nextState <= GENERATE_NODE;
					
					when DONE =>
						moveFound <= '1';						
						-- update the board of level 0
						write_move <= '1';
						player <= HERO;
						-- Blue's first move: 65u0
						if move_count = 1 then
						    x_hero        <= conv_std_logic_vector(5, 4);
						    y_hero        <= conv_std_logic_vector(4, 4);
						    tile_hero     <= tile_u;
						    rotation_hero <= conv_std_logic_vector(0, 3);
						-- Green's first move: 9au0
						elsif move_count = 2 then
                            x_hero        <= conv_std_logic_vector(8, 4);
                            y_hero        <= conv_std_logic_vector(9, 4);
                            tile_hero     <= tile_u;
                            rotation_hero <= conv_std_logic_vector(0, 3);
                        else
                            move_source <= CHOSEN_MOVE;
                        end if;
						-- Full reset reordering memory
						sort_rst_intermove <= '1';
						nextState <= SWAPPING_PLAYERS;
					
					-- Swap squares and tiles to change who the hero is
					when SWAPPING_PLAYERS =>
                        swap_players <= '1';
                        nextState <= IDLE;
				    
				    when CHECK_GAME_OVER =>                        
                        -- Check legal moves of the other player
                        player <= RIVAL;
                        check_end_game <= '1';
                        nextState <= CHECK_GAME_OVER_2;
                    
                    when CHECK_GAME_OVER_2 =>
                        player <= RIVAL;
                        -- Not end game: return pass
                        if legal_move_found = '1' then
                            pass_hero <= '1';
                            reset_legal_moves_status <= '1';                            
                            nextState <= SWAPPING_PLAYERS;
                        -- Game over
                        elsif no_legal_moves = '1' then                            
                            rst_game <= '1';
                            game_over <= '1';
                            nextState <= IDLE;
                        else
                            nextState <= CHECK_GAME_OVER_2;
                        end if;                        
			  end case;
		end process controlUnit;
		
		state: process (clk)
		begin			  
			if clk'EVENT and clk='1' then
				if rst = '1' then
					currentState <= IDLE;
				else
					currentState <= nextState;
				end if;
			end if;
		end process state;
		
		control: process (clk)
		begin			  
			if clk'EVENT and clk='1' then
				if hard_rst = '1' then
					expanded_node_cs <= (OTHERS=>'0');
					unset_overlapping_cs <= (OTHERS=>'0');
				else
					expanded_node_cs	 <= expanded_node_ns;	-- Necessary to control when a node has been expanded at least once. If not, and discarded flag is high, reexplore without checking overlapping
					unset_overlapping_cs <= unset_overlapping_ns;					
				end if;
			end if;
		end process control;
end AIArch;