---------------------------------------------------------------------------------------
-- Name: Wesley Grignani
-- Laboratory of Embedded and Distributed Systems (LEDS) - UNIVALI
---------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------
-- Description: This block is going to perform the local sum in a column oriented form
-- Local sum is equal to: 4*neighboor
---------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.ccsds123_b2_package.all;

entity local_sum is
port ( i_clk       : in  std_logic;
       i_enable    : in  std_logic;
       i_neighboor : in  std_logic_vector(SAMPLE_SIZE-1 downto 0);
       o_local_sum : out std_logic_vector(DATA_SIZE-1 downto 0));
end local_sum;

architecture arch of local_sum is

signal w_neighboor     : unsigned (DATA_SIZE-1 downto 0) := (others => '0');
signal w_neighboor_aux : unsigned (DATA_SIZE-1 downto 0) := (others => '0');

begin

w_neighboor_aux <= resize (unsigned (i_neighboor), DATA_SIZE);

    process(i_clk, i_enable)
    begin
      if(rising_edge(i_clk)) then
        if(i_enable = '1') then
          w_neighboor <= shift_left(w_neighboor_aux, 2);
        end if;
      end if;
    end process;

o_local_sum <= std_logic_vector (w_neighboor);

end arch;
