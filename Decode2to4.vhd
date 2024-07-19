--------------------------------------------------------------------------------
-- Title         : 2 bits to 4 bits decoder
-- Author        : Qingyun Yang  <qyang063@uottawa.ca>
-- Created       : 2024/06/27
-- Last modified : 2024/06/27
-------------------------------------------------------------------------------
-- Description : what you will expect from a decoder 
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY Decode2to4 IS
    PORT(
			i_en: IN STD_LOGIC;
        i_I: IN STD_LOGIC_VECTOR(1 downto 0);
        o_O: out STD_LOGIC_VECTOR(3 downto 0));
END ENTITY;
ARCHITECTURE rtl of Decode2to4 IS
BEGIN
    o_O(3) <= i_I(1) and i_I(0) and i_en;
    o_O(2) <= i_I(1) and not i_I(0) and i_en;
    o_O(1) <= not i_I(1) and i_I(0) and i_en;
    o_O(0) <= not i_I(1) and not i_I(0) and i_en;
END ARCHITECTURE;