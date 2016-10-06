library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use work.types.all;

entity move_translator is
   port (----------------
			---- INPUTS ----
			----------------
			clk 	  : in  STD_LOGIC;
			-- Move request
			read_move	  : in STD_LOGIC;
			move_num		  : in STD_LOGIC_VECTOR(7-1 downto 0);
			vertex_type	  : in STD_LOGIC_VECTOR(2-1 downto 0);
			window_center : in STD_LOGIC_VECTOR(8-1 downto 0);			
			-----------------
			---- OUTPUTS ----
			-----------------
			x, y 				: out STD_LOGIC_VECTOR(4-1 downto 0);
			tile 				: out STD_LOGIC_VECTOR(5-1 downto 0);
			rotation 		: out STD_LOGIC_VECTOR(3-1 downto 0)
	);
end move_translator;

architecture move_translatorArch of move_translator is
	-----------------------------------------------------
	------------ MOVES TRANSLATIONS MEMORIES ------------
	-----------------------------------------------------	
	component translations_memory_0
		port(clka  : in STD_LOGIC;
			  ena	  : in STD_LOGIC;
			  wea   : in STD_LOGIC_VECTOR(0 downto 0);
			  addra : in STD_LOGIC_VECTOR(7-1 downto 0);	  
			  dina  : in STD_LOGIC_VECTOR(14-1 downto 0);	  
			  douta : out STD_LOGIC_VECTOR(14-1 downto 0));
	end component;
	
	component translations_memory_1
		port(clka  : in STD_LOGIC;
			  ena	  : in STD_LOGIC;
			  wea   : in STD_LOGIC_VECTOR(0 downto 0);
			  addra : in STD_LOGIC_VECTOR(7-1 downto 0);	  
			  dina  : in STD_LOGIC_VECTOR(14-1 downto 0);	  
			  douta : out STD_LOGIC_VECTOR(14-1 downto 0));
	end component;
	
	component translations_memory_2
		port(clka  : in STD_LOGIC;
			  ena	  : in STD_LOGIC;
			  wea   : in STD_LOGIC_VECTOR(0 downto 0);
			  addra : in STD_LOGIC_VECTOR(7-1 downto 0);	  
			  dina  : in STD_LOGIC_VECTOR(14-1 downto 0);	  
			  douta : out STD_LOGIC_VECTOR(14-1 downto 0));
	end component;
	
	component translations_memory_3
		port(clka  : in STD_LOGIC;
			  ena	  : in STD_LOGIC;
			  wea   : in STD_LOGIC_VECTOR(0 downto 0);
			  addra : in STD_LOGIC_VECTOR(7-1 downto 0);	  
			  dina  : in STD_LOGIC_VECTOR(14-1 downto 0);	  
			  douta : out STD_LOGIC_VECTOR(14-1 downto 0));
	end component;

	-- Move mux inputs
	signal move_0, move_1, move_2, move_3: STD_LOGIC_VECTOR(14-1 downto 0);
	-- Move mux outputs
	signal move: STD_LOGIC_VECTOR(14-1 downto 0);
	
begin
	-----------------------------------------------------
	------------ MOVES TRANSLATIONS MEMORIES ------------
	-----------------------------------------------------								
	translations_memory_0_I: translations_memory_0
		port map(clka	=> clk,
					ena	=> read_move,
					wea	=> "0",
					addra	=> move_num,
					dina	=> "00000000000000",
					douta	=> move_0);
	
	translations_memory_1_I: translations_memory_1
		port map(clka	=> clk,
					ena	=> read_move,
					wea	=> "0",
					addra	=> move_num,
					dina	=> "00000000000000",
					douta	=> move_1);
	
	translations_memory_2_I: translations_memory_2
		port map(clka	=> clk,
					ena	=> read_move,
					wea	=> "0",
					addra	=> move_num,
					dina	=> "00000000000000",
					douta	=> move_2);
					
	translations_memory_3_I: translations_memory_3
		port map(clka	=> clk,
					ena	=> read_move,
					wea	=> "0",
					addra	=> move_num,
					dina	=> "00000000000000",
					douta	=> move_3);
	
	-- Memory output mux
	move <= move_0 when vertex_type = 0 else
			  move_1 when vertex_type = 1 else
			  move_2 when vertex_type = 2 else
			  move_3;
	
	-- Outputs	
	x 			<= conv_std_logic_vector(conv_integer(window_center(7 downto 4)) + conv_integer(move(1 downto 0)), 4) when move(2) = '0' else
					conv_std_logic_vector(conv_integer(window_center(7 downto 4)) - conv_integer(move(1 downto 0)), 4);
	y 			<= conv_std_logic_vector(conv_integer(window_center(3 downto 0)) + conv_integer(move(4 downto 3)), 4) when move(5) = '0' else
					conv_std_logic_vector(conv_integer(window_center(3 downto 0)) - conv_integer(move(4 downto 3)), 4);
	tile 		<= move(13 downto 9);
	rotation <= move(8 downto 6);
end move_translatorArch;