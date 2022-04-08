----------------------------------------------------------------------------------
-- Name: Wesley Grignani
-- Module Name: local diff ram memory
-- Description: 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.ccsds123_b2_package.all;

entity local_diff_mem is
port ( i_clk  : in  std_logic;
       i_wr   : in  std_logic;
       i_rd   : in  std_logic;
       i_addr : in  std_logic_vector(P-1 downto 0);
       i_din  : in  std_logic_vector(DATA_SIZE-1 downto 0);
       o_dout : out std_logic_vector(DATA_SIZE-1 downto 0));
end local_diff_mem;

architecture Behavioral of local_diff_mem is

  type t_Memory is array(P-1 downto 0) of std_logic_vector(DATA_SIZE-1 downto 0); -- 5 positions of 16 bits each
  signal w_Memory : t_Memory := (others => (others => '0'));  -- signal of t_Memory type
  signal w_Addr : std_logic_vector(P-1 downto 0);  -- signal for i_addr
  signal w_Dout : std_logic_vector(DATA_SIZE-1 downto 0);  -- signal for o_dout

begin

  w_Addr <= i_addr;
  process(i_clk, i_wr, i_rd)
  begin
    if (rising_edge (i_clk)) then
      if (i_wr = '1' and i_rd = '0') then 
        w_Memory(to_integer(unsigned(w_Addr))) <= i_din;
      end if;
    end if;
  end process;
  
  w_Dout <= w_Memory(to_integer(unsigned(w_Addr)));
  o_dout <= w_Dout;
  
end Behavioral;
