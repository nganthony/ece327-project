
library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity kirsch is
  port(
    ------------------------------------------
    -- main inputs and outputs
    i_clock    : in  std_logic;                      
    i_reset    : in  std_logic;                      
    i_valid    : in  std_logic;                 
    i_pixel    : in  std_logic_vector(7 downto 0);
    o_valid    : out std_logic;                 
    o_edge     : out std_logic;	                     
    o_dir      : out std_logic_vector(2 downto 0);                      
    o_mode     : out std_logic_vector(1 downto 0);
    o_row      : out std_logic_vector(7 downto 0);
    ------------------------------------------
    -- debugging inputs and outputs
    debug_key      : in  std_logic_vector( 3 downto 1) ; 
    debug_switch   : in  std_logic_vector(17 downto 0) ; 
    debug_led_red  : out std_logic_vector(17 downto 0) ; 
    debug_led_grn  : out std_logic_vector(5  downto 0) ; 
    debug_num_0    : out std_logic_vector(3 downto 0) ; 
    debug_num_1    : out std_logic_vector(3 downto 0) ; 
    debug_num_2    : out std_logic_vector(3 downto 0) ; 
    debug_num_3    : out std_logic_vector(3 downto 0) ; 
    debug_num_4    : out std_logic_vector(3 downto 0) ;
    debug_num_5    : out std_logic_vector(3 downto 0) 
    ------------------------------------------
  );  
end entity;


architecture main of kirsch is
--signal insertion starts here
signal column : unsigned(7 downto 0);
signal row : unsigned(8 downto 0);
signal a,b,c,d,e,f,g,h,i : unsigned(7 downto 0);
signal input_1,input_2,input_3: std_logic_vector(7 downto 0);
signal take_input: unsigned( 7 downto 0);
signal valid_shift: unsigned(0 to 7);

--Write/Read enable one hot encoding
subtype wren_state is std_logic_vector(2 downto 0);
	constant s0 : wren_state := "000";
	constant s1 : wren_state := "001";
	constant s2 : wren_state := "010";
	constant s3 : wren_state := "100";
	signal wren : wren_state := s0;

 -- A function to rotate left (rol) a vector by n bits 
function "rol" ( a : std_logic_vector; n : natural )
return std_logic_vector
is
begin
    return std_logic_vector( unsigned(a) rol n );
end function;

--signal insertion completed
begin  

  debug_num_5 <= X"E";
  debug_num_4 <= X"C";
  debug_num_3 <= X"E";
  debug_num_2 <= X"3";
  debug_num_1 <= X"2";
  debug_num_0 <= X"7";

  debug_led_red <= (others => '0');
  debug_led_grn <= (others => '0');
  
  
--code insertion starts here  
  row0 : entity work.mem(main)
		port map(
			address => std_logic_vector(column),
			clock => i_clock,
			data => i_pixel,
			wren => wren(0),
			q => input_1);

row1 : entity work.mem(main)
		port map(
			address => std_logic_vector(column),
			clock => i_clock,
			data => i_pixel,
			wren => wren(1),
			q => input_2);

row2 : entity work.mem(main)
		port map(
			address => std_logic_vector(column),
			clock => i_clock,
			data => i_pixel,
			wren => wren(2),
			q => input_3);

with wren select
  c<=unsigned(input_2)   when s1,
     unsigned(input_3)   when s2,
     unsigned(input_1)   when s3,
     "00000000"     when others;

with wren select
  d<=unsigned(input_3)    when s1,
     unsigned(input_1)    when s2,
     unsigned(input_2)    when s3,
     "00000000"  when others;

take_input <= unsigned(i_pixel);

-- reset_proc: process begin
-- wait until rising_edge(i_clock);
	-- if i_reset = '1' then
		-- wren <= s1;
	-- elsif column = x"FF" and i_valid = '1' then
		-- wren <= "rol"(wren, 1);
	-- else
	-- end if;
-- end process;

valid_shift_proc: process
 variable v_s: unsigned(0 to 7);
begin
wait until rising_edge(i_clock);
	v_s:= valid_shift srl 1;
if i_reset='1' then
	v_s:=x"00";
elsif i_valid='1' then
	v_s(0):='1';
end if;
	valid_shift<=v_s;
end process;


main_proc: process
begin
wait until rising_edge(i_clock);
--reset
if i_reset = '1' then
  column<=x"00";
  row<="000000000";
  wren <=s1;
--consecutive matrix input
elsif i_valid ='1' and row(8)='1' then
  column<=x"01";
  row<="000000000";

elsif i_valid = '1' then
	column <=column +1;
	
	if row >= 2 then
	--convolution table column shift
	--column 2->1
	a<=b;
	h<=i;
	g<=f;
	--column 3->2
	b<=c;
	i<=d;
	f<=e;
	--update column 3
	e<=take_input;
	end if;
	-- column and row control
	if column = x"FF" then
      row <= row + 1;
      column <= x"00";
      wren <= "rol"(wren, 1);
    end if;
end if;

end process;
  
end architecture;
