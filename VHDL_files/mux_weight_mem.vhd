-----------------------------------------------------------------------------------------------------
-- Name: Wesley Grignani
-- Laboratory of Embedded and Distributed Systems (LEDS) - UNIVALI
-----------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.ccsds123_b2_package.all;

entity mux_weight_mem is
  port (i_weight_from_update : in  std_logic_vector(WEIGHT_SIZE-1 downto 0);
        i_weight_from_init   : in  std_logic_vector(WEIGHT_SIZE-1 downto 0);
        i_sel                : in  std_logic;
        o_weight_out         : out std_logic_vector(WEIGHT_SIZE-1 downto 0));
end mux_weight_mem;

architecture Behavioral of mux_weight_mem is

begin

  p_mux : process(i_weight_from_update, i_weight_from_init, i_sel)
  begin 
    case i_sel is 
      when '1'    => o_weight_out    <= i_weight_from_init;
      when '0'    => o_weight_out    <= i_weight_from_update;
      when others => o_weight_out    <= (others => '0');
    end case;
  end process p_mux;

end Behavioral;
