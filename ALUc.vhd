--------------------------------------------------------------------------------
-- Title         : Any Bits ALU
-- Author        : Qingyun Yang  <qyang063@uottawa.ca>
-- Created       : 2024/06/27
-- Last modified : 2024/06/27
-------------------------------------------------------------------------------
-- Description : Do various ALU operations based on control signal input 
-- 000: AND, 001: OR, 010: ADD, 110: SUB, 111:SLT
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY ALUc IS
    GENERIC ( NUM_BITS : integer :=8);
    PORT(
        i_S:IN STD_LOGIC_VECTOR(2 downto 0);
        i_I0,i_I1:IN STD_LOGIC_VECTOR(NUM_BITS-1 downto 0);
        o_Zero, o_Overflow: OUT STD_LOGIC;
        o_O:OUT STD_LOGIC_VECTOR(NUM_BITS-1 downto 0));
END ENTITY;

ARCHITECTURE rtl OF ALUc IS

	SIGNAL int_adder: STD_LOGIC_VECTOR(7 downto 0);

    COMPONENT mux8to1 IS
        GENERIC ( NUM_BITS : integer :=8);
        PORT(
            i_S:IN STD_LOGIC_VECTOR(2 downto 0);
            i_I0,i_I1,i_I2,i_I3,i_I4,i_I5,i_I6,i_I7:IN STD_LOGIC_VECTOR(NUM_BITS-1 downto 0);
            o_O:OUT STD_LOGIC_VECTOR(NUM_BITS-1 downto 0));
    END COMPONENT;

    COMPONENT ByteAdder IS
        PORT(
        i_A,i_B : IN STD_LOGIC_vector(7 downto 0);
        i_Mode : IN STD_LOGIC;-- 0 for add 1 for subtract
        o_Out : OUT STD_LOGIC_vector(7 downto 0);
        o_Carry: OUT STD_LOGIC);
    END COMPONENT;

BEGIN

mux: mux8to1
    GENERIC MAP( NUM_BITS => 8)
    PORT MAP(i_S =>i_S,
        i_I0 => i_I0 and i_I1,--000
        i_I1 => i_I0 or i_I1,--001
        i_I2 => int_adder,--010
        i_I3 => "00000000",--011
        i_I4 => "00000000",--100
        i_I5 => "00000000",--101
        i_I6 =>int_adder,--110
        i_I7 => "0000000" & int_adder(7),--111
        o_O => o_O
    );

adder: ByteAdder
    PORT MAP(i_A => i_I0,
        i_B => i_I1,
        i_Mode => i_S(2),-- 0 for add 1 for subtract
        o_Out => int_adder,
        o_Carry => o_Overflow);
		  
		o_Zero <= not int_adder(7) and not int_adder(6) and not int_adder(5) and not int_adder(4) and not int_adder(3) and not int_adder(2) and not int_adder(2) and not int_adder(0);

END ARCHITECTURE;