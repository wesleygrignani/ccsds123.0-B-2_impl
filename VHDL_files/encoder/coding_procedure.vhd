----------------------------------------------------------------------------------
-- Name: Wesley Grignani
-- Laboratory of Embedded and Distributed Systems (LEDS) - UNIVALI
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.ccsds123_B2_package.all;

entity coding_procedure is
  port (i_clk    : in  std_logic;                                -- clock signal
        i_enable : in  std_logic;                                -- enable signal from fsm
        i_mapped : in  std_logic_vector(SAMPLE_SIZE-1 downto 0); -- mapped value from predictor
        i_kz     : in  std_logic_vector(KZ_SIZE-1 downto 0);     -- kz value calculated in the previous block
        o_select : out std_logic;                                -- output for fsm knows what path use for encode mapped sample 
        o_kz     : out std_logic_vector(KZ_SIZE-1 downto 0);     -- kz value calculate in previous block and used after in encode part
        o_uz     : out std_logic_vector(KZ_SIZE-1 downto 0));    -- uz value calculate in this block and used after in encode part
end coding_procedure;

architecture Behavioral of coding_procedure is

signal w_uz, w_kz, w_mapped : integer := 0;
signal w_select : std_logic := '0';
begin

  w_mapped <= to_integer(signed (i_mapped));
  w_kz <= to_integer(signed (i_kz));
  w_uz <= (w_mapped / w_kz);
  
  process(i_clk, i_enable)
  begin
    if(rising_edge(i_clk) and i_enable = '1') then 
      if(w_uz < UMAX) then
        -- then Rk consists of u_z 'zeros', followed by a 'one' and by the k least sig bits of the mapped
        w_select <= '1'; -- selector used for tell the fsm what path they are going to use for encode
      else 
        -- otherwise Rk consists of UMAX 'zeros' followed by D-bit binary representation of mappped
        w_select <= '0'; -- selector used for tell the fsm what path they are going to use for encode
      end if;
    end if;  
  end process;
  
  -- these outputs will be returned to fsm 
  o_select <= w_select;
  o_uz <= std_logic_vector(to_signed(w_uz, KZ_SIZE));
  o_kz <= std_logic_vector(to_signed(w_kz, KZ_SIZE));
  
  
end Behavioral;
