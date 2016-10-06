----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:38:54 11/27/2014 
-- Design Name: 
-- Module Name:    Moves_memory_L1_L2 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;
use work.types.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity moves_memory is
generic (score_size	 : positive := 10;
				chain_size : integer:= 48; -- cadena de n movimientos ira entera a L1 y solo ira el segundo a L2
				mov_size : integer:= 16; --tamaño de un movimiento
				bits_addr_L1  	 : positive := 9;
				bits_addr_L2  	 : positive := 8);
	port (clk : IN  std_logic;
         rst : IN  std_logic; 
         rst_intramove: in std_logic;	-- rst_intramove se usa para resetear al cambiar de nivel de profundidad de busqueda. Coloca el contador de lecturas a 0 y resetea la memoria sobre la que se va a empezar a escribir
			write_new_data : in  STD_LOGIC;-- IMPORTANTE: se asume que cuando escribes estás en el mismo nivel. es decir escribes L1 cuando estás en nivel 1 y escribes en l2 cuando estás en el nivel 2. 
			read_new_data : in  STD_LOGIC; -- IMPORTANTE: se asume que cuando lees estás en el nivel superior. Es decir lees L1 desde L0 y lees L2 desde L1
--         movement_in : in std_logic_vector(chain_size-1 downto 0); --cadena de movimientos. Si se escribe en L1 se escribe la cadena entera. Si se escribe en L2, solo el segundo movimiento movement_in(31 downto 16)
			movement_in : in tp_array_movements; --cadena de movimientos. Si se escribe en L1 se escribe la cadena entera. Si se escribe en L2, solo el segundo movimiento movement_in(31 downto 16)
			score_in: in std_logic_vector(score_size-1 downto 0);
			moves2read_L1: IN  std_logic_vector(bits_addr_L1 downto 0); -- especifica cuantas entradas se quieren leer en L1
			moves2read_L2: IN  std_logic_vector(bits_addr_L2 downto 0); -- especifica cuantas entradas se quieren leer en L1
			level: in  std_logic_vector(4-1 downto 0); --current level
			impar : in  STD_LOGIC; --nos dice si el maximo nivel de exploración  es par o impar (así sabemos de qué memoria escribir y de cual leer			
			first_execution : in  STD_LOGIC; -- se debe poner a 1 durante la primera exploración de la busqueda iterativa para que se asignen los índices a las entradas de L1. En las siguientes iteraciones se mantienen los índices.
														-- tb es necesaria para que se escriba en L2. Ya que en las exploraciones sucesicvas L2 ya sólo se puede leer
--------------------------Salidas-------------------------------------------
			done: OUT std_logic; -- se pone a uno cuando se da la orden de la última lectura (puede ser por que no hay más o porque se ha llegado al nº de movimientos que se quería leer) Tb está a uno si no estamos ni en L1 ni en L2
			ready : OUT  std_logic; --el módulo ha terminado de gestionar la última escritura
         movement_out_L1 : out tp_array_movements;	-- movimiento solicitado en L1 (cadena completa)
			movement_out_L2 : out std_logic_vector(mov_size-1 downto 0)-- movimiento solicitado en L2 (solo un movimiento)
	);
end moves_memory;

architecture Behavioral of moves_memory is

component moves_memory_L1 is
	generic (score_size	 : positive := 16;
				mov_size : integer:= 16;
				bits_addr  	 : positive := 10);
	port (clk : IN  std_logic;
         rst : IN  std_logic; --hay que resetear al empezar un nuevo nivel (hay que hacerlo una vez que estemos en el nivel ya que el bit menos isgnificativo se usa para ver que es lo que se resetea
         rst_intramove: in std_logic;	-- rst_intramove se usa para resetear al cambiar de nivel de profundidad de busqueda. Coloca el contador de lecturas a 0 y resetea la memoria sobre la que se va a empezar a escribir
			write_new_data : in  STD_LOGIC;
			read_new_data : in  STD_LOGIC;
         first_execution : in  STD_LOGIC; -- cuando está activa se asignan los índices, el resto de veces el índice se coge de la entrada
			impar : in  STD_LOGIC; --nos dice si el nivel actual es par o impar (así sabemos de qué memoria escribir y de cual leer			
         movement_in : in std_logic_vector(mov_size-1 downto 0);
			score_in: in std_logic_vector(score_size-1 downto 0);
         moves2read: IN  std_logic_vector(bits_addr downto 0); -- especifica cuantas entradas se quieren leer
--------------------------Salidas-------------------------------------------
			done: OUT std_logic; -- done nos avisa de si hemos terminado, peude ser porque hayamos alcanzado el número de lecturas ndicado en moves2read, o porque hayamos leido ya todos los nodos (valid_addr se pone a 0)
			ready : OUT  std_logic; --ready del nivel que indique la señal impar
			index_out: out std_logic_vector(bits_addr-1 downto 0); --indice del último dato leido
			movement_out : out std_logic_vector(mov_size-1 downto 0)-- movimiento del nivel contrario a la señal impar (si impar es uno la salida corresponde a la memoria par)
	);
end component;

component moves_memory_L2 is
	generic (score_size	 : positive := 10;
				mov_size : integer:= 16;
				bits_addr_L1  	 : positive := 9;
				bits_addr_L2  	 : positive := 8);
	port (clk : IN  std_logic;
         rst : IN  std_logic; 
         rst_L2: in std_logic;	--	-- rst_L2 resetea el nivel 2 cada vez que estamos en el nivel 1
			write_new_data : in  STD_LOGIC;
			read_new_data : in  STD_LOGIC;
         movement_in : in std_logic_vector(mov_size-1 downto 0);
			score_in: in std_logic_vector(score_size-1 downto 0);
			index_in: in std_logic_vector(bits_addr_L1-1 downto 0);
         moves2read: IN  std_logic_vector(bits_addr_L2 downto 0); -- especifica cuantas entradas se quieren leer (tiene un bit más porque hace falta para especificarlas todas)
--------------------------Salidas-------------------------------------------
			done: OUT std_logic; -- se pone a uno cuando se da la orden de la última lectura (puede ser por que no hay más o porque se ha llegado al nº de movimientos que se quería leer)
			ready : OUT  std_logic; --el módulo ha terminado de gestionar la última escritura	
         movement_out : out std_logic_vector(mov_size-1 downto 0)-- movimiento solicitado
	);
end component;
signal write_new_data_L2, write_new_data_L1, read_new_data_L2, read_new_data_L1, done_L2, done_L1, ready_L2, ready_L1 : std_logic;
signal rst_L2 : std_logic; 
signal movement_in_L2:std_logic_vector(mov_size-1 downto 0);
signal index_in_L2, index_out_L1: std_logic_vector(bits_addr_L1-1 downto 0);

-- OLI
signal movement_in_int, movement_out_L1_int: std_logic_vector(chain_size-1 downto 0);

begin
 L2_mem: moves_memory_L2 
				generic map (
				score_size	 => score_size,
				mov_size => mov_size, --solo entra un movimiento en L2
				bits_addr_L1 =>  	bits_addr_L1,
				bits_addr_L2 => bits_addr_L2)
				
				PORT MAP (
          clk => clk,
          rst => rst,
          rst_L2 => rst_L2,
          write_new_data => write_new_data_L2,
          read_new_data => read_new_data_L2,
          movement_in => movement_in_L2,
          score_in => score_in,
          index_in => index_in_L2,
          moves2read => moves2read_L2,
          done => done_L2,
          ready => ready_L2,
          movement_out => movement_out_L2
        );

 L1_mem: moves_memory_L1 
			generic map (
				score_size	 => score_size,
				mov_size => chain_size, --entra una cadena completa
				bits_addr =>  	bits_addr_L1)
			PORT MAP (
          CLK => CLK,
          rst => rst,
          rst_intramove => rst_intramove,
          write_new_data => write_new_data_L1,
          read_new_data => read_new_data_L1,
          impar => impar,
			 first_execution => first_execution,
          movement_in => movement_in_int,
          score_in => score_in,
          moves2read => moves2read_L1,
          done => done_L1,
          ready => ready_L1,
   		 index_out => index_out_L1,
          movement_out => movement_out_L1_int
        );

-- IMPORTANTE: se asume que cuando escribes estás en el mismo nivel: escribes L1 cuando estás en nivel 1 y escribes en l2 cuando estás en el nivel 2. 
--write commands:
write_new_data_L1 <= '1' when write_new_data='1' and level = "0001" else '0';
write_new_data_L2 <= '1' when write_new_data='1' and level = "0010" and first_execution ='1' else '0';
-- IMPORTANTE: se asume que cuando lees estás en el nivel superior. Es decir lees L1 desde L0 y lees L2 desde L1
-- read commands
read_new_data_L1 <= '1' when read_new_data='1' and level = "0000" else '0';
read_new_data_L2 <= '1' when read_new_data='1' and level = "0001" else '0';
-- move for L2.
-- OLI
--movement_in_L2 <= movement_in(2*mov_size - 1 downto mov_size);
movement_in_L2 <= movement_in_int(2*mov_size - 1 downto mov_size);
--index direct connection
index_in_L2 <= index_out_L1;
-- ready. For safety we wait until both levels are ready
ready <= ready_L1 AND ready_L2;
-- Done elige en función del nivel. SI no es nivel 1 ni 2 saca un 1.
done <= done_L1 when level = "0000" else done_L2 when level = "0001" else '1';
--  rst_L2: cada vez que subes a nivel reseteas nivel 2 para que cuando bajes a nivel 1 y empieces a pedir lecturas de nivel 2 empeices desde la 0
rst_L2 <= '1' when level ="0000" else '0'; --si estamos en nivel 1 reseteamos el nivel 2

-- OLI
movement_in_int <= movement_in(3) & movement_in(2) & movement_in(1) & movement_in(0);

movement_out_L1(0) <= movement_out_L1_int(15 downto  0);
movement_out_L1(1) <= movement_out_L1_int(31 downto 16);
movement_out_L1(2) <= movement_out_L1_int(47 downto 32);
movement_out_L1(3) <= movement_out_L1_int(63 downto 48);
end Behavioral;

