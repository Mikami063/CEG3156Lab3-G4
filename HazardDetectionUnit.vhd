LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY HazardDetectionUnit IS
    PORT(
        i_IdExMemRead:IN STD_LOGIC;
        i_IfIdRegisterRt,i_IfIdRegisterRs,i_IdExRegisterRt:IN STD_LOGIC_VECTOR(4 downto 0);
        o_IfIdWrite,o_PCWrite,o_muxControlSignal:OUT STD_LOGIC);
END ENTITY;

ARCHITECTURE rtl OF HazardDetectionUnit IS
    SIGNAL int_stall, int_condFirst,int_condSecond: STD_LOGIC;
BEGIN 

	int_condFirst <= (i_IdExRegisterRt(4) xnor i_IfIdRegisterRs(4)) and (i_IdExRegisterRt(3) xnor i_IfIdRegisterRs(3)) and (i_IdExRegisterRt(2) xnor i_IfIdRegisterRs(2)) and (i_IdExRegisterRt(1) xnor i_IfIdRegisterRs(1)) and (i_IdExRegisterRt(0) xnor i_IfIdRegisterRs(0));
	int_condSecond <= (i_IdExRegisterRt(4) xnor i_IfIdRegisterRt(4)) and (i_IdExRegisterRt(3) xnor i_IfIdRegisterRt(3)) and (i_IdExRegisterRt(2) xnor i_IfIdRegisterRt(2)) and (i_IdExRegisterRt(1) xnor i_IfIdRegisterRt(1)) and (i_IdExRegisterRt(0) xnor i_IfIdRegisterRt(0));
	
    int_stall <= i_IdExMemRead and (int_condFirst or int_condSecond);

    o_IfIdWrite <= int_stall;
    o_PCWrite <= int_stall;
    o_muxControlSignal <= int_stall;
    --first cycle output register hold signal
    --second cycle output mux control output 0 signal
	 -- might be issues

END ARCHITECTURE;