library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity registroDobleResetConInicializacion is
   generic( n : positive := 128; inicial : natural := 0);
   port( clk, rst, rst2, ld : in std_logic;
		din : in std_logic_vector( n-1 downto 0 );
		dout : out std_logic_vector( n-1 downto 0 ) );
end registroDobleResetConInicializacion;

architecture registroDobleResetConInicializacionArch of registroDobleResetConInicializacion is
   signal cs, ns : std_logic_vector( n-1 downto 0 );
   begin

   state:
   process(clk)
      begin
         if clk'event AND clk = '1' then
			  if rst = '1' then
             cs <= conv_std_logic_vector(inicial,n);
           else
             cs <= ns;
			  end if;
         end if;
   end process;

	next_state:
   process(cs, ld, rst2, din)
      begin
         if rst2 = '1' then 
			  ns <= conv_std_logic_vector(inicial,n);
         elsif ld = '1' then
			  ns <= din;
         else 
			  ns <= cs;
         end if;
   end process;
		
	moore_output:
		dout <= cs;
end registroDobleResetConInicializacionArch;