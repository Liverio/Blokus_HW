library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;
use work.types.ALL;

entity data_path is
generic (score_size : integer := 16;
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
			  write_new_data: in  STD_LOGIC; -- se usa para cargar el índice generado en la primera ejecución
			  read_new_data : in  STD_LOGIC;
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
end data_path;

architecture Behavioral of data_path is
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
signal RAM_addr, previous_pos, first_empty, sort_addr, sort_previous_addr: std_logic_vector (bits_addr-1 downto 0);
signal RAM_Din, RAM_Dout: std_logic_vector (bits_addr+score_size+mov_size-1 downto 0);
signal last_index_din, reg_index_out : std_logic_vector(bits_addr-1 downto 0);
signal Dout_current, sort_current_reg_in: std_logic_vector (bits_addr+score_size+mov_size-1 downto 0);
signal load_read_index, load_write_index, load_index: std_logic;
begin
----------------------------------------------------------------------------------------------
------------------------------------------RAM memory------------------------------------------
----------------------------------------------------------------------------------------------
	mem_1: memoriaRAM generic map (bits_addr+score_size+mov_size, bits_addr)
		port map (clk => clk, Addr => RAM_Addr, Din => RAM_Din, WE =>Write_data,ram_enable=> ram_enable, Dout => RAM_Dout);
--------------------------------------------------------------------------------------------------	
--------------------------------------------------------------------------------------------------
	-- registro de último índice
	-- este registro almacena el valor del índice que hay que usar para acceder a la memoria de nivel 2
	-- Si es la primera ejecución, este será el último indice escrito, sino el último leido
	last_index_din <= RAM_Dout(bits_addr+score_size+mov_size-1 downto score_size+mov_size);
	
-- load_read_index is just read_new_data with a delay of one clock cycle 	
-- the idea is to store the index of the read mov
	load_read_index_FF: process (clk)
	begin
		if clk'event and clk = '1' then
			if rst = '1' then
				load_read_index <= '0';
         else
            load_read_index <= read_new_data;
         end if;        
      end if;
   end process;
	--load_write_index <= '1' when (write_new_data = '1' and first_execution = '1') else '0';
	-- load index se activa se se ha leido un indice (en este caso se activa un ciclo más tarde para cargar la salida de la ram, o si se ha escrito un índice en la primera ejecución (en ese caso se coge el índice de la entrada de la ram)	
	load_index <= load_read_index; -- or load_write_index;
	last_index: reg 	generic map (bits_addr, 0)
							port map (clk => clk, rst => rst, Din => last_index_din , ld => load_index, Dout =>reg_index_out );
-- index out es el contador first_empty en la primera iteración y la salida de la ram en el resto
	index_out <= first_empty when first_execution ='1' else reg_index_out;

--------------------------------------------------------------------------------------------
	-- este contador señala la siguiente posición libre. Se usa para escribir nuevos datos y para avisar si una dirección se va de rango
	first_empty_position: contador_one_shot generic map (size => bits_addr)
		port map (clk => clk, rst => rst, ce => first_empty_ce, finished => full, count => first_empty);
	
	valid_addr <= '1' when (ext_Addr < '0'&first_empty) else '0';
	previous_pos <= first_empty - 1;
	empty <= '1' when first_empty = 0 else '0';
	
	sort_count: contador_dec_load generic map(size => bits_addr)
		port map (clk => clk, rst => rst, ce => sort_ce, Din => previous_pos, load => load_sort, count => sort_addr, tc => sort_tc);
	
	sort_previous_addr <= sort_addr + 1;
	
	sort_current_reg_in(mov_size-1 downto 0) <= movement_in;
	sort_current_reg_in(score_size+mov_size-1 downto mov_size) <= score_in;
	-- en la primera ejecución se asigna un índice (la primera posisción libre) sino se lee de la entrada.
	sort_current_reg_in(bits_addr+score_size+mov_size-1 downto score_size+mov_size) <= first_empty when first_execution ='1' else index_in;
	sort_current: reg generic map (bits_addr+score_size+mov_size, 0)
		port map (clk => clk, rst => rst, Din => sort_current_reg_in, ld => load_current, Dout => Dout_current);
	
	interchange <= '1' when Dout_current(score_size+mov_size-1 downto mov_size) > RAM_Dout(score_size+mov_size-1 downto mov_size) else '0';
	
	mux_RAM_addr: mux4_1 generic map (size => bits_addr)
		port map (Din0 => first_empty, Din1 => sort_addr, Din2 => sort_previous_addr, Din3 => Ext_ADDR(bits_addr-1 downto 0), ctrl => addr_ctrl, Dout=> Ram_Addr);
	
	mux_RAM_Din: mux3_1 generic map (size => bits_addr+score_size+mov_size)
		port map (Din0 => sort_current_reg_in, Din1 => Dout_current, Din2 => RAM_Dout, ctrl => Din_ctrl, Dout => RAM_Din );
	
	movement_out <= RAM_Dout(mov_size -1 downto 0);
	
end Behavioral;

