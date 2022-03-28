----------------------------------------------------------------------------------
-- Name: Wesley Grignani
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.ccsds123_b2_package.all;

entity rotate_localdiff is
  port ( i_clk       : in  std_logic;
         i_enable    : in  std_logic;
         i_localdiff : in  std_logic_vector(DATA_SIZE-1 downto 0);
         o_localdiff : out std_logic_vector(DATA_SIZE-1 downto 0));
end rotate_localdiff;

architecture Behavioral of rotate_localdiff is

begin



end Behavioral;
