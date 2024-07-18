library ieee;
use ieee.std_logic_1164.all;

ENTITY ByteAdder IS
	PORT(
	i_A,i_B : IN STD_LOGIC_vector(7 downto 0);
	i_Mode : IN STD_LOGIC;-- 0 for add 1 for subtract
	o_Out : OUT STD_LOGIC_vector(7 downto 0);
	o_Carry: OUT STD_LOGIC);
END ENTITY;

ARCHITECTURE rtl of ByteAdder IS

    SIGNAL int_CarryIn: STD_LOGIC_vector(7 downto 0);
    SIGNAL int_CarryOut: STD_LOGIC_vector(7 downto 0);

    COMPONENT oneBitAdder IS
        PORT(
            i_CarryIn		: IN	STD_LOGIC;
            i_Ai, i_Bi		: IN	STD_LOGIC;
            o_Sum, o_CarryOut	: OUT	STD_LOGIC);
    END COMPONENT;

BEGIN

    int_CarryIn(7 DOWNTO 1) <= int_CarryOut(6 DOWNTO 0);
    int_CarryIn(0) <= i_Mode;

loop1: FOR i IN 7 DOWNTO 0 GENERATE
    FA: oneBitAdder
    PORT MAP(
            i_CarryIn => int_CarryIn(i),
            i_Ai => i_A(i), 
            i_Bi => i_B(i) xor i_Mode,
            o_Sum => o_Out(i), 
            o_CarryOut => int_CarryOut(i)
            );
END GENERATE loop1;

    o_Carry <= int_CarryOut(7);
	 

END ARCHITECTURE;