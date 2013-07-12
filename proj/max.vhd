library ieee;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all ;

entity eight_bit_max is
  port (
	i_clock : in std_logic;
    i_src1, i_src2	: in unsigned( 7 downto 0);
	i_dir1, i_dir2	: in std_logic_vector(2 downto 0);
	o_dir	: out std_logic_vector(2 downto 0);
	o_max	: out unsigned (7 downto 0)
    );
end entity;

architecture main of eight_bit_max is
signal r1 : unsigned(7 downto 0);
begin
	process
	begin
	wait until rising_edge(i_clock);
		if (i_src1 >= i_src2) then
			r1<=i_src1;
			o_dir<=i_dir1;
		else
			r1<=i_src2;
			o_dir<=i_dir2;
		end if;
	end process;
o_max <= r1;

end architecture;