library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.types.ALL;

entity min_max_manager is
	generic (max_level : positive := 10;
			 bits_level : positive := 4);
	port (----------------
          ---- INPUTS ----
		  ----------------
		  clk, rst : in STD_LOGIC;
		  -- Tree control
		  new_level	: in STD_LOGIC;
		  close_level : in STD_LOGIC;
		  clean_level	: in STD_LOGIC;
		  evaluating	: in STD_LOGIC;
		  -- Best move
		  move : in STD_LOGIC_VECTOR(16-1 downto 0);
		  -- Score from evaluator
		  score : in STD_LOGIC_VECTOR(10-1 downto 0);
		  -----------------
		  ---- OUTPUTS ----
		  -----------------
		  level			    	: out STD_LOGIC_VECTOR(bits_level-1 downto 0);
		  current_max_level : out STD_LOGIC_VECTOR(bits_level-1 downto 0);
		  prune			 	 	: out STD_LOGIC;
		  move_to_sort		: out tp_array_movements;
		  score_to_sort		: out STD_LOGIC_VECTOR(10-1 downto 0);
		  best_move			: out STD_LOGIC_VECTOR(16-1 downto 0);
		  -- Info for prunes memory
		  prune_L3					: out STD_LOGIC;
		  prune_L4				: out STD_LOGIC;
		  prune_mem_move_L1 : out STD_LOGIC_VECTOR(15 downto 0);
		  prune_mem_move_L2 : out STD_LOGIC_VECTOR(15 downto 0);
		  prune_mem_move_L3 : out STD_LOGIC_VECTOR(15 downto 0);
		  prune_mem_move_L4 : out STD_LOGIC_VECTOR(15 downto 0)
	);
end min_max_manager;

architecture min_max_managerArch of min_max_manager is
	component registroDobleResetConInicializacion
		generic( n : positive := 128; inicial : natural := 0);
		port( clk, rst, rst2, ld : in std_logic;
			din : in std_logic_vector( n-1 downto 0 );
			dout : out std_logic_vector( n-1 downto 0 ) );
	end component;
	
	component max_reg is
		generic(bits : positive := 128; init_value : natural);
		port (clk, rst: in STD_LOGIC;
				rst2 : in STD_LOGIC;
				ld : in STD_LOGIC;
				din  : in STD_LOGIC_VECTOR(bits-1 downto 0);
				dout : out STD_LOGIC_VECTOR(bits-1 downto 0)
		);
	end component;
	
	component min_reg is
		generic(bits : positive := 128; init_value : natural);
		port (clk, rst: in STD_LOGIC;
				rst2 : in STD_LOGIC;
				ld : in STD_LOGIC;
				din  : in STD_LOGIC_VECTOR(bits-1 downto 0);
				dout : out STD_LOGIC_VECTOR(bits-1 downto 0)
		);
	end component;
	
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
	
	component counterIncDec
		generic( n : integer := 8 );
		port( clk, rst, rst2, inc, dec : in std_logic;
			dout : out std_logic_vector( n-1 downto 0 ) );
	end component;
	
	component counter_initValue
		generic (initialValue : natural; numBits : positive);
		port (clk : in  STD_LOGIC;
				rst : in STD_LOGIC;
				rst2 : in STD_LOGIC;
				inc : in  STD_LOGIC;
				count : out  STD_LOGIC_VECTOR (numBits-1 downto 0));
	end component;
	
	
   -- Best move register
	signal ld_best_move: STD_LOGIC;
	
	-- Best move level 2
	signal new_candidate_lvl2_score: STD_LOGIC_VECTOR(10-1 downto 0);
	signal ld_best_move_lvl2: STD_LOGIC;
	signal best_move_lvl2: STD_LOGIC_VECTOR(16-1 downto 0);	
	
	-- Best move level 3
	signal ld_current_candidate_lvl3: STD_LOGIC;
	signal current_candidate_lvl3: STD_LOGIC_VECTOR(16-1 downto 0); 
	signal current_candidate_lvl3_score: STD_LOGIC_VECTOR(10-1 downto 0);	
	signal best_move_lvl3: STD_LOGIC_VECTOR(16-1 downto 0);
	
	-- Best move level 4
	signal ld_current_candidate_lvl4: STD_LOGIC;
	signal current_candidate_lvl4: STD_LOGIC_VECTOR(16-1 downto 0);
	signal current_candidate_lvl4_score: STD_LOGIC_VECTOR(10-1 downto 0);
	signal best_lvl4_current_lvl3: STD_LOGIC_VECTOR(16-1 downto 0);
	signal best_move_lvl4: STD_LOGIC_VECTOR(16-1 downto 0);
	
	-- MINMAX
	signal rst_min_max_regs: STD_LOGIC_VECTOR(max_level downto 0);
		-- Last move regs
		signal ld_last_move: STD_LOGIC_VECTOR(max_level downto 0);
		type tp_last_move_array is array(0 to max_level) of STD_LOGIC_VECTOR(16-1 downto 0);
		signal last_move_out: tp_last_move_array;
		
		-- Score regs
		signal ld_score: STD_LOGIC_VECTOR(max_level-1 downto 0);
		signal score_in: STD_LOGIC_VECTOR(10-1 downto 0);
		type tp_score_array is array(0 to max_level-1) of STD_LOGIC_VECTOR(10-1 downto 0);
		signal score_out: tp_score_array;
	
	signal inc_level, dec_level: STD_LOGIC;
	signal level_int: STD_LOGIC_VECTOR(bits_level-1 downto 0);
	
	-- Iterative deepening stuff
	signal rst_current_max_level, inc_current_max_level: STD_LOGIC;
	signal current_max_level_int: STD_LOGIC_VECTOR(4-1 downto 0);
	
	
	-- DEBUG
	signal debug_last_x_lvl0, debug_last_y_lvl0: STD_LOGIC_VECTOR(3 downto 0);
	signal debug_last_tile_lvl0: STD_LOGIC_VECTOR(4 downto 0);
	signal debug_last_rot_lvl0: STD_LOGIC_VECTOR(2 downto 0);
	
	signal debug_score_lvl0, debug_score_lvl1, debug_score_lvl2, debug_score_lvl3, debug_score_lvl4: STD_LOGIC_VECTOR(10-1 downto 0);
