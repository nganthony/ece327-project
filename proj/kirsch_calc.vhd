library ieee;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all ;

entity kirsch_calc is
	port(
	a,b,c,d,e,f,g,h,i: in unsigned(7 downto 0);
	i_valid: in std_logic;
	i_clock: in std_logic;
	valid_shift: in unsigned(0 to 7);
	o_valid: out std_logic;
	o_dir: out std_logic_vector(2 downto 0);
	o_edge: out std_logic
	);
end entity;

architecture main of kirsch_calc is
subtype direction is std_logic_vector(2 downto 0);
	constant W: direction := "001";
	constant NW: direction := "100";
	constant N: direction := "010";
	constant NE: direction := "110";
	constant East: direction := "000";
	constant SE: direction := "101";
	constant S: direction := "011";
	constant SW: direction := "111";
	
--registers and other signals
	--global direction register
	signal dir_max,dir_reg1,dir_reg2: direction;
	--stage1 signals
	signal r1,r2,r3,r4,r5: unsigned(7 downto 0);
	signal maxi1,maxi2: unsigned ( 7 downto 0);
	signal r6: unsigned (8 downto 0);
	signal dir1,dir2: direction;

	
begin

--max module used in stage 1
stage_1_8bit_maxer: entity work.eight_bit_max(main)
			port map(i_src1=>maxi1,
			i_src2=>maxi2,
			i_dir1=>dir1,
			i_dir2=>dir2,
			o_dir=>dir_max,
			o_max=>r5
			);

stage_1_proc: process
	variable valid_check: unsigned(0 to 7);
begin
wait until rising_edge(i_clock);
	--go ahead in time
	valid_check := unsigned(valid_shift) srl 1;
	
	--s0
	if i_valid='1' then
		r1<=f;
		r2<=c;
		r3<=b;
		r4<=i;
	--s1
	elsif valid_check(1) = '1' then
		r1<=a;
		r2<=d;
		r3<=b;
		r4<=c;
		maxi1<=r1;
		maxi2<=r2;
	--s2
	elsif valid_check(2) = '1' then
		r1<=c;
		r2<=f;
		r3<=d;
		r4<=e;
		maxi1<=r1;
		maxi2<=r2;
	--s3
	elsif valid_check(3) = '1' then
		r1<=e;
		r2<=h;
		r3<=g;
		r4<=f;
		maxi1<=r1;
		maxi2<=r2;
	--s4
	elsif valid_check(4) = '1' then
		maxi1<=r1;
		maxi2<=r2;
	end if;

end process;

end architecture;