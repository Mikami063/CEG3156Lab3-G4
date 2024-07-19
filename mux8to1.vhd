--------------------------------------------------------------------------------
-- Title         : 8 bits to 1 bits mux
-- Author        : Qingyun Yang  <qyang063@uottawa.ca>
-- Created       : 2024/06/27
-- Last modified : 2024/06/27
-------------------------------------------------------------------------------
-- Description : what you will expect from a mux, with any bit width from input
-- (two inputs need to have same bit width)
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY mux8to1 IS
    GENERIC ( NUM_BITS : integer :=8);
    PORT(
        i_S:IN STD_LOGIC_VECTOR(2 downto 0);
        i_I0,i_I1,i_I2,i_I3,i_I4,i_I5,i_I6,i_I7:IN STD_LOGIC_VECTOR(NUM_BITS-1 downto 0);
        o_O:OUT STD_LOGIC_VECTOR(NUM_BITS-1 downto 0));
END ENTITY;

ARCHITECTURE rtl OF mux8to1 IS

    SIGNAL int_o1,int_o0: STD_LOGIC_VECTOR(NUM_BITS-1 downto 0);

    COMPONENT mux4to1 IS
        GENERIC ( NUM_BITS : integer := 8);--default to 8
        PORT(
            i_S:IN STD_LOGIC_VECTOR(1 downto 0);
            i_I0,i_I1,i_I2,i_I3:IN STD_LOGIC_VECTOR(NUM_BITS-1 downto 0);
            o_O:OUT STD_LOGIC_VECTOR(NUM_BITS-1 downto 0));
    END COMPONENT;

    COMPONENT mux2to1 IS
        GENERIC ( NUM_BITS : integer := 8);--default to 8
        PORT(
            i_S:IN STD_LOGIC;
            i_a,i_b:IN STD_LOGIC_VECTOR(NUM_BITS-1 downto 0);
            o_O:OUT STD_LOGIC_VECTOR(NUM_BITS-1 downto 0));
    END COMPONENT;


BEGIN 

mux1: mux4to1
    GENERIC MAP(
        NUM_BITS => 8
    )
    PORT MAP(
            i_S => i_S(1 downto 0),
            i_I0 => i_I4,
            i_I1 => i_I5,
            i_I2 => i_I6,
            i_I3 => i_I7,
            o_O => int_o1);

mux0: mux4to1
    GENERIC MAP(
        NUM_BITS => 8
    )
    PORT MAP(
            i_S => i_S(1 downto 0),
            i_I0 => i_I0,
            i_I1 => i_I1,
            i_I2 => i_I2,
            i_I3 => i_I3,
            o_O => int_o0);

mux : mux2to1
    GENERIC MAP(
        NUM_BITS => 8
    )
    PORT MAP(
            i_S => i_S(2),
            i_a => int_o0,
            i_b => int_o1,
            o_O => o_O);

END ARCHITECTURE;