library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.types.ALL;

entity squares_position is
	port (----------------
			---- INPUTS ----
			----------------
			vertex_x 	: in STD_LOGIC_VECTOR(4-1 downto 0);
			vertex_y 	: in STD_LOGIC_VECTOR(4-1 downto 0);
			vertex_type : in STD_LOGIC_VECTOR(2-1 downto 0);
			-----------------
			---- OUTPUTS ----
			-----------------
			a1_x, a1_y : out STD_LOGIC_VECTOR(4-1 downto 0);
			a2_x, a2_y : out STD_LOGIC_VECTOR(4-1 downto 0);
			b2_x, b2_y : out STD_LOGIC_VECTOR(4-1 downto 0)
	);
end squares_position;

architecture squares_positionArch of squares_position is
begin
	-- a1
	a1_x <= vertex_x		when vertex_type = "00" else
			  vertex_x + 1 when vertex_type = "01" else
			  vertex_x + 1 when vertex_type = "10" else
			  vertex_x;
			  
	a1_y <= vertex_y		when vertex_type = "00" else
			  vertex_y		when vertex_type = "01" else
			  vertex_y + 1 when vertex_type = "10" else
			  vertex_y + 1;

	-- a2
	a2_x <= vertex_x - 1	when vertex_type = "00" else
			  vertex_x + 1	when vertex_type = "01" else
			  vertex_x + 2	when vertex_type = "10" else
			  vertex_x;
	
	a2_y <= vertex_y		when vertex_type = "00" else
			  vertex_y - 1	when vertex_type = "01" else
			  vertex_y + 1	when vertex_type = "10" else
			  vertex_y + 2;
	
	-- b2
	b2_x <= vertex_x		when vertex_type = "00" else
			  vertex_x + 2	when vertex_type = "01" else
			  vertex_x + 1	when vertex_type = "10" else
			  vertex_x - 1;
	
	b2_y <= vertex_y - 1	when vertex_type = "00" else
			  vertex_y		when vertex_type = "01" else
			  vertex_y + 2	when vertex_type = "10" else
			  vertex_y + 1;
end squares_positionArch;