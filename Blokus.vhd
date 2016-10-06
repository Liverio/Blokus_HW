library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;
use work.types.ALL;
-- For DCM
Library UNISIM;
use UNISIM.vcomponents.all;

entity Blokus is
    port (----------------
          ---- INPUTS ----
          ----------------
          clk100, rst : in  STD_LOGIC;
          new_game : in STD_LOGIC;
          depth    : in STD_LOGIC_VECTOR(3-1 downto 0);
          -- Performance monitoring and debugging
          move_selector : in STD_LOGIC_VECTOR(6-1 downto 0);    -- Both for move and #boards
          -- For SW game time
          new_game_SW  : in STD_LOGIC;
          game_over_SW : in STD_LOGIC;
          -----------------
          ---- OUTPUTS ----
          -----------------
          game_over : out STD_LOGIC;
          -- DEBUG
          leds : out STD_LOGIC_VECTOR(3-1 downto 0);
          -- Performance monitoring and debugging
          moves_num   : out STD_LOGIC_VECTOR(6-1 downto 0);
          move        : out STD_LOGIC_VECTOR(16-1 downto 0);
          boards_num  : out STD_LOGIC_VECTOR(32-1 downto 0);
          game_time   : out STD_LOGIC_VECTOR(64-1 downto 0));
end Blokus;

architecture BlokusArch of Blokus is
	component AI
		generic (max_level: positive := 10; bits_level: positive := 4; timeout: positive := 1; iterativa: natural := 0; simulation : natural := 0);
		port (----------------
              ---- INPUTS ----
              ----------------
              clk, rst : in STD_LOGIC;            
              new_move : in STD_LOGIC;
              depth : in STD_LOGIC_VECTOR(3-1 downto 0);
              -----------------
              ---- OUTPUTS ----
              -----------------            
              game_over : out STD_LOGIC;
              pass_hero: out STD_LOGIC;
              moveFound: out STD_LOGIC;
              x_hero, y_hero: out STD_LOGIC_VECTOR(4-1 downto 0);
              tile_hero: out STD_LOGIC_VECTOR(5-1 downto 0);
              rotation_hero: out STD_LOGIC_VECTOR(3-1 downto 0);
              -- DEBUG
              debug_current_max_level: out STD_LOGIC_VECTOR(3-1 downto 0);
              -- Performance monitoring
              monitoring_num_boards : out STD_LOGIC_VECTOR(32-1 downto 0));
	end component;
	
	component counter
        generic (bits: positive);
        port (clk, rst: in STD_LOGIC;
                rst2 : in STD_LOGIC;
                inc : in STD_LOGIC;
                count : out STD_LOGIC_VECTOR(bits-1 downto 0));
    end component;
	
	-- FSM
	type states is (IDLE, WAIT_FOR_PLAYER_SWAPPING, REQUEST_MOVE, PROCESSING_MOVE, PLAYING_SW);
	signal currentState, nextState: states;
	
	-- AI
	signal new_move: STD_LOGIC;
	signal moveFound, pass_hero, game_over_int: STD_LOGIC;
	signal x_hero, y_hero: STD_LOGIC_VECTOR(4-1 downto 0);
    signal tile_hero: STD_LOGIC_VECTOR(5-1 downto 0);
    signal rotation_hero: STD_LOGIC_VECTOR(3-1 downto 0);
    	
	-- Moves memory
	type mem_moves is array(0 to 21*2-1) of STD_LOGIC_VECTOR(16-1 downto 0);
    type mem_num_boards is array(0 to 21*2-1) of STD_LOGIC_VECTOR(32-1 downto 0);
	signal monitoring_store_move, monitoring_store_moves_num: STD_LOGIC;
	signal monitoring_move_num: STD_LOGIC_VECTOR(6-1 downto 0);
    signal monitoring_moves_mem: mem_moves;
    signal monitoring_num_boards: STD_LOGIC_VECTOR(32-1 downto 0);
    signal monitoring_board_num_mem: mem_num_boards;
	
	-- Time measurement
    signal rst_game_timer: STD_LOGIC;
    signal inc_game_timer: STD_LOGIC;
	
	-- DCM
	signal clk: STD_LOGIC;	    -- DCM clock output (clk @25MHz)
	signal clk_fb: STD_LOGIC;	-- DCM output, same freq than clkin and aligned. It is used for feedback
