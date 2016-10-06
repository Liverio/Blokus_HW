library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.types.ALL;

entity moveChecker_vertex0 is
	port (----------------
			---- INPUTS ----
			----------------
			window 			 : in tpProcessingWindow;
			tiles_available : in STD_LOGIC_VECTOR(21-1 downto 0);
			-----------------
			---- OUTPUTS ----
			-----------------
			moves : out STD_LOGIC_VECTOR(v0a00 downto v0u00)
	);
end moveChecker_vertex0;

architecture moveChecker_vertex0Arch of moveChecker_vertex0 is
begin
	-- TILE U
	-- rot 0
	--  x     x
	--	xxx   xxo
	--  o     x  
	moves(v0u00) <= window(-2, 0) AND window(-1,-1) AND window(-1, 0) AND window(-1, 1) AND tiles_available(conv_integer(tile_u));
	moves(v0u01) <= window(-1,-1) AND window( 0,-2) AND window( 0,-1) AND window( 1,-1) AND tiles_available(conv_integer(tile_u));
	
	
	-- TILE T
	-- rot 0     | rot 1    | rot 2    | rot 3    | rot 4 | rot 5    | rot 6    | rot 7 
	--	x	   x   |   x    x |  xx   xo | xx   xx  |  x    |  x    x  |  x    x  |  x
	--	xxx   xxo | xxx  xxo | xx   xx  |  xx   xo | xxx   | xxx  xxo |  xx   xo | xx
	--  o     x  |  o    x  |  o    x  |  o    x  |   o   | o    x   | xo   xx  |  xo
 	moves(v0t00) <= window(-2,-1) AND window(-1,-1) AND window(-1, 0) AND window(-1, 1) AND tiles_available(conv_integer(tile_t));
	moves(v0t01) <= window(-1,-2) AND window( 0,-2) AND window( 0,-1) AND window( 1,-1) AND tiles_available(conv_integer(tile_t));
	moves(v0t10) <= window(-2, 1) AND window(-1,-1) AND window(-1, 0) AND window(-1, 1) AND tiles_available(conv_integer(tile_t));
	moves(v0t11) <= window(-1, 0) AND window( 0,-2) AND window( 0,-1) AND window( 1,-1) AND tiles_available(conv_integer(tile_t));
	moves(v0t20) <= window(-2, 0) AND window(-2, 1) AND window(-1,-1) AND window(-1, 0) AND tiles_available(conv_integer(tile_t));
	moves(v0t21) <= window( 0,-1) AND window( 1,-2) AND window( 1,-1) AND window( 2,-1) AND tiles_available(conv_integer(tile_t));
	moves(v0t30) <= window(-2,-1) AND window(-2, 0) AND window(-1, 0) AND window(-1, 1) AND tiles_available(conv_integer(tile_t));
	moves(v0t31) <= window(-1,-2) AND window(-1,-1) AND window( 0,-1) AND window( 1,-1) AND tiles_available(conv_integer(tile_t));
	moves(v0t40) <= window(-2,-1) AND window(-1,-2) AND window(-1,-1) AND window(-1, 0) AND tiles_available(conv_integer(tile_t));
	moves(v0t50) <= window(-2, 1) AND window(-1, 0) AND window(-1, 1) AND window(-1, 2) AND tiles_available(conv_integer(tile_t));
	moves(v0t51) <= window(-1,-1) AND window( 0,-2) AND window( 0,-1) AND window( 1,-2) AND tiles_available(conv_integer(tile_t));
	moves(v0t60) <= window(-2, 0) AND window(-1, 0) AND window(-1, 1) AND window( 0,-1) AND tiles_available(conv_integer(tile_t));
	moves(v0t61) <= window(-1,-1) AND window( 0,-1) AND window( 1,-2) AND window( 1,-1) AND tiles_available(conv_integer(tile_t));
	moves(v0t70) <= window(-2,-1) AND window(-1,-2) AND window(-1,-1) AND window( 0,-1) AND tiles_available(conv_integer(tile_t));
	
	
	-- TILE S
	-- rot 0 | rot 1    | rot 2    | rot 3 
	--	x     |   x    x |  xx   xo | xx
	--	xxx   | xxx  xxo |  x    x  |  x
	--   o   | o    x   | xo   xx  |  xo
	moves(v0s00) <= window(-2,-2) AND window(-1,-2) AND window(-1,-1) AND window(-1, 0) AND tiles_available(conv_integer(tile_s));
	moves(v0s10) <= window(-2, 2) AND window(-1, 0) AND window(-1, 1) AND window(-1, 2) AND tiles_available(conv_integer(tile_s));
	moves(v0s11) <= window(-1, 0) AND window( 0,-2) AND window( 0,-1) AND window( 1,-2) AND tiles_available(conv_integer(tile_s));
	moves(v0s20) <= window(-2, 0) AND window(-2, 1) AND window(-1, 0) AND window( 0,-1) AND tiles_available(conv_integer(tile_s));
	moves(v0s21) <= window( 0,-1) AND window( 1,-1) AND window( 2,-2) AND window( 2,-1) AND tiles_available(conv_integer(tile_s));
	moves(v0s30) <= window(-2,-2) AND window(-2,-1) AND window(-1,-1) AND window( 0,-1) AND tiles_available(conv_integer(tile_s));
	
	
	-- TILE R
	-- rot 0 | rot 1         | rot 2    | rot 3 
	--	xx    |  xx   xx   xo |   x    x | x
	--	 xx   | xx   xo   xx  |  xx   xo | xx
	--   o   | o    x    x   | xo   xx  |  xo
	moves(v0r00) <= window(-2,-2) AND window(-2,-1) AND window(-1,-1) AND window(-1, 0) AND tiles_available(conv_integer(tile_r));
	moves(v0r10) <= window(-2, 1) AND window(-2, 2) AND window(-1, 0) AND window(-1, 1) AND tiles_available(conv_integer(tile_r));
	moves(v0r11) <= window(-1, 0) AND window(-1, 1) AND window( 0,-1) AND window( 1,-1) AND tiles_available(conv_integer(tile_r));
	moves(v0r12) <= window( 0,-1) AND window( 1,-2) AND window( 1,-1) AND window( 2,-2) AND tiles_available(conv_integer(tile_r));
	moves(v0r20) <= window(-2, 1) AND window(-1, 0) AND window(-1, 1) AND window( 0,-1) AND tiles_available(conv_integer(tile_r));
	moves(v0r21) <= window(-1, 0) AND window( 0,-1) AND window( 1,-2) AND window( 1,-1) AND tiles_available(conv_integer(tile_r));
	moves(v0r30) <= window(-2,-2) AND window(-1,-2) AND window(-1,-1) AND window( 0,-1) AND tiles_available(conv_integer(tile_r));
	
	
	-- TILE Q
	-- rot 0 | rot 1 | rot 2    | rot 3 
	--	x     |   x   | xxx  xxo | xxx
	--	x     |   x	  | x    x   |   x
	-- xxo   | xxo	  | o    x   |   o
	moves(v0q00) <= window(-2,-2) AND window(-1,-2) AND window( 0,-2) AND window( 0,-1) AND tiles_available(conv_integer(tile_q));
	moves(v0q10) <= window(-2, 0) AND window(-1, 0) AND window( 0,-2) AND window( 0,-1) AND tiles_available(conv_integer(tile_q));
	moves(v0q20) <= window(-2, 0) AND window(-2, 1) AND window(-2, 2) AND window(-1, 0) AND tiles_available(conv_integer(tile_q));
	moves(v0q21) <= window( 0,-2) AND window( 0,-1) AND window( 1,-2) AND window( 2,-2) AND tiles_available(conv_integer(tile_q));
	moves(v0q30) <= window(-2,-2) AND window(-2,-1) AND window(-2, 0) AND window(-1, 0) AND tiles_available(conv_integer(tile_q));
	
	
	-- TILE P
	-- rot 0 | rot 2    | rot 3 | rot 4
	--	 x    | x    x   |   x   | xxx  xxo
	--	 x    | xxx  xxo | xxx   |	 x    x
	-- xxo   | o    x	  |   o   |  o    x
	moves(v0p00) <= window(-2,-1) AND window(-1,-1) AND window( 0,-2) AND window( 0,-1) AND tiles_available(conv_integer(tile_p));
	moves(v0p20) <= window(-2, 0) AND window(-1, 0) AND window(-1, 1) AND window(-1, 2) AND tiles_available(conv_integer(tile_p));
	moves(v0p21) <= window(-1,-2) AND window( 0,-2) AND window( 0,-1) AND window( 1,-2) AND tiles_available(conv_integer(tile_p));
	moves(v0p30) <= window(-2, 0) AND window(-1,-2) AND window(-1,-1) AND window(-1, 0) AND tiles_available(conv_integer(tile_p));
	moves(v0p40) <= window(-2,-1) AND window(-2, 0) AND window(-2, 1) AND window(-1, 0) AND tiles_available(conv_integer(tile_p));
	moves(v0p41) <= window( 0,-2) AND window( 0,-1) AND window( 1,-1) AND window( 2,-1) AND tiles_available(conv_integer(tile_p));
	
	
	-- TILE O
	-- rot 0  | rot 1 | rot 2      | rot 3      | rot 4 | rot 5  | rot 6 | rot 7
	--	x   x  |  x    | xxxx  xxxo | xxxx  xxxo |  x    | x   x  |  x    |   x
	--	xx  xo | xx	   |   o     x  |  o     x   |  x    | x   x  | xxxo  | xxxo
	-- x   x  |  x	   |            |            | xx    | xx  xo |       |
	-- o   x  |  o    |            |            |  o    | o   x  |       |
	moves(v0o00) <= window(-3, 0) AND window(-2, 0) AND window(-2, 1) AND window(-1, 0) AND tiles_available(conv_integer(tile_o));
	moves(v0o01) <= window(-1,-1) AND window( 0,-1) AND window( 1,-1) AND window( 2,-1) AND tiles_available(conv_integer(tile_o));
	moves(v0o10) <= window(-3, 0) AND window(-2,-1) AND window(-2, 0) AND window(-1, 0) AND tiles_available(conv_integer(tile_o));
	moves(v0o20) <= window(-1,-2) AND window(-1,-1) AND window(-1, 0) AND window(-1, 1) AND tiles_available(conv_integer(tile_o));
	moves(v0o21) <= window( 0,-3) AND window( 0,-2) AND window( 0,-1) AND window( 1,-1) AND tiles_available(conv_integer(tile_o));
	moves(v0o30) <= window(-1,-1) AND window(-1, 0) AND window(-1, 1) AND window(-1, 2) AND tiles_available(conv_integer(tile_o));
	moves(v0o31) <= window( 0,-3) AND window( 0,-2) AND window( 0,-1) AND window( 1,-2) AND tiles_available(conv_integer(tile_o));
	moves(v0o40) <= window(-3, 0) AND window(-2, 0) AND window(-1,-1) AND window(-1, 0) AND tiles_available(conv_integer(tile_o));
	moves(v0o50) <= window(-3, 0) AND window(-2, 0) AND window(-1, 0) AND window(-1, 1) AND tiles_available(conv_integer(tile_o));
	moves(v0o51) <= window(-2,-1) AND window(-1,-1) AND window( 0,-1) AND window( 1,-1) AND tiles_available(conv_integer(tile_o));
	moves(v0o60) <= window(-1,-2) AND window( 0,-3) AND window( 0,-2) AND window( 0,-1) AND tiles_available(conv_integer(tile_o));
	moves(v0o70) <= window(-1,-1) AND window( 0,-3) AND window( 0,-2) AND window( 0,-1) AND tiles_available(conv_integer(tile_o));
	
	
	-- TILE N
	-- rot 0 | rot 1  | rot 2 | rot 6
	--	xx    | xx  xo | x x   | xxx  xxx
	--	 x    | x	x  | xxo   | o x  x o
	-- xo    | xo	xx |       |
	moves(v0n00) <= window(-2,-1) AND window(-2, 0) AND window(-1, 0) AND window( 0,-1) AND tiles_available(conv_integer(tile_n));
	moves(v0n10) <= window(-2,-1) AND window(-2, 0) AND window(-1,-1) AND window( 0,-1) AND tiles_available(conv_integer(tile_n));
	moves(v0n11) <= window( 0,-1) AND window( 1,-1) AND window( 2,-1) AND window( 2, 0) AND tiles_available(conv_integer(tile_n));
	moves(v0n20) <= window(-1,-2) AND window(-1, 0) AND window( 0,-2) AND window( 0,-1) AND tiles_available(conv_integer(tile_n));
	moves(v0n60) <= window(-1, 0) AND window(-1, 1) AND window(-1, 2) AND window( 0, 2) AND tiles_available(conv_integer(tile_n));
	moves(v0n61) <= window(-1,-2) AND window(-1,-1) AND window(-1, 0) AND window( 0,-2) AND tiles_available(conv_integer(tile_n));
	
	
	-- TILE M
	-- rot 0 | rot 1 | rot 2 | rot 3 | rot 4  | rot 5 | rot 6 | rot 7
	--	 x    | x     | xx    |  xx   | xx  xx | xx    | xxx   | xxx  xxo
	--	xx    | xx	  | xxo   | xxo   | xx  xo | xx    |  xo   | xo   xx
	-- xo    | xo	  |       |       | o   x  |  o    |       |
	moves(v0m00) <= window(-2, 0) AND window(-1,-1) AND window(-1, 0) AND window( 0,-1) AND tiles_available(conv_integer(tile_m));
	moves(v0m10) <= window(-2,-1) AND window(-1,-1) AND window(-1, 0) AND window( 0,-1) AND tiles_available(conv_integer(tile_m));
	moves(v0m20) <= window(-1,-2) AND window(-1,-1) AND window( 0,-2) AND window( 0,-1) AND tiles_available(conv_integer(tile_m));
	moves(v0m30) <= window(-1,-1) AND window(-1, 0) AND window( 0,-2) AND window( 0,-1) AND tiles_available(conv_integer(tile_m));
	moves(v0m40) <= window(-2, 0) AND window(-2, 1) AND window(-1, 0) AND window(-1, 1) AND tiles_available(conv_integer(tile_m));
	moves(v0m41) <= window(-1,-1) AND window(-1, 0) AND window( 0,-1) AND window( 1,-1) AND tiles_available(conv_integer(tile_m));
	moves(v0m50) <= window(-2,-1) AND window(-2, 0) AND window(-1,-1) AND window(-1, 0) AND tiles_available(conv_integer(tile_m));
	moves(v0m60) <= window(-1,-2) AND window(-1,-1) AND window(-1, 0) AND window( 0,-1) AND tiles_available(conv_integer(tile_m));
	moves(v0m70) <= window(-1,-1) AND window(-1, 0) AND window(-1, 1) AND window( 0,-1) AND tiles_available(conv_integer(tile_m));
	moves(v0m71) <= window( 0,-2) AND window( 0,-1) AND window( 1,-2) AND window( 1,-1) AND tiles_available(conv_integer(tile_m));
	
	
	-- TILE L
	-- rot 0  | rot 1 | rot 2 | rot 3      | rot 4  | rot 5 | rot 6 | rot 7
	--	 x   x | x     | xx    |   xx    xo |  x   x | x     | xxx   |  xxx   xxo
	--	 x   x | x	   |  xxo  | xxo   xxx  | xx  xo | xx    |   xo  | xo    xx
	-- xx  xo | xx	   |       |            | x   x  |  x    |       |
	-- o   x  |  o    |       |            | o   x  |  o    |       |
	moves(v0l00) <= window(-3, 1) AND window(-2, 1) AND window(-1, 0) AND window(-1, 1) AND tiles_available(conv_integer(tile_l));
	moves(v0l01) <= window(-2, 0) AND window(-1, 0) AND window( 0,-1) AND window( 1,-1) AND tiles_available(conv_integer(tile_l));
	moves(v0l10) <= window(-3,-1) AND window(-2,-1) AND window(-1,-1) AND window(-1, 0) AND tiles_available(conv_integer(tile_l));
	moves(v0l20) <= window(-1,-3) AND window(-1,-2) AND window( 0,-2) AND window( 0,-1) AND tiles_available(conv_integer(tile_l));
	moves(v0l30) <= window(-1, 0) AND window(-1, 1) AND window( 0,-2) AND window( 0,-1) AND tiles_available(conv_integer(tile_l));
	moves(v0l31) <= window( 0,-1) AND window( 1,-3) AND window( 1,-2) AND window( 1,-1) AND tiles_available(conv_integer(tile_l));
	moves(v0l40) <= window(-3, 1) AND window(-2, 0) AND window(-2, 1) AND window(-1, 0) AND tiles_available(conv_integer(tile_l));
	moves(v0l41) <= window(-1, 0) AND window( 0,-1) AND window( 1,-1) AND window( 2,-1) AND tiles_available(conv_integer(tile_l));
	moves(v0l50) <= window(-3,-1) AND window(-2,-1) AND window(-2, 0) AND window(-1, 0) AND tiles_available(conv_integer(tile_l));
	moves(v0l60) <= window(-1,-3) AND window(-1,-2) AND window(-1,-1) AND window( 0,-1) AND tiles_available(conv_integer(tile_l));
	moves(v0l70) <= window(-1, 0) AND window(-1, 1) AND window(-1, 2) AND window( 0,-1) AND tiles_available(conv_integer(tile_l));
	moves(v0l71) <= window( 0,-2) AND window( 0,-1) AND window( 1,-3) AND window( 1,-2) AND tiles_available(conv_integer(tile_l));
	
	
	-- TILE K
	-- rot 0 | rot 1 | rot 2 | rot 3 | rot 4  | rot 5 | rot 6 | rot 7
	--	 x    | x     | x     |    x  | xx  xo | xx    | xxxx  | xxxx  xxxo
	--	 x    | x	  | xxxo  | xxxo  | x   x  |  x    |    o  | o     x
	--  x    | x	  |       |       | x   x  |  x    |       |
	-- xo    | xo    |       |       | o   x  |  o    |       |
	moves(v0k00) <= window(-3, 0) AND window(-2, 0) AND window(-1, 0) AND window( 0,-1) AND tiles_available(conv_integer(tile_k));
	moves(v0k10) <= window(-3,-1) AND window(-2,-1) AND window(-1,-1) AND window( 0,-1) AND tiles_available(conv_integer(tile_k));
	moves(v0k20) <= window(-1,-3) AND window( 0,-3) AND window( 0,-2) AND window( 0,-1) AND tiles_available(conv_integer(tile_k));
	moves(v0k30) <= window(-1, 0) AND window( 0,-3) AND window( 0,-2) AND window( 0,-1) AND tiles_available(conv_integer(tile_k));
	moves(v0k40) <= window(-3, 0) AND window(-3, 1) AND window(-2, 0) AND window(-1, 0) AND tiles_available(conv_integer(tile_k));
	moves(v0k41) <= window( 0,-1) AND window( 1,-1) AND window( 2,-1) AND window( 3,-1) AND tiles_available(conv_integer(tile_k));
	moves(v0k50) <= window(-3,-1) AND window(-3, 0) AND window(-2, 0) AND window(-1, 0) AND tiles_available(conv_integer(tile_k));
	moves(v0k60) <= window(-1,-3) AND window(-1,-2) AND window(-1,-1) AND window(-1, 0) AND tiles_available(conv_integer(tile_k));
	moves(v0k70) <= window(-1, 0) AND window(-1, 1) AND window(-1, 2) AND window(-1, 3) AND tiles_available(conv_integer(tile_k));
	moves(v0k71) <= window( 0,-3) AND window( 0,-2) AND window( 0,-1) AND window( 1,-3) AND tiles_available(conv_integer(tile_k));
	
	
	-- TILE J
	-- rot 0 | rot 2
	--	 x    | xxxxo
	--	 x    |
	--  x    |
	--  x    |
	--  o    |
	moves(v0j00) <= window(-4, 0) AND window(-3, 0) AND window(-2, 0) AND window(-1, 0) AND tiles_available(conv_integer(tile_j));
	moves(v0j20) <= window( 0,-4) AND window( 0,-3) AND window( 0,-2) AND window( 0,-1) AND tiles_available(conv_integer(tile_j));
	
	
	-- TILE I
	-- rot 0 | rot 1    | rot 2  | rot 3
	--	 xx   |  xx   xo |  x   x | x
	--	  xo  | xo   xx  | xx  xo | xx
	--       | 	        | o   x  |  o
	moves(v0i00) <= window(-1,-2) AND window(-1,-1) AND window( 0,-1) AND tiles_available(conv_integer(tile_i));
	moves(v0i10) <= window(-1, 0) AND window(-1, 1) AND window( 0,-1) AND tiles_available(conv_integer(tile_i));
	moves(v0i11) <= window( 0,-1) AND window( 1,-2) AND window( 1,-1) AND tiles_available(conv_integer(tile_i));
	moves(v0i20) <= window(-2, 1) AND window(-1, 0) AND window(-1, 1) AND tiles_available(conv_integer(tile_i));
	moves(v0i21) <= window(-1, 0) AND window( 0,-1) AND window( 1,-1) AND tiles_available(conv_integer(tile_i));
	moves(v0i30) <= window(-2,-1) AND window(-1,-1) AND window(-1, 0) AND tiles_available(conv_integer(tile_i));
	
	
	-- TILE H
	-- rot 0
	--	 xx
	--	 xo
	moves(v0h00) <= window(-1,-1) AND window(-1, 0) AND window( 0,-1) AND tiles_available(conv_integer(tile_h));
	
	
	-- TILE G
	-- rot 0   | rot 1 | rot 2    | rot 6
	--	 x   x  |  x    | xxx  xxo |  x
	--	 xx  xo | xx    |  o    x  | xxo
	--  o   x  |  o    |          |
	moves(v0g00) <= window(-2, 0) AND window(-1, 0) AND window(-1, 1) AND tiles_available(conv_integer(tile_g));
	moves(v0g01) <= window(-1,-1) AND window( 0,-1) AND window( 1,-1) AND tiles_available(conv_integer(tile_g));
	moves(v0g10) <= window(-2, 0) AND window(-1,-1) AND window(-1, 0) AND tiles_available(conv_integer(tile_g));
	moves(v0g20) <= window(-1,-1) AND window(-1, 0) AND window(-1, 1) AND tiles_available(conv_integer(tile_g));
	moves(v0g21) <= window( 0,-2) AND window( 0,-1) AND window( 1,-1) AND tiles_available(conv_integer(tile_g));
	moves(v0g60) <= window(-1,-1) AND window( 0,-2) AND window( 0,-1) AND tiles_available(conv_integer(tile_g));
	
	
	-- TILE F
	-- rot 0 | rot 1 | rot 2 | rot 3 | rot 4  | rot 5 | rot 6 | rot 7
	--	 x    | x     | x     |   x   | xx  xo | xx    | xxx   | xxx  xxo
	--	 x    | x     | xxo   | xxo   | x   x  |  x    |   o   | o    x
	-- xo    | xo    |       |       | o   x  |  o    |       |
	moves(v0f00) <= window(-2, 0) AND window(-1, 0) AND window( 0,-1) AND tiles_available(conv_integer(tile_f));
	moves(v0f10) <= window(-2,-1) AND window(-1,-1) AND window( 0,-1) AND tiles_available(conv_integer(tile_f));
	moves(v0f20) <= window(-1,-2) AND window( 0,-2) AND window( 0,-1) AND tiles_available(conv_integer(tile_f));
	moves(v0f30) <= window(-1, 0) AND window( 0,-2) AND window( 0,-1) AND tiles_available(conv_integer(tile_f));
	moves(v0f40) <= window(-2, 0) AND window(-2, 1) AND window(-1, 0) AND tiles_available(conv_integer(tile_f));
	moves(v0f41) <= window( 0,-1) AND window( 1,-1) AND window( 2,-1) AND tiles_available(conv_integer(tile_f));
	moves(v0f50) <= window(-2,-1) AND window(-2, 0) AND window(-1, 0) AND tiles_available(conv_integer(tile_f));
	moves(v0f60) <= window(-1,-2) AND window(-1,-1) AND window(-1, 0) AND tiles_available(conv_integer(tile_f));
	moves(v0f70) <= window(-1, 0) AND window(-1, 1) AND window(-1, 2) AND tiles_available(conv_integer(tile_f));
	moves(v0f71) <= window( 0,-2) AND window( 0,-1) AND window( 1,-2) AND tiles_available(conv_integer(tile_f));

	
	-- TILE E
	-- rot 0 | rot 2
	--	 x    | xxxo
	--	 x    |
	--  x    |
	--  o    |
	moves(v0e00) <= window(-3, 0) AND window(-2, 0) AND window(-1, 0) AND tiles_available(conv_integer(tile_e));
	moves(v0e20) <= window( 0,-3) AND window( 0,-2) AND window( 0,-1) AND tiles_available(conv_integer(tile_e));
	
	
	-- TILE D
	-- rot 0 | rot 1 | rot 2  | rot 3
	--	 x    |  x    | xx  xo | xx
	--	 xo   | xo    | o   x  |  o
	moves(v0d00) <= window(-1,-1) AND window( 0,-1) AND tiles_available(conv_integer(tile_d));
	moves(v0d10) <= window(-1, 0) AND window( 0,-1) AND tiles_available(conv_integer(tile_d));
	moves(v0d20) <= window(-1, 0) AND window(-1, 1) AND tiles_available(conv_integer(tile_d));
	moves(v0d21) <= window( 0,-1) AND window( 1,-1) AND tiles_available(conv_integer(tile_d));
	moves(v0d30) <= window(-1,-1) AND window(-1, 0) AND tiles_available(conv_integer(tile_d));
	
	
	-- TILE C
	-- rot 0 | rot 2
	--	 x    | xxo
	--	 x    |
	--  o    |
	moves(v0c00) <= window(-2, 0) AND window(-1, 0) AND tiles_available(conv_integer(tile_c));
	moves(v0c20) <= window( 0,-2) AND window( 0,-1) AND tiles_available(conv_integer(tile_c));
	
	
	-- TILE B
	-- rot 0 | rot 2
	--	 x    | xo
	--	 o    |
	moves(v0b00) <= window(-1, 0) AND tiles_available(conv_integer(tile_b));
	moves(v0b20) <= window( 0,-1) AND tiles_available(conv_integer(tile_b));
	
	
	-- TILE A
	-- rot 0
	--	 o
	moves(v0a00) <= tiles_available(conv_integer(tile_a));
end moveChecker_vertex0Arch;