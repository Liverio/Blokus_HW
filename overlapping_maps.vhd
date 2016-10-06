library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.types.ALL;

entity overlapping_maps is
	generic (max_level  : positive := 8;
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
end overlapping_maps;

architecture overlapping_mapsArch of overlapping_maps is	
	component overlapping_map_reg
		port (----------------
				---- INPUTS ----
				----------------
				clk, rst : in STD_LOGIC;
				ld	    : in STD_LOGIC;
				map_in : in tpAccessibility_map;
				-----------------
				---- OUTPUTS ----
				-----------------
				map_out : out tpAccessibility_map
		);
	end component;
	
	-- Overlapping maps registers
	signal ld_map: STD_LOGIC_VECTOR(0 to max_level);	
	type tpArray_accessibility_map is array(0 to max_level) of tpAccessibility_map;
	signal map_out_int: tpArray_accessibility_map;
	signal current_map: tpAccessibility_map;
begin
		------------------------------------
		-- OVERLAPPING MAP FOR EACH LEVEL --
		------------------------------------		
		overlapping_maps: for i in 0 to max_level generate
				overlapping_map_reg_reg_I: overlapping_map_reg
						port map(clk, rst, ld_map(i), map_in, map_out_int(i));
		end generate;
		
		-- Current level map mux
		current_map <= map_out_int(conv_integer(level)) when level < max_level else map_out_int(max_level);		
	
		-- Load and clear selectors
		load_clear: for i in 0 to max_level generate
							ld_map(i) <= '1' when load_map = '1' AND level = i else '0';
		end generate;		
		
		-- OUTPUTS
		map_out <= current_map;
end overlapping_mapsArch;