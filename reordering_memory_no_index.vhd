library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.types.ALL;
--------------------------------------------------------------------------
-- Escribe N datos en orden según score_in. Si se mandan más datos de los que caben los 
-- peores se pierden
---------------------------------------------------------------------------
entity reordering_memory_no_index is
	generic (score_size	 : positive := 16;
				mov_size : integer:= 16;
				bits_addr_L1  	 : positive := 10;
				bits_addr_L2  	 : positive := 10);
	port (----------------
			---- INPUTS ----
			----------------
			clk, rst: in std_logic;			--rst lo resetea todo
			-- Read ordered movement
			read_new_data 	: in  STD_LOGIC;
			-- Write and order movement
			write_new_data : in  STD_LOGIC;			
			-- address:
			Ext_ADDR 		: in std_logic_vector(bits_addr_L2 downto 0);
			index_in: in std_logic_vector(bits_addr_L1-1 downto 0);
			-- data:
			movement_in : in std_logic_vector(mov_size-1 downto 0);
			score_in: in std_logic_vector(score_size-1 downto 0);
			-----------------
			---- OUTPUTS ----
			-----------------
			ready : out std_logic; --'1' f the memory is ready to store new data
			valid_addr	 : out std_logic; -- '1' if ADDR is a valid address '0' otherwise
			movement_out : out std_logic_vector(mov_size-1 downto 0));
end reordering_memory_no_index;

architecture reordering_memoryArch of reordering_memory_no_index is
--**************************************************************	
	component UC_no_index is
		 Port ( clk : in  STD_LOGIC;
				  rst : in  STD_LOGIC;
				  write_new_data : in  STD_LOGIC;
				  read_new_data : in  STD_LOGIC;
				  empty : in  STD_LOGIC;
				  full : in  STD_LOGIC;
		--		  valid_addr : in  STD_LOGIC;
				  interchange : in  STD_LOGIC;
				  sort_tc : in  STD_LOGIC;
				  ready : out  STD_LOGIC;
				  write_data : out  STD_LOGIC;
				  ram_enable : out  STD_LOGIC;
				  first_empty_ce : out  STD_LOGIC;
				  sort_ce : out  STD_LOGIC;
				  load_sort : out  STD_LOGIC;
				  load_current : out  STD_LOGIC;
		 --       load_previous : out  STD_LOGIC;
				  Din_ctrl : out  STD_LOGIC_VECTOR (1 downto 0);
				  addr_ctrl : out  STD_LOGIC_VECTOR (1 downto 0));
	end component;
--**************************************************************	
	component data_path_no_index is
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
	end component;
--*****************************************************************

	signal write_data, ram_enable, first_empty_ce, sort_ce, load_sort, load_current, full, empty, sort_tc, interchange: std_logic;
	signal Din_ctrl,addr_ctrl: std_logic_vector(1 downto 0);
	--signal Ext_ADDR: std_logic_vector(bits_addr-1 downto 0);
begin
		
	data_path_L2: data_path_no_index generic map(score_size => score_size, mov_size => mov_size, bits_addr_L1 => bits_addr_L1, bits_addr_L2 => bits_addr_L2 )
		port map(clk => clk,
					rst => rst,
					Ext_ADDR => Ext_ADDR,
					index_in => index_in,
					movement_in => movement_in,
					score_in => score_in,
					Write_data => Write_data,
					ram_enable => ram_enable,
					first_empty_ce => first_empty_ce,
					sort_ce => sort_ce,
					load_sort => load_sort,
					load_current => load_current,
					Din_ctrl => Din_ctrl,
					addr_ctrl => addr_ctrl,
					empty => empty,
					full => full,
					sort_tc => sort_tc,
					valid_addr => valid_addr,
					interchange => interchange,
					movement_out => movement_out
		);
		  
	control_unit_L2: UC_no_index
		port map(clk => clk,
					rst => rst,
					write_new_data => write_new_data,
					read_new_data => read_new_data,
					empty => empty,
					full => full,
					interchange => interchange,
					sort_tc => sort_tc,
					ready => ready,
					write_data => write_data,
					ram_enable => ram_enable,
					first_empty_ce => first_empty_ce,
					sort_ce => sort_ce,
					load_sort => load_sort,
					load_current => load_current,
					Din_ctrl => Din_ctrl,
					addr_ctrl => addr_ctrl
		);
end reordering_memoryArch;