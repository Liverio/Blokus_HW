library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

-- Memoria RAM de 2^bits_addr palabras de word_size bits
entity memoriaRAM is 
    generic (word_size : integer := 16;
			 bits_addr : integer := 10);
    port (clk: in std_logic;
          addr : in std_logic_vector (bits_addr-1 downto 0); --Dir 
		  Din : in std_logic_vector (word_size-1 downto 0);--entrada de datos para el puerto de escritura
		  we : in std_logic;		-- write enable	
		  ram_enable: in std_logic;		-- needed to read or write		  
		  Dout : out std_logic_vector (word_size-1 downto 0));
end memoriaRAM;

architecture Behavioral of memoriaRAM is
    type RamType is array(0 to ((2**bits_addr)-1)) of std_logic_vector(word_size-1 downto 0);
	signal RAM : RamType;
begin
    process(clk)
    begin
        if (clk'event and clk = '1') then
            if (ram_enable = '1') then 
                if (we = '1') then -- sólo se escribe si WE vale 1
                    RAM(conv_integer(addr)) <= Din;
                else
					Dout <= RAM(conv_integer(addr));-- No se lee nada nuevo cuando se escribe (es el modo no change)
				end if;
			end if;
        end if;
    end process;
end Behavioral;