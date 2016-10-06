library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.types.ALL;

entity overlapping_filter is
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
end overlapping_filter;

architecture overlapping_filterArch of overlapping_filter is
	component squares_position
		port (----------------
				---- INPUTS ----
				----------------
				vertex_x 			: in STD_LOGIC_VECTOR(4-1 downto 0);
				vertex_y 			: in STD_LOGIC_VECTOR(4-1 downto 0);
				vertex_type 		: in STD_LOGIC_VECTOR(2-1 downto 0);
				-----------------
				---- OUTPUTS ----
				-----------------
				a1_x, a1_y : out STD_LOGIC_VECTOR(4-1 downto 0);
				a2_x, a2_y : out STD_LOGIC_VECTOR(4-1 downto 0);
				b2_x, b2_y : out STD_LOGIC_VECTOR(4-1 downto 0)
		);
	end component;
	
	-- a1, a2 and b2 positions
	signal a1_x, a1_y : STD_LOGIC_VECTOR(4-1 downto 0);
	signal a2_x, a2_y : STD_LOGIC_VECTOR(4-1 downto 0);
	signal b2_x, b2_y : STD_LOGIC_VECTOR(4-1 downto 0);
	signal a1, a2, b2 : STD_LOGIC;
begin
	squares_position_I: squares_position
		port map(---- INPUTS ----
					vertex_x, vertex_y, vertex_type,
					---- OUTPUTS ----
					a1_x, a1_y, a2_x, a2_y, b2_x, b2_y
		);
	
	-- Muxes over accessibility map
--	a1 <= accessibility_map(conv_integer(a1_y), conv_integer(a1_x));
--	a2 <= accessibility_map(conv_integer(a2_y), conv_integer(a2_x));
--	b2 <= accessibility_map(conv_integer(b2_y), conv_integer(b2_x));
	
	a1 <= accessibility_map(conv_integer(a1_y), + conv_integer(a1_x)) when a1_y >= 0 AND a1_y <=13 AND a1_x >= 0 AND a1_x <= 13 else '0';
	a2 <= accessibility_map(conv_integer(a2_y), + conv_integer(a2_x)) when a2_y >= 0 AND a2_y <=13 AND a2_x >= 0 AND a2_x <= 13 else '0';
	b2 <= accessibility_map(conv_integer(b2_y), + conv_integer(b2_x)) when b2_y >= 0 AND b2_y <=13 AND b2_x >= 0 AND b2_x <= 13 else '0';
	
	
	-- OUTPUT
	skip_vertex <= NOT(a1) AND NOT(a2) AND NOT(b2) AND threshold(2);
end overlapping_filterArch;