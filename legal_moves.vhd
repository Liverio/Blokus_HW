library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use work.types.all;

entity legalMoves is
	generic (max_level  : positive := 10;
				bits_level : positive := 4);
    port (----------------
          ---- INPUTS ----
		  ----------------
		  clk 	: in  STD_LOGIC;
		  rst	    : in  STD_LOGIC;
		  timeout : in  STD_LOGIC;
		  -- Move request
		  move_request 	   : in STD_LOGIC;
		  level			   : in STD_LOGIC_VECTOR(bits_level-1 downto 0);
		  current_max_level : in STD_LOGIC_VECTOR(bits_level-1 downto 0);
          -- Find moves to check if the current board is end-game
		  check_end_game : in STD_LOGIC;
		  -- Current player vertices map
          vertices_map		: in tpVertices_map;
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
          -- Move number for prunes memory and for setting suggested min size to explore
          move_count	: in STD_LOGIC_VECTOR(6-1 downto 0);
          -- When checking end-game while reading best chain, this info is necessary to know whether to return the memory move just after end-game is checked or not
          check_overlapping : in STD_LOGIC;
          -- Info for prunes_memory
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
        window_x, window_y : out STD_LOGIC_VECTOR(4-1 downto 0);
        -- Vertex data for overlapping filter
        vertex_x, vertex_y : out STD_LOGIC_VECTOR(4-1 downto 0);
        vertex_type_out	 : out STD_LOGIC_VECTOR(2-1 downto 0);
        -- Move finding results
        move_found	  	: out STD_LOGIC;
        x, y 				: out STD_LOGIC_VECTOR(4-1 downto 0);
        tile 				: out STD_LOGIC_VECTOR(5-1 downto 0);
        rotation 		: out STD_LOGIC_VECTOR(3-1 downto 0);
        -- No more moves
        move_not_found	: out STD_LOGIC;
        -- Node without moves
        no_moves			: out STD_LOGIC;
        -- Memory is ready to be written
        sort_ready_out : out STD_LOGIC;
        -- Overlapping restriction will be disabled if it is more restrictive than this value
        min_size_to_explore : out STD_LOGIC_VECTOR(3-1 downto 0)
	);
end legalMoves;

