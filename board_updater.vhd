library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use work.types.all;

entity board_updater is
	port (----------------
			---- INPUTS ----
			----------------			
			-- Movement info
			player			 : in tpPlayer;
			tile_x_pos		 : in tpPiecesPositions;
			tile_y_pos		 : in tpPiecesPositions;
			piece_valid		 : in STD_LOGIC_VECTOR(5-1 downto 0);
			forbidden_x_pos : in tpForbiddenPositions;
			forbidden_y_pos : in tpForbiddenPositions;
			forbidden_valid : in STD_LOGIC_VECTOR(12-1 downto 0);
			-- Forbiddens board
			board : in tpBoard;
			-- Color board
			board_color : in tpBoard;
			-----------------
			---- OUTPUTS ----
			-----------------			
			new_board 		 : out tpBoard;
			new_board_color : out tpBoard
	);
end board_updater;

architecture board_updaterArch of board_updater is	
	signal color: tpSquare;
begin
	color <= SQUARE_HERO when player = HERO else SQUARE_RIVAL;
	
	-- Tile writing: marks as FORBIDDEN_BOTH the occupied square, and updates its north, south, west and east adjacent squares
	move_writing_row: for i in 0 to 14-1 generate
		move_writing_col: for j in 0 to 14-1 generate
			-- Board for accessibility
			new_board(i)(j) <= FORBIDDEN_BOTH 		 when (piece_valid(0) = '1' AND i = conv_integer(tile_y_pos(0)) AND j = conv_integer(tile_x_pos(0))) OR
																		(piece_valid(1) = '1' AND i = conv_integer(tile_y_pos(1)) AND j = conv_integer(tile_x_pos(1))) OR
																		(piece_valid(2) = '1' AND i = conv_integer(tile_y_pos(2)) AND j = conv_integer(tile_x_pos(2))) OR
																		(piece_valid(3) = '1' AND i = conv_integer(tile_y_pos(3)) AND j = conv_integer(tile_x_pos(3))) OR
																		(piece_valid(4) = '1' AND i = conv_integer(tile_y_pos(4)) AND j = conv_integer(tile_x_pos(4)))
																		else
									 '1' & board(i)(j)(0) when (player = HERO) AND 
																		(
																		 (forbidden_valid( 0) = '1' AND i = conv_integer(forbidden_y_pos( 0)) AND j = conv_integer(forbidden_x_pos( 0))) OR
																		 (forbidden_valid( 1) = '1' AND i = conv_integer(forbidden_y_pos( 1)) AND j = conv_integer(forbidden_x_pos( 1))) OR
																		 (forbidden_valid( 2) = '1' AND i = conv_integer(forbidden_y_pos( 2)) AND j = conv_integer(forbidden_x_pos( 2))) OR
																		 (forbidden_valid( 3) = '1' AND i = conv_integer(forbidden_y_pos( 3)) AND j = conv_integer(forbidden_x_pos( 3))) OR
																		 (forbidden_valid( 4) = '1' AND i = conv_integer(forbidden_y_pos( 4)) AND j = conv_integer(forbidden_x_pos( 4))) OR
																		 (forbidden_valid( 5) = '1' AND i = conv_integer(forbidden_y_pos( 5)) AND j = conv_integer(forbidden_x_pos( 5))) OR
																		 (forbidden_valid( 6) = '1' AND i = conv_integer(forbidden_y_pos( 6)) AND j = conv_integer(forbidden_x_pos( 6))) OR
																		 (forbidden_valid( 7) = '1' AND i = conv_integer(forbidden_y_pos( 7)) AND j = conv_integer(forbidden_x_pos( 7))) OR
																		 (forbidden_valid( 8) = '1' AND i = conv_integer(forbidden_y_pos( 8)) AND j = conv_integer(forbidden_x_pos( 8))) OR
																		 (forbidden_valid( 9) = '1' AND i = conv_integer(forbidden_y_pos( 9)) AND j = conv_integer(forbidden_x_pos( 9))) OR
																		 (forbidden_valid(10) = '1' AND i = conv_integer(forbidden_y_pos(10)) AND j = conv_integer(forbidden_x_pos(10))) OR
																		 (forbidden_valid(11) = '1' AND i = conv_integer(forbidden_y_pos(11)) AND j = conv_integer(forbidden_x_pos(11)))
																		) else
									 board(i)(j)(1) & '1' when (player = RIVAL) AND 
																	   (
																		 (forbidden_valid( 0) = '1' AND i = conv_integer(forbidden_y_pos( 0)) AND j = conv_integer(forbidden_x_pos( 0))) OR
																		 (forbidden_valid( 1) = '1' AND i = conv_integer(forbidden_y_pos( 1)) AND j = conv_integer(forbidden_x_pos( 1))) OR
																		 (forbidden_valid( 2) = '1' AND i = conv_integer(forbidden_y_pos( 2)) AND j = conv_integer(forbidden_x_pos( 2))) OR
																		 (forbidden_valid( 3) = '1' AND i = conv_integer(forbidden_y_pos( 3)) AND j = conv_integer(forbidden_x_pos( 3))) OR
																		 (forbidden_valid( 4) = '1' AND i = conv_integer(forbidden_y_pos( 4)) AND j = conv_integer(forbidden_x_pos( 4))) OR
																		 (forbidden_valid( 5) = '1' AND i = conv_integer(forbidden_y_pos( 5)) AND j = conv_integer(forbidden_x_pos( 5))) OR
																		 (forbidden_valid( 6) = '1' AND i = conv_integer(forbidden_y_pos( 6)) AND j = conv_integer(forbidden_x_pos( 6))) OR
																		 (forbidden_valid( 7) = '1' AND i = conv_integer(forbidden_y_pos( 7)) AND j = conv_integer(forbidden_x_pos( 7))) OR
																		 (forbidden_valid( 8) = '1' AND i = conv_integer(forbidden_y_pos( 8)) AND j = conv_integer(forbidden_x_pos( 8))) OR
																		 (forbidden_valid( 9) = '1' AND i = conv_integer(forbidden_y_pos( 9)) AND j = conv_integer(forbidden_x_pos( 9))) OR
																		 (forbidden_valid(10) = '1' AND i = conv_integer(forbidden_y_pos(10)) AND j = conv_integer(forbidden_x_pos(10))) OR
																		 (forbidden_valid(11) = '1' AND i = conv_integer(forbidden_y_pos(11)) AND j = conv_integer(forbidden_x_pos(11)))
																		) else
									 board(i)(j);
			
			-- Board for vertex detection
			new_board_color(i)(j) <= color when (piece_valid(0) = '1' AND i = conv_integer(tile_y_pos(0)) AND j = conv_integer(tile_x_pos(0))) OR
															(piece_valid(1) = '1' AND i = conv_integer(tile_y_pos(1)) AND j = conv_integer(tile_x_pos(1))) OR
															(piece_valid(2) = '1' AND i = conv_integer(tile_y_pos(2)) AND j = conv_integer(tile_x_pos(2))) OR
															(piece_valid(3) = '1' AND i = conv_integer(tile_y_pos(3)) AND j = conv_integer(tile_x_pos(3))) OR
															(piece_valid(4) = '1' AND i = conv_integer(tile_y_pos(4)) AND j = conv_integer(tile_x_pos(4))) 
											 else board_color(i)(j);
		end generate;
	end generate;
end board_updaterArch;