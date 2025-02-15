--------------------------------------------------------------------------------
-- Title         : Control Path
-- Author        : Qingyun Yang  <qyang063@uottawa.ca>
-- Created       : 2024/07/14
-- Last modified : 2024/07/14
-------------------------------------------------------------------------------
-- Description : The control module for pipeline processor
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY controlpath IS
    PORT(
        OpCode:IN STD_LOGIC_VECTOR(5 downto 0);
		  equal:IN STD_LOGIC;
        RegDst,Jump,Branch,MemRead,MemToReg,MemWrite,ALUSrc,RegWrite,IFFlush: OUT STD_LOGIC;
        ALUOp: OUT STD_LOGIC_VECTOR(1 downto 0)
        );
END ENTITY;

ARCHITECTURE rtl OF controlpath IS

    SIGNAL RType, lw, sw, beq, j : STD_LOGIC;

BEGIN

    RType <= not OpCode(5) and not OpCode(4) and not OpCode(3) and not OpCode(2) and not OpCode(1) and not OpCode(0);

    lw <= OpCode(5) and not OpCode(4) and not OpCode(3) and not OpCode(2) and OpCode(1) and OpCode(0);
    -- 35 0b100011

    sw <= OpCode(5) and not OpCode(4) and OpCode(3) and not OpCode(2) and OpCode(1) and OpCode(0);
    -- 43 0b101011

    beq <= not OpCode(5) and not OpCode(4) and not OpCode(3) and OpCode(2) and not OpCode(1) and not OpCode(0);
    -- 4 0b000100

    j <= not OpCode(5) and not OpCode(4) and not OpCode(3) and not OpCode(2) and OpCode(1) and not OpCode(0);
    -- 2 0b000010


    RegDst <= RType;
    Jump <= j;
    Branch <= beq;
    MemRead <= lw;
    MemToReg <= lw;
    MemWrite <= sw;
    ALUSrc <= lw or sw;
    RegWrite <= RType or lw;
    ALUOp(1) <= RType;
    ALUOp(0) <= beq;
	 IFFlush <= beq and equal;

END ARCHITECTURE;