architecture legalMovesArch of legalMoves is
	component status
		generic (max_level : positive := 8;
					bitsLevel : positive := 3);
		port (----------------
				---- INPUTS ----
				----------------
				clk	  : in STD_LOGIC;
				rst	  : in STD_LOGIC;
				timeout : in STD_LOGIC;
				level	  : in STD_LOGIC_VECTOR(bitsLevel-1 downto 0);
				-- Vertex
				update_vertex : in STD_LOGIC;
				vertex_in 	  : in STD_LOGIC_VECTOR(8-1 downto 0);	-- 13*13 = 169 vertices
				-- Move
				update_move : in STD_LOGIC;
				move_in		: in STD_LOGIC_VECTOR(7-1 downto 0);
				-- Resets the vertex and move in the current level
				clear : in STD_LOGIC;					
				-----------------
				---- OUTPUTS ----
				-----------------
				-- Vertex
				last_vertex	: out STD_LOGIC_VECTOR(8-1 downto 0);
				-- Move
				last_move_out : out STD_LOGIC_VECTOR(7-1 downto 0)
		);
	end component;
	
	-------------------------------------------------
	-------------- VERTICES MANAGAMENT --------------
	-------------------------------------------------
	component vertex_selector
		generic (direction : integer := 0);
		port (----------------
				---- INPUTS ----
				----------------
				last_vertex	: in STD_LOGIC_VECTOR(8-1 downto 0);	-- 7..row..4 3..col..0
				-- Current player vertices map
				vertices_map : in tpVertices_map;
				-----------------
				---- OUTPUTS ----
				-----------------
				next_vertex : out STD_LOGIC_VECTOR(8-1 downto 0);
				no_vertex	: out STD_LOGIC
		);
	end component;
	
	component window_center
		port (----------------
				---- INPUTS ----
				----------------
				vertex_type : in STD_LOGIC_VECTOR(2-1 downto 0);
				vertex_row	: in STD_LOGIC_VECTOR(4-1 downto 0);
				vertex_col	: in STD_LOGIC_VECTOR(4-1 downto 0);			
				-----------------
				---- OUTPUTS ----
				-----------------
				window_center_out : out STD_LOGIC_VECTOR(8-1 downto 0)
		);
	end component;
	
	-------------------------------------------------
	---------------- MOVE MANAGAMENT ----------------
	-------------------------------------------------
	component move_selector is
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
	end component;	
	
	component move_translator
		port (----------------
				---- INPUTS ----
				----------------
				clk 	  : in  STD_LOGIC;
				-- Move request
				read_move	  : in STD_LOGIC;
				move_num		  : in STD_LOGIC_VECTOR(7-1 downto 0);
				vertex_type	  : in STD_LOGIC_VECTOR(2-1 downto 0);
				window_center : in STD_LOGIC_VECTOR(8-1 downto 0);			
				-----------------
				---- OUTPUTS ----
				-----------------
				x, y 				: out STD_LOGIC_VECTOR(4-1 downto 0);
				tile 				: out STD_LOGIC_VECTOR(5-1 downto 0);
				rotation 		: out STD_LOGIC_VECTOR(3-1 downto 0)
		);
	end component;	

	component moves_memory
		generic (score_size	 : positive := 10;
					chain_size 	 : integer	:= 48; -- cadena de n movimientos ira entera a L1 y solo ira el segundo a L2
					mov_size 	 : integer	:= 16; -- tamaño de un movimiento
					bits_addr_L1 : positive := 9;
					bits_addr_L2 : positive := 8);
		port (----------------
				---- INPUTS ----
				----------------
				clk : IN  std_logic;
				rst : IN  std_logic; 
				rst_intramove: in std_logic;	-- rst_intramove se usa para resetear al cambiar de nivel de profundidad de busqueda. Coloca el contador de lecturas a 0 y resetea la memoria sobre la que se va a empezar a escribir
				write_new_data : in  STD_LOGIC;-- IMPORTANTE: se asume que cuando escribes estás en el mismo nivel. es decir escribes L1 cuando estás en nivel 1 y escribes en l2 cuando estás en el nivel 2. 
				read_new_data : in  STD_LOGIC; -- IMPORTANTE: se asume que cuando lees estás en el nivel superior. Es decir lees L1 desde L0 y lees L2 desde L1
				movement_in : in tp_array_movements; --cadena de movimientos. Si se escribe en L1 se escribe la cadena entera. Si se escribe en L2, solo el segundo movimiento movement_in(31 downto 16)
				score_in: in std_logic_vector(score_size-1 downto 0);
				moves2read_L1: IN  std_logic_vector(bits_addr_L1 downto 0); -- especifica cuantas entradas se quieren leer en L1
				moves2read_L2: IN  std_logic_vector(bits_addr_L2 downto 0); -- especifica cuantas entradas se quieren leer en L1
				level: in  std_logic_vector(4-1 downto 0); --current level
				impar : in  STD_LOGIC; --nos dice si el maximo nivel de exploración  es par o impar (así sabemos de qué memoria escribir y de cual leer			
				first_execution : in  STD_LOGIC; -- se debe poner a 1 durante la primera exploración de la busqueda iterativa para que se asignen los índices a las entradas de L1. En las siguientes iteraciones se mantienen los índices.
															-- tb es necesaria para que se escriba en L". Ya que en las exploraciones sucesicvas L2 ya sólo se puede leer
				-----------------
				---- OUTPUTS ----
				-----------------
				done: OUT std_logic; -- se pone a uno cuando se da la orden de la última lectura (puede ser por que no hay más o porque se ha llegado al nº de movimientos que se quería leer) Tb está a uno si no estamos ni en L1 ni en L2
				ready : OUT  std_logic; --el módulo ha terminado de gestionar la última escritura
				movement_out_L1 : out tp_array_movements;-- movimiento solicitado en L1 (cadena completa)
				movement_out_L2 : out std_logic_vector(mov_size-1 downto 0)-- movimiento solicitado en L2 (solo un movimiento)
		);
	end component;
	
	component prunes_L3_mem is
		port (----------------
				---- INPUTS ----
				----------------
				clk : in std_logic;
				rst : in std_logic;
				clear_hash : in STD_LOGIC;
				turn : in STD_LOGIC_VECTOR(6-1 downto 0);
				writepodaL3 : in STD_LOGIC;
				MovL1 		: in STD_LOGIC_VECTOR(16-1 downto 0);
				MovL2 		: in STD_LOGIC_VECTOR(16-1 downto 0);
				MovPoda_in 	: in STD_LOGIC_VECTOR(16-1 downto 0);			
				-----------------
				---- OUTPUTS ----
				-----------------
				hit_poda_L3 : out STD_LOGIC;
				MovPoda_out : out STD_LOGIC_VECTOR(16-1 downto 0)
		);
	end component;
	
	component prunes_L4_mem is
		generic (addr_bits : positive := 14);
		Port (----------------
				---- INPUTS ----
				----------------
				clk : in std_logic;
				rst : in std_logic;
				clear_hash: in STD_LOGIC;
				turn 			 : in  STD_LOGIC_VECTOR (5 downto 0);
				write_poda_L4 : in  STD_LOGIC;
				MovL1 			 : in  STD_LOGIC_VECTOR (15 downto 0);
				MovL2			 : in  STD_LOGIC_VECTOR (15 downto 0);
				MovL3			 : in  STD_LOGIC_VECTOR (15 downto 0);
				MovPoda_in	 : in  STD_LOGIC_VECTOR (15 downto 0);           
				-----------------
				---- OUTPUTS ----
				-----------------
				hash_cleared : out STD_LOGIC;
				hit_poda_L4 : out  STD_LOGIC;
	-- debug
--			  num_overwrites_L4 : out std_logic_vector(9 downto 0);
--			  num_writes_L4: out std_logic_vector(14 downto 0);
			  --end debug
				movPoda_out_L4 : out  STD_LOGIC_VECTOR (15 downto 0));
	end component;
	
	-- debug
	component contador is
		generic (
		size : integer := 10
	);
	Port ( clk : in  STD_LOGIC;
				  rst : in  STD_LOGIC;
				  ce : in  STD_LOGIC;
				  count : out  STD_LOGIC_VECTOR (size-1 downto 0));
	end component;
	-- debug
	
	-- Status
	signal update_vertex: STD_LOGIC;
	signal update_move: STD_LOGIC;
	signal clear_status, clear_int: STD_LOGIC;
	
	-- Vertex selector
	signal vertex, next_vertex, next_vertex_mapped: STD_LOGIC_VECTOR(8-1 downto 0);
	signal no_vertex: STD_LOGIC;
		
	-- Window center
	signal vertex_type: STD_LOGIC_VECTOR(2-1 downto 0);
	signal window_center_int: STD_LOGIC_VECTOR(8-1 downto 0);
	
	-- Move selector
	signal move, next_move_num: STD_LOGIC_VECTOR(7-1 downto 0);
	signal no_next_move: STD_LOGIC;

	-- Move translator
	signal read_move: STD_LOGIC;
	signal x_legal, y_legal: STD_LOGIC_VECTOR(4-1 downto 0);
	signal tile_legal: STD_LOGIC_VECTOR(5-1 downto 0);
	signal rotation_legal: STD_LOGIC_VECTOR(3-1 downto 0);	
	
	-- Moves memory
	signal rst_reordering_memory: STD_LOGIC;
	signal read_sorted_move: STD_LOGIC;
	signal sorted_move_addr: STD_LOGIC_VECTOR(10-1 downto 0);
	signal sorted_move: tp_array_movements;	
	signal sort_ready, sort_done: STD_LOGIC;
	signal x_sorted, y_sorted: STD_LOGIC_VECTOR(4-1 downto 0);
	signal tile_sorted: STD_LOGIC_VECTOR(5-1 downto 0);
	signal rotation_sorted: STD_LOGIC_VECTOR(3-1 downto 0);	
	signal generating_L2_data: STD_LOGIC;
	signal sorted_move_L2: STD_LOGIC_VECTOR(16-1 downto 0);
	
	-- Prunes L3 memory	
	signal prune_L3_move_found: STD_LOGIC;
	signal prune_L3_move: STD_LOGIC_VECTOR(16-1 downto 0);
	signal read_from_L3_prunes_memory: STD_LOGIC;
	signal reading_prunes_l3_memory_cs, reading_prunes_l3_memory_ns: STD_LOGIC;	 
	
	-- Prunes L4 memory
	signal prune_L4_move_found: STD_LOGIC;
	signal prune_L4_move: STD_LOGIC_VECTOR(16-1 downto 0);
	signal read_from_L4_prunes_memory: STD_LOGIC;
	signal reading_prunes_l4_memory_cs, reading_prunes_l4_memory_ns: STD_LOGIC;
	signal write_prune_L4_int: STD_LOGIC;
	
	-- Move generation FSM
	type state is (IDLE,
	               CHECK_END_GAME_VERTEX_SELECTION, CHECK_END_GAME_MOVE_SELECTION,          -- Checking end-game 
                   WAIT_UNTIL_MEMORY_IS_READY, MOVE_READ_FROM_MEMORY, NO_MORE_MOVES_MEMORY, -- Moves from reordering memory
                   MOVE_READ_FROM_PRUNE_MEMORY,												-- Moves from prunes memory
				   VERTEX_SELECTION, MOVE_SELECTION, MOVE_SELECTED);						-- Move finder
	signal currentState, nextState: state;
	signal first_request_cs, first_request_ns: STD_LOGIC;
	signal read_from_memory_L1: STD_LOGIC;
	signal read_from_memory_L2: STD_LOGIC;
	signal reading_best_chain_cs, reading_best_chain_ns: STD_LOGIC;
	signal reading_l2_memory_cs, reading_l2_memory_ns: STD_LOGIC;
	signal inhibit_hash: STD_LOGIC;	
	
	-- Suggested minimum tile size to explore
	signal size_suggested : STD_LOGIC_VECTOR(3-1 downto 0);	
	
	-- DEBUG
	signal debug_sorted_move_lvl0_x, debug_sorted_move_lvl0_y: STD_LOGIC_VECTOR(4-1 downto 0);
	signal debug_sorted_move_lvl0_tile: STD_LOGIC_VECTOR(5-1 downto 0);
	signal debug_sorted_move_lvl0_rotation: STD_LOGIC_VECTOR(3-1 downto 0);
	signal debug_sorted_move_lvl1_x, debug_sorted_move_lvl1_y: STD_LOGIC_VECTOR(4-1 downto 0);
	signal debug_sorted_move_lvl1_tile: STD_LOGIC_VECTOR(5-1 downto 0);
	signal debug_sorted_move_lvl1_rotation: STD_LOGIC_VECTOR(3-1 downto 0);
	signal debug_sorted_move_lvl2_x, debug_sorted_move_lvl2_y: STD_LOGIC_VECTOR(4-1 downto 0);
	signal debug_sorted_move_lvl2_tile: STD_LOGIC_VECTOR(5-1 downto 0);
	signal debug_sorted_move_lvl2_rotation: STD_LOGIC_VECTOR(3-1 downto 0);
	
	signal debug_num_reads_l3:STD_LOGIC_VECTOR(20-1 downto 0); 
	signal debug_inc_l3: STD_LOGIC;
begin
--	debug_counter: contador generic map (20)
--		port map (clk => clk, rst => rst, ce =>  debug_inc_l3, count => debug_num_reads_l3);
--	debug_inc_l3 <= '1' when currentState = MOVE_READ_FROM_PRUNE_MEMORY else '0';
	
	
	
	
	
	
	--------------------------------------------------
	-------------- STATUS OF EACH LEVEL --------------
	--------------------------------------------------	
	status_I: status generic map(max_level, bits_level)
		port map(---- INPUTS ----
					clk	  => clk,
					rst	  => rst,
					timeout => timeout,
					level	  => level,
					-- Vertex
					update_vertex => update_vertex,
					vertex_in	  => next_vertex,
					-- Move
					update_move	=> update_move,
					move_in 		=> next_move_num,
					-- Resets all the info in the current level
					clear => clear_status,
					-----------------
					---- OUTPUTS ----
					-----------------
					-- Vertex
					last_vertex => vertex,
					-- Move
					last_move_out => move);	
	
	clear_status <= clear_int OR clear;
	
	
	-------------------------------------------------
	-------------- VERTICES MANAGAMENT --------------
	-------------------------------------------------
	vertex_selector_I: vertex_selector generic map(0)
			port map(---- INPUTS ----
						last_vertex	 => vertex,
						vertices_map => vertices_map,
						---- OUTPUTS ----
						next_vertex => next_vertex,
						no_vertex	=> no_vertex
			);
	
	-- Need to know vertex type to center the processing window and to choose the proper moveChecker output
	vertex_type <= vertices_type_map(conv_integer(vertex(7 downto 4)), conv_integer(vertex(3 downto 0))) when vertex(3 downto 0) < 13 else "00";
	
	window_center_I: window_center
		port map(---- INPUTS ----
					vertex_type	=> vertex_type,
					vertex_row 	=> vertex(7 downto 4),
					vertex_col 	=> vertex(3 downto 0),
					---- OUTPUTS ----
					window_center_out => window_center_int);
					
	-- Outputs to retrive data from Blokus/AI/board
	window_x <= window_center_int(7 downto 4);
	window_y <= window_center_int(3 downto 0);
	
	-- Output for overlapping filter
	vertex_y			 <= vertex(7 downto 4);
	vertex_x			 <= vertex(3 downto 0);
	vertex_type_out <= vertex_type;

 
	-------------------------------------------------
	---------------- MOVE MANAGAMENT ----------------
	-------------------------------------------------
	-- Suggested minimum tile size to explore
	size_suggested <= conv_std_logic_vector(5, 3) when conv_integer(move_count) + conv_integer(level(3 downto 1)) <= 4 else
						   conv_std_logic_vector(4, 3) when conv_integer(move_count) + conv_integer(level(3 downto 1)) <= 7 else
						   conv_std_logic_vector(1, 3);	
	
	move_selector_I: move_selector
		port map(---- INPUTS ----
					-- Data to decide the next move
					window, vertex_type, move, tiles_available,
					-- Size filter
					size_suggested,
					---- OUTPUTS ----
					-- Move pos in the moves vector to be stored in status
					next_move_num, no_next_move,
					-- Overlapping restriction will be disabled if it is more restrictive than this value
					min_size_to_explore);
					
									
	move_translator_I: move_translator
		port map(---- INPUTS ----
					clk,
					-- Move request
					read_move, next_move_num, vertex_type, window_center_int,
					---- OUTPUTS ----
					x_legal, y_legal, tile_legal, rotation_legal);
	
	rst_reordering_memory <= rst OR sort_rst_intermove;
	generating_L2_data <= '1' when current_max_level = 2 else '0';
	moves_memory_I: moves_memory			
		generic map(10, 16*last_level_sorted, 16, 9, 7)
		port map(---- INPUTS ----
					clk => clk,
					rst => rst_reordering_memory,
					rst_intramove => sort_rst_intramove,
					impar => current_max_level(0),
					level => level,
					-- Write and order movement
					write_new_data => sort_move,
					movement_in		=> move_to_sort,
					score_in			=> score_to_sort,
					-- Read ordered movement
					read_new_data => read_sorted_move,					
					moves2read_L1 => "1000000000",
					moves2read_L2 => "10000000",
					-- Generating L2 data					
					first_execution => generating_L2_data,
					---- OUTPUTS ----
					done	=> sort_done,
					ready => sort_ready,
					movement_out_L1 => sorted_move,
					movement_out_L2 => sorted_move_L2);	
	
	prunes_L3_mem_I: prunes_L3_mem
		port map(---- INPUTS ----
					clk, rst,
					clear_hash,
					move_count,
					write_prune_L3, prune_mem_move_L1, prune_mem_move_L2, prune_mem_move_L3,
					---- OUTPUTS ----
					prune_L3_move_found, prune_L3_move);	
	
	write_prune_L4_int <= write_prune_L4 AND reading_prunes_l4_memory_cs;
	
	prunes_L4_mem_I: prunes_L4_mem generic map(12)
		port map(---- INPUTS ----
					clk, rst,
					clear_hash,
					move_count,
					write_prune_L4_int, prune_mem_move_L1, prune_mem_move_L2, prune_mem_move_L3, prune_mem_move_L4,
					---- OUTPUTS ----
					hash_cleared,
					prune_L4_move_found, prune_L4_move);
	
	x_sorted 		 <= sorted_move(conv_integer(level))(15 downto 12) when level < last_level_sorted else (OTHERS=>'0');
	y_sorted 		 <= sorted_move(conv_integer(level))(11 downto  8) when level < last_level_sorted else (OTHERS=>'0');
	tile_sorted		 <= sorted_move(conv_integer(level))( 7 downto  3) when level < last_level_sorted else (OTHERS=>'0');
	rotation_sorted  <= sorted_move(conv_integer(level))( 2 downto  0) when level < last_level_sorted else (OTHERS=>'0');
	
-- DEBUG
--read_from_memory_L1 <= '0';
	read_from_memory_L1 <= '1' when current_max_level > 2 AND level = 0 else '0';
--read_from_memory_L2 <= '0';
	read_from_memory_L2 <= '1' when level = 1 AND current_max_level > 2 AND reading_best_chain_cs = '0' AND reading_l2_memory_cs = '1' else '0';
--read_from_L3_prunes_memory <= '0';	
	read_from_L3_prunes_memory <= '1' when current_max_level > 3 AND level = 2 AND prune_L3_move_found = '1' AND reading_prunes_l3_memory_cs = '1' else '0';
read_from_L4_prunes_memory <= '0';	
	--read_from_L4_prunes_memory <= '1' when current_max_level > 4 AND level = 3 AND prune_L4_move_found = '1' AND reading_prunes_l4_memory_cs = '1' else '0';
	
	
	-- Move generation FSM
	move_generator_FSM: process(currentState, first_request_cs, reading_best_chain_cs, reading_l2_memory_cs, x_legal, y_legal, tile_legal, rotation_legal,			-- DEFAULT
										 move_request,	read_from_memory_L1, read_from_memory_L2, read_from_L3_prunes_memory, check_end_game, sort_ready, sort_done, vertex, -- IDLE
										 x_sorted, y_sorted, tile_sorted, rotation_sorted,	level, current_max_level,																			-- MOVE_READ_FROM_MEMORY
										 no_vertex,																																									-- VERTEX_SELECTION
										 no_next_move, skip_vertex, check_overlapping,
										 sorted_move_L2, prune_L3_move, reading_prunes_l3_memory_cs, reading_prunes_l4_memory_cs)																													-- MOVE_SELECTION
	begin		
		nextState <= currentState;
		move_found <= '0';
		move_not_found <= '0';
		no_moves <= '0';
		update_vertex <= '0';
		update_move <= '0';		
		first_request_ns <= first_request_cs;
		clear_int <= '0';
		read_move <= '0';
		-- Moves memory
		read_sorted_move <= '0';
		reading_best_chain_ns <= reading_best_chain_cs;
		reading_l2_memory_ns <= reading_l2_memory_cs;
		reading_prunes_l3_memory_ns <= reading_prunes_l3_memory_cs;
		reading_prunes_l4_memory_ns <= reading_prunes_l4_memory_cs;
		-- Move returned
		x 			<= x_legal;
		y 			<= y_legal;
		tile 		<= tile_legal;
		rotation <= rotation_legal;		
		
		case currentState is
            when IDLE =>
				-- New move request
				if move_request = '1' then
					-- REORDERING MEMORY
					if read_from_memory_L1 = '1' then
						reading_best_chain_ns <= '1';
						reading_l2_memory_ns <= '1';
						if sort_ready = '0' then
							nextState <= WAIT_UNTIL_MEMORY_IS_READY;
						else
							-- Read next move
							if sort_done = '0' then
								read_sorted_move <= '1';
								nextState <= MOVE_READ_FROM_MEMORY;
							-- No more moves
							else
								nextState <= NO_MORE_MOVES_MEMORY;
							end if;							
						end if;
					elsif reading_best_chain_cs = '1' then
						reading_prunes_l3_memory_ns <= '1';
						reading_prunes_l4_memory_ns <= '1';
						nextState <= MOVE_READ_FROM_MEMORY;
					elsif read_from_memory_L2 = '1' then						
						-- Read next move
						if sort_done = '0' then
							read_sorted_move <= '1';
							nextState <= MOVE_READ_FROM_MEMORY;
						-- No more moves
						else
							nextState <= NO_MORE_MOVES_MEMORY;
						end if;
						reading_prunes_l3_memory_ns <= '1';
						reading_prunes_l4_memory_ns <= '1';
					elsif read_from_L3_prunes_memory = '1' then
						nextState <= MOVE_READ_FROM_PRUNE_MEMORY;
					elsif read_from_L4_prunes_memory = '1' then
						nextState <= MOVE_READ_FROM_PRUNE_MEMORY;
					-- MOVE FINDER
					else
						-- New board: look for the first vertex
						if vertex(3 downto 1) = "111" then
							first_request_ns <= '1';
							nextState <= VERTEX_SELECTION;
						else
							first_request_ns <= '0';
							-- Try with next vertex (if exists)
							if no_next_move = '1' then
								nextState <= VERTEX_SELECTION;
							-- Move found: read from translation memory
							else
								-- Read move translation
								read_move <= '1';
								-- Store move
								update_move <= '1';				
								nextState <= MOVE_SELECTED;
							end if;
						end if;
					end if;
				elsif check_end_game = '1' then
					nextState <= CHECK_END_GAME_VERTEX_SELECTION;
				else
					nextState <= IDLE;
				end if;
				
			---------------------------
			---- CHECKING END-GAME ----
			---------------------------	
            when CHECK_END_GAME_VERTEX_SELECTION =>				
                if no_vertex = '1' then
                    no_moves <= '1';             
                    reading_best_chain_ns <= '0';
                    if level = 1 then
                        reading_l2_memory_ns <= '0';
                    end if;
                    if level <= 2 then
                        reading_prunes_l3_memory_ns <= '0';
                    end if;
                    if level <= 3 then
                        reading_prunes_l4_memory_ns <= '0';
                    end if;
                    clear_int <= '1';
                    nextState <= IDLE;
                else
                    -- Store vertex
                    update_vertex <= '1';
                    nextState <= CHECK_END_GAME_MOVE_SELECTION;
                end if;

            when CHECK_END_GAME_MOVE_SELECTION =>	
                -- Try with next vertex (if exists)
                if no_next_move = '1' then
                    nextState <= CHECK_END_GAME_VERTEX_SELECTION;
                -- Move found: read from translation memory if we are using it, if reading best chain, return the corresponding move 
                else
                    -- Checking end-game while some memory can return a movement
                    if reading_best_chain_cs = '1' OR read_from_memory_L2 = '1' OR read_from_L3_prunes_memory = '1' then
                        -- We have used move finder but we return a move stored in memory, so reset the move finder status to find it again later
                        clear_int <= '1';
                        -- Return move from memory
                        if check_overlapping = '0' then
                            if reading_best_chain_cs = '1' OR read_from_memory_L2 = '1' then
                                reading_prunes_l3_memory_ns <= '1';
                                reading_prunes_l4_memory_ns <= '1';
                                nextState <= MOVE_READ_FROM_MEMORY;
                            else
                                nextState <= MOVE_READ_FROM_PRUNE_MEMORY;
                            end if;
                        -- Just notify this is not an end-game node. Overlapping map will be created before requesting again this move
                        else                
                            move_found <= '1';
                            nextState <= IDLE;
                        end if;
                    else
                        -- Read move translation
                        read_move <= '1';
                        -- Store move
                        update_move <= '1';				
                        nextState <= MOVE_SELECTED;
                    end if;
                end if;
			
			------------------------------
            ---- GET MOVE FROM MEMORY ----
            ------------------------------
			when WAIT_UNTIL_MEMORY_IS_READY =>
				-- Read next move
				if sort_ready = '1' then
					-- Read next move
					if sort_done = '0' then
						read_sorted_move <= '1';
						nextState <= MOVE_READ_FROM_MEMORY;
					-- No more moves
					else
						nextState <= NO_MORE_MOVES_MEMORY;
					end if;
				-- Wait...
				else
					nextState <= WAIT_UNTIL_MEMORY_IS_READY;
				end if;				
			
			when MOVE_READ_FROM_MEMORY =>
				move_found <= '1';
				if reading_best_chain_cs = '0' AND level = 1 then
					x 			<= sorted_move_L2(15 downto 12);
					y 			<= sorted_move_L2(11 downto  8);
					tile 		<= sorted_move_L2( 7 downto  3);
					rotation <= sorted_move_L2( 2 downto  0);
				else
					x 			<= x_sorted;
					y 			<= y_sorted;
					tile 		<= tile_sorted;
					rotation <= rotation_sorted;
				end if;
				-- 1) Still no info about level 3 or 4: next move must be use move finder
				-- 2) Best of level 4 generated: chain created
				if (level = 1 AND current_max_level = 3) OR 
                   (level = 2 AND current_max_level = 4) OR 
				   (level = 3) then
					reading_best_chain_ns <= '0';
				end if;
				nextState <= IDLE;
			
			when NO_MORE_MOVES_MEMORY =>
				reading_best_chain_ns <= '0';
				move_not_found <= '1';
				nextState <= IDLE;
			
			when MOVE_READ_FROM_PRUNE_MEMORY =>
				inhibit_hash <= '1';
				move_found <= '1';
				if level = 2 then
					x 			<= prune_L3_move(15 downto 12);
					y 			<= prune_L3_move(11 downto  8);
					tile 		<= prune_L3_move( 7 downto  3);
					rotation <= prune_L3_move( 2 downto  0);
					reading_prunes_l3_memory_ns <= '0';
				else
					x 			<= prune_L4_move(15 downto 12);
					y 			<= prune_L4_move(11 downto  8);
					tile 		<= prune_L4_move( 7 downto  3);
					rotation <= prune_L4_move( 2 downto  0);
					reading_prunes_l4_memory_ns <= '0';					
				end if;
				nextState <= IDLE;
				
			-----------------------------------
            ---- GET MOVE FROM MOVE FINDER ----
            -----------------------------------
			when VERTEX_SELECTION =>				
				if no_vertex = '1' then
					if first_request_cs = '0' then						
						move_not_found <= '1';
					else
						no_moves <= '1';						
					end if;
					clear_int <= '1';
					nextState <= IDLE;
				else
					-- Store vertex
					update_vertex <= '1';
					nextState <= MOVE_SELECTION;
				end if;
			
			when MOVE_SELECTION =>	
				-- Try with next vertex (if exists)
				if no_next_move = '1' then
					nextState <= VERTEX_SELECTION;
				elsif skip_vertex = '1' then
					first_request_ns <= '0';
					nextState <= VERTEX_SELECTION;
				-- Move found: read from translation memory if we are using it, if reading best chain, return the corresponding move 
				else					
                    -- Read move translation
					read_move <= '1';
					-- Store move
					update_move <= '1';				
					nextState <= MOVE_SELECTED;
				end if;
				
			when MOVE_SELECTED =>				
				move_found <= '1';
				nextState <= IDLE;
		end case;
	end process move_generator_FSM;
	

	states: process(clk)
	begin			  
		if clk'event AND clk = '1' then
			if rst = '1' OR timeout = '1' then
				currentState <= IDLE;				
				first_request_cs <= '0';
				reading_best_chain_cs <= '0';
				reading_l2_memory_cs <= '0';
				reading_prunes_l3_memory_cs <= '0';
				reading_prunes_l4_memory_cs <= '0';
			else
				currentState <= nextState;				
				first_request_cs <= first_request_ns;
