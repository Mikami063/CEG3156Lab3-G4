library ieee;
use ieee.std_logic_1164.all;

ENTITY RegisterFile IS
	PORT(
	    i_resetBar, i_clock, RegWrite: IN STD_LOGIC;
        i_Value: IN	STD_LOGIC_VECTOR(7 downto 0);
        ReadReg1,ReadReg2,WriteReg: IN STD_LOGIC_VECTOR(4 downto 0);
        ReadData1, ReadData2: OUT STD_LOGIC_VECTOR(7 downto 0);
		  debug_reg7 :OUT STD_LOGIC_VECTOR(7 downto 0);
		  debug_reg6 :OUT STD_LOGIC_VECTOR(7 downto 0);
		  debug_reg5 :OUT STD_LOGIC_VECTOR(7 downto 0);
		  debug_reg4 :OUT STD_LOGIC_VECTOR(7 downto 0);
		  debug_reg3 :OUT STD_LOGIC_VECTOR(7 downto 0);
		  debug_reg2 :OUT STD_LOGIC_VECTOR(7 downto 0);
		  debug_reg1 :OUT STD_LOGIC_VECTOR(7 downto 0);
		  debug_reg0 :OUT STD_LOGIC_VECTOR(7 downto 0)
        );
END ENTITY;

ARCHITECTURE rtl OF RegisterFile IS

    SIGNAL int_en: STD_LOGIC_VECTOR(7 downto 0);
    Type int_Reg_t IS ARRAY (7 downto 0) OF STD_LOGIC_VECTOR(7 downto 0);
	 SIGNAL int_Reg: int_Reg_t;
    

    COMPONENT ByteRegister IS
        PORT(
            i_resetBar, i_load : IN    STD_LOGIC;
            i_clock           : IN    STD_LOGIC;
            i_Value           : IN    STD_LOGIC_VECTOR(7 downto 0);
            o_Value           : OUT   STD_LOGIC_VECTOR(7 downto 0));
    END COMPONENT;

    COMPONENT Decode3to8 IS
        PORT(
		  i_en: IN STD_LOGIC;
            i_I: IN STD_LOGIC_VECTOR(2 downto 0);
            o_O: out STD_LOGIC_VECTOR(7 downto 0));
    END COMPONENT;

    COMPONENT mux8to1 IS
        GENERIC ( NUM_BITS : integer :=8);
        PORT(
            i_S:IN STD_LOGIC_VECTOR(2 downto 0);
            i_I0,i_I1,i_I2,i_I3,i_I4,i_I5,i_I6,i_I7:IN STD_LOGIC_VECTOR(NUM_BITS-1 downto 0);
            o_O:OUT STD_LOGIC_VECTOR(NUM_BITS-1 downto 0));
    END COMPONENT;

BEGIN

mux1: mux8to1
    PORT MAP(
        i_S => ReadReg1(2 downto 0),
        i_I0 => int_Reg(0),
        i_I1 => int_Reg(1),
        i_I2 => int_Reg(2),
        i_I3 => int_Reg(3),
        i_I4 => int_Reg(4),
        i_I5 => int_Reg(5),
        i_I6 => int_Reg(6),
        i_I7 => int_Reg(7),
        o_O => ReadData1
        );

mux2: mux8to1
    PORT MAP(
        i_S => ReadReg2(2 downto 0),
        i_I0 => int_Reg(0),
        i_I1 => int_Reg(1),
        i_I2 => int_Reg(2),
        i_I3 => int_Reg(3),
        i_I4 => int_Reg(4),
        i_I5 => int_Reg(5),
        i_I6 => int_Reg(6),
        i_I7 => int_Reg(7),
        o_O => ReadData2
        );

decoder: Decode3to8
    PORT MAP(
	 i_en => '1',
        i_I => WriteReg(2 downto 0),
        o_O => int_en
        );


loop1: FOR i IN 7 DOWNTO 0 GENERATE
    Reg: ByteRegister
    PORT MAP(
            i_resetBar => i_resetBar, 
            i_load => int_en(i) and RegWrite,
            i_clock => i_clock,
            i_Value => i_Value,
            o_Value => int_Reg(i)
            );
END GENERATE loop1;

debug_reg7 <= int_Reg(7);
debug_reg6 <= int_Reg(6);
debug_reg5 <= int_Reg(5);
debug_reg4 <= int_Reg(4);
debug_reg3 <= int_Reg(3);
debug_reg2 <= int_Reg(2);
debug_reg1 <= int_Reg(1);
debug_reg0 <= int_Reg(0);


END ARCHITECTURE;