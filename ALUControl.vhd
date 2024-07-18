LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY ALUControl IS
    PORT(
        ALUOp:IN STD_LOGIC_VECTOR(1 downto 0);
        FuncCode :IN STD_LOGIC_VECTOR(5 downto 0);
        Control: OUT STD_LOGIC_VECTOR(2 downto 0)
        );
END ENTITY;

ARCHITECTURE rtl OF ALUControl IS

BEGIN

    Control(2) <= ALUOp(0) or (ALUOp(1) and FuncCode(1));
    Control(1) <= not ALUOp(1) or not FuncCode(2);
    Control(0) <= (ALUOp(1) and FuncCode(0) and FuncCode(3)) or (ALUOp(1) and FuncCode(2));

END ARCHITECTURE;