-- DEBUG SW
--reading_best_chain_cs <= '0';
				reading_best_chain_cs <= reading_best_chain_ns;
				reading_l2_memory_cs <= reading_l2_memory_ns;
				reading_prunes_l3_memory_cs <= reading_prunes_l3_memory_ns;
				reading_prunes_l4_memory_cs <= reading_prunes_l4_memory_ns;
			end if;
		end if;
	end process;
	
	sort_ready_out <= sort_ready;
	
	-- DEBUG
	debug_sorted_move_lvl0_x <= sorted_move(0)(15 downto 12);
	debug_sorted_move_lvl0_y <= sorted_move(0)(11 downto 8);
	debug_sorted_move_lvl0_tile <= sorted_move(0)(7 downto 3);
	debug_sorted_move_lvl0_rotation <= sorted_move(0)(2 downto 0);
	debug_sorted_move_lvl1_x <= sorted_move(1)(15 downto 12);
	debug_sorted_move_lvl1_y <= sorted_move(1)(11 downto 8);
	debug_sorted_move_lvl1_tile <= sorted_move(1)(7 downto 3);
	debug_sorted_move_lvl1_rotation <= sorted_move(1)(2 downto 0);
	debug_sorted_move_lvl2_x <= sorted_move(2)(15 downto 12);
	debug_sorted_move_lvl2_y <= sorted_move(2)(11 downto 8);
	debug_sorted_move_lvl2_tile <= sorted_move(2)(7 downto 3);
	debug_sorted_move_lvl2_rotation <= sorted_move(2)(2 downto 0);
	
--	process (clk)
--	begin			  
--		if clk'EVENT and clk='1' then
--			if rst = '1' OR (close_level = '1' AND level = 0 AND current_max_level < max_level) then
--				debug_moves_ordenados_leidos <= (OTHERS=>'0');
--			elsif read_sorted_move = '1' then
--				debug_moves_ordenados_leidos <= debug_moves_ordenados_leidos + 1;
--			else
--				debug_moves_ordenados_leidos <= debug_moves_ordenados_leidos;				
--			end if;
--		end if;
--	end process;
end legalMovesArch;