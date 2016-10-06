library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use work.types.all;

entity board_reg is
    port (----------------
	   	  ---- INPUTS ----
		  ----------------
		  clk, rst : in STD_LOGIC;
		  write_move  : in STD_LOGIC;
		  write_board : in STD_LOGIC;
		  swap_board  : in STD_LOGIC;
		  -- Data from board_updater
		  new_board 	  : in tpBoard;
		  new_board_color : in tpBoard;
		  -- Data from boards BRAMs
		  board_input 	    : in tpBoard;
		  board_color_input : in tpBoard;
		  -----------------
		  ---- OUTPUTS ----
		  -----------------
		  board 	  : out tpBoard; -- Forbidden info
		  board_color : out tpBoard  -- Color info
    );
end board_reg;

architecture board_reg_arch of board_reg is
    signal board_int, board_color_int: tpBoard;
    signal board_swapped, board_color_swapped: tpBoard;
begin
    -- Boards writings
	process(clk)
	begin	
		if clk'event and clk = '1' then
			if rst = '1' then
				board_int <= (others=> (others=>"00"));
				board_color_int <= (others=> (others=>"00"));
			else
				if write_move = '1' then
					board_int <= new_board;
					board_color_int <= new_board_color;
				elsif write_board = '1' then
					board_int <= board_input;
					board_color_int <= board_color_input;
				elsif swap_board = '1' then
				    board_int <= board_swapped;
				    board_color_int <= board_color_swapped;
				end if;			
			end if;
		end if;
	end process;
	
	-- Board swapping
	swap_y: for i in 0 to 14-1 generate
        swap_x: for j in 0 to 14-1 generate
            board_swapped(i)(j) <=  board_int(i)(j)(0) & board_int(i)(j)(1);
            board_color_swapped(i)(j) <= board_color_int(i)(j)(0) & board_color_int(i)(j)(1);
        end generate;
    end generate;
    
    -- OUTPUTS
    board <= board_int;
    board_color <= board_color_int;
end board_reg_arch;