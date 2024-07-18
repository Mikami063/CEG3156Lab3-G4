--------------------------------------------------------------------------------
-- Title         : Any bits register
-- Author        : Qingyun Yang  <qyang063@uottawa.ca>
-- Created       : 2024/05/30
-- Last modified : 2024/05/30
-------------------------------------------------------------------------------
-- Description : what you will expect from a register 
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY AnyBitsRegister IS
		GENERIC ( NUM_BITS : integer := 8);--default to 8
    PORT(
        i_resetBar, i_load : IN    STD_LOGIC;
        i_clock           : IN    STD_LOGIC;
        i_Value           : IN    STD_LOGIC_VECTOR(NUM_BITS-1 downto 0);
        o_Value           : OUT   STD_LOGIC_VECTOR(NUM_BITS-1 downto 0));
END ENTITY;

ARCHITECTURE rtl OF AnyBitsRegister IS
    SIGNAL int_Value : STD_LOGIC_VECTOR(NUM_BITS-1 downto 0);

    COMPONENT enARdFF_2
    PORT(
        i_resetBar : IN    STD_LOGIC;
        i_d        : IN    STD_LOGIC;
        i_enable   : IN    STD_LOGIC;
        i_clock    : IN    STD_LOGIC;
        o_q, o_qBar : OUT   STD_LOGIC);
    END COMPONENT;

BEGIN

loop1: FOR i IN NUM_BITS-1 DOWNTO 0 GENERATE
    ff: enARdFF_2
    PORT MAP (i_resetBar => i_resetBar,
              i_d => i_Value(i), 
              i_enable => i_load,
              i_clock => i_clock,
              o_q => int_Value(i));
END GENERATE loop1;

    -- Output Driver
    o_Value     <= int_Value;

END rtl;
