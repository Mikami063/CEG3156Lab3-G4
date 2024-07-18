LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY mux2to1 IS
    GENERIC ( NUM_BITS : integer := 8);--default to 8
    PORT(
        i_S:IN STD_LOGIC;
        i_a,i_b:IN STD_LOGIC_VECTOR(NUM_BITS-1 downto 0);
        o_O:OUT STD_LOGIC_VECTOR(NUM_BITS-1 downto 0));
END ENTITY;

ARCHITECTURE rtl OF mux2to1 IS
    SIGNAL int_S: STD_LOGIC_VECTOR(NUM_BITS-1 downto 0);
BEGIN 
    int_S<= (others=> i_S);
    o_O<=(i_b and int_S) or (i_a and not int_S);
END ARCHITECTURE;