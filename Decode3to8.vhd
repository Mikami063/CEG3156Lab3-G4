--------------------------------------------------------------------------------
-- Title         : 3 bits to 8 bits decoder
-- Author        : Qingyun Yang  <qyang063@uottawa.ca>
-- Created       : 2024/06/27
-- Last modified : 2024/06/27
-------------------------------------------------------------------------------
-- Description : what you will expect from a decoder, made from two smaller 2 to 4 decoder
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

ENTITY Decode3to8 IS
    PORT(
			i_en: IN STD_LOGIC;
        i_I: IN STD_LOGIC_VECTOR(2 downto 0);
        o_O: out STD_LOGIC_VECTOR(7 downto 0));
END ENTITY;
ARCHITECTURE rtl of Decode3to8 IS

    SIGNAL int_en1,int_en0:STD_LOGIC;
    COMPONENT Decode2to4 IS
        PORT(
				i_en: IN STD_LOGIC;
            i_I: IN STD_LOGIC_VECTOR(1 downto 0);
            o_O: out STD_LOGIC_VECTOR(3 downto 0));
    END COMPONENT;

BEGIN

    int_en0<= not i_I(2) and i_en;
    int_en1<= i_I(2) and i_en;

d1: Decode2to4
    PORT MAP(
					i_en => int_en1,
             i_I=> i_I(1 downto 0),
             o_O=> o_O(7 downto 4));

d0: Decode2to4
    PORT MAP(
					i_en => int_en0,
             i_I=> i_I(1 downto 0),
             o_O=> o_O(3 downto 0));
    
END ARCHITECTURE;