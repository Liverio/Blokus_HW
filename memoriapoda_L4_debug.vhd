library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;

entity prunes_L4_mem is
    generic (addr_bits : positive := 14);
	port (----------------
			---- INPUTS ----
			----------------
			clk : in std_logic;
			rst : in std_logic;
			clear_hash: in STD_LOGIC;
			turn : in  STD_LOGIC_VECTOR(5 downto 0);
			write_poda_L4 : in  STD_LOGIC;
			MovL1 : in  STD_LOGIC_VECTOR(15 downto 0);
			MovL2 : in  STD_LOGIC_VECTOR(15 downto 0);
			MovL3 : in  STD_LOGIC_VECTOR(15 downto 0);
			MovPoda_in : in  STD_LOGIC_VECTOR(15 downto 0);           
			hit_poda_L4 : out  STD_LOGIC;
			-----------------
			---- OUTPUTS ----
			-----------------
			hash_cleared: out STD_LOGIC;
			movPoda_out_L4 : out STD_LOGIC_VECTOR(15 downto 0));
end prunes_L4_mem;

architecture Behavioral of prunes_L4_mem is
	component memoriaRAM is 
		generic (word_size : integer := 16+16+16+16+6;
				 bits_addr : integer := 15);
		port (CLK : in std_logic;
				ADDR : in std_logic_vector (bits_addr-1 downto 0); --Dir 
				Din : in std_logic_vector(word_size-1 downto 0);--entrada de datos para el puerto de escritura
				WE : in std_logic;		-- write enable	
				ram_enable: in std_logic;		-- read enable		  
				Dout : out std_logic_vector(word_size-1 downto 0));
	end component;
	
	component contador is
		generic (size : integer := 10);
		port (clk : in  STD_LOGIC;
				rst : in  STD_LOGIC;
				ce : in  STD_LOGIC;
				count : out  STD_LOGIC_VECTOR (size-1 downto 0));
	end component;
	
	-- RAM
	signal RAM_we: STD_LOGIC;
	signal RAM_Addr: std_logic_vector(addr_bits-1 downto 0);
	signal RAM_Din, RAM_Dout: std_logic_vector(70-1 downto 0);
	-- Inputs
	signal RAM_Dout_L1, RAM_Dout_L2, RAM_Dout_L3: std_logic_vector(15 downto 0);
	signal RAM_Dout_turn: std_logic_vector(6-1 downto 0);
	signal hit_turn, hit_L1, hit_L2,hit_L3: std_logic;
	signal overwriten : std_logic;
	signal hash1: std_logic_vector(21-1 downto 0);
	signal hash2: std_logic_vector(26-1 downto 0);
	-- Hash cleaning
	signal inc_cleaning_addr: STD_LOGIC;
	signal cleaning_addr: STD_LOGIC_VECTOR(addr_bits-1 downto 0);
	signal clear_hash_pos: STD_LOGIC;
	-- Hash cleaning FSM		
	type state is (IDLE, CLEANING_HASH);
	signal currentState, nextState: state;

	-- debug
	signal num_overwrites_L4 :  std_logic_vector(9 downto 0);
	signal num_writes_L4:  std_logic_vector(14 downto 0);
begin		
	-- Calculamos la dirección seleccionando los bits menos significativos de x, y el menos significativo de tile para movL1, L2y L3
	hash1 <= conv_std_logic_vector(conv_integer(MovL1)*31, 21) xor ("00000"&MovL2);
	hash2 <= conv_std_logic_vector(conv_integer(hash1)*31, 26) xor ("0000000000"&MovL3);
	
	-- RAM ---	
	mem_podas: memoriaRAM generic map(70, addr_bits)
		--port map (clk => clk, Addr => RAM_Addr, Din => RAM_Din, WE =>write_poda_L4, ram_enable=> '1', Dout => RAM_Dout);
		port map (clk => clk, Addr => RAM_Addr, Din => RAM_Din, WE => RAM_we, ram_enable => '1', Dout => RAM_Dout);
	
	-- Comparaciones --	
	RAM_Dout_turn <= RAM_Dout(21 downto 16);
	RAM_Dout_L1 <= RAM_Dout(37 downto 22);
	RAM_Dout_L2 <= RAM_Dout(53 downto 38);
	RAM_Dout_L3 <= RAM_Dout(69 downto 54);
	hit_turn <= '1' when (turn = RAM_Dout_turn) else '0';
	hit_L1 <= '1' when (MovL1 = RAM_Dout_L1) else '0';
	hit_L2 <= '1' when (MovL2 = RAM_Dout_L2) else '0';
	hit_L3 <= '1' when (MovL3 = RAM_Dout_L3) else '0';
	hit_poda_L4 <= hit_turn and hit_L1 and hit_L2 and hit_L3;	
	
	-- OUTPUT ---
	MovPoda_out_L4 <= RAM_Dout(15 downto 0);
	
	---------------------------
	------ HASH CLEANING ------
	---------------------------
	cleaning_counter: contador generic map(addr_bits)
		port map (clk, rst, inc_cleaning_addr, cleaning_addr);
	
	RAM_Addr <= hash2(addr_bits-1 downto 0) when clear_hash_pos = '0' else cleaning_addr;	
	RAM_Din  <= MovL3 & MovL2 & MovL1 & turn & MovPoda_in when clear_hash_pos = '0' else (OTHERS=>'0');
	RAM_we   <= write_poda_L4 when clear_hash_pos = '0' else '1';
	
	-- FSM to manage hash cleaning between games
	hash_cleaning_FSM: process(currentState,	-- DEFAULT
							   clear_hash,		-- IDLE
							   cleaning_addr)	-- CLEANING_HASH
	begin
		clear_hash_pos <= '0';
		inc_cleaning_addr <= '0';
		hash_cleared <= '0';		
		
		case currentState is
			when IDLE =>				
				if clear_hash = '1' then
					nextState <= CLEANING_HASH;
				else
					nextState <= IDLE;
				end if;		
			
			when CLEANING_HASH =>
				clear_hash_pos <= '1';				
				if cleaning_addr = (2**addr_bits)-1 then						
					hash_cleared <= '1';
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
	overwriten <= '1' when hit_turn = '1' and (hit_L1 = '0' or hit_L2 = '0' or hit_L3 = '0') and write_poda_L4 = '1' else'0';
	overwrite_counter: contador generic map (10)
		port map (clk => clk, rst => rst, ce => overwriten, count => num_overwrites_L4);
	write_counter: contador generic map (15)
		port map (clk => clk, rst => rst, ce =>  write_poda_L4, count => num_writes_L4);
	--end debug-----------------------------------------------------------------------------------------------------------------------
end Behavioral;

