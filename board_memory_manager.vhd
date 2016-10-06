library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use work.types.all;

entity board_memory_manager is
   port (----------------
			---- INPUTS ----
			----------------
			clk : in STD_LOGIC;
			load_real_board : in STD_LOGIC;
			store_board 	 : in STD_LOGIC;
			level				 : in STD_LOGIC_VECTOR(4-1 downto 0);
			-- From Board Register
			board_input 		: in tpBoard;
			board_color_input : in tpBoard;			
			-----------------
			---- OUTPUTS ----
			-----------------
			board_output 		 : out tpBoard;
			board_color_output : out tpBoard			
	);
end board_memory_manager;

architecture board_memory_managerArch of board_memory_manager is
	component boards_memory
		port(clka  : in STD_LOGIC;
			  wea   : in STD_LOGIC_VECTOR(0 downto 0);
			  addra : in STD_LOGIC_VECTOR(4-1 downto 0);	  
			  dina  : in STD_LOGIC_VECTOR(392-1 downto 0);	  
			  douta : out STD_LOGIC_VECTOR(392-1 downto 0)
		);
	end component;
	
	component boards_color_memory
		port(clka  : in STD_LOGIC;
			  wea   : in STD_LOGIC_VECTOR(0 downto 0);
			  addra : in STD_LOGIC_VECTOR(4-1 downto 0);	  
			  dina  : in STD_LOGIC_VECTOR(392-1 downto 0);	  
			  douta : out STD_LOGIC_VECTOR(392-1 downto 0)
		);
	end component;
	
	signal addr: STD_LOGIC_VECTOR(4-1 downto 0);
	signal we: STD_LOGIC_VECTOR(1-1 downto 0);	
	signal boards_mem_din, 		  boards_mem_dout: STD_LOGIC_VECTOR(14*14*2-1 downto 0);	-- 14*14 squares, 2 bits per square
	signal boards_color_mem_din, boards_color_mem_dout: STD_LOGIC_VECTOR(14*14*2-1 downto 0);	-- 14*14 squares, 2 bits per square
begin
	addr <= -- Storings
			  level 				when store_board = '1' 		else 
			  -- Level 0 restoring due to timeout arrival
			  "0000" 			when load_real_board = '1' else
			  -- Readings (going up in the search tree)
			  level-1;
	we <= "0" when store_board = '0' else "1";
	
	boards_mem_I: boards_memory
				port map(clka  => clk,
						   wea   => we,
						   addra => addr,
						   dina  => boards_mem_din,
						   douta => boards_mem_dout);
	
	boards_color_mem_I: boards_color_memory
				port map(clka  => clk,
						   wea   => we,
						   addra => addr,
						   dina  => boards_color_mem_din,
						   douta => boards_color_mem_dout);							
							
	-- Type conversion to interface board register and boards memory		
		board_conversion_row: for i in 0 to 13 generate
			board_conversion_col: for j in 0 to 13 generate
				-- Manager outputs
				board_output		(i)(j) <= boards_mem_dout		 ((i*14*2)+(j*2)+2-1 downto (i*14*2)+(j*2));
				board_color_output(i)(j) <= boards_color_mem_dout((i*14*2)+(j*2)+2-1 downto (i*14*2)+(j*2));
				-- Memory inputs
				boards_mem_din		  ((i*14*2)+(j*2)+2-1 downto (i*14*2)+(j*2)) <= board_input		  (i)(j);
				boards_color_mem_din((i*14*2)+(j*2)+2-1 downto (i*14*2)+(j*2)) <= board_color_input(i)(j);
			end generate;
		end generate;
end board_memory_managerArch;