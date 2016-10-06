library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.types.ALL;

entity overlapping is
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
end overlapping;

architecture overlappingArch of overlapping is
	component overlapping_maps
		generic (max_level  : positive := 5;
					bits_level : positive := 4);
		port (----------------
				---- INPUTS ----
				----------------			
				clk, rst	: in STD_LOGIC;
				level	  	: in STD_LOGIC_VECTOR(bits_level-1 downto 0);
				-- New overlapping map created
				load_map : in STD_LOGIC;
				-- New map to be stored where level indicates
				map_in : in tpAccessibility_map;
				-----------------
				---- OUTPUTS ----
				-----------------
				-- Current level map
				map_out : out tpAccessibility_map
		);
	end component;
	
	component overlapping_filter
		port (----------------
				---- INPUTS ----
				----------------
				accessibility_map : in tpAccessibility_map;
				vertex_x 			: in STD_LOGIC_VECTOR(4-1 downto 0);
				vertex_y 			: in STD_LOGIC_VECTOR(4-1 downto 0);
				vertex_type 		: in STD_LOGIC_VECTOR(2-1 downto 0);
				threshold			: in STD_LOGIC_VECTOR(3-1 downto 0);
				-----------------
				---- OUTPUTS ----
				-----------------
				skip_vertex	: out STD_LOGIC
		);
	end component;
		
	-- Overlapping maps
	signal current_overlapping_map: tpAccessibility_map;
	
	-- Overlapping detection
	signal valid_tile_x_pos, valid_tile_y_pos: tpPiecesPositions;
	signal overlap: STD_LOGIC_VECTOR(5-1 downto 0);
	-- Threshold
	signal threshold, threshold_suggested, overlapping: STD_LOGIC_VECTOR(3-1 downto 0);
begin
	overlapping_maps_I: overlapping_maps generic map(5, bits_level)
		port map(---- INPUTS ----			
					clk, rst,
					level,
					-- New overlapping map created
					load_map,
					-- New map to be stored where level indicates
					overlapping_map,
					---- OUTPUTS ----
					-- Current level map
					current_overlapping_map);
	
	-- Set threshold
	process(move_count, level)
	begin
		if	  conv_integer(move_count) + conv_integer(level(3 downto 1)) <= 4 then
			threshold_suggested <= conv_std_logic_vector(4, 3);
		elsif conv_integer(move_count) + conv_integer(level(3 downto 1)) <= 7 then
			threshold_suggested <= conv_std_logic_vector(3, 3);	
		elsif conv_integer(move_count) + conv_integer(level(3 downto 1)) <= 10 then
			threshold_suggested <= conv_std_logic_vector(1, 3);	
		else
			threshold_suggested <= conv_std_logic_vector(0, 3);
		end if;
	end process;
	
	-- Apply suggested threshold while it is less restrictive than the actual min_size available for the vertex under exploration, otherwise disable it
--  threshold <= threshold_suggested when threshold_suggested <= min_size_to_explore else conv_std_logic_vector(1, 3);
	-- DEBUG SW
	threshold <= threshold_suggested;
--	threshold <= conv_std_logic_vector(0, 3);
	
	overlapping_filter_I: overlapping_filter
		port map(---- INPUTS ----
				 current_overlapping_map, vertex_x, vertex_y, vertex_type, threshold,
				 ---- OUTPUTS ----
				 skip_vertex
		);
		
	-- Overlapping checking
	checkers: for i in 0 to 5-1 generate
		valid_tile_x_pos(i) <= tile_x_pos(i) when tile_x_pos(i) <= 13 else "0000";
		valid_tile_y_pos(i) <= tile_y_pos(i) when tile_y_pos(i) <= 13 else "0000";
		overlap(i) <= tile_pos_valid(i) AND current_overlapping_map(conv_integer(valid_tile_y_pos(i)), conv_integer(valid_tile_x_pos(i)));
	end generate checkers;
	
	-- Sum
	overlapping <= conv_std_logic_vector(overlap(0), 3) + 
						conv_std_logic_vector(overlap(1), 3) +
						conv_std_logic_vector(overlap(2), 3) +
						conv_std_logic_vector(overlap(3), 3) +
						conv_std_logic_vector(overlap(4), 3);
	-- OUTPUT
	check_overlapping <= '1' when threshold /= 0 AND level <= max_level else '0';
	move_overlapped <= '1' when overlapping >= threshold else '0';
end overlappingArch;