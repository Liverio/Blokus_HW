library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.types.ALL;
--------------------------------------------------------------------------
-- Incluye N memorias ordenadas, una para cada nodo de L1. Desde L1 llega un índice para saber con qué memoria hay que trabajar
-- Tb usamos el índice para acceder a una memoria en la que se guarda cuantos nodos hay para cada índice. 
-- Escribe N datos en orden según score_in. Si se mandan más datos de los que caben los 
-- peores se pierden
-- 
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;
use work.types.ALL;

entity moves_memory_L2 is
	generic (score_size	 : positive := 10;
				mov_size : integer:= 16;
				bits_addr_L1  	 : positive := 9;
				bits_addr_L2  	 : positive := 8);
	port (clk : IN  std_logic;
         rst : IN  std_logic; 
         rst_L2: in std_logic;	-- rst_L2 resetea el nivel 2 cada vez que estamos en el nivel 1
			write_new_data : in  STD_LOGIC;
			read_new_data : in  STD_LOGIC;
         movement_in : in std_logic_vector(mov_size-1 downto 0);
			score_in: in std_logic_vector(score_size-1 downto 0);
			index_in: in std_logic_vector(bits_addr_L1-1 downto 0);
         moves2read: IN  std_logic_vector(bits_addr_L2 downto 0); -- especifica cuantas entradas se quieren leer (tiene un bit más porque hace falta para especificarlas todas)
--------------------------Salidas-------------------------------------------
			done: OUT std_logic; -- se pone a uno cuando se da la orden de la última lectura (puede ser por que no hay más o porque se ha llegado al nº de movimientos que se quería leer)
			ready : OUT  std_logic; --el módulo ha terminado de gestionar la última escritura
	--		valid_addr : OUT  std_logic; -- Se funde con el done. La dirección solicitada contiene un dato válido
         movement_out : out std_logic_vector(mov_size-1 downto 0)-- movimiento solicitado
	);
end moves_memory_L2;

architecture moves_memoryArch of moves_memory_L2 is
	component reordering_memory_no_index is
	generic (score_size	 : positive := 16;
				mov_size : integer:= 16;
				bits_addr_L1  	 : positive := 10;
				bits_addr_L2  	 : positive := 10);
	port (----------------
			---- INPUTS ----
			----------------
			clk, rst: in std_logic;			--rst lo resetea todo, como sólo se escribe una vez 
			-- Read ordered movement
			read_new_data 	: in  STD_LOGIC;
			-- Write and order movement
			write_new_data : in  STD_LOGIC;			
				-- Addr info
			Ext_ADDR 		: in std_logic_vector(bits_addr_L2 downto 0); --lo da el contador de lecturas. Le meto un bit más para evitar un desbordamiento
			index_in: in std_logic_vector(bits_addr_L1-1 downto 0); --el índice nos da el resto de la dirección
			-- Movement info
			movement_in : in std_logic_vector(mov_size-1 downto 0);
			score_in: in std_logic_vector(score_size-1 downto 0);
			-----------------
			---- OUTPUTS ----
			-----------------
			ready : out std_logic; --'1' f the memory is ready to store new data
			valid_addr	 : out std_logic; -- '1' if ADDR is a valid address '0' otherwise
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
	
	signal valid_addr, reset_L2: std_logic; 
	signal Ext_ADDR: std_logic_vector (bits_addr_L2 downto 0);
begin
---RESET
-- reseteamos si nos llega el reset global o si hay cambio de nivelel contador se resetea con el reset global y cuando cambiamos de nivel
	reset_L2 <= rst or rst_L2;		

	mem_L2: reordering_memory_no_index generic map(score_size => score_size, mov_size => mov_size, bits_addr_L1 => bits_addr_L1, bits_addr_L2 => bits_addr_L2 )
		port map(---- INPUTS ----
					clk => clk,
					rst => reset_L2,
					read_new_data	 => read_new_data,
					write_new_data => write_new_data,       
					-- Addr info
					Ext_ADDR => Ext_ADDR,
					index_in => index_in,
					-- Movement info
					movement_in => movement_in,
					score_in	 => score_in,
					---- OUTPUTS ----
					-- Ready to write a new movement
					ready => ready,
					-- More movements to be read
					valid_addr => valid_addr,
					movement_out => movement_out);

	
		-- This counter increments the address after each read operation
	read_counter: counter generic map(bits_addr_L2+1)
		port map (clk, reset_L2, '0', read_new_data, Ext_ADDR);

	-- done nos avisa de si hemos terminado, peude ser porque hayamos alcanzado el número de lecturas
	-- indicado en moves2read, o porque hayamos leido ya todos los nodos (valid_addr se pone a 0)
	done <= '1' when ((Ext_ADDR >= moves2read) or (valid_addr ='0')) else '0';  

	
end moves_memoryArch;