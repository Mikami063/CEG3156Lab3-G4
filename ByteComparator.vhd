LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY ByteComparator IS
    PORT(
        i_a,i_b:IN STD_LOGIC_VECTOR(7 downto 0);
        o_equal:OUT STD_LOGIC);
END ENTITY;

ARCHITECTURE rtl OF ByteComparator IS
BEGIN 
    o_equal <= (i_a(7) xnor i_b(7)) and (i_a(6) xnor i_b(6)) and (i_a(5) xnor i_b(5)) and (i_a(4) xnor i_b(4)) and (i_a(3) xnor i_b(3)) and (i_a(2) xnor i_b(2)) and (i_a(1) xnor i_b(1)) and (i_a(0) xnor i_b(0));
	 --i_a xnor i_b
END ARCHITECTURE;