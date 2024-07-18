LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY ForwardingUnit IS
    PORT(
        i_ExMemRegWrite, i_MemWbRegWrite:IN STD_LOGIC;
        i_ExMemRegisterRd,i_MemWbRegisterRd,i_IdExRegisterRs,i_IdExRegisterRt:IN STD_LOGIC_VECTOR(4 downto 0);
        o_FowardA,o_FowardB:OUT STD_LOGIC_VECTOR(1 downto 0));
END ENTITY;

ARCHITECTURE rtl OF ForwardingUnit IS
    SIGNAL int_caseA,int_caseB,int_caseC,int_caseD, int_condFirst, int_condSecond, int_condThird, int_condForth: STD_LOGIC;
BEGIN 

	int_condFirst <= (i_ExMemRegisterRd(4) xnor i_IdExRegisterRs(4)) and (i_ExMemRegisterRd(3) xnor i_IdExRegisterRs(3)) and (i_ExMemRegisterRd(2) xnor i_IdExRegisterRs(2)) and (i_ExMemRegisterRd(1) xnor i_IdExRegisterRs(1)) and (i_ExMemRegisterRd(0) xnor i_IdExRegisterRs(0));
	--(i_ExMemRegisterRd xnor i_IdExRegisterRs)
    int_caseA <= i_ExMemRegWrite and (i_ExMemRegisterRd(4) or i_ExMemRegisterRd(3) or i_ExMemRegisterRd(2) or i_ExMemRegisterRd(1) or i_ExMemRegisterRd(0)) and int_condFirst;
    --ForwardA= 10

	 int_condSecond <= (i_ExMemRegisterRd(4) xnor i_IdExRegisterRt(4)) and (i_ExMemRegisterRd(3) xnor i_IdExRegisterRt(3)) and (i_ExMemRegisterRd(2) xnor i_IdExRegisterRt(2)) and (i_ExMemRegisterRd(1) xnor i_IdExRegisterRt(1)) and (i_ExMemRegisterRd(0) xnor i_IdExRegisterRt(0));
	 --(i_ExMemRegisterRd xnor i_IdExRegisterRt)
    int_caseB <= i_ExMemRegWrite and (i_ExMemRegisterRd(4) or i_ExMemRegisterRd(3) or i_ExMemRegisterRd(2) or i_ExMemRegisterRd(1) or i_ExMemRegisterRd(0)) and int_condSecond;
    --ForwardB= 10

	 int_condThird <= (i_MemWbRegisterRd(4) xnor i_IdExRegisterRs(4)) and (i_MemWbRegisterRd(3) xnor i_IdExRegisterRs(3)) and (i_MemWbRegisterRd(2) xnor i_IdExRegisterRs(2)) and (i_MemWbRegisterRd(1) xnor i_IdExRegisterRs(1)) and (i_MemWbRegisterRd(0) xnor i_IdExRegisterRs(0));
	 --(i_MemWbRegisterRd xnor i_IdExRegisterRs)
    int_caseC <= i_MemWbRegWrite and (i_MemWbRegisterRd(4) or i_MemWbRegisterRd(3) or i_MemWbRegisterRd(2) or i_MemWbRegisterRd(1) or i_MemWbRegisterRd(0)) and int_condThird;
    --ForwardA= 01

	 int_condForth <= (i_MemWbRegisterRd(4) xnor i_IdExRegisterRt(4)) and (i_MemWbRegisterRd(3) xnor i_IdExRegisterRt(3)) and (i_MemWbRegisterRd(2) xnor i_IdExRegisterRt(2)) and (i_MemWbRegisterRd(1) xnor i_IdExRegisterRt(1)) and (i_MemWbRegisterRd(0) xnor i_IdExRegisterRt(0));
	 --(i_MemWbRegisterRd xnor i_IdExRegisterRt)
    int_caseD <= i_MemWbRegWrite and (i_MemWbRegisterRd(4) or i_MemWbRegisterRd(3) or i_MemWbRegisterRd(2) or i_MemWbRegisterRd(1) or i_MemWbRegisterRd(0)) and int_condForth;
    --ForwardB= 01

    o_FowardA(1) <= int_caseA and not int_caseC;
    o_FowardB(1) <= int_caseB and not int_caseD;
    o_FowardA(0) <= int_caseC and not int_caseA;
    o_FowardB(0) <= int_caseD and not int_caseB;
    -- i'm not sure if this could prevent something bad from happening
    -- but i wrote it anyway

END ARCHITECTURE;