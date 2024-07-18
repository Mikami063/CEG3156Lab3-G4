library verilog;
use verilog.vl_types.all;
entity \3156lab3\ is
    port(
        Branch          : out    vl_logic;
        clk             : in     vl_logic;
        resetBar        : in     vl_logic;
        Zero            : out    vl_logic;
        MemWrite        : out    vl_logic;
        RegWrite        : out    vl_logic;
        ALUResult       : out    vl_logic_vector(7 downto 0);
        ControlSignals  : out    vl_logic_vector(7 downto 0);
        Instruction     : out    vl_logic_vector(31 downto 0);
        PC              : out    vl_logic_vector(7 downto 0);
        ReadData1       : out    vl_logic_vector(7 downto 0);
        ReadData2       : out    vl_logic_vector(7 downto 0);
        WriteData       : out    vl_logic_vector(7 downto 0)
    );
end \3156lab3\;
