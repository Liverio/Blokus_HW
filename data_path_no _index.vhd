library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;
use work.types.ALL;

entity data_path_no_index is
generic (score_size	 : positive := 16;
				mov_size : integer:= 16;
				bits_addr_L1  	 : positive := 10;
				bits_addr_L2  	 : positive := 10);
	port (
			  CLK : in std_logic;
			  rst : in std_logic;
			  -- address:
			Ext_ADDR 		: in std_logic_vector(bits_addr_L2 downto 0);
			index_in: in std_logic_vector(bits_addr_L1-1 downto 0);
			  -- data:
			  movement_in : in std_logic_vector(mov_size-1 downto 0);
			  score_in: in std_logic_vector(score_size-1 downto 0);
			   --control signals
			  Write_data : in std_logic;		-- write enable viene de la UC	
			  ram_enable: in std_logic;		-- ram enable viene de la UC			  
			  first_empty_ce: in std_logic; -- count enable of the free position counter
			  sort_ce: in std_logic; -- count enable of the sort counter
			  load_sort: in std_logic; --load for the sort counter
			  load_current: in std_logic; --load for the register that stores the current position	
			  Din_ctrl: in std_logic_vector (1 downto 0); -- control signal for the Din mux
			  addr_ctrl: in std_logic_vector (1 downto 0); -- control signal for the addr mux
			    --outputs
			  empty: out std_logic; -- '1' if the memory is empty, '0' otherwise
			  full: out std_logic; -- '1' if the memory is full, '0' otherwise
			  sort_tc: out std_logic; -- '1' if the sort counter reach 0, '0' otherwise
			  valid_addr: out std_logic; -- '1' if ADDR is a valid address '0' otherwise
			  interchange: out std_logic; -- Used during the sort process. '1' if the previous position is greater than the current one
			  movement_out : out std_logic_vector(mov_size-1 downto 0));
end data_path_no_index;

architecture Behavioral of data_path_no_index is
--*****************************************************************
component memoriaRAM is 
	generic (word_size : integer := 9+16;
				bits_addr : integer := 10);
	port (
			  CLK : in std_logic;
			  ADDR : in std_logic_vector (bits_addr-1 downto 0); --Dir 
			  Din : in std_logic_vector(word_size-1 downto 0);--entrada de datos para el puerto de escritura
			  WE : in std_logic;		-- write enable	
			  ram_enable: in std_logic;		-- read enable		  
			  Dout : out std_logic_vector(word_size-1 downto 0));
end component;
--*****************************************************************
component mux4_1 is
  generic (
   size : integer := 32
);
  Port (   DIn0 : in  STD_LOGIC_VECTOR (size-1 downto 0);
           DIn1 : in  STD_LOGIC_VECTOR (size-1 downto 0);
			  DIn2 : in  STD_LOGIC_VECTOR (size-1 downto 0);
           DIn3 : in  STD_LOGIC_VECTOR (size-1 downto 0);
			  ctrl : in  STD_LOGIC_VECTOR (1 downto 0);
           Dout : out  STD_LOGIC_VECTOR (size-1 downto 0));
end component;
--*****************************************************************
component mux3_1 is
  generic (
   size : integer := 32
);
  Port (   DIn0 : in  STD_LOGIC_VECTOR (size-1 downto 0);
           DIn1 : in  STD_LOGIC_VECTOR (size-1 downto 0);
			  DIn2 : in  STD_LOGIC_VECTOR (size-1 downto 0);
			  ctrl : in  STD_LOGIC_VECTOR (1 downto 0);
           Dout : out  STD_LOGIC_VECTOR (size-1 downto 0));
end component;
--*****************************************************************
component reg is
    generic(bits		  : positive := 128;
			   init_value : natural := 0);
	 Port ( Din : in  STD_LOGIC_VECTOR (bits-1 downto 0);
           clk : in  STD_LOGIC;
			  rst : in  STD_LOGIC;
           ld : in  STD_LOGIC;
           Dout : out  STD_LOGIC_VECTOR (bits-1 downto 0));
end component;
--*****************************************************************
component contador_one_shot is
 generic (
   size : integer := 10
);
Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           ce : in  STD_LOGIC;
			  finished : out  STD_LOGIC;
			  count : out  STD_LOGIC_VECTOR (size-1 downto 0));
