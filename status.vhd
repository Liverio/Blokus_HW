library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity status is
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
			vertex_in 	  : in STD_LOGIC_VECTOR(8-1 downto 0);	-- 7..row..4 3..col..0
			-- Move
			update_move : in STD_LOGIC;
			move_in 		: in STD_LOGIC_VECTOR(7-1 downto 0);
			-- Resets the vertex, vertex type, and move in the current level
			clear : in STD_LOGIC;					
			-----------------
			---- OUTPUTS ----
			-----------------
			-- Vertex
			last_vertex	: out STD_LOGIC_VECTOR(8-1 downto 0);
			-- Move
			last_move_out : out STD_LOGIC_VECTOR(7-1 downto 0)
		);
end status;

architecture statusArch of status is
	component reg
		generic(bits		 : positive := 128;
				  init_value : natural := 0);
		port (----------------
				---- INPUTS ----
				----------------
				clk : in std_logic;
				rst : in std_logic;
				ld	 : in std_logic;
				din : in std_logic_vector(bits-1 downto 0);
				-----------------
				---- OUTPUTS ----
				-----------------
				dout : out std_logic_vector(bits-1 downto 0)
		);
	end component;
	
	signal rstReg, rstMove_num_reg, ld_vertex, ld_move: STD_LOGIC_VECTOR(max_level-1 downto 0);
	signal vertex: STD_LOGIC_VECTOR((max_level-1)*8+8-1 downto 0);
	signal move: STD_LOGIC_VECTOR((max_level-1)*7+7-1 downto 0);
begin
	verticesReg: for i in 0 to max_level-1 generate		-- Last level DOES NOT find legal moves
			-- Unexplored vertex marked as 8+4+2 so comparison to check it are only need 3 bits (take 0000 1110 as "no vertex" since it is not a valid vertex)
			vertex_num_reg: 		reg generic map(8, 8+4+2)
										port map (clk, rstReg(i), 			  ld_vertex(i), 		vertex_in, 			vertex(i*8+8-1 downto i*8));
			move_num_reg: 			reg generic map(7, 127)
										port map (clk, rstMove_num_reg(i), ld_move(i), 			move_in, 			move(i*7+7-1 downto i*7));
			
			ld_vertex(i) 		 <= '1' when update_vertex = '1' 	  AND conv_integer(level) = i else '0';
			ld_move(i) 			 <= '1' when update_move = '1' 		  AND conv_integer(level) = i else '0';
			rstReg(i) 			 <= '1' when rst = '1' OR timeout = '1' OR (clear = '1' AND conv_integer(level) = i) else '0';
			rstMove_num_reg(i) <= '1' when rst = '1' OR timeout = '1' OR (clear = '1' AND conv_integer(level) = i) OR (update_vertex = '1' AND conv_integer(level) = i)  else '0';
	end generate verticesReg;
	
	last_vertex 	  	<= vertex(conv_integer(level)*8+8-1 downto conv_integer(level)*8);
	last_move_out 	 	<= move(conv_integer(level)*7+7-1 downto conv_integer(level)*7);
end statusArch;