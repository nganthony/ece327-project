library ieee;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all ;

entity kirsch_calc is
	port(
	a,b,c,d,e,f,g,h,i: in unsigned(7 downto 0);
	i_valid: in std_logic;
	valid_shift: in std_logic_vector(0 to 7);
	o_valid: out std_logic;
	o_dir: out std_logic_vector(2 downto 0);
	o_edge: out std_logic
	);
end entity;

architecture main of kirsch_calc is
begin

end architecture;