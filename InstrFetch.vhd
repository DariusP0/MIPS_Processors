
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity InstrFetch is
  Port ( clk : in STD_LOGIC;
         en : in STD_LOGIC;
         clr : in STD_LOGIC;
         branch_addr : in STD_LOGIC_VECTOR (15 downto 0);
         jmp_addr : in STD_LOGIC_VECTOR (15 downto 0);
         jump : in STD_LOGIC;
         PCSrc : in STD_LOGIC;
         current_instr : out STD_LOGIC_VECTOR (15 downto 0);
         next_instr_addr : out STD_LOGIC_VECTOR (15 downto 0));
end InstrFetch;

architecture Behavioral of InstrFetch is

signal pc_out : STD_LOGIC_VECTOR (15 DOWNTO 0) := X"0000";
signal sum_out : STD_LOGIC_VECTOR (15 downto 0) := X"0000";
signal mux1_out : STD_LOGIC_VECTOR (15 downto 0) := X"0000";
signal mux2_out : STD_LOGIC_VECTOR (15 downto 0) := X"0000";
type rom_array is array (0 to 255) of std_logic_vector(15 downto 0);
signal rom256x16: rom_array := (
   B"001_000_010_0000000", -- addi $2, $0, 0    #2100  -- s = 0;
   B"001_000_011_0000001", -- addi $3, $0, 1    #2181  -- i = 1;
   B"001_000_100_0000011", -- addi $4, $0, 10   #2203  -- n = 10;
   B"100_011_100_0000011", -- beq $3, $4, 3     #8E03  -- while(i<n){
   B"000_010_011_010_0_000", -- add $2, $3, $2  #09A0  -- s = s+i;
   B"001_011_011_0000001", -- addi $3, $3, 1    #2d81
   B"111_0000000000011", -- j 3                 #E003
   B"011_000_010_0000001", -- sw $2, 1          #6101
   others => x"1111"
);

begin
    -- PC
    process(clk, en, clr)
    begin
        if clr = '1' then
            pc_out <= x"0000";
        else
            if rising_edge(clk) then
                if en = '1' then
                    pc_out <= mux2_out;
                end if;
            end if;
        end if;
    end process;
    
    -- sumator 
    sum_out <= pc_out + 1;
    
    -- memoria de instructiuni
    current_instr <= rom256x16(conv_integer(pc_out));
    
    next_instr_addr <= sum_out;
    
    -- mux1
    mux1_out <= sum_out when PCSrc = '0'
                else branch_addr;
    
    -- mux2
    mux2_out <= mux1_out when jump = '0'
                else jmp_addr;
    

end Behavioral;
