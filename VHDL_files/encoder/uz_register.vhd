----------------------------------------------------------------------------------
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.ccsds123_B2_package.all;

entity uz_register is
  port ( i_clk              : in  std_logic;
         i_rst              : in  std_logic;
         i_enable_decounter : in  std_logic;
         i_enable_uz        : in  std_logic;
         i_uz_value         : in  std_logic_vector(KZ_SIZE-1 downto 0);
         o_output           : out std_logic_vector(KZ_SIZE-1 downto 0));
end uz_register;

architecture Behavioral of uz_register is

signal w_uz_value, w_uz_output : integer := 0;

begin
  
  w_uz_value <= to_integer(unsigned(i_uz_value));
  
  process(i_clk, i_enable_decounter, i_enable_uz)
  begin
    if(i_rst = '1') then
      w_uz_output <= 0;
    elsif(rising_edge(i_clk)) then
      if(i_enable_uz = '1') then
        w_uz_output <= w_uz_value;
      elsif(i_enable_decounter = '1') then
        w_uz_output <= w_uz_output - 1;
      else 
        w_uz_output <= w_uz_output;
      end if;
    end if;
  end process;
  
  o_output <= std_logic_vector(to_unsigned(w_uz_output, KZ_SIZE));

end Behavioral;
