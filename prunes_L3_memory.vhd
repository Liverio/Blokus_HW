library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;

entity prunes_L3_mem is
	port (----------------
			---- INPUTS ----
			----------------
			clk : in std_logic;
			rst : in std_logic;
			clear_hash: in STD_LOGIC;
			turn : in STD_LOGIC_VECTOR(6-1 downto 0);
			writepodaL3 : in STD_LOGIC;
			MovL1 		: in STD_LOGIC_VECTOR(16-1 downto 0);
			MovL2 		: in STD_LOGIC_VECTOR(16-1 downto 0);
			MovPoda_in 	: in STD_LOGIC_VECTOR(16-1 downto 0);			
			-----------------
			---- OUTPUTS ----
			-----------------
			--debug
			  num_overwrites : out std_logic_vector(7 downto 0);
			  num_writes: out std_logic_vector(9 downto 0);
			--debug
			hit_poda_L3 : out STD_LOGIC;
			MovPoda_out : out STD_LOGIC_VECTOR(16-1 downto 0)
	);
end prunes_L3_mem;

architecture prunes_L3_memArch of prunes_L3_mem is
	component memoriaRAM is 
		generic (word_size : integer := 16+16+16+6;
					bits_addr : integer := 12);
		port (CLK : in std_logic;
				ADDR : in std_logic_vector (bits_addr-1 downto 0); --Dir 
				Din : in std_logic_vector(word_size-1 downto 0);--entrada de datos para el puerto de escritura
				WE : in std_logic;		-- write enable	
				ram_enable: in std_logic;		-- read enable		  
				Dout : out std_logic_vector(word_size-1 downto 0));
	end component;
	
	component contador is
		generic (
		size : integer := 10
	);
	Port ( clk : in  STD_LOGIC;
				  rst : in  STD_LOGIC;
				  ce : in  STD_LOGIC;
				  count : out  STD_LOGIC_VECTOR (size-1 downto 0));
	end component;

	-- RAM
	signal RAM_we: STD_LOGIC;
	signal RAM_Addr: std_logic_vector (14-1 downto 0);
	signal RAM_Din, RAM_Dout: std_logic_vector (54-1 downto 0);
	-- Inputs	
	signal hash: std_logic_vector (21-1 downto 0);	
	signal MovL1_x, MovL1_y, MovL2_x, MovL2_y, MovL1_x_plus_1, MovL1_y_plus_1, MovL2_x_plus_1, MovL2_y_plus_1 : STD_LOGIC_VECTOR (3 downto 0);
	signal MovL1_tile, MovL2_tile: std_logic_vector (5-1 downto 0);
	signal MovL1_rot, MovL2_rot: std_logic_vector (3-1 downto 0);
	signal RAM_Dout_L1: std_logic_vector (15 downto 0);
	signal RAM_Dout_L2: std_logic_vector (15 downto 0);
	signal RAM_Dout_turn: std_logic_vector (6-1 downto 0);
	signal hit_turn, hit_L1, hit_L2: std_logic;
	signal overwriten : std_logic;
	-- Hash cleaning
	signal inc_cleaning_addr: STD_LOGIC;
	signal cleaning_addr: STD_LOGIC_VECTOR(14-1 downto 0);
	signal clear_hash_pos: STD_LOGIC;
	-- Hash cleaning FSM		
	type state is (IDLE, CLEANING_HASH);
	signal currentState, nextState: state;
begin	
	MovL1_x <= MovL1(15 downto 12);
	MovL1_y <= MovL1(11 downto 8);
	MovL1_tile <= MovL1(7 downto 3);
	MovL1_rot <= MovL1(2 downto 0);
	MovL2_x <= MovL2(15 downto 12);
	MovL2_y <= MovL2(11 downto 8);
	MovL2_tile <= MovL2(7 downto 3);
	MovL2_rot <= MovL2(2 downto 0);
	
	-- calculamos la dirección seleccionando los bits menos significativos de x, y y tile para movL1 y L2
	hash <= conv_std_logic_vector(conv_integer(MovL1)*31, 21) xor ("00000"&MovL2);
	
	-- RAM ---	
	mem_podas: memoriaRAM generic map (16*3+6, 14)
		port map (clk => clk, Addr => RAM_Addr, Din => RAM_Din, WE => RAM_we, ram_enable=> '1', Dout => RAM_Dout);
	-- Comparaciones --	
	RAM_Dout_turn <= RAM_Dout(21 downto 16);
	RAM_Dout_L1 <= RAM_Dout(37 downto 22);
	RAM_Dout_L2 <= RAM_Dout(53 downto 38);
	--Remaining_L1 <= MovL1_x(3 downto 1) & MovL1_y(3 downto 1) & MovL1_tile(4 downto 1)& MovL1_rot(2 downto 1);
	--Remaining_L2 <= MovL2_x(3 downto 2) & MovL2_y(3 downto 2) & MovL2_tile(4 downto 2)& MovL2_rot(2);
	hit_turn <= '1' when (turn = RAM_Dout_turn) else '0';
	hit_L1 <= '1' when (MovL1 = RAM_Dout_L1) else '0';
	hit_L2 <= '1' when (MovL2 = RAM_Dout_L2) else '0';
	hit_poda_L3 <= hit_turn and hit_L1 and hit_L2;
	
	----- OUTPUTS -----
	MovPoda_out <= RAM_Dout(15 downto 0);
	
	---------------------------
	------ HASH CLEANING ------
	---------------------------
	cleaning_counter: contador generic map(14)
		port map (clk, rst, inc_cleaning_addr, cleaning_addr);
	
	RAM_Addr <= hash(14-1 downto 0) when clear_hash_pos = '0' else cleaning_addr;	
	RAM_Din <= MovL2 & MovL1 & turn & MovPoda_in when clear_hash_pos = '0' else (OTHERS=>'0');
	RAM_we <= writepodaL3 when clear_hash_pos = '0' else '1';
	
	-- FSM to manage hash cleaning between games
	hash_cleaning_FSM: process(currentState,	-- DEFAULT
										clear_hash,		-- IDLE
										cleaning_addr)	-- CLEANING_HASH
	begin
		clear_hash_pos <= '0';
		inc_cleaning_addr <= '0';
		
		case currentState is
			when IDLE =>				
				if clear_hash = '1' then
					nextState <= CLEANING_HASH;
				else
					nextState <= IDLE;
				end if;		
			
			when CLEANING_HASH =>
				clear_hash_pos <= '1';				
				if cleaning_addr = (2**14)-1 then
					nextState <= IDLE;
				else
					inc_cleaning_addr <= '1';
					nextState <= CLEANING_HASH;
				end if;
		end case;
	end process hash_cleaning_FSM;	

	states: process(clk)
	begin			  
		if clk'event AND clk = '1' then
			if rst = '1' then
				currentState <= IDLE;
			else
				currentState <= nextState;
			end if;
		end if;
	end process;
	
	-----------------------------------------------------------------------------------------------------------------------------
	-- debug and test--
	-- This counter identifies when a write operation overwrites useful data during the first exploration of L3. It must be checked at the end of that exploration 
	overwriten <= hit_turn and (hit_L1 nand hit_L2) and writepodaL3;
	overwrite_counter: contador generic map (8)
		port map (clk => clk, rst => rst, ce => overwriten, count => num_overwrites);
	write_counter: contador generic map (10)
		port map (clk => clk, rst => rst, ce =>  writepodaL3, count => num_writes);
	--end debug-----------------------------------------------------------------------------------------------------------------------
end prunes_L3_memArch;

