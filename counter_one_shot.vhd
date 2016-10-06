----------------------------------------------------------------------------------
-- 
-- Additional Comments: This counter goes form 0 to 2^size -1 and stops. It will not start again until it receives a reset signal
-- When 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity contador_one_shot is
 generic (
   size : integer := 10
);
Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           ce : in  STD_LOGIC;
			  finished : out  STD_LOGIC; -- se activa al tratar de contar más allá del máximo
			  count : out  STD_LOGIC_VECTOR (size-1 downto 0));
end contador_one_shot;

architecture Behavioral of contador_one_shot is
signal count_int: STD_LOGIC_VECTOR (size-1 downto 0);
signal stop, finished_int: STD_LOGIC;
begin
counting: process (clk) 
begin
   if clk='1' and clk'event then
      if rst='1' then 
         count_int <= (others => '0');
		elsif ce='1' and stop='0' then
         count_int <= count_int + 1;
		end if;
   end if;
end process;
process (clk) 
begin
   if clk='1' and clk'event then
      if rst='1' then 
         finished_int <= '0';
      elsif ce='1' and stop='1' then
			finished_int <= '1';
      end if;
   end if;
end process;
count <= count_int;
stop <= '1' when (count_int +1) = 0 else '0';
finished <= finished_int;
end Behavioral;

