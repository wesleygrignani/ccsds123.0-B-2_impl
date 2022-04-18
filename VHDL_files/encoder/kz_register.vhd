----------------------------------------------------------------------------------
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.ccsds123_B2_package.all;

entity kz_register is
  port ( i_clk              : in  std_logic;
         i_rst              : in  std_logic;
         i_enable_decounter : in  std_logic;
         i_enable_kz        : in  std_logic;
         i_kz_value         : in  std_logic_vector(KZ_SIZE-1 downto 0);
         o_output           : out std_logic_vector(KZ_SIZE-1 downto 0));
end kz_register;

architecture Behavioral of kz_register is

signal w_kz_value, w_kz_output : integer := 0;

begin
  
  w_kz_value <= to_integer(unsigned(i_kz_value));
  
  process(i_clk, i_enable_decounter, i_enable_kz)
  begin
    if(i_rst = '1') then
      w_kz_output <= 0;
    elsif(rising_edge(i_clk)) then
      if(i_enable_kz = '1') then
        w_kz_output <= w_kz_value;
      elsif(i_enable_decounter = '1') then
        w_kz_output <= w_kz_output - 1;
      else 
        w_kz_output <= w_kz_output;
      end if;
    end if;
  end process;
  
  o_output <= std_logic_vector(to_unsigned(w_kz_output, KZ_SIZE));

end Behavioral;
