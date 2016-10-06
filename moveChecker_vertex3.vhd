library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.types.ALL;

entity moveChecker_vertex3 is
	port (----------------
			---- INPUTS ----
			----------------
			window 			 : in tpProcessingWindow;
			tiles_available : in STD_LOGIC_VECTOR(21-1 downto 0);
			-----------------
			---- OUTPUTS ----
			-----------------
			moves : out STD_LOGIC_VECTOR(v3a00 downto v3u00)
	);
end moveChecker_vertex3;

architecture moveChecker_vertex3Arch of moveChecker_vertex3 is
begin
	-- TILE U
	-- rot 0
	--  x    o
	--	xxo  xxx
	--  x    x
	moves(v3u00) <= window(-1,-1) AND window( 0,-2) AND window( 0,-1) AND window( 1,-1) AND tiles_available(conv_integer(tile_u));
	moves(v3u01) <= window( 1,-1) AND window( 1, 0) AND window( 1, 1) AND window( 2, 0) AND tiles_available(conv_integer(tile_u));
	
	
	-- TILE T
	-- rot 0      | rot 1 | rot 2 | rot 3    | rot 4    | rot 5    | rot 6    | rot 7 
	--	x    o	  |   o   |  xo   | xx   xo  |  x    o  |  x    o  |  x    o  |  x    o
	--	xxo  xxx   | xxx   | xx    |  xo   xx | xxo  xxx | xxo  xxx |  xo   xx | xx   xx
	--  x    x    |  x    |  x    |  x    x  |   x    x | x    x   | xx   xx  |  xo   xx
 	moves(v3t00) <= window(-1,-2) AND window( 0,-2) AND window( 0,-1) AND window( 1,-1) AND tiles_available(conv_integer(tile_t));
	moves(v3t01) <= window( 1, 0) AND window( 1, 1) AND window( 1, 2) AND window( 2, 1) AND tiles_available(conv_integer(tile_t));
	moves(v3t10) <= window( 1,-2) AND window( 1,-1) AND window( 1, 0) AND window( 2,-1) AND tiles_available(conv_integer(tile_t));
	moves(v3t20) <= window( 0,-1) AND window( 1,-2) AND window( 1,-1) AND window( 2,-1) AND tiles_available(conv_integer(tile_t));
	moves(v3t30) <= window(-1,-2) AND window(-1,-1) AND window( 0,-1) AND window( 1,-1) AND tiles_available(conv_integer(tile_t));
	moves(v3t31) <= window( 0,-1) AND window( 1, 0) AND window( 1, 1) AND window( 2, 0) AND tiles_available(conv_integer(tile_t));
	moves(v3t40) <= window(-1,-1) AND window( 0,-2) AND window( 0,-1) AND window( 1, 0) AND tiles_available(conv_integer(tile_t));
	moves(v3t41) <= window( 1,-1) AND window( 1, 0) AND window( 1, 1) AND window( 2, 1) AND tiles_available(conv_integer(tile_t));
	moves(v3t50) <= window(-1,-1) AND window( 0,-2) AND window( 0,-1) AND window( 1,-2) AND tiles_available(conv_integer(tile_t));
	moves(v3t51) <= window( 1,-1) AND window( 1, 0) AND window( 1, 1) AND window( 2,-1) AND tiles_available(conv_integer(tile_t));
	moves(v3t60) <= window(-1,-1) AND window( 0,-1) AND window( 1,-2) AND window( 1,-1) AND tiles_available(conv_integer(tile_t));
	moves(v3t61) <= window( 1, 0) AND window( 1, 1) AND window( 2,-1) AND window( 2, 0) AND tiles_available(conv_integer(tile_t));
	moves(v3t70) <= window(-2,-1) AND window(-1,-2) AND window(-1,-1) AND window( 0,-1) AND tiles_available(conv_integer(tile_t));
	moves(v3t71) <= window( 1,-1) AND window( 1, 0) AND window( 2, 0) AND window( 2, 1) AND tiles_available(conv_integer(tile_t));
	
	
	-- TILE S
	-- rot 0    | rot 1 | rot 2 | rot 3 
	--	x    o   |   o   |  xo   | xx   xo
	--	xxo  xxx | xxx   |  x    |  x    x
	--   x    x | x     | xx    |  xo   xx
	moves(v3s00) <= window(-1,-2) AND window( 0,-2) AND window( 0,-1) AND window( 1, 0) AND tiles_available(conv_integer(tile_s));
	moves(v3s01) <= window( 1, 0) AND window( 1, 1) AND window( 1, 2) AND window( 2, 2) AND tiles_available(conv_integer(tile_s));
	moves(v3s10) <= window( 1,-2) AND window( 1,-1) AND window( 1, 0) AND window( 2,-2) AND tiles_available(conv_integer(tile_s));
	moves(v3s20) <= window( 0,-1) AND window( 1,-1) AND window( 2,-2) AND window( 2,-1) AND tiles_available(conv_integer(tile_s));
	moves(v3s30) <= window(-2,-2) AND window(-2,-1) AND window(-1,-1) AND window( 0,-1) AND tiles_available(conv_integer(tile_s));
	moves(v3s31) <= window( 0,-1) AND window( 1, 0) AND window( 2, 0) AND window( 2, 1) AND tiles_available(conv_integer(tile_s));
	
	
	-- TILE R
	-- rot 0    | rot 1 | rot 2 | rot 3 
	--	xx   xo  |  xo   |   o   | x    x    o
	--  xo   xx | xx    |  xx   | xx   xo   xx
	--   x    x | x     | xx    |  xo   xx   xx
	moves(v3r00) <= window(-1,-2) AND window(-1,-1) AND window( 0,-1) AND window( 1, 0) AND tiles_available(conv_integer(tile_r));
	moves(v3r01) <= window( 0,-1) AND window( 1, 0) AND window( 1, 1) AND window( 2, 1) AND tiles_available(conv_integer(tile_r));
	moves(v3r10) <= window( 0,-1) AND window( 1,-2) AND window( 1,-1) AND window( 2,-2) AND tiles_available(conv_integer(tile_r));
	moves(v3r20) <= window( 1,-1) AND window( 1, 0) AND window( 2,-2) AND window( 2,-1) AND tiles_available(conv_integer(tile_r));
	moves(v3r30) <= window(-2,-2) AND window(-1,-2) AND window(-1,-1) AND window( 0,-1) AND tiles_available(conv_integer(tile_r));
	moves(v3r31) <= window(-1,-1) AND window( 0,-1) AND window( 1, 0) AND window( 1, 1) AND tiles_available(conv_integer(tile_r));
	moves(v3r32) <= window( 1, 0) AND window( 1, 1) AND window( 2, 1) AND window( 2, 2) AND tiles_available(conv_integer(tile_r));
	
	
	-- TILE Q
	-- rot 0    | rot 1 | rot 2 | rot 3 
	--	x    o   |   o   | xxo   | xxo
	--	x    x   |   x   | x     |   x
	-- xxo  xxx | xxx   | x     |   x
	moves(v3q00) <= window(-2,-2) AND window(-1,-2) AND window( 0,-2) AND window( 0,-1) AND tiles_available(conv_integer(tile_q));
	moves(v3q01) <= window( 1, 0) AND window( 2, 0) AND window( 2, 1) AND window( 2, 2) AND tiles_available(conv_integer(tile_q));
	moves(v3q10) <= window( 1, 0) AND window( 2,-2) AND window( 2,-1) AND window( 2, 0) AND tiles_available(conv_integer(tile_q));
	moves(v3q20) <= window( 0,-2) AND window( 0,-1) AND window( 1,-2) AND window( 2,-2) AND tiles_available(conv_integer(tile_q));
	moves(v3q30) <= window( 0,-2) AND window( 0,-1) AND window( 1, 0) AND window( 2, 0) AND tiles_available(conv_integer(tile_q));
	
	
	-- TILE P
	-- rot 0    | rot 2    | rot 3 | rot 4
	--	 x    o  | x    o   |   o   | xxo
	--	 x    x  | xxo  xxx | xxx   |	 x
	-- xxo  xxx | x    x   |   x   |  x
	moves(v3p00) <= window(-2,-1) AND window(-1,-1) AND window( 0,-2) AND window( 0,-1) AND tiles_available(conv_integer(tile_p));
	moves(v3p01) <= window( 1, 0) AND window( 2,-1) AND window( 2, 0) AND window( 2, 1) AND tiles_available(conv_integer(tile_p));
	moves(v3p20) <= window(-1,-2) AND window( 0,-2) AND window( 0,-1) AND window( 1,-2) AND tiles_available(conv_integer(tile_p));
	moves(v3p21) <= window( 1, 0) AND window( 1, 1) AND window( 1, 2) AND window( 2, 0) AND tiles_available(conv_integer(tile_p));
	moves(v3p30) <= window( 1,-2) AND window( 1,-1) AND window( 1, 0) AND window( 2, 0) AND tiles_available(conv_integer(tile_p));
	moves(v3p40) <= window( 0,-2) AND window( 0,-1) AND window( 1,-1) AND window( 2,-1) AND tiles_available(conv_integer(tile_p));
	
	
	-- TILE O
	-- rot 0  | rot 1 | rot 2 | rot 3 | rot 4 | rot 5  | rot 6      | rot 7
	--	x   o  |  o    | xxxo  | xxxo  |  o    | x   o  |  x     o   |   x     o
	--	xo  xx | xx    |   x   |  x    |  x    | x   x  | xxxo  xxxx | xxxo  xxxx
	-- x   x  |  x    |       |       | xx    | xo  xx |            |
	-- x   x  |  x    |       |       |  x    | x   x  |            |
	moves(v3o00) <= window(-1,-1) AND window( 0,-1) AND window( 1,-1) AND window( 2,-1) AND tiles_available(conv_integer(tile_o));
	moves(v3o01) <= window( 1, 0) AND window( 1, 1) AND window( 2, 0) AND window( 3, 0) AND tiles_available(conv_integer(tile_o));
	moves(v3o10) <= window( 1,-1) AND window( 1, 0) AND window( 2, 0) AND window( 3, 0) AND tiles_available(conv_integer(tile_o));
	moves(v3o20) <= window( 0,-3) AND window( 0,-2) AND window( 0,-1) AND window( 1,-1) AND tiles_available(conv_integer(tile_o));
	moves(v3o30) <= window( 0,-3) AND window( 0,-2) AND window( 0,-1) AND window( 1,-2) AND tiles_available(conv_integer(tile_o));
	moves(v3o40) <= window( 1, 0) AND window( 2,-1) AND window( 2, 0) AND window( 3, 0) AND tiles_available(conv_integer(tile_o));
	moves(v3o50) <= window(-2,-1) AND window(-1,-1) AND window( 0,-1) AND window( 1,-1) AND tiles_available(conv_integer(tile_o));
	moves(v3o51) <= window( 1, 0) AND window( 2, 0) AND window( 2, 1) AND window( 3, 0) AND tiles_available(conv_integer(tile_o));
	moves(v3o60) <= window(-1,-2) AND window( 0,-3) AND window( 0,-2) AND window( 0,-1) AND tiles_available(conv_integer(tile_o));
	moves(v3o61) <= window( 1,-1) AND window( 1, 0) AND window( 1, 1) AND window( 1, 2) AND tiles_available(conv_integer(tile_o));
	moves(v3o70) <= window(-1,-1) AND window( 0,-3) AND window( 0,-2) AND window( 0,-1) AND tiles_available(conv_integer(tile_o));
	moves(v3o71) <= window( 1,-2) AND window( 1,-1) AND window( 1, 0) AND window( 1, 1) AND tiles_available(conv_integer(tile_o));
	
	
	-- TILE N
	-- rot 0 | rot 1  | rot 2    | rot 6
	--	xo    | xx  xo | o x  x o | xxo  
	--	 x    | x	x  | xxx  xxx | x x
	-- xx    | xo  xx |          |
	moves(v3n00) <= window( 0,-1) AND window( 1, 0) AND window( 2,-1) AND window( 2, 0) AND tiles_available(conv_integer(tile_n));
	moves(v3n10) <= window(-2,-1) AND window(-2, 0) AND window(-1,-1) AND window( 0,-1) AND tiles_available(conv_integer(tile_n));
	moves(v3n11) <= window( 0,-1) AND window( 1,-1) AND window( 2,-1) AND window( 2, 0) AND tiles_available(conv_integer(tile_n));
	moves(v3n20) <= window( 0, 2) AND window( 1, 0) AND window( 1, 1) AND window( 1, 2) AND tiles_available(conv_integer(tile_n));
	moves(v3n21) <= window( 0,-2) AND window( 1,-2) AND window( 1,-1) AND window( 1, 0) AND tiles_available(conv_integer(tile_n));
	moves(v3n60) <= window( 0,-2) AND window( 0,-1) AND window( 1,-2) AND window( 1, 0) AND tiles_available(conv_integer(tile_n));
	

	-- TILE M
	-- rot 0 | rot 1  | rot 2    | rot 3 | rot 4 | rot 5 | rot 6 | rot 7
	--	 o    | x   o  | xx   xo  |  xo   | xo    | xo    | xxo   | xxo
	--	xx    | xo  xx	| xxo  xxx | xxx   | xx    | xx    |  xx   | xx
	-- xx    | xx	xx |          |       | x     |  x    |       |
	moves(v3m00) <= window( 1,-1) AND window( 1, 0) AND window( 2,-1) AND window( 2, 0) AND tiles_available(conv_integer(tile_m));
	moves(v3m10) <= window(-1,-1) AND window( 0,-1) AND window( 1,-1) AND window( 1, 0) AND tiles_available(conv_integer(tile_m));
	moves(v3m11) <= window( 1, 0) AND window( 1, 1) AND window( 2, 0) AND window( 2, 1) AND tiles_available(conv_integer(tile_m));
	moves(v3m20) <= window(-1,-2) AND window(-1,-1) AND window( 0,-2) AND window( 0,-1) AND tiles_available(conv_integer(tile_m));
	moves(v3m21) <= window( 0,-1) AND window( 1,-1) AND window( 1, 0) AND window( 1, 1) AND tiles_available(conv_integer(tile_m));
	moves(v3m30) <= window( 0,-1) AND window( 1,-2) AND window( 1,-1) AND window( 1, 0) AND tiles_available(conv_integer(tile_m));
	moves(v3m40) <= window( 0,-1) AND window( 1,-1) AND window( 1, 0) AND window( 2,-1) AND tiles_available(conv_integer(tile_m));
	moves(v3m50) <= window( 0,-1) AND window( 1,-1) AND window( 1, 0) AND window( 2, 0) AND tiles_available(conv_integer(tile_m));
	moves(v3m60) <= window( 0,-2) AND window( 0,-1) AND window( 1,-1) AND window( 1, 0) AND tiles_available(conv_integer(tile_m));
	moves(v3m70) <= window( 0,-2) AND window( 0,-1) AND window( 1,-2) AND window( 1,-1) AND tiles_available(conv_integer(tile_m));
	
	
	-- TILE L
	-- rot 0 | rot 1 | rot 2      | rot 3 | rot 4 | rot 5  | rot 6      | rot 7
	--	 o    | x  o  | xx    xo   |   xo  |  o    | x   o  | xxx   xxo  |  xxo
	--	 x    | x  x  |  xxo   xxx | xxx   | xx    | xo  xx |   xo    xx | xx
	-- xx    | xo xx |            |       | x     |  x   x |            |
	-- x     |  x  x |            |       | x     |  x   x |            |
	moves(v3l00) <= window( 1, 0) AND window( 2,-1) AND window( 2, 0) AND window( 3,-1) AND tiles_available(conv_integer(tile_l));
	moves(v3l10) <= window(-2,-1) AND window(-1,-1) AND window( 0,-1) AND window( 1, 0) AND tiles_available(conv_integer(tile_l));
	moves(v3l11) <= window( 1, 0) AND window( 2, 0) AND window( 2, 1) AND window( 3, 1) AND tiles_available(conv_integer(tile_l));
	moves(v3l20) <= window(-1,-3) AND window(-1,-2) AND window( 0,-2) AND window( 0,-1) AND tiles_available(conv_integer(tile_l));
	moves(v3l21) <= window( 0,-1) AND window( 1, 0) AND window( 1, 1) AND window( 1, 2) AND tiles_available(conv_integer(tile_l));
	moves(v3l30) <= window( 0,-1) AND window( 1,-3) AND window( 1,-2) AND window( 1,-1) AND tiles_available(conv_integer(tile_l));
	moves(v3l40) <= window( 1,-1) AND window( 1, 0) AND window( 2,-1) AND window( 3,-1) AND tiles_available(conv_integer(tile_l));
	moves(v3l50) <= window(-1,-1) AND window( 0,-1) AND window( 1, 0) AND window( 2, 0) AND tiles_available(conv_integer(tile_l));
	moves(v3l51) <= window( 1, 0) AND window( 1, 1) AND window( 2, 1) AND window( 3, 1) AND tiles_available(conv_integer(tile_l));
	moves(v3l60) <= window(-1,-3) AND window(-1,-2) AND window(-1,-1) AND window( 0,-1) AND tiles_available(conv_integer(tile_l));
	moves(v3l61) <= window( 0,-2) AND window( 0,-1) AND window( 1, 0) AND window( 1, 1) AND tiles_available(conv_integer(tile_l));
	moves(v3l70) <= window( 0,-2) AND window( 0,-1) AND window( 1,-3) AND window( 1,-2) AND tiles_available(conv_integer(tile_l));
	
	
	-- TILE K
	-- rot 0 | rot 1  | rot 2      | rot 3 | rot 4 | rot 5 | rot 6 | rot 7
	--	 o    | x   o  | x     o    |    o  | xo    | xo    | xxxo  | xxxo
	--	 x    | x   x  | xxxo  xxxx | xxxx  | x     |  x    |    x  | x
	--  x    | x   x  |            |       | x     |  x    |       |
	-- xx    | xo  xx |            |       | x     |  x    |       |
	moves(v3k00) <= window( 1, 0) AND window( 2, 0) AND window( 3,-1) AND window( 3, 0) AND tiles_available(conv_integer(tile_k));
	moves(v3k10) <= window(-3,-1) AND window(-2,-1) AND window(-1,-1) AND window( 0,-1) AND tiles_available(conv_integer(tile_k));
	moves(v3k11) <= window( 1, 0) AND window( 2, 0) AND window( 3, 0) AND window( 3, 1) AND tiles_available(conv_integer(tile_k));
	moves(v3k20) <= window(-1,-3) AND window( 0,-3) AND window( 0,-2) AND window( 0,-1) AND tiles_available(conv_integer(tile_k));
	moves(v3k21) <= window( 1, 0) AND window( 1, 1) AND window( 1, 2) AND window( 1, 3) AND tiles_available(conv_integer(tile_k));
	moves(v3k30) <= window( 1,-3) AND window( 1,-2) AND window( 1,-1) AND window( 1, 0) AND tiles_available(conv_integer(tile_k));
	moves(v3k40) <= window( 0,-1) AND window( 1,-1) AND window( 2,-1) AND window( 3,-1) AND tiles_available(conv_integer(tile_k));
	moves(v3k50) <= window( 0,-1) AND window( 1, 0) AND window( 2, 0) AND window( 3, 0) AND tiles_available(conv_integer(tile_k));
	moves(v3k60) <= window( 0,-3) AND window( 0,-2) AND window( 0,-1) AND window( 1, 0) AND tiles_available(conv_integer(tile_k));
	moves(v3k70) <= window( 0,-3) AND window( 0,-2) AND window( 0,-1) AND window( 1,-3) AND tiles_available(conv_integer(tile_k));
	
	
	-- TILE J
	-- rot 0 | rot 2
	--	 o    | xxxxo
	--	 x    |
	--  x    |
	--  x    |
	--  x    |
	moves(v3j00) <= window( 1, 0) AND window( 2, 0) AND window( 3, 0) AND window( 4, 0) AND tiles_available(conv_integer(tile_j));
	moves(v3j20) <= window( 0,-4) AND window( 0,-3) AND window( 0,-2) AND window( 0,-1) AND tiles_available(conv_integer(tile_j));
	
	
	-- TILE I
	-- rot 0     | rot 1 | rot 2 | rot 3
	--	 xx   xo  |  xo   |  o    | x   o
	--	  xo   xx | xx    | xx    | xo  xx
	--           |       | x     |  x   x
	moves(v3i00) <= window(-1,-2) AND window(-1,-1) AND window( 0,-1) AND tiles_available(conv_integer(tile_i));
	moves(v3i01) <= window( 0,-1) AND window( 1, 0) AND window( 1, 1) AND tiles_available(conv_integer(tile_i));
	moves(v3i10) <= window( 0,-1) AND window( 1,-2) AND window( 1,-1) AND tiles_available(conv_integer(tile_i));
	moves(v3i20) <= window( 1,-1) AND window( 1, 0) AND window( 2,-1) AND tiles_available(conv_integer(tile_i));
	moves(v3i30) <= window(-1,-1) AND window( 0,-1) AND window( 1, 0) AND tiles_available(conv_integer(tile_i));
	moves(v3i31) <= window( 1, 0) AND window( 1, 1) AND window( 2, 1) AND tiles_available(conv_integer(tile_i));
	
	
	-- TILE H
	-- rot 0
	--	 xo
	--	 xx
	moves(v3h00) <= window( 0,-1) AND window( 1,-1) AND window( 1, 0) AND tiles_available(conv_integer(tile_h));
	
	
	-- TILE G
	-- rot 0   | rot 1 | rot 2 | rot 6
	--	 x   o  |  o    | xxo   |  x    o
	--	 xo  xx | xx    |  x    | xxo  xxx
	--  x   x  |  x    |       |
	moves(v3g00) <= window(-1,-1) AND window( 0,-1) AND window( 1,-1) AND tiles_available(conv_integer(tile_g));
	moves(v3g01) <= window( 1, 0) AND window( 1, 1) AND window( 2, 0) AND tiles_available(conv_integer(tile_g));
	moves(v3g10) <= window( 1,-1) AND window( 1, 0) AND window( 2, 0) AND tiles_available(conv_integer(tile_g));
	moves(v3g20) <= window( 0,-2) AND window( 0,-1) AND window( 1,-1) AND tiles_available(conv_integer(tile_g));
	moves(v3g60) <= window(-1,-1) AND window( 0,-2) AND window( 0,-1) AND tiles_available(conv_integer(tile_g));
	moves(v3g61) <= window( 1,-1) AND window( 1, 0) AND window( 1, 1) AND tiles_available(conv_integer(tile_g));

	
	-- TILE F
	-- rot 0 | rot 1 | rot 2    | rot 3 | rot 4 | rot 5 | rot 6 | rot 7
	--	 o    | x  o  | x    o   |   o   | xo    | xo    | xxo   | xxo
	--	 x    | x  x  | xxo  xxx | xxx   | x     |  x    |   x   | x
	-- xx    | xo xx |          |       | x     |  x    |       |
	moves(v3f00) <= window( 1, 0) AND window( 2,-1) AND window( 2, 0) AND tiles_available(conv_integer(tile_f));
	moves(v3f10) <= window(-2,-1) AND window(-1,-1) AND window( 0,-1) AND tiles_available(conv_integer(tile_f));
	moves(v3f11) <= window( 1, 0) AND window( 2, 0) AND window( 2, 1) AND tiles_available(conv_integer(tile_f));
	moves(v3f20) <= window(-1,-2) AND window( 0,-2) AND window( 0,-1) AND tiles_available(conv_integer(tile_f));
	moves(v3f21) <= window( 1, 0) AND window( 1, 1) AND window( 1, 2) AND tiles_available(conv_integer(tile_f));
	moves(v3f30) <= window( 1,-2) AND window( 1,-1) AND window( 1, 0) AND tiles_available(conv_integer(tile_f));
	moves(v3f40) <= window( 0,-1) AND window( 1,-1) AND window( 2,-1) AND tiles_available(conv_integer(tile_f));
	moves(v3f50) <= window( 0,-1) AND window( 1, 0) AND window( 2, 0) AND tiles_available(conv_integer(tile_f));
	moves(v3f60) <= window( 0,-2) AND window( 0,-1) AND window( 1, 0) AND tiles_available(conv_integer(tile_f));
	moves(v3f70) <= window( 0,-2) AND window( 0,-1) AND window( 1,-2) AND tiles_available(conv_integer(tile_f));

	
	-- TILE E
	-- rot 0 | rot 2
	--	 o    | xxxo
	--	 x    |
	--  x    |
	--  x    |
	moves(v3e00) <= window( 1, 0) AND window( 2, 0) AND window( 3, 0) AND tiles_available(conv_integer(tile_e));
	moves(v3e20) <= window( 0,-3) AND window( 0,-2) AND window( 0,-1) AND tiles_available(conv_integer(tile_e));
	
	
	-- TILE D
	-- rot 0   | rot 1 | rot 2 | rot 3
	--	 x   o  |  o    | xo    | xo
	--	 xo  xx | xx    | x     |  x
	moves(v3d00) <= window(-1,-1) AND window( 0,-1) AND tiles_available(conv_integer(tile_d));
	moves(v3d01) <= window( 1, 0) AND window( 1, 1) AND tiles_available(conv_integer(tile_d));
	moves(v3d10) <= window( 1,-1) AND window( 1, 0) AND tiles_available(conv_integer(tile_d));
	moves(v3d20) <= window( 0,-1) AND window( 1,-1) AND tiles_available(conv_integer(tile_d));
	moves(v3d30) <= window( 0,-1) AND window( 1, 0) AND tiles_available(conv_integer(tile_d));
	
	
	-- TILE C
	-- rot 0 | rot 2
	--	 o    | xxo
	--	 x    |
	--  x    |
	moves(v3c00) <= window( 1, 0) AND window( 2, 0) AND tiles_available(conv_integer(tile_c));
	moves(v3c20) <= window( 0,-2) AND window( 0,-1) AND tiles_available(conv_integer(tile_c));
	
	
	-- TILE B
	-- rot 0 | rot 2
	--	 o    | xo
	--	 x    |
	moves(v3b00) <= window( 1, 0) AND tiles_available(conv_integer(tile_b));
	moves(v3b20) <= window( 0,-1) AND tiles_available(conv_integer(tile_b));
	
	
	-- TILE A
	-- rot 0
	--	 o
	moves(v3a00) <= tiles_available(conv_integer(tile_a));
end moveChecker_vertex3Arch;