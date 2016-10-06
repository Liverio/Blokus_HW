library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.types.ALL;

entity moveChecker_vertex2 is
	port (----------------
			---- INPUTS ----
			----------------
			window 			 : in tpProcessingWindow;
			tiles_available : in STD_LOGIC_VECTOR(21-1 downto 0);
			-----------------
			---- OUTPUTS ----
			-----------------
			moves : out STD_LOGIC_VECTOR(v2a00 downto v2u00)
	);
end moveChecker_vertex2;

architecture moveChecker_vertex2Arch of moveChecker_vertex2 is
begin
	-- TILE U
	-- rot 0
	--  x    o
	--	oxx  xxx
	--  x    x
	moves(v2u00) <= window(-1, 1) AND window( 0, 1) AND window( 0, 2) AND window( 1, 1) AND tiles_available(conv_integer(tile_u));
	moves(v2u01) <= window( 1,-1) AND window( 1, 0) AND window( 1, 1) AND window( 2, 0) AND tiles_available(conv_integer(tile_u));
	
	
	-- TILE T
	-- rot 0 | rot 1    | rot 2    | rot 3 | rot 4    | rot 5    | rot 6   | rot 7 
	--	o	   |   x    o |  xx   ox | ox    |  x    o  |  x    o  |  x   o  |  x    o
	--	xxx   | oxx  xxx | ox   xx  |  xx   | oxx  xxx | oxx  xxx |  xx  xx | ox   xx
	--  x    |  x    x  |  x    x  |  x    |   x    x | x    x   | ox  xx  |  xx   xx
 	moves(v2t00) <= window( 1, 0) AND window( 1, 1) AND window( 1, 2) AND window( 2, 1) AND tiles_available(conv_integer(tile_t));
	moves(v2t10) <= window(-1, 2) AND window( 0, 1) AND window( 0, 2) AND window( 1, 1) AND tiles_available(conv_integer(tile_t));
	moves(v2t11) <= window( 1,-2) AND window( 1,-1) AND window( 1, 0) AND window( 2,-1) AND tiles_available(conv_integer(tile_t));
	moves(v2t20) <= window(-1, 1) AND window(-1, 2) AND window( 0, 1) AND window( 1, 1) AND tiles_available(conv_integer(tile_t));
	moves(v2t21) <= window( 0, 1) AND window( 1,-1) AND window( 1, 0) AND window( 2, 0) AND tiles_available(conv_integer(tile_t));
	moves(v2t30) <= window( 0, 1) AND window( 1, 1) AND window( 1, 2) AND window( 2, 1) AND tiles_available(conv_integer(tile_t));
	moves(v2t40) <= window(-1, 1) AND window( 0, 1) AND window( 0, 2) AND window( 1, 2) AND tiles_available(conv_integer(tile_t));
	moves(v2t41) <= window( 1,-1) AND window( 1, 0) AND window( 1, 1) AND window( 2, 1) AND tiles_available(conv_integer(tile_t));
	moves(v2t50) <= window(-1, 1) AND window( 0, 1) AND window( 0, 2) AND window( 1, 0) AND tiles_available(conv_integer(tile_t));
	moves(v2t51) <= window( 1,-1) AND window( 1, 0) AND window( 1, 1) AND window( 2,-1) AND tiles_available(conv_integer(tile_t));
	moves(v2t60) <= window(-2, 1) AND window(-1, 1) AND window(-1, 2) AND window( 0, 1) AND tiles_available(conv_integer(tile_t));
	moves(v2t61) <= window( 1, 0) AND window( 1, 1) AND window( 2,-1) AND window( 2, 0) AND tiles_available(conv_integer(tile_t));
	moves(v2t70) <= window(-1, 1) AND window( 0, 1) AND window( 1, 1) AND window( 1, 2) AND tiles_available(conv_integer(tile_t));
	moves(v2t71) <= window( 1,-1) AND window( 1, 0) AND window( 2, 0) AND window( 2, 1) AND tiles_available(conv_integer(tile_t));
	
	
	-- TILE S
	-- rot 0 | rot 1   | rot 2    | rot 3 
	--	o     |   x   o |  xx   ox | ox
	--	xxx   | oxx xxx |  x    x  |  x  
	--   x   | x   x   | ox   xx  |  xx
	moves(v2s00) <= window( 1, 0) AND window( 1, 1) AND window( 1, 2) AND window( 2, 2) AND tiles_available(conv_integer(tile_s));
	moves(v2s10) <= window(-1, 2) AND window( 0, 1) AND window( 0, 2) AND window( 1, 0) AND tiles_available(conv_integer(tile_s));
	moves(v2s11) <= window( 1,-2) AND window( 1,-1) AND window( 1, 0) AND window( 2,-2) AND tiles_available(conv_integer(tile_s));
	moves(v2s20) <= window(-2, 1) AND window(-2, 2) AND window(-1, 1) AND window( 0, 1) AND tiles_available(conv_integer(tile_s));
	moves(v2s21) <= window( 0, 1) AND window( 1, 0) AND window( 2,-1) AND window( 2, 0) AND tiles_available(conv_integer(tile_s));
	moves(v2s30) <= window( 0, 1) AND window( 1, 1) AND window( 2, 1) AND window( 2, 2) AND tiles_available(conv_integer(tile_s));
	
	
	-- TILE R
	-- rot 0 | rot 1    | rot 2         | rot 3 
	--	ox    |  xx   ox |   x    x    o | o
	--  xx   | ox   xx  |  xx   ox   xx | xx
	--   x   | x    x   | ox   xx   xx  |  xx
	moves(v2r00) <= window( 0, 1) AND window( 1, 1) AND window( 1, 2) AND window( 2, 2) AND tiles_available(conv_integer(tile_r));
	moves(v2r10) <= window(-1, 1) AND window(-1, 2) AND window( 0, 1) AND window( 1, 0) AND tiles_available(conv_integer(tile_r));
	moves(v2r11) <= window( 0, 1) AND window( 1,-1) AND window( 1, 0) AND window( 2,-1) AND tiles_available(conv_integer(tile_r));
	moves(v2r20) <= window(-2, 2) AND window(-1, 1) AND window(-1, 2) AND window( 0, 1) AND tiles_available(conv_integer(tile_r));
	moves(v2r21) <= window(-1, 1) AND window( 0, 1) AND window( 1,-1) AND window( 1, 0) AND tiles_available(conv_integer(tile_r));
	moves(v2r22) <= window( 1,-1) AND window( 1, 0) AND window( 2,-2) AND window( 2,-1) AND tiles_available(conv_integer(tile_r));
	moves(v2r30) <= window( 1, 0) AND window( 1, 1) AND window( 2, 1) AND window( 2, 2) AND tiles_available(conv_integer(tile_r));
	
	
	-- TILE Q
	-- rot 0 | rot 1    | rot 2 | rot 3 
	--	o     |   x    o | oxx   | oxx
	--	x     |   x	   x | x     |   x
	-- xxx   | oxx  xxx | x     |   x
	moves(v2q00) <= window( 1, 0) AND window( 2, 0) AND window( 2, 1) AND window( 2, 2) AND tiles_available(conv_integer(tile_q));
	moves(v2q10) <= window(-2, 2) AND window(-1, 2) AND window( 0, 1) AND window( 0, 2) AND tiles_available(conv_integer(tile_q));
	moves(v2q11) <= window( 1, 0) AND window( 2,-2) AND window( 2,-1) AND window( 2, 0) AND tiles_available(conv_integer(tile_q));
	moves(v2q20) <= window( 0, 1) AND window( 0, 2) AND window( 1, 0) AND window( 2, 0) AND tiles_available(conv_integer(tile_q));
	moves(v2q30) <= window( 0, 1) AND window( 0, 2) AND window( 1, 2) AND window( 2, 2) AND tiles_available(conv_integer(tile_q));
	
	
	-- TILE P
	-- rot 0    | rot 2 | rot 3    | rot 4
	--	 x    o  | o     |   x    o | oxx
	--	 x    x  | xxx   | oxx  xxx |	 x
	-- oxx  xxx | x     |   x    x |  x
	moves(v2p00) <= window(-2, 1) AND window(-1, 1) AND window( 0, 1) AND window( 0, 2) AND tiles_available(conv_integer(tile_p));
	moves(v2p01) <= window( 1, 0) AND window( 2,-1) AND window( 2, 0) AND window( 2, 1) AND tiles_available(conv_integer(tile_p));
	moves(v2p20) <= window( 1, 0) AND window( 1, 1) AND window( 1, 2) AND window( 2, 0) AND tiles_available(conv_integer(tile_p));
	moves(v2p30) <= window(-1, 2) AND window( 0, 1) AND window( 0, 2) AND window( 1, 2) AND tiles_available(conv_integer(tile_p));
	moves(v2p31) <= window( 1,-2) AND window( 1,-1) AND window( 1, 0) AND window( 2, 0) AND tiles_available(conv_integer(tile_p));
	moves(v2p40) <= window( 0, 1) AND window( 0, 2) AND window( 1, 1) AND window( 2, 1) AND tiles_available(conv_integer(tile_p));
	
	
	-- TILE O
	-- rot 0 | rot 1  | rot 2 | rot 3 | rot 4  | rot 5 | rot 6      | rot 7
	--	o     |  x   o | oxxx  | oxxx  |  x   o | o     |  x     o   |   x     o
	--	xx    | ox  xx	|   x   |  x    |  x   x | x     | oxxx  xxxx | oxxx  xxxx
	-- x     |  x	 x |       |       | ox  xx | xx    |            |
	-- x     |  x   x |       |       |  x   x | x     |            |
	moves(v2o00) <= window( 1, 0) AND window( 1, 1) AND window( 2, 0) AND window( 3, 0) AND tiles_available(conv_integer(tile_o));
	moves(v2o10) <= window(-1, 1) AND window( 0, 1) AND window( 1, 1) AND window( 2, 1) AND tiles_available(conv_integer(tile_o));
	moves(v2o11) <= window( 1,-1) AND window( 1, 0) AND window( 2, 0) AND window( 3, 0) AND tiles_available(conv_integer(tile_o));
	moves(v2o20) <= window( 0, 1) AND window( 0, 2) AND window( 0, 3) AND window( 1, 2) AND tiles_available(conv_integer(tile_o));
	moves(v2o30) <= window( 0, 1) AND window( 0, 2) AND window( 0, 3) AND window( 1, 1) AND tiles_available(conv_integer(tile_o));
	moves(v2o40) <= window(-2, 1) AND window(-1, 1) AND window( 0, 1) AND window( 1, 1) AND tiles_available(conv_integer(tile_o));
	moves(v2o41) <= window( 1, 0) AND window( 2,-1) AND window( 2, 0) AND window( 3, 0) AND tiles_available(conv_integer(tile_o));
	moves(v2o50) <= window( 1, 0) AND window( 2, 0) AND window( 2, 1) AND window( 3, 0) AND tiles_available(conv_integer(tile_o));
	moves(v2o60) <= window(-1, 1) AND window( 0, 1) AND window( 0, 2) AND window( 0, 3) AND tiles_available(conv_integer(tile_o));
	moves(v2o61) <= window( 1,-1) AND window( 1, 0) AND window( 1, 1) AND window( 1, 2) AND tiles_available(conv_integer(tile_o));
	moves(v2o70) <= window(-1, 2) AND window( 0, 1) AND window( 0, 2) AND window( 0, 3) AND tiles_available(conv_integer(tile_o));
	moves(v2o71) <= window( 1,-2) AND window( 1,-1) AND window( 1, 0) AND window( 1, 1) AND tiles_available(conv_integer(tile_o));
	
	
	-- TILE N
	-- rot 0  | rot 1 | rot 2    | rot 6
	--	xx  ox | ox    | o x  x o | oxx  
	--	 x   x | x	   | xxx  xxx | x x
	-- ox  xx | xx	   |          |
	moves(v2n00) <= window( 0, 1) AND window(-1, 1) AND window(-2, 0) AND window(-2, 1) AND tiles_available(conv_integer(tile_n));
	moves(v2n01) <= window( 0, 1) AND window( 1, 1) AND window( 2, 0) AND window( 2, 1) AND tiles_available(conv_integer(tile_n));
	moves(v2n10) <= window( 0, 1) AND window( 1, 0) AND window( 2, 0) AND window( 2, 1) AND tiles_available(conv_integer(tile_n));
	moves(v2n20) <= window( 0, 2) AND window( 1, 0) AND window( 1, 1) AND window( 1, 2) AND tiles_available(conv_integer(tile_n));
	moves(v2n21) <= window( 0,-2) AND window( 1,-2) AND window( 1,-1) AND window( 1, 0) AND tiles_available(conv_integer(tile_n));
	moves(v2n60) <= window( 0, 1) AND window( 0, 2) AND window( 1, 0) AND window( 1, 2) AND tiles_available(conv_integer(tile_n));
	

	-- TILE M
	-- rot 0  | rot 1 | rot 2 | rot 3    | rot 4 | rot 5 | rot 6 | rot 7
	--	 x   o | o     | ox    |  xx   ox | ox    | ox    | oxx   | oxx
	--	ox  xx | xx	   | xxx   | oxx  xxx | xx    | xx    |  xx   | xx
	-- xx  xx | xx	   |       |          | x     |  x    |       |
	moves(v2m00) <= window(-1, 1) AND window( 0, 1) AND window( 1, 0) AND window( 1, 1) AND tiles_available(conv_integer(tile_m));
	moves(v2m01) <= window( 1,-1) AND window( 1, 0) AND window( 2,-1) AND window( 2, 0) AND tiles_available(conv_integer(tile_m));
	moves(v2m10) <= window( 1, 0) AND window( 1, 1) AND window( 2, 0) AND window( 2, 1) AND tiles_available(conv_integer(tile_m));
	moves(v2m20) <= window( 0, 1) AND window( 1, 0) AND window( 1, 1) AND window( 1, 2) AND tiles_available(conv_integer(tile_m));
	moves(v2m30) <= window(-1, 1) AND window(-1, 2) AND window( 0, 1) AND window( 0, 2) AND tiles_available(conv_integer(tile_m));
	moves(v2m31) <= window( 0, 1) AND window( 1,-1) AND window( 1, 0) AND window( 1, 1) AND tiles_available(conv_integer(tile_m));
	moves(v2m40) <= window( 0, 1) AND window( 1, 0) AND window( 1, 1) AND window( 2, 0) AND tiles_available(conv_integer(tile_m));
	moves(v2m50) <= window( 0, 1) AND window( 1, 0) AND window( 1, 1) AND window( 2, 1) AND tiles_available(conv_integer(tile_m));
	moves(v2m60) <= window( 0, 1) AND window( 0, 2) AND window( 1, 1) AND window( 1, 2) AND tiles_available(conv_integer(tile_m));
	moves(v2m70) <= window( 0, 1) AND window( 0, 2) AND window( 1, 0) AND window( 1, 1) AND tiles_available(conv_integer(tile_m));
	
	
	-- TILE L
	-- rot 0  | rot 1 | rot 2 | rot 3      | rot 4  | rot 5 | rot 6  | rot 7
	--	 x   o | o     | ox    |   xx    ox |  x   o | o     | oxx    |  xxx   oxx
	--	 x   x | x	   |  xxx  | oxx   xxx  | ox  xx | xx    |   xx   | ox    xx
	-- ox  xx | xx    |       |            | x   x  |  x    |        |
	-- x   x  |  x    |       |            | x   x  |  x    |        |
	moves(v2l00) <= window(-2, 1) AND window(-1, 1) AND window( 0, 1) AND window( 1, 0) AND tiles_available(conv_integer(tile_l));
	moves(v2l01) <= window( 1, 0) AND window( 2,-1) AND window( 2, 0) AND window( 3,-1) AND tiles_available(conv_integer(tile_l));
	moves(v2l10) <= window( 1, 0) AND window( 2, 0) AND window( 2, 1) AND window( 3, 1) AND tiles_available(conv_integer(tile_l));
	moves(v2l20) <= window( 0, 1) AND window( 1, 1) AND window( 1, 2) AND window( 1, 3) AND tiles_available(conv_integer(tile_l));
	moves(v2l30) <= window(-1, 2) AND window(-1, 3) AND window( 0, 1) AND window( 0, 2) AND tiles_available(conv_integer(tile_l));
	moves(v2l31) <= window( 0, 1) AND window( 1,-2) AND window( 1,-1) AND window( 1, 0) AND tiles_available(conv_integer(tile_l));
	moves(v2l40) <= window(-1, 1) AND window( 0, 1) AND window( 1, 0) AND window( 2, 0) AND tiles_available(conv_integer(tile_l));
	moves(v2l41) <= window( 1,-1) AND window( 1, 0) AND window( 2,-1) AND window( 3,-1) AND tiles_available(conv_integer(tile_l));
	moves(v2l50) <= window( 1, 0) AND window( 1, 1) AND window( 2, 1) AND window( 3, 1) AND tiles_available(conv_integer(tile_l));
	moves(v2l60) <= window( 0, 1) AND window( 0, 2) AND window( 1, 2) AND window( 1, 3) AND tiles_available(conv_integer(tile_l));
	moves(v2l70) <= window(-1, 1) AND window(-1, 2) AND window(-1, 3) AND window( 0, 1) AND tiles_available(conv_integer(tile_l));
	moves(v2l71) <= window( 0, 1) AND window( 0, 2) AND window( 1,-1) AND window( 1, 0) AND tiles_available(conv_integer(tile_l));
	
	
	-- TILE K
	-- rot 0  | rot 1 | rot 2 | rot 3      | rot 4 | rot 5 | rot 6 | rot 7
	--	 x   o | o     | o     |    x     o | ox    | ox    | oxxx  | oxxx
	--	 x   x | x	   | xxxx  | oxxx  xxxx | x     |  x    |    x  | x
	--  x   x | x	   |       |            | x     |  x    |       |
	-- ox  xx | xx    |       |            | x     |  x    |       |
	moves(v2k00) <= window(-3, 1) AND window(-2, 1) AND window(-1, 1) AND window( 0, 1) AND tiles_available(conv_integer(tile_k));
	moves(v2k01) <= window( 1, 0) AND window( 2, 0) AND window( 3,-1) AND window( 3, 0) AND tiles_available(conv_integer(tile_k));
	moves(v2k10) <= window( 1, 0) AND window( 2, 0) AND window( 3, 0) AND window( 3, 1) AND tiles_available(conv_integer(tile_k));
	moves(v2k20) <= window( 1, 0) AND window( 1, 1) AND window( 1, 2) AND window( 1, 3) AND tiles_available(conv_integer(tile_k));
	moves(v2k30) <= window(-1, 3) AND window( 0, 1) AND window( 0, 2) AND window( 0, 3) AND tiles_available(conv_integer(tile_k));
	moves(v2k31) <= window( 1,-3) AND window( 1,-2) AND window( 1,-1) AND window( 1, 0) AND tiles_available(conv_integer(tile_k));
	moves(v2k40) <= window( 0, 1) AND window( 1, 0) AND window( 2, 0) AND window( 3, 0) AND tiles_available(conv_integer(tile_k));
	moves(v2k50) <= window( 0, 1) AND window( 1, 1) AND window( 2, 1) AND window( 3, 1) AND tiles_available(conv_integer(tile_k));
	moves(v2k60) <= window( 0, 1) AND window( 0, 2) AND window( 0, 3) AND window( 1, 3) AND tiles_available(conv_integer(tile_k));
	moves(v2k70) <= window( 0, 1) AND window( 0, 2) AND window( 0, 3) AND window( 1, 0) AND tiles_available(conv_integer(tile_k));
	
	
	-- TILE J
	-- rot 0 | rot 2
	--	 o    | oxxxx
	--	 x    |
	--  x    |
	--  x    |
	--  x    |
	moves(v2j00) <= window( 1, 0) AND window( 2, 0) AND window( 3, 0) AND window( 4, 0) AND tiles_available(conv_integer(tile_j));
	moves(v2j20) <= window( 0, 1) AND window( 0, 2) AND window( 0, 3) AND window( 0, 4) AND tiles_available(conv_integer(tile_j));
	
	
	-- TILE I
	-- rot 0 | rot 1    | rot 2  | rot 3
	--	 ox   |  xx   ox |  x   o | o
	--	  xx  | ox   xx  | ox  xx | xx
	--       | 	        | x   x  |  x
	moves(v2i00) <= window( 0, 1) AND window( 1, 1) AND window( 1, 2) AND tiles_available(conv_integer(tile_i));
	moves(v2i10) <= window(-1, 1) AND window(-1, 2) AND window( 0, 1) AND tiles_available(conv_integer(tile_i));
	moves(v2i11) <= window( 0, 1) AND window( 1,-1) AND window( 1, 0) AND tiles_available(conv_integer(tile_i));
	moves(v2i20) <= window(-1, 1) AND window( 0, 1) AND window( 1, 0) AND tiles_available(conv_integer(tile_i));
	moves(v2i21) <= window( 1,-1) AND window( 1, 0) AND window( 2,-1) AND tiles_available(conv_integer(tile_i));
	moves(v2i30) <= window( 1, 0) AND window( 1, 1) AND window( 2, 1) AND tiles_available(conv_integer(tile_i));

	
	-- TILE H
	-- rot 0
	--	 ox
	--	 xx
	moves(v2h00) <= window( 0, 1) AND window( 1, 0) AND window( 1, 1) AND tiles_available(conv_integer(tile_h));
	
	
	-- TILE G
	-- rot 0 | rot 1  | rot 2 | rot 6
	--	 o    |  x   o | oxx   |  x    o
	--	 xx   | ox  xx |  x    | oxx  xxx
	--  x    |  x   x |       |
	moves(v2g00) <= window( 1, 0) AND window( 1, 1) AND window( 2, 0) AND tiles_available(conv_integer(tile_g));
	moves(v2g10) <= window(-1, 1) AND window( 0, 1) AND window( 1, 1) AND tiles_available(conv_integer(tile_g));
	moves(v2g11) <= window( 1,-1) AND window( 1, 0) AND window( 2, 0) AND tiles_available(conv_integer(tile_g));
	moves(v2g20) <= window( 0, 1) AND window( 0, 2) AND window( 1, 1) AND tiles_available(conv_integer(tile_g));
	moves(v2g60) <= window(-1, 1) AND window( 0, 1) AND window( 0, 2) AND tiles_available(conv_integer(tile_g));
	moves(v2g61) <= window( 1,-1) AND window( 1, 0) AND window( 1, 1) AND tiles_available(conv_integer(tile_g));
	
	
	-- TILE F
	-- rot 0  | rot 1 | rot 2 | rot 3    | rot 4 | rot 5 | rot 6 | rot 7
	--	 x   o | o     | o     |   x    o | ox    | ox    | oxx   | oxx
	--	 x   x | x     | xxx   | oxx  xxx | x     |  x    |   x   | x
	-- ox  xx | xx    |       |          | x     |  x    |       |
	moves(v2f00) <= window(-2, 1) AND window(-1, 1) AND window( 0, 1) AND tiles_available(conv_integer(tile_f));
	moves(v2f01) <= window( 1, 0) AND window( 2,-1) AND window( 2, 0) AND tiles_available(conv_integer(tile_f));
	moves(v2f10) <= window( 1, 0) AND window( 2, 0) AND window( 2, 1) AND tiles_available(conv_integer(tile_f));
	moves(v2f20) <= window( 1, 0) AND window( 1, 1) AND window( 1, 2) AND tiles_available(conv_integer(tile_f));
	moves(v2f30) <= window(-1, 2) AND window( 0, 1) AND window( 0, 2) AND tiles_available(conv_integer(tile_f));
	moves(v2f31) <= window( 1,-2) AND window( 1,-1) AND window( 1, 0) AND tiles_available(conv_integer(tile_f));
	moves(v2f40) <= window( 0, 1) AND window( 1, 0) AND window( 2, 0) AND tiles_available(conv_integer(tile_f));
	moves(v2f50) <= window( 0, 1) AND window( 1, 1) AND window( 2, 1) AND tiles_available(conv_integer(tile_f));
	moves(v2f60) <= window( 0, 1) AND window( 0, 2) AND window( 1, 2) AND tiles_available(conv_integer(tile_f));
	moves(v2f70) <= window( 0, 1) AND window( 0, 2) AND window( 1, 0) AND tiles_available(conv_integer(tile_f));

	
	-- TILE E
	-- rot 0 | rot 2
	--	 o    | oxxx
	--	 x    |
	--  x    |
	--  x    |
	moves(v2e00) <= window( 1, 0) AND window( 2, 0) AND window( 3, 0) AND tiles_available(conv_integer(tile_e));
	moves(v2e20) <= window( 0, 1) AND window( 0, 2) AND window( 0, 3) AND tiles_available(conv_integer(tile_e));
	
	
	-- TILE D
	-- rot 0 | rot 1  | rot 2 | rot 3
	--	 o    |  x   o | ox    | ox
	--	 xx   | ox  xx | x     |  x
	moves(v2d00) <= window( 1, 0) AND window( 1, 1) AND tiles_available(conv_integer(tile_d));
	moves(v2d10) <= window(-1, 1) AND window( 0, 1) AND tiles_available(conv_integer(tile_d));
	moves(v2d11) <= window( 1,-1) AND window( 1, 0) AND tiles_available(conv_integer(tile_d));
	moves(v2d20) <= window( 0, 1) AND window( 1, 0) AND tiles_available(conv_integer(tile_d));
	moves(v2d30) <= window( 0, 1) AND window( 1, 1) AND tiles_available(conv_integer(tile_d));
	
	
	-- TILE C
	-- rot 0 | rot 2
	--	 o    | oxx
	--	 x    |
	--  x    |
	moves(v2c00) <= window( 1, 0) AND window( 2, 0) AND tiles_available(conv_integer(tile_c));
	moves(v2c20) <= window( 0, 1) AND window( 0, 2) AND tiles_available(conv_integer(tile_c));
	
	
	-- TILE B
	-- rot 0 | rot 2
	--	 o    | ox
	--	 x    |
	moves(v2b00) <= window( 1, 0) AND tiles_available(conv_integer(tile_b));
	moves(v2b20) <= window( 0, 1) AND tiles_available(conv_integer(tile_b));
	
	
	-- TILE A
	-- rot 0
	--	 o
	moves(v2a00) <= tiles_available(conv_integer(tile_a));
end moveChecker_vertex2Arch;