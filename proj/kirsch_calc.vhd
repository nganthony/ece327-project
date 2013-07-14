library ieee;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all ;

entity kirsch_calc is
	port(
	a,b,c,d,e,f,g,h,i: in unsigned(7 downto 0);
	i_valid: in std_logic;
	i_clock: in std_logic;
	valid_shift: in unsigned(0 to 8);
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
	signal dir_max,dir_reg1,dir_reg2,dir_max_stg3: direction;
	--stage1 signals
	signal r1,r2,r3,r4,r5: unsigned(7 downto 0);
--	signal maxi1,maxi2: unsigned ( 7 downto 0);
	signal r6: unsigned (8 downto 0);
	signal dir1,dir2,dir3,dir4: direction;
	--stage 2 signal
	signal r7: unsigned (9 downto 0);
	signal r6_buffer: unsigned (8 downto 0);
	--stage 3 signal
	signal r8,r8_buffer: unsigned (13 downto 0);
	signal r9,stg3_max_result: unsigned (9 downto 0);
	signal r_postshift: unsigned (12 downto 0);
	--stage 4 signal
	signal r10: signed (14 downto 0);
	
	

	
begin

--max module used in stage 1
stage_1_8bit_maxer: entity work.eight_bit_max(main)
			port map(
			i_clock=>i_clock,
			i_src1=>r1,
			i_src2=>r2,
			i_dir1=>dir1,
			i_dir2=>dir2,
			o_dir=>dir_max,
			o_max=>r5
			);
			
stage_3_10bit_maxer: entity work.ten_bit_max(main)
			port map(
			i_clock=>i_clock,
			i_src1=>r7,
			i_src2=>r9,
			i_dir1=>dir3,
			i_dir2=>dir4,
			o_dir=>dir_max_stg3,
			o_max=>stg3_max_result
			);

stage_1_proc: process
	variable valid_check: unsigned(0 to 8);
begin
wait until rising_edge(i_clock);
	--go ahead in time
		valid_check := valid_shift srl 1;
	
	--s0
	if i_valid='1' or valid_check(4)='1' then
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
	--s2
	elsif valid_check(2) = '1' then
		r1<=c;
		r2<=f;
		r3<=d;
		r4<=e;
	--s3
	elsif valid_check(3) = '1' then
		r1<=e;
		r2<=h;
		r3<=g;
		r4<=f;
	end if;
	r6<=('0'&r3)+('0'&r4);
end process;

stage_2_proc: process
begin
wait until rising_edge(i_clock);

	r7<=("00"&r5)+('0'&r6);
	r6_buffer<=r6;

end process;

stage_3_proc: process
	variable valid_check2: unsigned(0 to 8);
	variable for_shift: unsigned (13 downto 0);
begin
wait until rising_edge(i_clock);
	-- go ahead in time
		valid_check2 := valid_shift srl 1;
	
	-- shifting
	if valid_check2(5)='1' then
		for_shift:=r8 sll 1;
		r_postshift<= for_shift(12 downto 0);
	end if;
	
	-- r8
	if valid_check2(2)='1' then
		r8<="00000"&r6_buffer;
	-- elsif valid_check2(6)='1' then
		-- r8<=('0'&r_postshift)+r8;
	else
		r8<=("00000"&r6)+r8;
	end if;
	
	if valid_check2(6)='1' then
		r8_buffer<=('0'&r_postshift)+r8;
	end if;
	
	-- r9
	if valid_check2(2)='1' then
		r9<=r7;
	elsif valid_check2(3)='1' then
		r9<=r9;
	else
		r9<=stg3_max_result;
	end if;
	
end process;


stage_4_proc: process
variable valid_check3: unsigned(0 to 8);
variable eighttimesr9: unsigned(13 downto 0);
variable out_valid,out_edge: std_logic;
begin
wait until rising_edge(i_clock);
--go ahead in time
	valid_check3 := valid_shift srl 1;

	out_valid:='0';
	out_edge:='0';
	
	if valid_check3(7)='1' then
		eighttimesr9:='0'&r9&"000";
		r10<=signed('0'&eighttimesr9)-signed('0'&r8_buffer);
	end if;
	
	if valid_check3(8)='1' then
		out_valid:='1';
		if r10>383 then
			out_edge:='1';
		end if;
	end if;	
		
	o_valid<=out_valid;
	o_edge<=out_edge;
	
end process;

end architecture;
