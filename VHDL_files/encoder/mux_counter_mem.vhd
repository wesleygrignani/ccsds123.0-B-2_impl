----------------------------------------------------------------------------------
-- Name: Wesley Grignani
-- Description: Mux for select what counter are going to pass for the memory input
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.ccsds123_B2_package.all;

entity mux_counter_mem is
  port (i_counter_from_init   : in  std_logic_vector(COUNT_SIZE-1 downto 0);
        i_counter_from_update : in  std_logic_vector(COUNT_SIZE-1 downto 0); 
        i_sel                 : in  std_logic;
        o_counter_out         : out std_logic_vector(COUNT_SIZE-1 downto 0));
end mux_counter_mem;

architecture Behavioral of mux_counter_mem is

begin

  p_mux : process(i_counter_from_update, i_counter_from_init, i_sel)
  begin 
    case i_sel is 
      when '1'    => o_counter_out    <= i_counter_from_init;
      when '0'    => o_counter_out    <= i_counter_from_update;
      when others => o_counter_out    <= (others => '0');
    end case;
  end process p_mux;

end Behavioral;