begin			
	---------------------------------------------------------------------
	-------------------------- MIN-MAX CONTROL --------------------------
	---------------------------------------------------------------------
	treeRegisters: for i in 0 to max_level generate
		-- Last move generated in each level
		lastMoveReg: registroDobleResetConInicializacion generic map(4*2+5+3, 0)
			port map(clk, 
						rst,
						rst_min_max_regs(i),
						ld_last_move(i),
						move,
						last_move_out(i)
			);
				
		rst_min_max_regs(i) <= '1' when (close_level = '1' OR clean_level = '1') AND conv_integer(level_int) = i else '0';
		ld_last_move(i) <= '1' when new_level = '1' AND level_int = i else '0';		
		
		not_last_level: if i < max_level generate
			-- Min-max values
			score_in <= score when evaluating = '1' else score_out(conv_integer(level_int));
		
			-- Min-max values
			max: if i mod 2 = 0 generate
				max_reg_I: max_reg generic map(10, 0)
					port map (clk, rst, rst_min_max_regs(i), ld_score(i), score_in, score_out(i));
			end generate;
			
			min: if i mod 2 /= 0 generate
				min_reg_I: min_reg generic map(10, 1023)
					port map (clk, rst, rst_min_max_regs(i), ld_score(i), score_in, score_out(i));
			end generate;
			
			ld_score(i) <= '1' when close_level = '1' AND level_int-1 = i AND level_int /= 0 else '0';
		end generate;
	end generate;	
	
	-------------------------------------
	------------- BEST MOVE -------------
	-------------------------------------
	best_move_reg: reg generic map(4*2+5+3, 0) -- (15..x..12 11..y..8 7..tile..3 2..rotation..0)
		port map(clk => clk, 
					rst => rst, 
					ld => ld_best_move,
					din => last_move_out(0),
					dout => best_move);		

	ld_best_move <= '1' when close_level = '1' 			  AND 
									 conv_integer(level_int) = 1 AND
									 ((evaluating = '1' AND score > score_out(0)) OR (evaluating = '0' AND score_out(1) > score_out(0))) else
						 '0';

	-----------------------------------------
	------------- CURRENT LEVEL -------------
	-----------------------------------------
	inc_level <= new_level;
	dec_level <= '1' when (close_level = '1' OR clean_level = '1') AND level_int /= 0 else '0';
	levelCounter: counterIncDec generic map(bits_level)
			port map(clk, rst, '0', inc_level, dec_level, level_int);
	
	---------------------------------------------
	------------- CURRENT MAX LEVEL -------------
	---------------------------------------------					
	current_max_levelCounter: counter_initValue generic map(2, bits_level)
			port map(clk, rst, rst_current_max_level, inc_current_max_level, current_max_level_int);
	
	inc_current_max_level <= '1' when close_level = '1' AND level_int = 0 AND current_max_level_int < max_level else '0';
	rst_current_max_level <= '1' when (close_level = '1' AND level_int = 0 AND current_max_level_int = max_level) OR (clean_level = '1' AND level_int = 0) else '0';
	
			
	---------------------------------------------
	------------- BEST MOVE LEVEL 2 -------------
	---------------------------------------------
	best_move_lvl2_reg: reg generic map(4*2+5+3, 0)
		port map(clk, rst, ld_best_move_lvl2, last_move_out(1), best_move_lvl2);		

	new_candidate_lvl2_score <= score when evaluating = '1' else score_out(2);
	ld_best_move_lvl2 <= '1' when close_level = '1'								 AND 
											level_int = 2				 					 AND
											new_candidate_lvl2_score < score_out(1) else
								'0';
	
	---------------------------------------------
	------------- BEST MOVE LEVEL 3 -------------
	---------------------------------------------
	current_candidate_lvl3_reg: reg generic map(4*2+5+3, 0)
		port map(clk, rst, ld_current_candidate_lvl3, last_move_out(2), current_candidate_lvl3);
	
	current_candidate_lvl3_score <= score when evaluating = '1' else score_out(3);
	ld_current_candidate_lvl3 <= '1' when close_level = '1' 			 				 		 AND 
													  level_int = 3 				 						 AND
													  current_candidate_lvl3_score > score_out(2) else
										  '0';
	
	best_move_lvl3_reg: reg generic map(4*2+5+3, 0)
		port map(clk, rst, ld_best_move_lvl2, current_candidate_lvl3, best_move_lvl3);
	
	---------------------------------------------
	------------- BEST MOVE LEVEL 4 -------------
	---------------------------------------------
	-- Current best lvl4 move in the current branch
	current_candidate_lvl4_reg: reg generic map(4*2+5+3, 0)
		port map(clk, rst, ld_current_candidate_lvl4, last_move_out(3), current_candidate_lvl4);
	
	current_candidate_lvl4_score <= score when evaluating = '1' else score_out(4);
	ld_current_candidate_lvl4 <= '1' when close_level = '1' 			 				 		 AND 
													  level_int = 4 				 						 AND
													  current_candidate_lvl4_score < score_out(3) else
										  '0';
	
	-- Best lvl4 move in the branch of the current best lvl3 move so far
	best_lvl4_current_lvl3_reg: reg generic map(4*2+5+3, 0)
		port map(clk, rst, ld_current_candidate_lvl3, current_candidate_lvl4, best_lvl4_current_lvl3);	
	
	-- Chain best lvl4
	best_move_lvl4_reg: reg generic map(4*2+5+3, 0)
		port map(clk, rst, ld_best_move_lvl2, best_lvl4_current_lvl3, best_move_lvl4);
	
	
	-- OUTPUTS
	level <= level_int;
	current_max_level <= current_max_level_int;	
	prune <= '1' when (current_max_level_int > 2) AND
					  (level_int > 0) 			  AND
					  (
					   ((level_int(0) = '0') AND (score_out(conv_integer(level_int)) >= score_out(conv_integer(level_int-1))))
						OR
					   ((level_int(0) = '1') AND (score_out(conv_integer(level_int)) <= score_out(conv_integer(level_int-1))))
					  )
			          else
			 '0';
				
	-- Distinguish between best chain stores or level 2 nodes
	move_to_sort(0) <= last_move_out(0);
	move_to_sort(1) <= best_move_lvl2 when level_int = 1 else last_move_out(1);
	move_to_sort(2) <= best_move_lvl3;
	move_to_sort(3) <= best_move_lvl4;
	score_to_sort <= score_out(1) when level_int = 1 else score;
	
	-- Prunes memory
	prune_L3 <= '1' when current_max_level_int >= 3 AND level_int = 2 AND close_level = '1' else '0';
	prune_L4 <= '1' when current_max_level_int >= 4 AND level_int = 3 else '0';
	prune_mem_move_L1 <= last_move_out(0);
	prune_mem_move_L2 <= last_move_out(1);
	--prune_mem_move_L3 <= last_move_out(2);
	prune_mem_move_L3 <= current_candidate_lvl3;
	prune_mem_move_L4 <= last_move_out(3);
	
	-- DEBUG
	debug_last_x_lvl0    <= last_move_out(0)(15 downto 12);
	debug_last_y_lvl0    <= last_move_out(0)(11 downto 8);
	debug_last_tile_lvl0 <= last_move_out(0)(7 downto 3);
	debug_last_rot_lvl0  <= last_move_out(0)(2 downto 0);
	
	debug_score_lvl0 <= score_out(0);
	debug_score_lvl1 <= score_out(1);
	debug_score_lvl2 <= score_out(2);
	debug_score_lvl3 <= score_out(3);
	debug_score_lvl4 <= score_out(4);
	-- DEBUG
end min_max_managerArch;