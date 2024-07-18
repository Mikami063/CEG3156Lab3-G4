--------------------------------------------------------------------------------
-- Title         : 8 bits register
-- Author        : Qingyun Yang  <qyang063@uottawa.ca>
-- Created       : 2024/05/30
-- Last modified : 2024/05/30
-------------------------------------------------------------------------------
-- Description : what you will expect from a register 
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY ByteRegister IS
    PORT(
        i_resetBar, i_load : IN    STD_LOGIC;
        i_clock           : IN    STD_LOGIC;
        i_Value           : IN    STD_LOGIC_VECTOR(7 downto 0);
        o_Value           : OUT   STD_LOGIC_VECTOR(7 downto 0));
END ENTITY;

ARCHITECTURE rtl OF ByteRegister IS
    SIGNAL int_Value : STD_LOGIC_VECTOR(7 downto 0);

    COMPONENT enARdFF_2
    PORT(
        i_resetBar : IN    STD_LOGIC;
        i_d        : IN    STD_LOGIC;
        i_enable   : IN    STD_LOGIC;
        i_clock    : IN    STD_LOGIC;
        o_q, o_qBar : OUT   STD_LOGIC);
    END COMPONENT;

BEGIN

ff7: enARdFF_2
    PORT MAP (i_resetBar => i_resetBar,
              i_d => i_Value(7), 
              i_enable => i_load,
              i_clock => i_clock,
              o_q => int_Value(7));

ff6: enARdFF_2
    PORT MAP (i_resetBar => i_resetBar,
              i_d => i_Value(6), 
              i_enable => i_load,
              i_clock => i_clock,
              o_q => int_Value(6));

ff5: enARdFF_2
    PORT MAP (i_resetBar => i_resetBar,
              i_d => i_Value(5), 
              i_enable => i_load,
              i_clock => i_clock,
              o_q => int_Value(5));

ff4: enARdFF_2
    PORT MAP (i_resetBar => i_resetBar,
              i_d => i_Value(4), 
              i_enable => i_load,
              i_clock => i_clock,
              o_q => int_Value(4));

ff3: enARdFF_2
    PORT MAP (i_resetBar => i_resetBar,
              i_d => i_Value(3), 
              i_enable => i_load,
              i_clock => i_clock,
              o_q => int_Value(3));

ff2: enARdFF_2
    PORT MAP (i_resetBar => i_resetBar,
              i_d => i_Value(2), 
              i_enable => i_load,
              i_clock => i_clock,
              o_q => int_Value(2));

ff1: enARdFF_2
    PORT MAP (i_resetBar => i_resetBar,
              i_d => i_Value(1), 
              i_enable => i_load,
              i_clock => i_clock,
              o_q => int_Value(1));

ff0: enARdFF_2
    PORT MAP (i_resetBar => i_resetBar,
              i_d => i_Value(0), 
              i_enable => i_load,
              i_clock => i_clock,
              o_q => int_Value(0));

    -- Output Driver
    o_Value     <= int_Value;

END rtl;
