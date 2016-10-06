library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.types.ALL;

entity available_tiles is
	generic (max_level : positive := 10;
             bits_level : positive := 4);
    port (----------------
		  ---- INPUTS ----
		  ----------------
		  clk : in  STD_LOGIC;
		  rst : in  STD_LOGIC;			
		  swap_players : in STD_LOGIC;
		  remove_tile  : in STD_LOGIC;
		  restore_tile : in STD_LOGIC;			
		  player	   : in tpPlayer;
		  tile		   : in STD_LOGIC_VECTOR(5-1 downto 0);
		  level		   : in STD_LOGIC_VECTOR(bits_level-1 downto 0);
		  -----------------
		  ---- OUTPUTS ----
		  -----------------
		  -- Tiles available for the current search branch and player
		  tiles_available_hero	: out STD_LOGIC_VECTOR(21-1 downto 0);
		  tiles_available_rival : out STD_LOGIC_VECTOR(21-1 downto 0));
end available_tiles;

architecture available_tilesArch of available_tiles is
	component reg is
		generic(bits		 : positive := 128;
				  init_value : natural := 0);
		port (----------------
				---- INPUTS ----
				----------------
				clk : in std_logic;
				rst : in std_logic;
				ld	 : in std_logic;
				din : in std_logic_vector(bits-1 downto 0);
				-----------------
				---- OUTPUTS ----
				-----------------
				dout : out std_logic_vector(bits-1 downto 0)
		);
	end component;
	
	signal update_hero, update_rival: STD_LOGIC; 
	signal new_tiles_vector_hero, new_tiles_vector_rival: STD_LOGIC_VECTOR(21-1 downto 0);
	signal tiles_hero, tiles_rival: STD_LOGIC_VECTOR(21-1 downto 0);
	-- Placed tiles reg
	type tp_placed_tiles is array(0 to max_level-1) of STD_LOGIC_VECTOR(5-1 downto 0); 
	signal placed_tiles: tp_placed_tiles;
	signal upper_level_placed_tile: STD_LOGIC_VECTOR(5-1 downto 0);
	signal ld_placed_tile: STD_LOGIC_VECTOR(max_level-1 downto 0);
begin
	tiles_hero_reg : reg generic map(21, 2097151) port map(clk, rst, update_hero,  new_tiles_vector_hero,  tiles_hero);
	tiles_rival_reg: reg generic map(21, 2097151) port map(clk, rst, update_rival, new_tiles_vector_rival, tiles_rival);	
	
	update_hero  <= '1' when swap_players = '1' OR (player = HERO  AND (remove_tile = '1' OR restore_tile = '1')) else '0';
    update_rival <= '1' when swap_players = '1' OR (player = RIVAL AND (remove_tile = '1' OR restore_tile = '1')) else '0';
	
	upper_level_placed_tile <= placed_tiles(conv_integer(level-1)) when level > 0 else conv_std_logic_vector(21, 5);
	
	new_tiles_vector: for i in 0 to 21-1 generate
			new_tiles_vector_hero(i)  <= '0'            when remove_tile  = '1' AND i = tile else
										 '1'            when restore_tile = '1' AND i = upper_level_placed_tile else
										 tiles_rival(i) when swap_players = '1' else
										 tiles_hero(i);
			new_tiles_vector_rival(i) <= '0'           when remove_tile  = '1' AND i = tile else
										 '1'           when restore_tile = '1' AND i = upper_level_placed_tile else
										 tiles_hero(i) when swap_players = '1' else
										 tiles_rival(i);
	end generate;
	
	-- Info of placed tiles in a branch to restore them
	branch_tiles: for i in 0 to max_level-1 generate
		placed_tiles_reg : reg generic map(5, 0) port map(clk, rst, ld_placed_tile(i), tile, placed_tiles(i));
		ld_placed_tile(i) <= '1' when remove_tile = '1' AND level = i else '0';
	end generate;
	
	-- Output
	tiles_available_hero  <= tiles_hero;
	tiles_available_rival <= tiles_rival;
end available_tilesArch;