begin
    -- Moves memory
    process(clk) is
    begin
        if rising_edge (clk) then
            if new_game = '1' then
                monitoring_move_num <= "000000";
            elsif moveFound = '1' then
                monitoring_move_num <= monitoring_move_num + 1;
                monitoring_moves_mem(conv_integer(monitoring_move_num)) <= x_hero & y_hero & tile_hero & rotation_hero;
            elsif pass_hero = '1' then
                monitoring_move_num <= monitoring_move_num + 1;
                monitoring_moves_mem(conv_integer(monitoring_move_num)) <= x"FFFF";
            else
                monitoring_move_num  <= monitoring_move_num;
                monitoring_moves_mem <= monitoring_moves_mem;   
            end if;
        end if;
    end process;
    move      <= monitoring_moves_mem(conv_integer(move_selector));
    moves_num <= monitoring_move_num;
    
    process(clk) is
    begin
        if (rising_edge (clk)) then
            if moveFound = '1' then                      
                monitoring_board_num_mem(conv_integer(monitoring_move_num)) <= monitoring_num_boards;
            elsif pass_hero = '1' then
                monitoring_board_num_mem(conv_integer(monitoring_move_num)) <= (OTHERS=>'0');
            else
                monitoring_board_num_mem <= monitoring_board_num_mem;   
            end if;
        end if;
    end process;
    boards_num <= monitoring_board_num_mem(conv_integer(move_selector));
    -- Moves memory
    
    -- Time measurement
    game_timer: counter generic map(64)
        port map(clk, rst_game_timer, new_game, inc_game_timer, game_time);
    -- Time measurement
    
    AI_I: AI
        generic map(max_level => 10, bits_level => 4, timeout => 1, iterativa => 1, simulation => 0)
        port map(---- INPUTS ----
                 clk, rst, new_move, depth,
                 ---- OUTPUTS ----			
				 game_over_int, pass_hero, moveFound, x_hero, y_hero, tile_hero, rotation_hero,
				 -- DEBUG
                 leds,
				 -- Performance monitoring
                 monitoring_num_boards
		);
	
    -- Game flow FSM
	gameFlowFSM: process(currentState, new_game, new_game_SW, moveFound, pass_hero, game_over_int, game_over_SW) is
	begin
        -- Defaults
        new_move		<= '0';
        -- Performance monitoring        
        rst_game_timer <= '0';
        inc_game_timer <= '0';
			  
        case currentState is
            when IDLE =>
                if new_game = '1' then
                    rst_game_timer <= '1';
                    nextState <= REQUEST_MOVE;
                elsif new_game_SW = '1' then
                    rst_game_timer <= '1';
                    nextState <= PLAYING_SW;
                else
                    nextState <= IDLE;
                end if;
            
            when WAIT_FOR_PLAYER_SWAPPING =>
                nextState <= REQUEST_MOVE;
            
            when REQUEST_MOVE =>                
                new_move <= '1';
                nextState <= PROCESSING_MOVE;
                                							
            when PROCESSING_MOVE =>
                inc_game_timer  <= '1';
                if moveFound = '1' OR pass_hero = '1' then     
                    nextState <= WAIT_FOR_PLAYER_SWAPPING;
                elsif game_over_int = '1' then
                    nextState <= IDLE;
                else
                    nextState <= PROCESSING_MOVE;
                end if;
                
            when PLAYING_SW =>
                inc_game_timer <= '1';
                if game_over_SW = '1' then
                    nextState <= IDLE;
                else
                    nextState <= PLAYING_SW;
                end if;
        end case;
	end process gameFlowFSM;
		
		
	state: process (clk)
	begin			  
        if clk'EVENT and clk = '1' then
            if rst = '1' then
                currentState <= IDLE;
            else
                currentState <= nextState;
            end if;
        end if;
	end process state;
	
	-- OUTPUTS
	game_over <= game_over_int;
	

    -- MMCME2_BASE: Base Mixed Mode Clock Manager
    --              Artix-7
    -- Xilinx HDL Language Template, version 2014.4
    
    MMCME2_BASE_inst : MMCME2_BASE
        generic map (
            BANDWIDTH => "OPTIMIZED",  -- Jitter programming (OPTIMIZED, HIGH, LOW)
            CLKFBOUT_MULT_F => 6.0,    -- Multiply value for all CLKOUT (2.000-64.000).
            CLKFBOUT_PHASE => 0.0,     -- Phase offset in degrees of CLKFB (-360.000-360.000).
            CLKIN1_PERIOD => 10.0,      -- Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
            -- CLKOUT0_DIVIDE - CLKOUT6_DIVIDE: Divide amount for each CLKOUT (1-128)
            CLKOUT1_DIVIDE => 1,
            CLKOUT2_DIVIDE => 1,
            CLKOUT3_DIVIDE => 1,
            CLKOUT4_DIVIDE => 1,
            CLKOUT5_DIVIDE => 1,
            CLKOUT6_DIVIDE => 1,
            CLKOUT0_DIVIDE_F => 24.0,   -- Divide amount for CLKOUT0 (1.000-128.000).
            -- CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for each CLKOUT (0.01-0.99).
            CLKOUT0_DUTY_CYCLE => 0.5,
            CLKOUT1_DUTY_CYCLE => 0.5,
            CLKOUT2_DUTY_CYCLE => 0.5,
            CLKOUT3_DUTY_CYCLE => 0.5,
            CLKOUT4_DUTY_CYCLE => 0.5,
            CLKOUT5_DUTY_CYCLE => 0.5,
            CLKOUT6_DUTY_CYCLE => 0.5,
            -- CLKOUT0_PHASE - CLKOUT6_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
            CLKOUT0_PHASE => 0.0,
            CLKOUT1_PHASE => 0.0,
            CLKOUT2_PHASE => 0.0,
            CLKOUT3_PHASE => 0.0,
            CLKOUT4_PHASE => 0.0,
            CLKOUT5_PHASE => 0.0,
            CLKOUT6_PHASE => 0.0,
            CLKOUT4_CASCADE => FALSE,  -- Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
            DIVCLK_DIVIDE => 1,        -- Master division value (1-106)
            REF_JITTER1 => 0.0,        -- Reference input jitter in UI (0.000-0.999).
            STARTUP_WAIT => FALSE      -- Delays DONE until MMCM is locked (FALSE, TRUE)
        )
        port map (
            -- Clock Outputs: 1-bit (each) output: User configurable clock outputs
            CLKOUT0  => clk,    -- 1-bit output: CLKOUT0
            CLKOUT0B => open,   -- 1-bit output: Inverted CLKOUT0
            CLKOUT1  => open,   -- 1-bit output: CLKOUT1
            CLKOUT1B => open,   -- 1-bit output: Inverted CLKOUT1
            CLKOUT2  => open,   -- 1-bit output: CLKOUT2
            CLKOUT2B => open,   -- 1-bit output: Inverted CLKOUT2
            CLKOUT3  => open,   -- 1-bit output: CLKOUT3
            CLKOUT3B => open,   -- 1-bit output: Inverted CLKOUT3
            CLKOUT4  => open,   -- 1-bit output: CLKOUT4
            CLKOUT5  => open,   -- 1-bit output: CLKOUT5
            CLKOUT6  => open,   -- 1-bit output: CLKOUT6
            -- Feedback Clocks: 1-bit (each) output: Clock feedback ports
            CLKFBOUT  => clk_fb,-- 1-bit output: Feedback clock
            CLKFBOUTB => open,  -- 1-bit output: Inverted CLKFBOUT
            -- Status Ports: 1-bit (each) output: MMCM status ports
            LOCKED => open,     -- 1-bit output: LOCK
            -- Clock Inputs: 1-bit (each) input: Clock input
            CLKIN1 => clk100,   -- 1-bit input: Clock
            -- Control Ports: 1-bit (each) input: MMCM control ports
            PWRDWN => '0',      -- 1-bit input: Power-down
            RST    => '0',      -- 1-bit input: Reset
            -- Feedback Clocks: 1-bit (each) input: Clock feedback ports
            CLKFBIN => clk_fb   -- 1-bit input: Feedback clock
        );
end BlokusArch;

