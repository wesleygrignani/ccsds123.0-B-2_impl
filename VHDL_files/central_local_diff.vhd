-----------------------------------------------------------------------------------------------------
-- Name: Wesley Grignani
-- Laboratory of Embedded and Distributed Systems (LEDS) - UNIVALI
-----------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------
-- Description: block for sample local difference calculation
-- The result of this block is going to be add in a vector of central local differences for each band
-----------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.ccsds123_b2_package.all;

entity central_local_diff is
port ( i_clk                : in  std_logic;                                 -- clock input
       i_enable             : in  std_logic;                                 -- enable input
       i_sample             : in  std_logic_vector(SAMPLE_SIZE-1 downto 0);  -- actual sample
       i_local_sum          : in  std_logic_vector(DATA_SIZE-1 downto 0);    -- output from local_sum
       o_central_local_diff : out std_logic_vector(DATA_SIZE-1 downto 0));   -- output central_local_difference
end central_local_diff;

architecture Behavioral of central_local_diff is

signal w_sample : signed (DATA_SIZE-1 downto 0) := (others => '0');
signal w_local_sum, w_central_diff, w_sample_mult : integer := 0;

begin

  w_sample <= shift_left(resize(signed (i_sample), DATA_SIZE), 2);
  w_sample_mult <= to_integer(w_sample);  -- int para o sample
  w_local_sum <=  to_integer(signed (i_local_sum)); -- int para o local sum

  process(i_clk, i_enable)
  begin
    if(rising_edge(i_clk)) then
      if(i_enable = '1') then 
        w_central_diff <= w_sample_mult - w_local_sum;
      end if;
    end if;
  end process;

o_central_local_diff <= std_logic_vector(to_signed (w_central_diff, DATA_SIZE)); -- passa para vetor signed novamente

end Behavioral;
