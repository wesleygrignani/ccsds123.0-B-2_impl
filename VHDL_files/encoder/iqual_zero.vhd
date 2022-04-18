----------------------------------------------------------------------------------
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.ccsds123_B2_package.all;


entity iqual_zero is
  port (i_input  : in  std_logic_vector(KZ_SIZE-1 downto 0);
        o_output : out std_logic);
end iqual_zero;

architecture Behavioral of iqual_zero is

signal w_input : integer := 0;

begin

  w_input <= to_integer(unsigned(i_input));

  o_output <= '0' when (w_input > 0) else '1';

end Behavioral;
