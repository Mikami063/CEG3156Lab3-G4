--------------------------------------------------------------------------------
-- Title         : pipelined Proccesor
-- Author        : Qingyun Yang  <qyang063@uottawa.ca>
-- Created       : 2024/07/18
-- Last modified : 2024/07/18
-------------------------------------------------------------------------------
-- Description : the pipeline processor top level entity
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity pipelinedProc is
	port(ValueSelect, InstructionSelect: in std_logic_vector(2 downto 0);
	GClock, GReset: in std_logic;
	MuxOut: out std_logic_vector(7 downto 0);
	InstructionOut: out std_logic_vector(31 downto 0);
	BranchOut, ZeroOut, MemWriteOut, RegWriteOut: out std_logic);
end pipelinedProc;

architecture rtl of pipelinedProc is

	component datapathPipeline is
		PORT(
        -- Clock and Reset
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;

        o_PC, o_ALUResult, o_ReadData1, o_ReadData2, o_WriteData, o_ControlSignals: OUT STD_LOGIC_VECTOR(7 downto 0);
        o_Instruction: OUT STD_LOGIC_VECTOR(31 downto 0);
        o_BranchOut,o_ZeroOut,o_MemWriteOut,o_RegWriteOut: OUT STD_LOGIC
        );
	  end component;
	component mux8to1 IS
		 GENERIC ( NUM_BITS : integer :=8);
		 PORT(
			  i_S:IN STD_LOGIC_VECTOR(2 downto 0);
			  i_I0,i_I1,i_I2,i_I3,i_I4,i_I5,i_I6,i_I7:IN STD_LOGIC_VECTOR(NUM_BITS-1 downto 0);
			  o_O:OUT STD_LOGIC_VECTOR(NUM_BITS-1 downto 0));
	END component;

  
	
	signal int_pc, int_ALUResult, int_readData1, int_readData2, int_writeData, int_controlSignals, int_MuxOut: std_logic_vector(7 downto 0);
	signal int_instructionIF:std_LOGIC_VECTOR(31 downto 0);
	
	begin
	datapath:datapathPipeline
		port map(GClock, not(GReset), int_pc, int_ALUResult, int_readData1, int_readData2, int_writeData, int_controlSignals, int_instructionIF, BranchOut, ZeroOut, MemWriteOut, RegWriteOut);
		
	ValueMux:mux8to1
		port map(ValueSelect, int_pc, int_ALUResult, int_readData1, int_readData2, int_writeData, int_controlSignals, int_controlSignals, int_controlSignals, int_MuxOut);
		
	MuxOut<=int_MuxOut;
	InstructionOut<=int_instructionIF;
	
	end rtl;