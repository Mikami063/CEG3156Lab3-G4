--------------------------------------------------------------------------------
-- Title         : datapathPipeline
-- Author        : Qingyun Yang  <qyang063@uottawa.ca>
-- Created       : 2024/07/11
-- Last modified : 2024/07/12
-------------------------------------------------------------------------------
-- Description : 
--    All the internal connections that made up the pipeline cpu
--    Details about the internal signals in code comments
--    See design file to understand the stuctural of internal connection and the content index for pipeline buffer
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY datapathPipeline IS
    PORT(
        -- Clock and Reset
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;

        o_PC, o_ALUResult, o_ReadData1, o_ReadData2, o_WriteData, o_ControlSignals: OUT STD_LOGIC_VECTOR(7 downto 0);
        o_Instruction: OUT STD_LOGIC_VECTOR(31 downto 0);
        o_BranchOut,o_ZeroOut,o_MemWriteOut,o_RegWriteOut: OUT STD_LOGIC;
		  o_FowardA,o_FowardB:OUT STD_LOGIC_VECTOR(1 downto 0)
        );
END ENTITY;

ARCHITECTURE rtl of datapathPipeline IS

    SIGNAL int_PCWrite, int_IFFlush, int_IfIdWrite, int_equal, int_HazardMuxControl, int_ControlUnitMuxControl, int_Zero: STD_LOGIC;
    SIGNAL int_PCInput, int_PC, int_PC4, int_BranchTargetAddr, int_RegWriteData, int_ReadData1, int_ReadData2, int_ALUResult, int_DataMemory: STD_LOGIC_VECTOR(7 downto 0);
    SIGNAL int_RegWriteAddr_Ex: STD_LOGIC_VECTOR(4 downto 0);
    SIGNAL int_instructionMemory: STD_LOGIC_VECTOR(31 downto 0);
    SIGNAL int_ALUControlSig: STD_LOGIC_VECTOR(2 downto 0);
    -- the rest

    SIGNAL int_RegDst, int_Jump, int_Branch, int_MemRead, int_MemToReg, int_MemWrite, int_RegWrite: STD_LOGIC;
    SIGNAL int_ALUOp: STD_LOGIC_VECTOR(1 downto 0);
    -- most of control unit logics

    SIGNAL int_FowardA,int_FowardB: STD_LOGIC_VECTOR(1 downto 0);
    SIGNAL int_MuxA, int_MuxB:STD_LOGIC_VECTOR(7 downto 0);
    -- most of forwarding logic

    SIGNAL int_ControlSigMux:STD_LOGIC_VECTOR(9 downto 0);
	 
	 SIGNAL int_IfIdPipeReg: STD_LOGIC_VECTOR(39 downto 0);
	 SIGNAL int_IdExPipeReg: STD_LOGIC_VECTOR(50 downto 0);
	 SIGNAL int_ExMemPipeReg: STD_LOGIC_VECTOR(16 downto 0);
	 SIGNAL int_MemWbPipeReg: STD_LOGIC_VECTOR(22 downto 0);
	 

    COMPONENT RegisterFile IS
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
    END COMPONENT;

    COMPONENT InstructionMem IS
        PORT
        (
            address		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
            clock		: IN STD_LOGIC  := '1';
            data		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
            wren		: IN STD_LOGIC ;
            q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT DataRam IS
        PORT
        (
            address		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
            clock		: IN STD_LOGIC  := '1';
            data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
            wren		: IN STD_LOGIC ;
            q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT ALUc IS -- this is actual ALU Component NOT control!!! importand
        GENERIC ( NUM_BITS : integer :=8);
        PORT(
            i_S:IN STD_LOGIC_VECTOR(2 downto 0);
            i_I0,i_I1:IN STD_LOGIC_VECTOR(NUM_BITS-1 downto 0);
            o_Zero, o_Overflow: OUT STD_LOGIC;
            o_O:OUT STD_LOGIC_VECTOR(NUM_BITS-1 downto 0));
    END COMPONENT;

    COMPONENT ALUControl IS
        PORT(
            ALUOp:IN STD_LOGIC_VECTOR(1 downto 0);
            FuncCode :IN STD_LOGIC_VECTOR(5 downto 0);
            Control: OUT STD_LOGIC_VECTOR(2 downto 0)
            );
    END COMPONENT;

    COMPONENT mux4to1 IS
        GENERIC ( NUM_BITS : integer := 8);--default to 8
        PORT(
            i_S:IN STD_LOGIC_VECTOR(1 downto 0);
            i_I0,i_I1,i_I2,i_I3:IN STD_LOGIC_VECTOR(NUM_BITS-1 downto 0);
            o_O:OUT STD_LOGIC_VECTOR(NUM_BITS-1 downto 0));
    END COMPONENT;

    COMPONENT mux2to1 IS
        GENERIC ( NUM_BITS : integer := 8);--default to 8
        PORT(
            i_S:IN STD_LOGIC;
            i_a,i_b:IN STD_LOGIC_VECTOR(NUM_BITS-1 downto 0);
            o_O:OUT STD_LOGIC_VECTOR(NUM_BITS-1 downto 0));
    END COMPONENT;

    COMPONENT ByteComparator IS
        PORT(
            i_a,i_b:IN STD_LOGIC_VECTOR(7 downto 0);
            o_equal:OUT STD_LOGIC);
    END COMPONENT;

    COMPONENT AnyBitsAdder IS
        GENERIC ( NUM_BITS : integer :=8);
        PORT(
        i_A,i_B : IN STD_LOGIC_vector(NUM_BITS-1 downto 0);
        i_Mode : IN STD_LOGIC;-- 0 for add 1 for subtract
        o_Out : OUT STD_LOGIC_vector(NUM_BITS-1 downto 0);
        o_Carry: OUT STD_LOGIC);
    END COMPONENT;

    COMPONENT AnyBitsRegister IS
            GENERIC ( NUM_BITS : integer := 8);--default to 8
        PORT(
            i_resetBar, i_load : IN    STD_LOGIC;
            i_clock           : IN    STD_LOGIC;
            i_Value           : IN    STD_LOGIC_VECTOR(NUM_BITS-1 downto 0);
            o_Value           : OUT   STD_LOGIC_VECTOR(NUM_BITS-1 downto 0));
    END COMPONENT;

    COMPONENT controlpath IS
		 PORT(
			  OpCode:IN STD_LOGIC_VECTOR(5 downto 0);
			  equal:IN STD_LOGIC;
			  RegDst,Jump,Branch,MemRead,MemToReg,MemWrite,ALUSrc,RegWrite,IFFlush: OUT STD_LOGIC;
			  ALUOp: OUT STD_LOGIC_VECTOR(1 downto 0)
			  );
	END COMPONENT;

    COMPONENT ForwardingUnit IS
        PORT(
            i_ExMemRegWrite, i_MemWbRegWrite:IN STD_LOGIC;
            i_ExMemRegisterRd,i_MemWbRegisterRd,i_IdExRegisterRs,i_IdExRegisterRt:IN STD_LOGIC_VECTOR(4 downto 0);
            o_FowardA,o_FowardB:OUT STD_LOGIC_VECTOR(1 downto 0));
    END COMPONENT;

    Component HazardDetectionUnit IS
        PORT(
            i_IdExMemRead:IN STD_LOGIC;
            i_IfIdRegisterRt,i_IfIdRegisterRs,i_IdExRegisterRt:IN STD_LOGIC_VECTOR(4 downto 0);
            o_IfIdWrite,o_PCWrite,o_muxControlSignal:OUT STD_LOGIC);
    END Component;
       
BEGIN

-- start of IF stage
PC: AnyBitsRegister
    GENERIC MAP(
        NUM_BITS => 8
    )
    PORT MAP(
        i_resetBar => reset, 
        i_load => not int_PCWrite,
        i_clock => clk,
        i_Value => int_PCInput,
        o_Value => int_PC
    );

InstructionMem0: InstructionMem
    PORT MAP(
        address	=> int_PC,
        clock => clk,
		  data => "00000000000000000000000000000000",
		  wren => '0',
        q => int_instructionMemory
    );

AddrAdder4: AnyBitsAdder
    GENERIC MAP( NUM_BITS => 8)
    PORT MAP(
        i_A => int_PC,
        i_B => "00000100",
        i_Mode => '0',
        o_Out => int_PC4
    );

PCInputMux: mux2to1
    GENERIC MAP( NUM_BITS => 8)
    PORT MAP(
        i_S => int_IFFlush,
        i_a => int_PC4,
        i_b => int_BranchTargetAddr,
        o_O => int_PCInput
    );
-- end of IF stage

IfIdPipeReg: AnyBitsRegister
    GENERIC MAP(
        NUM_BITS => 40 -- 32instruction + 8pc+4
    )
    PORT MAP(
        i_resetBar => reset, 
        i_load => not int_IfIdWrite,
        i_clock => clk,
        i_Value => int_PC4 & int_instructionMemory,
        o_Value => int_IfIdPipeReg
    );

-- start of ID stage
RegisterFile0: RegisterFile
    PORT MAP(
        i_resetBar => reset,
        i_clock => clk, 
        RegWrite => int_MemWbPipeReg(22),-- control of whether write or not
        i_Value => int_RegWriteData, -- the content which write to register
        ReadReg1 => int_IfIdPipeReg(25 downto 21),--rs
        ReadReg2 => int_IfIdPipeReg(20 downto 16),--rt
        WriteReg => int_MemWbPipeReg(4 downto 0),-- the address which writes to the reg
        ReadData1 => int_ReadData1,
        ReadData2 => int_ReadData2
    );

ByteComparator0: ByteComparator
    PORT MAP(
        i_a => int_ReadData1,
        i_b => int_ReadData2,
        o_equal => int_equal
    );

BranchAddrAdder: AnyBitsAdder
    GENERIC MAP( NUM_BITS => 8)
    PORT MAP(
        i_A => int_IfIdPipeReg(7 downto 0),
        i_B => int_IfIdPipeReg(39 downto 32),
        i_Mode => '0',
        o_Out => int_BranchTargetAddr
    );

control: controlpath
    PORT MAP(
        OpCode => int_IfIdPipeReg(31 downto 26),
        equal => int_equal,
        RegDst => int_RegDst,
        Jump => int_Jump,
        Branch => int_Branch,
        MemRead => int_MemRead,
        MemToReg => int_MemToReg,
        MemWrite => int_MemWrite,
        --ALUSrc => ,-- i think we don't need this, or i can't find place to put it in
        RegWrite => int_RegWrite,
        IFFlush => int_IFFlush,
        ALUOp => int_ALUOp
    );

HazardDetectionUnit0: HazardDetectionUnit
    PORT MAP(
        i_IdExMemRead => int_IdExPipeReg(45),
        i_IfIdRegisterRt => int_IfIdPipeReg(20 downto 16),
        i_IfIdRegisterRs => int_IfIdPipeReg(25 downto 21),
        i_IdExRegisterRt => int_IdExPipeReg(9 downto 5),
        o_IfIdWrite => int_IfIdWrite,
        o_PCWrite => int_PCWrite,
        o_muxControlSignal => int_HazardMuxControl
    );

ControlSigMux: mux2to1
    GENERIC MAP( NUM_BITS => 10)-- control signals numbers
    PORT MAP(
        i_S => int_HazardMuxControl or int_ControlUnitMuxControl,
        i_a(0) => int_RegDst,
        i_a(1) => int_Jump,
        i_a(2) => int_Branch,
        i_a(3) => '0',--control signals ALU Source not implemented
        i_a(5 downto 4) => int_ALUOp,
        i_a(6) => int_MemRead,
        i_a(7) => int_MemWrite,
        i_a(8) => int_MemToReg,
        i_a(9) => int_RegWrite,
        i_b => "0000000000", -- corresponding num of zeros, should be 10 zeros, in case i fucked up
        o_O => int_ControlSigMux
    );
-- end of ID stage

IdExPipeReg: AnyBitsRegister
    GENERIC MAP(
        NUM_BITS => 51 
    )
    PORT MAP(
        i_resetBar => reset, 
        i_load => '1',
        i_clock => clk,
        i_Value(4 downto 0) => int_IfIdPipeReg(15 downto 11),--rd
        i_Value(9 downto 5) => int_IfIdPipeReg(20 downto 16),--rt
        i_Value(14 downto 10) => int_IfIdPipeReg(25 downto 21),--rs
        i_Value(22 downto 15) => int_IfIdPipeReg(7 downto 0),--addr lower 8 bits
        i_Value(30 downto 23) => int_ReadData2,--read2
        i_Value(38 downto 31) => int_ReadData1,--read1
        i_Value(39) => int_ControlSigMux(0),--control signals
        i_Value(40) => int_ControlSigMux(1),--control signals
        i_Value(41) => int_ControlSigMux(2),--control signals
        i_Value(42) => int_ControlSigMux(3),--control signals ALU Source not implemented
        i_Value(44 downto 43) => int_ControlSigMux(5 downto 4),--control signals
        i_Value(45) => int_ControlSigMux(6),--control signals
        i_Value(46) => int_ControlSigMux(7),--control signals
        i_Value(47) => int_ControlSigMux(8),--control signals
        i_Value(48) => int_ControlSigMux(9),--control signals
        i_Value(49) => int_equal,
        i_Value(50) => int_Branch,--actually this is same as int_Branch for BEQ
        -- maybe i should change this line to use control mux
        o_Value => int_IdExPipeReg
    );

-- start of EX stage
MuxA: mux4to1
    GENERIC MAP( NUM_BITS => 8)
    PORT MAP(
        i_S => int_FowardA,
        i_I0 => int_IdExPipeReg(38 downto 31), --read1
        i_I1 => int_RegWriteData,--WB stage result
        i_I2 => int_ExMemPipeReg(12 downto 5),--mem stage alu result
        i_I3 => "00000000",--not being used
        o_O => int_MuxA
    );

MuxB: mux4to1
    GENERIC MAP( NUM_BITS => 8)
    PORT MAP(
        i_S => int_FowardB,
        i_I0 => int_IdExPipeReg(30 downto 23), --read2
        i_I1 => int_RegWriteData,--WB stage result
        i_I2 => int_ExMemPipeReg(12 downto 5),--mem stage alu result
        i_I3 => "00000000",--not being used
        o_O => int_MuxB
    );

ALUc0: ALUc
    PORT MAP(
        i_S => int_ALUControlSig,
        i_I0 => int_MuxA,
        i_I1 => int_MuxB,
        o_Zero => int_Zero,
        o_O => int_ALUResult
    );

ALUControl0: ALUControl
    PORT MAP(
        ALUOp => int_IdExPipeReg(44 downto 43),
        FuncCode => int_IdExPipeReg(20 downto 15),--6 digit extract from addr space
        Control => int_ALUControlSig
    );

DstRegMux: mux2to1
    GENERIC MAP( NUM_BITS => 5)
    PORT MAP(
        i_S => int_IdExPipeReg(39), --RegDst
        i_a => int_IdExPipeReg(4 downto 0), -- 0: rd
        i_b => int_IdExPipeReg(9 downto 5), -- 1: rt
        o_O => int_RegWriteAddr_Ex
    );

ForwardingUnit0: ForwardingUnit
    PORT MAP(
        i_ExMemRegWrite => int_ExMemPipeReg(16), 
        i_MemWbRegWrite => int_MemWbPipeReg(22),
        i_ExMemRegisterRd => int_ExMemPipeReg(4 downto 0),
        i_MemWbRegisterRd => int_MemWbPipeReg(4 downto 0),
        i_IdExRegisterRs => int_IdExPipeReg(14 downto 10),--rs
        i_IdExRegisterRt => int_IdExPipeReg(9 downto 5),--rt
        o_FowardA => int_FowardA,
        o_FowardB => int_FowardB
    );
	 
	 o_FowardA<= int_FowardA;
	 o_FowardB<= int_FowardB;
-- end of EX stage

ExMemPipeReg: AnyBitsRegister
    GENERIC MAP(
        NUM_BITS => 17 
    )
    PORT MAP(
        i_resetBar => reset, 
        i_load => '1',
        i_clock => clk,
        i_Value(4 downto 0) => int_RegWriteAddr_Ex,
        i_Value(12 downto 5) => int_ALUResult,
        i_Value(13) => int_IdExPipeReg(45),--memread
        i_Value(14) => int_IdExPipeReg(46),--memwrite
        i_Value(15) => int_IdExPipeReg(47),--memtoreg
        i_Value(16) => int_IdExPipeReg(48),--regwrite
        o_Value => int_ExMemPipeReg
    );

-- start of MEM stage
DataRam0: DataRam
PORT MAP(
        address	=> int_ExMemPipeReg(12 downto 5),--ALUResult
        clock => clk,
        data => int_ExMemPipeReg(12 downto 5),--ALUResult
        wren => int_ExMemPipeReg(14),--memwrite
        q => int_DataMemory
    );
-- end of MEM stage

MemWbPipeReg: AnyBitsRegister
    GENERIC MAP(
        NUM_BITS => 23 
    )
    PORT MAP(
        i_resetBar => reset, 
        i_load => '1',
        i_clock => clk,
        i_Value(4 downto 0) => int_ExMemPipeReg(4 downto 0),--RegWriteAddr
        i_Value(12 downto 5) => int_ExMemPipeReg(12 downto 5),--ALUResult
        i_Value(20 downto 13) => int_DataMemory,
        i_Value(21) => int_ExMemPipeReg(15),--MemToReg
        i_Value(22) => int_ExMemPipeReg(16),--RegWrite
        o_Value => int_MemWbPipeReg
    );

-- start of WB stage
WBMux: mux2to1
    GENERIC MAP( NUM_BITS => 8)
    PORT MAP(
        i_S => int_MemWbPipeReg(21),--MemToReg
        i_a => int_MemWbPipeReg(12 downto 5),
        i_b => int_MemWbPipeReg(20 downto 13),
        o_O => int_RegWriteData
    );
-- end of WB stage

	int_ControlUnitMuxControl <= int_IdExPipeReg(49) and int_IdExPipeReg(50);

    o_PC <= int_PC;
    o_ALUResult <= int_ALUResult;
    o_ReadData1 <= int_ReadData1;
    o_ReadData2 <= int_ReadData2;
    o_WriteData <= int_RegWriteData;
    o_ControlSignals(7) <= '0';
    o_ControlSignals(6) <= int_RegDst;
    o_ControlSignals(5) <= int_Jump;
    o_ControlSignals(4) <= int_MemRead;
    o_ControlSignals(3) <= int_MemToReg;
    o_ControlSignals(2 downto 1) <= int_ALUOp;
    o_ControlSignals(0) <= '0';--ALU Src disabled, if what to enable it's super easy

    o_Instruction <= int_instructionMemory;-- i don't get what do instruction select mean in lab requiremnets

    o_BranchOut <= int_Branch;
    o_ZeroOut <= int_Zero;
    o_MemWriteOut <= int_MemWrite;
    o_RegWriteOut <= int_RegWrite;

END ARCHITECTURE;