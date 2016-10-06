library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UC is
    port(clk : in  STD_LOGIC;
			rst : in  STD_LOGIC;
			write_new_data : in  STD_LOGIC;
			read_new_data : in  STD_LOGIC;
			empty : in  STD_LOGIC;
			full : in  STD_LOGIC;
			interchange : in  STD_LOGIC;
			sort_tc : in  STD_LOGIC;
			ready : out  STD_LOGIC;
			write_data : out  STD_LOGIC;
			ram_enable : out  STD_LOGIC;
			first_empty_ce : out  STD_LOGIC;
			sort_ce : out  STD_LOGIC;
			load_sort : out  STD_LOGIC;
			load_current : out  STD_LOGIC;
			load_read_index: out std_logic; --load for the index register
			Din_ctrl : out  STD_LOGIC_VECTOR (1 downto 0);
			addr_ctrl : out  STD_LOGIC_VECTOR (1 downto 0));
end UC;

architecture Behavioral of UC is
	type state_type is (IDLE, read_mem, compare, write_new, read_mem_last, compare_last); -- IDLE: IDLE; read_mem: cargamos una palabra de la memoria, compare: comparamos y si hace falta hacmos la primera escritura para intercambiar las posiciones; write_second: escribimos la segunda plabra para terminar el intercambio de posiciones; 
	signal state, next_state : state_type; 
begin

	SYNC_PROC: process (clk)
	begin
		if clk'event and clk = '1' then
			if rst = '1' then
				state <= IDLE;
         else
            state <= next_state;
         end if;        
      end if;
   end process;

	NEXT_STATE_DECODE: process(state, write_new_data, empty, interchange, sort_tc, full)
   begin
		next_state <= state;
		case state is
			when IDLE =>
				if write_new_data = '1' AND empty = '0' AND full ='0' then
					next_state <= read_mem;
				elsif write_new_data = '1' AND empty = '0' AND full ='1' then
					next_state <= read_mem_last; --en este caso debemos leer la última posición y no la última menso 1
				else
					next_state <= IDLE;
				end if;
			when read_mem_last =>  --leemos el último dato de la memoria
             next_state <= compare_last;
			when compare_last =>  -- comparamos el último dato de la memoria con el nuevo y escribimos si es necesario
           if interchange= '1' and sort_tc ='0' then
               next_state <= read_mem;
				elsif interchange ='1' and sort_tc ='1' then
					next_state <= write_new;
				else
					next_state <= IDLE;
            end if;
			when read_mem =>  --leemos un nuevo dato de la memoria
             next_state <= compare;
			when compare =>  -- comparamos y escribimos si es necesario
           if interchange= '1' and sort_tc ='0' then
               next_state <= read_mem;
				elsif interchange ='1' and sort_tc ='1' then
					next_state <= write_new;
				else
					next_state <= IDLE;
            end if;
         when write_new => -- en este estado se escribe el nuevo dato en caso de que hayamsos intercambiado hasta la primera posición
             next_state <= IDLE;
			when others =>
            next_state <= state; --no debería pasar nunca
      end case;      
   end process;
   
   OUTPUT_DECODE: process(state,read_new_data, write_new_data, interchange, sort_tc, empty)
   begin
		ready <= '0';
      write_data <= '0';
      ram_enable <= '0';
      first_empty_ce <= '0';
      sort_ce <= '0';
      load_sort <= '0';
      load_current <= '0';
 --     load_previous <= '0';
      Din_ctrl <= "00";
      addr_ctrl <= "00";
	if state = IDLE then
		ready <= '1';
		if write_new_data='1' then 
			first_empty_ce <= '1';-- avanzamos el contador que señala la primera posición libre.
			if empty = '1' then  -- escribimos el dato en la ram, no hay que ordenar nada
				write_data <= '1';
				ram_enable <= '1';
				Din_ctrl <= "00";
				addr_ctrl <= "00";
			else						
				load_sort <= '1';-- cargamos la posición en la que hemos escrito el nuevo valor en el contador que usamos para ordenar
				load_current <= '1';--cargamos el valor que queremos ordenar
			end if;
			
		elsif read_new_data = '1' then
			ram_enable <= '1';
			addr_ctrl <= "11";
		end if;
	elsif state= read_mem then
		ram_enable <= '1';
		addr_ctrl <= "01";--leemos una posición de la memoria
	elsif state= read_mem_last then
		ram_enable <= '1';
		addr_ctrl <= "00";--leemos la última posición de la memoria (cuando la memoria está llena first empty señala a la última posición.
	elsif state= compare then	
		write_data <= '1'; -- siempre se escribe o el dato leido bajandolo una posición para hacer hueco, o el dato nuevo, colocándolo en su sitio
		ram_enable <= '1';
		if interchange='1' then
			Din_ctrl <= "10"; -- escribimos el dato leido una posición más adelante
         addr_ctrl <= "10";
		   if sort_tc= '0' then
				SORT_CE <= '1'; --SI NO HEMOS TERMINADO DECREMENTAMOS EL CONTADOR Y SEGUIMOS ORDENANDO
			end if;
		else   -- si no hay que intercambiar escribimos el nuevo dato
			Din_ctrl <= "01"; -- escribimos el nuevo dato
			addr_ctrl <= "10";
		end if;
	elsif state= compare_last then	
		-- no hay que hacer nada especial. Si hay que intercambiar quiere decir que debemos empezar el proceso normal. y si no hay que intercambiar nos iremos sin escribir. 
	elsif state= write_new then
			write_data <= '1'; -- segunda escritura del intercambio. 
			ram_enable <= '1';
			Din_ctrl <= "01"; -- escribimos el nuevo dato
			addr_ctrl <= "01";
	 end if;	
	end process;
end Behavioral;

