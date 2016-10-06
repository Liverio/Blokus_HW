-- Description: dos memorias ordenadas. En cada nivel se escribe en una de ellas y se lee de la otra. Mirando el bit menos significativo del nivel 
-- se elige la memoria para cada caso. Por ejemplo, si el nivel es par, se escribe en la memoria par (y se lee de la impar)
-- Importante, al entrar en un nuevo nivel hay que darle al reset para que los contadores se pongan a cero. Tenemos que estar ya en el nivel para 
-- resetear el nivel correcto

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;
use work.types.ALL;

entity moves_memory_L1 is
	generic (score_size	 : positive := 16;
				mov_size : integer:= 16;
				bits_addr  	 : positive := 10);
	port (clk : IN  std_logic;
         rst : IN  std_logic; --hay que resetear al empezar un nuevo nivel (hay que hacerlo una vez que estemos en el nivel ya que el bit menos isgnificativo se usa para ver que es lo que se resetea
         rst_intramove: in std_logic;	-- rst_intramove se usa para resetear al cambiar de nivel de profundidad de busqueda. Coloca el contador de lecturas a 0 y resetea la memoria sobre la que se va a empezar a escribir
			write_new_data : in  STD_LOGIC;
			read_new_data : in  STD_LOGIC;
         first_execution : in  STD_LOGIC; -- cuando está activa se asignan los índices, el resto de veces el índice se coge de la entrada
			impar : in  STD_LOGIC; --nos dice si el maximo nivel de exploración  es par o impar (así sabemos de qué memoria escribir y de cual leer			
         movement_in : in std_logic_vector(mov_size-1 downto 0);
			score_in: in std_logic_vector(score_size-1 downto 0);
         moves2read: IN  std_logic_vector(bits_addr downto 0); -- especifica cuantas entradas se quieren leer
--------------------------Salidas-------------------------------------------
			done: OUT std_logic; -- done nos avisa de si hemos terminado, peude ser porque hayamos alcanzado el número de lecturas ndicado en moves2read, o porque hayamos leido ya todos los nodos (valid_addr se pone a 0)
			ready : OUT  std_logic; --ready del nivel que indique la señal impar
			index_out: out std_logic_vector(bits_addr-1 downto 0); --indice del último dato leido
			movement_out : out std_logic_vector(mov_size-1 downto 0)-- movimiento del nivel contrario a la señal impar (si impar es uno la salida corresponde a la memoria par)
	);
		  
end moves_memory_L1;

architecture moves_memoryArch of moves_memory_L1 is
	component reordering_memory_index is  
		generic (score_size : integer := 16;
			mov_size : integer:= 16;
					bits_addr  : integer := 10);
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
end component;
	
	component counter
		generic (bits: positive);
		port (clk, rst: in STD_LOGIC;
				rst2 : in STD_LOGIC;
				inc : in STD_LOGIC;
				count : out STD_LOGIC_VECTOR(bits-1 downto 0)
		);
	end component;

	signal read_new_data_par, write_new_data_par, read_new_data_impar, write_new_data_impar, ready_par, rst_contador, rst_par, rst_impar, valid_addr_par, ready_impar, valid_addr_impar, valid_addr : std_logic;   
	signal movement_out_par, movement_out_impar: std_logic_vector (mov_size-1 downto 0);
	signal index_out_impar, index_out_par: std_logic_vector (bits_addr-1 downto 0);
	signal read_addr: std_logic_vector (bits_addr downto 0);
begin
	read_new_data_par <= read_new_data and impar;
	read_new_data_impar <= read_new_data and (not impar);
	write_new_data_par <= write_new_data and (not impar);
	write_new_data_impar <= write_new_data and impar;
	
	-- Resets
	-- la memoria par se resetea en el reset y en el reset intra move si el nivel es par. 
--	rst_par <= rst or (rst_intramove and (not impar)); OLI
	rst_par <= rst OR (rst_intramove AND impar);
	-- la memoria impar se resetea en el reset y en el reset intra move si el nivel es impar. 
--	rst_impar <= rst or (rst_intramove and impar); OLI
	rst_impar <= rst OR (rst_intramove AND NOT(impar));
	
	
	mem_par: reordering_memory_index generic map(score_size => score_size, mov_size => mov_size, bits_addr => bits_addr)
		port map(---- INPUTS ----
					clk => clk,
					rst => rst_par,
					read_new_data	 => read_new_data_par,
					write_new_data => write_new_data_par,       
					Ext_ADDR => read_addr,
					first_execution => first_execution, --la primera ejecución es siempre con current_max_level=2 así que va sólo a la memoria par
					-- Movement info
					movement_in => movement_in,
					score_in	 => score_in,
					index_in => index_out_impar, 
					---- OUTPUTS ----
					-- Ready to write a new movement
					ready => ready_par,
					-- More movements to be read
					 index_out => index_out_par, 
					valid_addr => valid_addr_par,
					movement_out => movement_out_par);

	mem_impar: reordering_memory_index generic map(score_size => score_size, mov_size => mov_size, bits_addr => bits_addr)
		port map(---- INPUTS ----
					clk => clk,
					rst => rst_impar,
					read_new_data => read_new_data_impar,
					write_new_data => write_new_data_impar,       
					Ext_ADDR => read_addr,
					first_execution => '0', --la primera ejecución es siempre con current_max_level=2 así que va sólo a la memoria par, la impar recibe un '0'
					-- Movement info
					movement_in => movement_in,
					score_in => score_in,
					index_in => index_out_par,
					---- OUTPUTS ----
					-- Ready to write a new movement
					ready => ready_impar,
					-- More movements to be read
					valid_addr	 => valid_addr_impar,
					index_out => index_out_impar, 
					movement_out => movement_out_impar);
			 

	-- el contador se resetea con el reset global o el intramove
	rst_contador <= rst or rst_intramove;	
	-- This counter increments the address after each read operation
	read_counter: counter generic map(bits_addr+1)
		port map (clk, rst_contador, '0', read_new_data, read_addr);

	-- control del número de lecturas
	done <= '1' when (read_addr >= moves2read) or (valid_addr ='0')else '0';  
	
	ready <= ready_impar AND ready_par;

	-- el resto son para las lecturas así que se usa el contrario
	movement_out <= movement_out_par when impar = '1' else movement_out_impar;
	valid_addr <= valid_addr_par when impar = '1' else valid_addr_impar;
	-- el indice es especial. Se inicializa cuando se hace la primera escritura, y el resto de las veces se accede en lectura.
	index_out <= index_out_par when (impar = '1' or  first_execution ='1') else index_out_impar;
	
end moves_memoryArch;