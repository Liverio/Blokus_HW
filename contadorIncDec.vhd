library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity counterIncDec is
   generic( n : integer := 8 );
   port( clk, rst, rst2, inc, dec : in std_logic;
      dout : out std_logic_vector( n-1 downto 0 ) );
end counterIncDec;

architecture counterIncDecArch of counterIncDec is
   signal cs, ns : std_logic_vector( n-1 downto 0 ); 
begin
   state:
   process(clk)
     begin
        if clk'event and clk = '1' then 
			 if rst = '1' then 
				cs <= (others=>'0');
			 else
				cs <= ns;
			 end if;        
        end if;
   end process;

   next_state:
   process(cs, dec, inc, rst2)
      begin
			if rst2 = '1' then
				ns <= (others => '0');
         elsif inc = '1' then 
			  ns <= cs + 1;
         elsif dec = '1' then
			  ns <= cs - 1;
         else 
			  ns <= cs;
         end if;
   end process;

   moore_output: dout <= cs;

end counterIncDecArch;
