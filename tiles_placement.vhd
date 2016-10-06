library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use work.types.all;

---------------------------------------------- ***** Description ***** ----------------------------------------------
-- Returns the absolute positions of each piece of the requested tile
-- This module is used to:
--	- * Write movements *
-- - * Check overlapping *
---------------------------------------------------------------------------------------------------------------------

entity tiles_placement is
	port (----------------
			---- INPUTS ----
			----------------
			-- Center
			x, y		 : in STD_LOGIC_VECTOR(4-1 downto 0);
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
end tiles_placement;

architecture tiles_placementArch of tiles_placement is
	component tiles_memory
		port (----------------
				---- INPUTS ----
				----------------
				tile		: in STD_LOGIC_VECTOR(5-1 downto 0);
				rotation : in STD_LOGIC_VECTOR(3-1 downto 0);			
				-----------------
				---- OUTPUTS ----
				-----------------
				tile_definition: out STD_LOGIC_VECTOR(102-1 downto 0)
		);
	end component;
	
	-- Tiles memory
	signal tile_definition: STD_LOGIC_VECTOR(102-1 downto 0);
	
	-- Tile definition decomposed into tile pieces and forbiddens
	signal tile_positions: STD_LOGIC_VECTOR(30-1 downto 0);
	signal forbidden_positions: STD_LOGIC_VECTOR(72-1 downto 0);
begin
	tiles_memory_I: tiles_memory
		port map(---- INPUTS ----
					tile		=> tile,
					rotation => rotation,
					---- OUTPUTS ----
					tile_definition => tile_definition
		);
	
	-- Mem outputs	
	tile_positions 	  <= tile_definition(101 downto 72);
	forbidden_positions <= tile_definition( 71 downto  0);
	
	-- OUTPUTS --
	-- Tile absolute positions (center + piece offset)
	tile_pos: for i in 0 to 5-1 generate
		tile_x_pos(i) <= x + tile_positions(i*6+4 downto i*6+3) when tile_positions(i*6+5) = '0' else x - tile_positions(i*6+4 downto i*6+3);
		tile_y_pos(i) <= y + tile_positions(i*6+1 downto i*6+0) when tile_positions(i*6+2) = '0' else y - tile_positions(i*6+1 downto i*6+0);
	end generate;
	
	-- Which pieces are valid?	
	pieces_valids: for i in 0 to 5-1 generate
		piece_valid(i) <= '0' when -- No piece of tile shifted -3,-3
											(tile_positions(i*6+5 downto i*6) = "111111")
								else '1';
	end generate;
	
	-- Forbiddens absolute positions (center + piece offset)
	forbiddens_pos: for i in 0 to 12-1 generate
		forbidden_x_pos(i) <= x + forbidden_positions(i*6+4 downto i*6+3) when forbidden_positions(i*6+5) = '0' else x - forbidden_positions(i*6+4 downto i*6+3);
		forbidden_y_pos(i) <= y + forbidden_positions(i*6+1 downto i*6+0) when forbidden_positions(i*6+2) = '0' else y - forbidden_positions(i*6+1 downto i*6+0);		
	end generate;
	
	-- Which forbiddens are valid?	
	forbiddens_valids: for i in 0 to 12-1 generate
		forbidden_valid(i) <= '0' when -- No tile with a forbidden shifted -3,-3
												 (forbidden_positions(i*6+5 downto i*6) = "111111") OR
												 -- Out of board
												 (forbidden_positions(i*6+5) = '0' AND conv_integer(x + forbidden_positions(i*6+4 downto i*6+3)) > 13) OR
												 (forbidden_positions(i*6+5) = '1' AND forbidden_positions(i*6+4 downto i*6+3) > x) 						  OR
												 (forbidden_positions(i*6+2) = '0' AND conv_integer(y + forbidden_positions(i*6+1 downto i*6+0)) > 13) OR
												 (forbidden_positions(i*6+2) = '1' AND forbidden_positions(i*6+1 downto i*6+0) > y)
									 else '1';
	end generate;
end tiles_placementArch;