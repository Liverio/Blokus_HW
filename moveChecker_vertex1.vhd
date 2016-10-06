library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.types.ALL;

entity moveChecker_vertex1 is
	port (----------------
			---- INPUTS ----
			----------------
			window 			 : in tpProcessingWindow;
			tiles_available : in STD_LOGIC_VECTOR(21-1 downto 0);
			-----------------
			---- OUTPUTS ----
			-----------------
			moves : out STD_LOGIC_VECTOR(v1a00 downto v1u00)
	);
end moveChecker_vertex1;

architecture moveChecker_vertex1Arch of moveChecker_vertex1 is
begin
	-- TILE U
	-- rot 0
	--  x     x
	--	xxx   oxx
	--  o     x  
	moves(v1u00) <= window(-2, 0) AND window(-1,-1) AND window(-1, 0) AND window(-1, 1) AND tiles_available(conv_integer(tile_u));
	moves(v1u01) <= window(-1, 1) AND window( 0, 1) AND window( 0, 2) AND window( 1, 1) AND tiles_available(conv_integer(tile_u));
	
	
	-- TILE T
	-- rot 0     | rot 1    | rot 2    | rot 3    | rot 4    | rot 5 | rot 6 | rot 7 
	--	x	   x   |   x    x |  xx   xx | xx   ox  |  x    x  |  x    |  x    |  x    x
	--	xxx   oxx | xxx  oxx | xx   ox  |  xx   xx | xxx  oxx | xxx   |  xx   | xx   ox
	--  o     x  |  o    x  |  o    x  |  o    x  |   o    x | o     | ox    |  ox   xx
 	moves(v1t00) <= window(-2,-1) AND window(-1,-1) AND window(-1, 0) AND window(-1, 1) AND tiles_available(conv_integer(tile_t));
	moves(v1t01) <= window(-1, 0) AND window( 0, 1) AND window( 0, 2) AND window( 1, 1) AND tiles_available(conv_integer(tile_t));
	moves(v1t10) <= window(-2, 1) AND window(-1,-1) AND window(-1, 0) AND window(-1, 1) AND tiles_available(conv_integer(tile_t));
	moves(v1t11) <= window(-1, 2) AND window( 0, 1) AND window( 0, 2) AND window( 1, 1) AND tiles_available(conv_integer(tile_t));
	moves(v1t20) <= window(-2, 0) AND window(-2, 1) AND window(-1,-1) AND window(-1, 0) AND tiles_available(conv_integer(tile_t));
	moves(v1t21) <= window(-1, 1) AND window(-1, 2) AND window( 0, 1) AND window( 1, 1) AND tiles_available(conv_integer(tile_t));
	moves(v1t30) <= window(-2,-1) AND window(-2, 0) AND window(-1, 0) AND window(-1, 1) AND tiles_available(conv_integer(tile_t));
	moves(v1t31) <= window( 0, 1) AND window( 1, 1) AND window( 1, 2) AND window( 2, 1) AND tiles_available(conv_integer(tile_t));
	moves(v1t40) <= window(-2,-1) AND window(-1,-2) AND window(-1,-1) AND window(-1, 0) AND tiles_available(conv_integer(tile_t));
	moves(v1t41) <= window(-1, 1) AND window( 0, 1) AND window( 0, 2) AND window( 1, 2) AND tiles_available(conv_integer(tile_t));
	moves(v1t50) <= window(-2, 1) AND window(-1, 0) AND window(-1, 1) AND window(-1, 2) AND tiles_available(conv_integer(tile_t));
	moves(v1t60) <= window(-2, 1) AND window(-1, 1) AND window(-1, 2) AND window( 0, 1) AND tiles_available(conv_integer(tile_t));
	moves(v1t70) <= window(-2, 0) AND window(-1,-1) AND window(-1, 0) AND window( 0, 1) AND tiles_available(conv_integer(tile_t));
	moves(v1t71) <= window(-1, 1) AND window( 0, 1) AND window( 1, 1) AND window( 1, 2) AND tiles_available(conv_integer(tile_t));
	
	
	-- TILE S
	-- rot 0   | rot 1 | rot 2 | rot 3 
	--	x   x   |   x   |  xx   | xx   ox
	--	xxx oxx | xxx   |  x    |  x    x  
	--   o   x | o     | ox    |  ox   xx
	moves(v1s00) <= window(-2,-2) AND window(-1,-2) AND window(-1,-1) AND window(-1, 0) AND tiles_available(conv_integer(tile_s));
	moves(v1s01) <= window(-1, 0) AND window( 0, 1) AND window( 0, 2) AND window( 1, 2) AND tiles_available(conv_integer(tile_s));
	moves(v1s10) <= window(-2, 2) AND window(-1, 0) AND window(-1, 1) AND window(-1, 2) AND tiles_available(conv_integer(tile_s));
	moves(v1s20) <= window(-2, 1) AND window(-2, 2) AND window(-1, 1) AND window( 0, 1) AND tiles_available(conv_integer(tile_s));
	moves(v1s30) <= window(-2,-1) AND window(-2, 0) AND window(-1, 0) AND window( 0, 1) AND tiles_available(conv_integer(tile_s));
	moves(v1s31) <= window( 0, 1) AND window( 1, 1) AND window( 2, 1) AND window( 2, 2) AND tiles_available(conv_integer(tile_s));
	
	
	-- TILE R
	-- rot 0         | rot 1 | rot 2 | rot 3 
	--	xx   xx   ox  |  xx   |   x   | x    x
	--	 xx   ox   xx | xx    |  xx   | xx   ox
	--   o    x    x | o     | ox    |  ox   xx
	moves(v1r00) <= window(-2,-2) AND window(-2,-1) AND window(-1,-1) AND window(-1, 0) AND tiles_available(conv_integer(tile_r));
	moves(v1r01) <= window(-1,-1) AND window(-1, 0) AND window( 0, 1) AND window( 1, 1) AND tiles_available(conv_integer(tile_r));
	moves(v1r02) <= window( 0, 1) AND window( 1, 1) AND window( 1, 2) AND window( 2, 2) AND tiles_available(conv_integer(tile_r));
	moves(v1r10) <= window(-2, 1) AND window(-2, 2) AND window(-1, 0) AND window(-1, 1) AND tiles_available(conv_integer(tile_r));
	moves(v1r20) <= window(-2, 2) AND window(-1, 1) AND window(-1, 2) AND window( 0, 1) AND tiles_available(conv_integer(tile_r));
	moves(v1r30) <= window(-2,-1) AND window(-1,-1) AND window(-1, 0) AND window( 0, 1) AND tiles_available(conv_integer(tile_r));
	moves(v1r31) <= window(-1, 0) AND window( 0, 1) AND window( 1, 1) AND window( 1, 2) AND tiles_available(conv_integer(tile_r));
	
	
	-- TILE Q
	-- rot 0 | rot 1 | rot 2 | rot 3 
	--	x     |   x   | xxx   | xxx  oxx
	--	x     |   x	  | x     |   x    x
	-- oxx   | oxx	  | o     |   o    x
	moves(v1q00) <= window(-2, 0) AND window(-1, 0) AND window( 0, 1) AND window( 0, 2) AND tiles_available(conv_integer(tile_q));
	moves(v1q10) <= window(-2, 2) AND window(-1, 2) AND window( 0, 1) AND window( 0, 2) AND tiles_available(conv_integer(tile_q));
	moves(v1q20) <= window(-2, 0) AND window(-2, 1) AND window(-2, 2) AND window(-1, 0) AND tiles_available(conv_integer(tile_q));
	moves(v1q30) <= window(-2,-2) AND window(-2,-1) AND window(-2, 0) AND window(-1, 0) AND tiles_available(conv_integer(tile_q));
	moves(v1q31) <= window( 0, 1) AND window( 0, 2) AND window( 1, 2) AND window( 2, 2) AND tiles_available(conv_integer(tile_q));
	
	
	-- TILE P
	-- rot 0 | rot 2 | rot 3    | rot 4
	--	 x    | x     |   x    x | xxx  oxx
	--	 x    | xxx   | xxx  oxx |	 x    x
	-- oxx   | o     |   o    x |  o    x
	moves(v1p00) <= window(-2, 1) AND window(-1, 1) AND window( 0, 1) AND window( 0, 2) AND tiles_available(conv_integer(tile_p));
	moves(v1p20) <= window(-2, 0) AND window(-1, 0) AND window(-1, 1) AND window(-1, 2) AND tiles_available(conv_integer(tile_p));
	moves(v1p30) <= window(-2, 0) AND window(-1,-2) AND window(-1,-1) AND window(-1, 0) AND tiles_available(conv_integer(tile_p));
	moves(v1p31) <= window(-1, 2) AND window( 0, 1) AND window( 0, 2) AND window( 1, 2) AND tiles_available(conv_integer(tile_p));
	moves(v1p40) <= window(-2,-1) AND window(-2, 0) AND window(-2, 1) AND window(-1, 0) AND tiles_available(conv_integer(tile_p));
	moves(v1p41) <= window( 0, 1) AND window( 0, 2) AND window( 1, 1) AND window( 2, 1) AND tiles_available(conv_integer(tile_p));
	
	
	-- TILE O
	-- rot 0 | rot 1  | rot 2      | rot 3      | rot 4  | rot 5 | rot 6 | rot 7
	--	x     |  x   x | xxxx  oxxx | xxxx  oxxx |  x   x | x     |  x    |   x
	--	xx    | xx  ox	|   o     x  |  o     x   |  x   x | x     | oxxx  | oxxx
	-- x     |  x	 x |            |            | xx  ox | xx    |       |
	-- o     |  o   x |            |            |  o   x | o     |       |
	moves(v1o00) <= window(-3, 0) AND window(-2, 0) AND window(-2, 1) AND window(-1, 0) AND tiles_available(conv_integer(tile_o));
	moves(v1o10) <= window(-3, 0) AND window(-2,-1) AND window(-2, 0) AND window(-1, 0) AND tiles_available(conv_integer(tile_o));
	moves(v1o11) <= window(-1, 1) AND window( 0, 1) AND window( 1, 1) AND window( 2, 1) AND tiles_available(conv_integer(tile_o));
	moves(v1o20) <= window(-1,-2) AND window(-1,-1) AND window(-1, 0) AND window(-1, 1) AND tiles_available(conv_integer(tile_o));
	moves(v1o21) <= window( 0, 1) AND window( 0, 2) AND window( 0, 3) AND window( 1, 2) AND tiles_available(conv_integer(tile_o));
	moves(v1o30) <= window(-1,-1) AND window(-1, 0) AND window(-1, 1) AND window(-1, 2) AND tiles_available(conv_integer(tile_o));
	moves(v1o31) <= window( 0, 1) AND window( 0, 2) AND window( 0, 3) AND window( 1, 1) AND tiles_available(conv_integer(tile_o));
	moves(v1o40) <= window(-3, 0) AND window(-2, 0) AND window(-1,-1) AND window(-1, 0) AND tiles_available(conv_integer(tile_o));
	moves(v1o41) <= window(-2, 1) AND window(-1, 1) AND window( 0, 1) AND window( 1, 1) AND tiles_available(conv_integer(tile_o));
	moves(v1o50) <= window(-3, 0) AND window(-2, 0) AND window(-1, 0) AND window(-1, 1) AND tiles_available(conv_integer(tile_o));
	moves(v1o60) <= window(-1, 1) AND window( 0, 1) AND window( 0, 2) AND window( 0, 3) AND tiles_available(conv_integer(tile_o));
	moves(v1o70) <= window(-1, 2) AND window( 0, 1) AND window( 0, 2) AND window( 0, 3) AND tiles_available(conv_integer(tile_o));
	
	
	-- TILE N
	-- rot 0  | rot 1 | rot 2 | rot 6
	--	xx  ox | xx    | x x   | xxx  xxx
	--	 x   x | x	   | oxx   | o x  x o
	-- ox  xx | ox	   |       |
	moves(v1n00) <= window(-2, 0) AND window(-2, 1) AND window(-1, 1) AND window( 0, 1) AND tiles_available(conv_integer(tile_n));
	moves(v1n01) <= window( 0, 1) AND window( 1, 1) AND window( 2, 0) AND window( 2, 1) AND tiles_available(conv_integer(tile_n));
	moves(v1n10) <= window(-2, 0) AND window(-2, 1) AND window(-1, 0) AND window( 0, 1) AND tiles_available(conv_integer(tile_n));
	moves(v1n20) <= window(-1, 0) AND window(-1, 2) AND window( 0, 1) AND window( 0, 2) AND tiles_available(conv_integer(tile_n));
	moves(v1n60) <= window(-1, 0) AND window(-1, 1) AND window(-1, 2) AND window( 0, 2) AND tiles_available(conv_integer(tile_n));
	moves(v1n61) <= window(-1,-2) AND window(-1,-1) AND window(-1, 0) AND window( 0,-2) AND tiles_available(conv_integer(tile_n));
	

	-- TILE M
	-- rot 0 | rot 1 | rot 2 | rot 3 | rot 4 | rot 5  | rot 6    | rot 7
	--	 x    | x     | xx    |  xx   | xx    | xx  xx | xxx  oxx | xxx
	--	xx    | xx	  | oxx   | oxx   | xx    | xx  ox |  ox   xx | ox
	-- ox    | ox	  |       |       | o     |  o   x |          |
	moves(v1m00) <= window(-2, 1) AND window(-1, 0) AND window(-1, 1) AND window( 0, 1) AND tiles_available(conv_integer(tile_m));
	moves(v1m10) <= window(-2, 0) AND window(-1, 0) AND window(-1, 1) AND window( 0, 1) AND tiles_available(conv_integer(tile_m));
	moves(v1m20) <= window(-1, 0) AND window(-1, 1) AND window( 0, 1) AND window( 0, 2) AND tiles_available(conv_integer(tile_m));
	moves(v1m30) <= window(-1, 1) AND window(-1, 2) AND window( 0, 1) AND window( 0, 2) AND tiles_available(conv_integer(tile_m));
	moves(v1m40) <= window(-2, 0) AND window(-2, 1) AND window(-1, 0) AND window(-1, 1) AND tiles_available(conv_integer(tile_m));
	moves(v1m50) <= window(-2,-1) AND window(-2, 0) AND window(-1,-1) AND window(-1, 0) AND tiles_available(conv_integer(tile_m));
	moves(v1m51) <= window(-1, 0) AND window(-1, 1) AND window( 0, 1) AND window( 1, 1) AND tiles_available(conv_integer(tile_m));
	moves(v1m60) <= window(-1,-1) AND window(-1, 0) AND window(-1, 1) AND window( 0, 1) AND tiles_available(conv_integer(tile_m));
	moves(v1m61) <= window( 0, 1) AND window( 0, 2) AND window( 1, 1) AND window( 1, 2) AND tiles_available(conv_integer(tile_m));
	moves(v1m70) <= window(-1, 0) AND window(-1, 1) AND window(-1, 2) AND window( 0, 1) AND tiles_available(conv_integer(tile_m));
	
	
	-- TILE L
	-- rot 0 | rot 1  | rot 2      | rot 3 | rot 4 | rot 5  | rot 6      | rot 7
	--	 x    | x   x  | xx    ox   |   xx  |  x    | x   x  | xxx   oxx  |  xxx
	--	 x    | x	x  |  oxx   xxx | oxx   | xx    | xx  ox |   ox    xx | ox
	-- xx    | xx  ox	|            |       | x     |  x   x |            |
	-- o     |  o   x |            |       | o     |  o   x |            |
	moves(v1l00) <= window(-3, 1) AND window(-2, 1) AND window(-1, 0) AND window(-1, 1) AND tiles_available(conv_integer(tile_l));
	moves(v1l10) <= window(-3,-1) AND window(-2,-1) AND window(-1,-1) AND window(-1, 0) AND tiles_available(conv_integer(tile_l));
	moves(v1l11) <= window(-2, 0) AND window(-1, 0) AND window( 0, 1) AND window( 1, 1) AND tiles_available(conv_integer(tile_l));
	moves(v1l20) <= window(-1,-1) AND window(-1, 0) AND window( 0, 1) AND window( 0, 2) AND tiles_available(conv_integer(tile_l));
	moves(v1l21) <= window( 0, 1) AND window( 1, 1) AND window( 1, 2) AND window( 1, 3) AND tiles_available(conv_integer(tile_l));
	moves(v1l30) <= window(-1, 2) AND window(-1, 3) AND window( 0, 1) AND window( 0, 2) AND tiles_available(conv_integer(tile_l));
	moves(v1l40) <= window(-3, 1) AND window(-2, 0) AND window(-2, 1) AND window(-1, 0) AND tiles_available(conv_integer(tile_l));
	moves(v1l50) <= window(-3,-1) AND window(-2,-1) AND window(-2, 0) AND window(-1, 0) AND tiles_available(conv_integer(tile_l));
	moves(v1l51) <= window(-1, 0) AND window( 0, 1) AND window( 1, 1) AND window( 2, 1) AND tiles_available(conv_integer(tile_l));
	moves(v1l60) <= window(-1,-2) AND window(-1,-1) AND window(-1, 0) AND window( 0, 1) AND tiles_available(conv_integer(tile_l));
	moves(v1l61) <= window( 0, 1) AND window( 0, 2) AND window( 1, 2) AND window( 1, 3) AND tiles_available(conv_integer(tile_l));
	moves(v1l70) <= window(-1, 1) AND window(-1, 2) AND window(-1, 3) AND window( 0, 1) AND tiles_available(conv_integer(tile_l));
	
	
	-- TILE K
	-- rot 0 | rot 1 | rot 2 | rot 3 | rot 4 | rot 5  | rot 6      | rot 7
	--	 x    | x     | x     |    x  | xx    | xx  ox | xxxx  oxxx | xxxx
	--	 x    | x	  | oxxx  | oxxx  | x     |  x   x |    o     x | o
	--  x    | x	  |       |       | x     |  x   x |            |
	-- ox    | ox    |       |       | o     |  o   x |            |
	moves(v1k00) <= window(-3, 1) AND window(-2, 1) AND window(-1, 1) AND window( 0, 1) AND tiles_available(conv_integer(tile_k));
	moves(v1k10) <= window(-3, 0) AND window(-2, 0) AND window(-1, 0) AND window( 0, 1) AND tiles_available(conv_integer(tile_k));
	moves(v1k20) <= window(-1, 0) AND window( 0, 1) AND window( 0, 2) AND window( 0, 3) AND tiles_available(conv_integer(tile_k));
	moves(v1k30) <= window(-1, 3) AND window( 0, 1) AND window( 0, 2) AND window( 0, 3) AND tiles_available(conv_integer(tile_k));
	moves(v1k40) <= window(-3, 0) AND window(-3, 1) AND window(-2, 0) AND window(-1, 0) AND tiles_available(conv_integer(tile_k));
	moves(v1k50) <= window(-3,-1) AND window(-3, 0) AND window(-2, 0) AND window(-1, 0) AND tiles_available(conv_integer(tile_k));
	moves(v1k51) <= window( 0, 1) AND window( 1, 1) AND window( 2, 1) AND window( 3, 1) AND tiles_available(conv_integer(tile_k));
	moves(v1k60) <= window(-1,-3) AND window(-1,-2) AND window(-1,-1) AND window(-1, 0) AND tiles_available(conv_integer(tile_k));
	moves(v1k61) <= window( 0, 1) AND window( 0, 2) AND window( 0, 3) AND window( 1, 3) AND tiles_available(conv_integer(tile_k));
	moves(v1k70) <= window(-1, 0) AND window(-1, 1) AND window(-1, 2) AND window(-1, 3) AND tiles_available(conv_integer(tile_k));
	
	
	-- TILE J
	-- rot 0 | rot 2
	--	 x    | oxxxx
	--	 x    |
	--  x    |
	--  x    |
	--  o    |
	moves(v1j00) <= window(-4, 0) AND window(-3, 0) AND window(-2, 0) AND window(-1, 0) AND tiles_available(conv_integer(tile_j));
	moves(v1j20) <= window( 0, 1) AND window( 0, 2) AND window( 0, 3) AND window( 0, 4) AND tiles_available(conv_integer(tile_j));
	
	
	-- TILE I
	-- rot 0 	 | rot 1 | rot 2 | rot 3
	--	 xx   ox  |  xx   |  x    | x   x
	--	  ox   xx | ox    | xx    | xx  ox
	--           | 	   | o     |  o   x
	moves(v1i00) <= window(-1,-1) AND window(-1, 0) AND window( 0, 1) AND tiles_available(conv_integer(tile_i));
	moves(v1i01) <= window( 0, 1) AND window( 1, 1) AND window( 1, 2) AND tiles_available(conv_integer(tile_i));
	moves(v1i10) <= window(-1, 1) AND window(-1, 2) AND window( 0, 1) AND tiles_available(conv_integer(tile_i));
	moves(v1i20) <= window(-2, 1) AND window(-1, 0) AND window(-1, 1) AND tiles_available(conv_integer(tile_i));
	moves(v1i30) <= window(-2,-1) AND window(-1,-1) AND window(-1, 0) AND tiles_available(conv_integer(tile_i));
	moves(v1i31) <= window(-1, 0) AND window( 0, 1) AND window( 1, 1) AND tiles_available(conv_integer(tile_i));
	
	
	-- TILE H
	-- rot 0
	--	 xx
	--	 ox
	moves(v1h00) <= window(-1, 0) AND window(-1, 1) AND window( 0, 1) AND tiles_available(conv_integer(tile_h));
	
	
	-- TILE G
	-- rot 0 | rot 1  | rot 2    | rot 6
	--	 x    |  x   x | xxx  oxx |  x
	--	 xx   | xx  ox |  o    x  | oxx
	--  o    |  o   x |          |
	moves(v1g00) <= window(-2, 0) AND window(-1, 0) AND window(-1, 1) AND tiles_available(conv_integer(tile_g));
	moves(v1g10) <= window(-2, 0) AND window(-1,-1) AND window(-1, 0) AND tiles_available(conv_integer(tile_g));
	moves(v1g11) <= window(-1, 1) AND window( 0, 1) AND window( 1, 1) AND tiles_available(conv_integer(tile_g));
	moves(v1g20) <= window(-1,-1) AND window(-1, 0) AND window(-1, 1) AND tiles_available(conv_integer(tile_g));
	moves(v1g21) <= window( 0, 1) AND window( 0, 2) AND window( 1, 1) AND tiles_available(conv_integer(tile_g));
	moves(v1g60) <= window(-1, 1) AND window( 0, 1) AND window( 0, 2) AND tiles_available(conv_integer(tile_g));
	
	
	-- TILE F
	-- rot 0 | rot 1 | rot 2 | rot 3 | rot 4 | rot 5 | rot 6    | rot 7
	--	 x    | x     | x     |   x   | xx    | xx ox | xxx  oxx | xxx
	--	 x    | x     | oxx   | oxx   | x     |  x  x |   o    x | o
	-- ox    | ox    |       |       | o     |  o  x |          |
	moves(v1f00) <= window(-2, 1) AND window(-1, 1) AND window( 0, 1) AND tiles_available(conv_integer(tile_f));
	moves(v1f10) <= window(-2, 0) AND window(-1, 0) AND window( 0, 1) AND tiles_available(conv_integer(tile_f));
	moves(v1f20) <= window(-1, 0) AND window( 0, 1) AND window( 0, 2) AND tiles_available(conv_integer(tile_f));
	moves(v1f30) <= window(-1, 2) AND window( 0, 1) AND window( 0, 2) AND tiles_available(conv_integer(tile_f));
	moves(v1f40) <= window(-2, 0) AND window(-2, 1) AND window(-1, 0) AND tiles_available(conv_integer(tile_f));
	moves(v1f50) <= window(-2,-1) AND window(-2, 0) AND window(-1, 0) AND tiles_available(conv_integer(tile_f));
	moves(v1f51) <= window( 0, 1) AND window( 1, 1) AND window( 2, 1) AND tiles_available(conv_integer(tile_f));
	moves(v1f60) <= window(-1,-2) AND window(-1,-1) AND window(-1, 0) AND tiles_available(conv_integer(tile_f));
	moves(v1f61) <= window( 0, 1) AND window( 0, 2) AND window( 1, 2) AND tiles_available(conv_integer(tile_f));
	moves(v1f70) <= window(-1, 0) AND window(-1, 1) AND window(-1, 2) AND tiles_available(conv_integer(tile_f));

	
	-- TILE E
	-- rot 0 | rot 2
	--	 x    | oxxx
	--	 x    |
	--  x    |
	--  o    |
	moves(v1e00) <= window(-3, 0) AND window(-2, 0) AND window(-1, 0) AND tiles_available(conv_integer(tile_e));
	moves(v1e20) <= window( 0, 1) AND window( 0, 2) AND window( 0, 3) AND tiles_available(conv_integer(tile_e));
	
	
	-- TILE D
	-- rot 0 | rot 1 | rot 2 | rot 3
	--	 x    |  x    | xx    | xx  ox
	--	 ox   | ox    | o     |  o   x
	moves(v1d00) <= window(-1, 0) AND window( 0, 1) AND tiles_available(conv_integer(tile_d));
	moves(v1d10) <= window(-1, 1) AND window( 0, 1) AND tiles_available(conv_integer(tile_d));
	moves(v1d20) <= window(-1, 0) AND window(-1, 1) AND tiles_available(conv_integer(tile_d));
	moves(v1d30) <= window(-1,-1) AND window(-1, 0) AND tiles_available(conv_integer(tile_d));
	moves(v1d31) <= window( 0, 1) AND window( 1, 1) AND tiles_available(conv_integer(tile_d));
	
	
	-- TILE C
	-- rot 0 | rot 2
	--	 x    | oxx
	--	 x    |
	--  o    |
	moves(v1c00) <= window(-2, 0) AND window(-1, 0) AND tiles_available(conv_integer(tile_c));
	moves(v1c20) <= window( 0, 1) AND window( 0, 2) AND tiles_available(conv_integer(tile_c));
	
	
	-- TILE B
	-- rot 0 | rot 2
	--	 x    | ox
	--	 o    |
	moves(v1b00) <= window(-1, 0) AND tiles_available(conv_integer(tile_b));
	moves(v1b20) <= window( 0, 1) AND tiles_available(conv_integer(tile_b));
	
	
	-- TILE A
	-- rot 0
	--	 o
	moves(v1a00) <= tiles_available(conv_integer(tile_a));
end moveChecker_vertex1Arch;