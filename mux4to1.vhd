LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY mux4to1 IS
    GENERIC ( NUM_BITS : integer := 8);--default to 8
    PORT(
        i_S:IN STD_LOGIC_VECTOR(1 downto 0);
        i_I0,i_I1,i_I2,i_I3:IN STD_LOGIC_VECTOR(NUM_BITS-1 downto 0);
        o_O:OUT STD_LOGIC_VECTOR(NUM_BITS-1 downto 0));
END ENTITY;

ARCHITECTURE rtl OF mux4to1 IS
    SIGNAL int_S1,int_S0,int_SINV1,int_SINV0:STD_LOGIC_VECTOR(NUM_BITS-1 downto 0);
    SIGNAL A0,A1,A2,A3:STD_LOGIC_VECTOR(NUM_BITS-1 downto 0);
BEGIN 
    int_SINV1 <= not int_S1;
    int_SINV0 <= not int_S0;

    int_S0 <= (others=> i_S(0));
    int_S1 <= (others=> i_S(1));

    A3<= i_I3 and int_S0 and int_S1;
    A2<= i_I2 and int_SINV0 and int_S1;
    A1<= i_I1 and int_S0 and int_SINV1;
    A0<= i_I0 and int_SINV0 and int_SINV1;
    o_O<=A3 or A2 or A1 or A0;
END ARCHITECTURE;