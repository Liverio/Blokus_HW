library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.types.ALL;
--------------------------------------------------------------------------
-- Escribe N datos en orden según score_in. Si se mandan más datos de los que caben los 
-- peores se pierden
-- V2: incluye gestión de índices para acceder a una memoria en al que se guardan los hijos de nivel 2 para cada nodo de nivel 1.
--  IMPORTANTE: para que funcione tienen que caber todos los nodos de nivel 1 ya que si no se asignará el mismo índice a distintos movimientos
---------------------------------------------------------------------------
entity reordering_memory_index is
	generic (score_size : integer := 16;
				mov_size : integer:= 16;
				bits_addr : integer := 10);
	port (----------------
			---- INPUTS ----
			----------------
			clk, rst: in std_logic;			--rst lo resetea todo
			-- Read ordered movement
			read_new_data 	: in  STD_LOGIC;
			-- Write and order movement
			write_new_data : in  STD_LOGIC;			
			Ext_ADDR 		: in std_logic_vector(bits_addr downto 0);
			movement_in : in std_logic_vector(mov_size-1 downto 0);
			score_in: in std_logic_vector(score_size-1 downto 0);
			index_in: in std_logic_vector(bits_addr-1 downto 0);
			first_execution : in  STD_LOGIC; -- cuando está activa se asignan los índices, el resto de veces el índice se coge de la entrada
			-----------------
			---- OUTPUTS ----
			-----------------
			ready : out std_logic; --'1' f the memory is ready to store new data
			valid_addr	 : out std_logic; -- '1' if ADDR is a valid address '0' otherwise
			index_out: out std_logic_vector(bits_addr-1 downto 0); --indice del último dato leido
			movement_out : out std_logic_vector(mov_size-1 downto 0));
end reordering_memory_index;

architecture reordering_memory_indexArch of reordering_memory_index is
--**************************************************************	
	component UC is
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
				  Din_ctrl : out  STD_LOGIC_VECTOR (1 downto 0);
				  addr_ctrl : out  STD_LOGIC_VECTOR (1 downto 0));
	end component;
--**************************************************************	
	component data_path is
	generic (score_size : integer := 32;
				mov_size : integer:= 16;
				bits_addr : integer := 10);
	port (
			  CLK : in std_logic;
			  rst : in std_logic;
			  Ext_ADDR : in std_logic_vector (bits_addr downto 0); --Dir externa
			  movement_in : in std_logic_vector(mov_size-1 downto 0);
			  score_in: in std_logic_vector(score_size-1 downto 0);
			  index_in: in std_logic_vector(bits_addr-1 downto 0);
			  first_execution : in  STD_LOGIC; -- cuando está activa se asignan los índices, el resto de veces el índice se coge de la entrada
			  Write_data : in std_logic;		-- write enable viene de la UC	
			  read_new_data : in  STD_LOGIC;
			    write_new_data: in  STD_LOGIC; -- se usa para cargar el índice generado en la primera ejecución
			  ram_enable: in std_logic;		-- ram enable viene de la UC			  
			  first_empty_ce: in std_logic; -- count enable of the free position counter
			  sort_ce: in std_logic; -- count enable of the sort counter
			  load_sort: in std_logic; --load for the sort counter
			  load_current: in std_logic; --load for the register that stores the current position	
			  Din_ctrl: in std_logic_vector (1 downto 0); -- control signal for the Din mux
			  addr_ctrl: in std_logic_vector (1 downto 0); -- control signal for the addr mux
			  empty: out std_logic; -- '1' if the memory is empty, '0' otherwise
			  full: out std_logic; -- '1' if the memory is full, '0' otherwise
			  sort_tc: out std_logic; -- '1' if the sort counter reach 0, '0' otherwise
			  valid_addr: out std_logic; -- '1' if ADDR is a valid address '0' otherwise
			  interchange: out std_logic; -- Used during the sort process. '1' if the previous position is greater than the current one
			  index_out: out std_logic_vector(bits_addr-1 downto 0); --indice del último dato leido
			  movement_out : out std_logic_vector(mov_size-1 downto 0));
	end component;
--*****************************************************************

	signal write_data, ram_enable, first_empty_ce, sort_ce, load_sort, load_current,full, empty, sort_tc, interchange: std_logic;
	signal Din_ctrl,addr_ctrl: std_logic_vector(1 downto 0);
	--signal Ext_ADDR: std_logic_vector(bits_addr-1 downto 0);
begin
		
	data_path_I: data_path generic map(score_size => score_size, mov_size => mov_size, bits_addr => bits_addr)
		port map(clk => clk,
					rst => rst,
					Ext_ADDR => Ext_ADDR,
					movement_in => movement_in,
					score_in => score_in,
					index_in => index_in,
					first_execution => first_execution,
					Write_data => Write_data,
					write_new_data=> Write_new_data,
					read_new_data => read_new_data,
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
					index_out => index_out,
					movement_out => movement_out
		);
		  
	control_unit_I: UC
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
end reordering_memory_indexArch;