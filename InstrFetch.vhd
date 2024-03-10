library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
   -- addi $2, $0, 0    #2100  -- s = 0;
   -- addi $3, $0, 1    #2181  -- i = 1;
   -- addi $4, $0, 10   #2203  -- n = 10;
   -- beq $3, $4, 3     #8E03  -- while(i<n){
   -- add $2, $3, $2    #09A0  -- s = s+i;
   -- addi $3, $3, 1    #2d81
   -- j 3               #E003
   -- sw $2, 1          #6101

entity InstrFetch is
 Port(
        Clk:in std_logic;
        en: in std_logic;
        pcSrc :in std_logic;
        BranchAddr:in std_logic_vector(15 downto 0);
        JmpAddr:in std_logic_vector(15 downto 0);
        Jump:in std_logic;
        Instr:out std_logic_vector(15 downto 0);
        pcPlus: out std_logic_vector(15 downto 0)--nextInstr
        );
end InstrFetch;

architecture Behavioral of InstrFetch is
    signal pcAddr :  std_logic_vector(15 downto 0):=x"0000";
    signal mx1 : std_logic_vector(15 downto 0):=x"0000";
    signal mx2 : std_logic_vector(15 downto 0):=x"0000";
    signal sum :  std_logic_vector(15 downto 0):=x"0000";
    
     type ROM_type is array(0 to 255) of std_logic_vector(15 downto 0);
        signal ROM_M: ROM_type := (
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

      
Instr <= ROM_M (conv_integer(pcAddr));
sum <= pcAddr + 1;
 pcPlus<=sum;
MUX1: process(pcSrc)
    begin
    if pcSrc='0' then
        mx1<=sum;
    else
        mx1<=BranchAddr;    
    end if;
end process;
 
MUX2: process(Jump)
    begin 
     if Jump='0' then 
        mx2<=mx1;
    else
        mx2<=JmpAddr;
    end if;  
end process;


PC: process(clk)
begin
    if rising_edge(clk) then
        if en='1' then
            pcAddr<=mx2;
        end if;
   end if;
end process;


end architecture;