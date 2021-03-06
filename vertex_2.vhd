library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.types.ALL;

entity vertex_2 is
	port (window: in tpProcessingWindow;
			a2, b2: OUT STD_LOGIC;
			a3, b3, c3, d3, e3: OUT STD_LOGIC;
			a4, b4, c4, d4, e4, f4, g4, h4: OUT STD_LOGIC;
			a5, b5, c5, d5, e5, f5, g5, h5, i5, j5, k5, l5, m5: OUT STD_LOGIC);
end vertex_2;

architecture vertex_2Arch of vertex_2 is
begin
		-- Squares availability
		--             b5 
		--          a5 a4 c5
		--             a3 b4 d5
		--    m5    xx a2 b3 c4 e5 
		-- l5 h4 e3 b2 c3 d4 f5
		--    k5 g4 d3 e4 g5  
		--       j5 f4 h5
		--				i5
		
		a2 <= window( 0, 1);
		b2 <= window( 1, 0);
		a3 <= window(-1, 1);
		b3 <= window( 0, 2);
		c3 <= window( 1, 1);
		d3 <= window( 2, 0);
		e3 <= window( 1,-1);
		a4 <= window(-2, 1);
		b4 <= window(-1, 2);
		c4 <= window( 0, 3);
		d4 <= window( 1, 2);
		e4 <= window( 2, 1);
		f4 <= window( 3, 0);
		g4 <= window( 2,-1);
		h4 <= window( 1,-2);
		a5 <= window(-2, 0);
		b5 <= window(-3, 1);
		c5 <= window(-2, 2);
		d5 <= window(-1, 3);
		e5 <= window( 0, 4);
		f5 <= window( 1, 3);
		g5 <= window( 2, 2);
		h5 <= window( 3, 1);
		i5 <= window( 4, 0);
		j5 <= window( 3,-1);
		k5 <= window( 2,-2);
		l5 <= window( 1,-3);
		m5 <= window( 0,-2);
end vertex_2Arch;