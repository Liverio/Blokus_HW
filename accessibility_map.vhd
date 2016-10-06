library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.types.ALL;

entity accessibility_map is
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
			map_created 		  : out STD_LOGIC;				
			accessibility_count : out STD_LOGIC_VECTOR(7-1 downto 0);
			overlapping_map_out : out tpAccessibility_map
	);
end accessibility_map;

architecture accessibility_mapArch of accessibility_map is
	component evaluation_unit
		generic (player	  : tpPlayer := HERO;
					bits_level : positive := 4;
					unit_num   : integer  := 0);
		port (----------------
				---- INPUTS ----
				----------------			
				clk, rst	: in STD_LOGIC;
				timeout	: in STD_LOGIC;
				level	  	: in STD_LOGIC_VECTOR(bits_level-1 downto 0);
				-- Info from board module to carry out vertex selection
				vertices_map 		: in tpVertices_map;
				vertices_type_map	: in tpVertices_type_map;
				-- Info from board module to initialize map with forbidden_rival positions
				board : in tpBoard;			
				tiles_available : in STD_LOGIC_VECTOR(21-1 downto 0);
				-- Map loads
				create_map : in STD_LOGIC;
				update_map : in STD_LOGIC;
				-- Forbiddens map
				mark_forbiddens : in STD_LOGIC;
				forbiddens_map	 : in tpAccessibility_map;
				-----------------
				---- OUTPUTS ----
				-----------------					
				-- Current vertex
				x, y : out STD_LOGIC_VECTOR(4-1 downto 0);
				no_vertex : out STD_LOGIC;			
				-- Map
				accessibility_map : out tpAccessibility_map
		);
	end component;		
	
	component treeCounter
		port (input:  in  tpAccessibility_map;
			   output: out STD_LOGIC_VECTOR(7-1 downto 0));
	end component;
		
	-- Joined accessibility map
	signal accessibility_map_int: tpAccessibility_map;
	
	-- Evaluation units
	signal x_1, y_1, x_2, y_2: STD_LOGIC_VECTOR(4-1 downto 0);
	signal no_vertex_1, no_vertex_2: STD_LOGIC;	
	signal map_1, map_2: tpAccessibility_map;
	
	-- Overlapping map	
	signal forbiddens_map: tpAccessibility_map;
	
	-- Accessibility FSM
	signal mark_forbiddens, update_map: STD_LOGIC;
	signal no_vertex: STD_LOGIC;
	type state is (IDLE, INIT_WITH_FORBIDDENS, UPDATING_MAP);
	signal currentState, nextState : state;
begin	
		evaluation_unit_1: evaluation_unit generic map(player, bits_level, 0)
			port map(---- INPUTS ----			
						clk, rst, timeout,
						level,
						-- Info from board module to carry out vertex selection
						vertices_map, vertices_type_map,
						-- Info from board module to initialize map with forbidden_rival positions
						board, tiles_available,
						-- Map loads
						create_map,
						update_map,
						-- Forbiddens map
						mark_forbiddens,
						forbiddens_map,
						---- OUTPUTS ----
						-- Current vertex
						x_1, y_1,
						no_vertex_1,
						-- Map
						map_1);
		
		-- Count
		accessibilityCounter: treeCounter
				port map(---- INPUTS ----
							accessibility_map_int,
							---- OUTPUTS ----
							accessibility_count);
			
		no_vertex <= '1' when no_vertex_1 = '1' else
						 '0';
			
		-------------------------
		---- OVERLAPPING MAP ----
		-------------------------
		------- Accessibility map new input while updating with forbidden positions -------
		-- Forbidden_rival coded as 01, and forbidden_hero as 10, so...
		forbiddens_y: for i in 0 to 14-1 generate
			forbiddens_x: for j in 0 to 14-1 generate
				forbiddens_map(i,j) <= '1' when (level(0) = '0' AND board(i)(j) = "01") OR 
														  (level(0) = '1' AND board(i)(j) = "10") else 
											  '0';
			end generate;
		end generate;
		
		
		-- Accessibility map building FSM
		accessibility_map_FSM: process(currentState,				-- DEFAULT
												 create_map, work_mode,	-- IDLE
												 no_vertex)					-- MAP_UPDATE
		begin
			mark_forbiddens <= '0';
			map_created <= '0';
			update_map <= '0';
			
			case currentState is
				when IDLE =>
					-- New map request
					if create_map = '1' then						
						if work_mode = OVERLAPPING_MODE then
							nextState <= INIT_WITH_FORBIDDENS;
						else
							nextState <= UPDATING_MAP;
						end if;
					else
						nextState <= IDLE;
					end if;				
				
				when INIT_WITH_FORBIDDENS =>				
					mark_forbiddens <= '1';
					nextState <= UPDATING_MAP;
				
				when UPDATING_MAP =>
					if no_vertex = '1' then						
						map_created <= '1';
						nextState <= IDLE;
					else
						update_map <= '1';
						nextState <= UPDATING_MAP;
					end if;
			end case;
		end process accessibility_map_FSM;
		

		states: process(clk)
		begin			  
			if clk'event AND clk = '1' then
				if rst = '1' OR timeout = '1' then
					currentState <= IDLE;
				else
					currentState <= nextState;
				end if;
			end if;
		end process;

		-- OUTPUTS
		new_input_y: for i in 0 to 14-1 generate
			new_input_x: for j in 0 to 14-1 generate
				accessibility_map_int(i,j) <= map_1(i,j);
			end generate;
		end generate;
		
	overlapping_map_out <= accessibility_map_int;
end accessibility_mapArch;