end component;
--******************************************************************
component contador_dec_load is
 generic (
   size : integer := 10
);
Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           load : in  STD_LOGIC;
			  ce : in  STD_LOGIC;
			  din: in  STD_LOGIC_VECTOR (size-1 downto 0);
			  tc: out  STD_LOGIC;
			  count : out  STD_LOGIC_VECTOR (size-1 downto 0));
end component;
--******************************************************************
signal RAM_addr: std_logic_vector (bits_addr_L1+bits_addr_L2-1 downto 0);
signal RAM_addr_low, previous_pos, first_empty, sort_addr, sort_previous_addr: std_logic_vector (bits_addr_L2-1 downto 0);
signal number_nodes_Dout, number_nodes_Din: std_logic_vector (bits_addr_L2 downto 0);
signal RAM_Din, RAM_Dout: std_logic_vector (score_size+mov_size-1 downto 0);
signal Write_number_nodes, full_int: std_logic;
signal Dout_current, sort_current_reg_in: std_logic_vector (score_size+mov_size-1 downto 0);

begin
	-- L2 memory that stores all the L2 nodes
	mem_L2: memoriaRAM generic map (score_size+mov_size, bits_addr_L1+bits_addr_L2)
		port map (clk => clk, Addr => RAM_Addr, Din => RAM_Din, WE =>Write_data,ram_enable=> ram_enable, Dout => RAM_Dout);
	
	-- Number of nodes memory: stores the number of succesors of each L1 node. It is used to generate the "valid address" signal
	mem_number_nodes: memoriaRAM generic map (bits_addr_L2 +1, bits_addr_L1)
		port map (clk => clk, Addr => index_in, Din => number_nodes_Din, WE =>Write_number_nodes, ram_enable=> '1', Dout => number_nodes_Dout);
	
   -- The input of Number of nodes memory is the number of nodes written, i.e. first_empty +1, unless the memory is already full. In the latter case we just do not update the value.   
	number_nodes_Din <= '0'&first_empty + 1;
	-- We update the number of nodes after each write unless the memory is already full
	Write_number_nodes <= '1' when first_empty_ce = '1' and full_int ='0' else '0';
	-- este contador señala la siguiente posición libre. Se usa para escribir nuevos datos y para avisar si una dirección se va de rango
	first_empty_position: contador_one_shot generic map (size => bits_addr_L2)
		port map (clk => clk, rst => rst, ce => first_empty_ce, finished => full_int, count => first_empty);
	
	full <= full_int;
	
	valid_addr <= '1' when (ext_Addr < number_nodes_Dout) else '0';
	
	previous_pos <= first_empty - 1;
	
	empty <= '1' when first_empty = 0 else '0';
	
	sort_count: contador_dec_load generic map(size => bits_addr_L2)
		port map (clk => clk, rst => rst, ce => sort_ce, Din => previous_pos, load => load_sort, count => sort_addr, tc => sort_tc);
	
	sort_previous_addr <= sort_addr + 1;
	
	sort_current_reg_in(mov_size-1 downto 0) <= movement_in;
	sort_current_reg_in(score_size+mov_size-1 downto mov_size) <= score_in;
	
	sort_current: reg generic map (score_size+mov_size, 0)
		port map (clk => clk, rst => rst, Din => sort_current_reg_in, ld => load_current, Dout => Dout_current);
	
	interchange <= '1' when Dout_current(score_size+mov_size-1 downto mov_size) < RAM_Dout(score_size+mov_size-1 downto mov_size) else '0';
	
	mux_RAM_addr: mux4_1 generic map (size => bits_addr_L2)
		port map (Din0 => first_empty, Din1 => sort_addr, Din2 => sort_previous_addr, Din3 => Ext_ADDR(bits_addr_L2-1 downto 0), ctrl => addr_ctrl, Dout=> Ram_Addr_low);
	
	Ram_addr <= index_in&Ram_Addr_low;
	
	mux_RAM_Din: mux3_1 generic map (size => score_size+mov_size)
		port map (Din0 => sort_current_reg_in, Din1 => Dout_current, Din2 => RAM_Dout, ctrl => Din_ctrl, Dout => RAM_Din );
	
	movement_out <= RAM_Dout(mov_size -1 downto 0);
	
end Behavioral;

