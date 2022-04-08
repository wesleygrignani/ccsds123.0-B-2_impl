-----------------------------------------------------------------------------------------------------
-- Name: Wesley Grignani
-- Laboratory of Embedded and Distributed Systems (LEDS) - UNIVALI
-----------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.ccsds123_b2_package.all;

entity mapped_residual is
  port (i_clk             : in  std_logic;
        i_enable          : in  std_logic;
        i_double_res      : in  std_logic_vector(MAX_SIZE-1 downto 0);
        i_quantized_index : in  std_logic_vector(MAX_SIZE-1 downto 0);
        o_mapped          : out std_logic_vector(SAMPLE_SIZE-1 downto 0));
end mapped_residual;

architecture Behavioral of mapped_residual is

signal w_predicted_sample, w_predicted_sample_aux  : unsigned (MAX_SIZE-1 downto 0) := (others => '0');
signal predicted_sample, quantized_index, theta, mapped, double_res, w_aux1  : integer := 0;

begin

w_predicted_sample_aux <= unsigned (i_double_res);
w_predicted_sample <= shift_right(w_predicted_sample_aux, 1);
predicted_sample <= to_integer(signed(w_predicted_sample));
quantized_index <= to_integer(signed(i_quantized_index));
double_res <= to_integer(signed(i_double_res));

theta <= predicted_sample when (predicted_sample < (SMAX - predicted_sample)) else
         (SMAX - predicted_sample);
        

w_aux1 <=  quantized_index when (double_res mod 2 = 0) else 
           -quantized_index;

process(i_clk, i_enable, quantized_index, w_aux1)
begin
  if(rising_edge(i_clk) and i_enable = '1') then
    if(abs(quantized_index) > theta) then
      mapped <= abs(quantized_index) + theta;
    elsif((w_aux1 >= 0) and (w_aux1 <= theta)) then
      mapped <= 2*abs(quantized_index);
    else
      mapped <= (2*abs(quantized_index)) - 1;
    end if;
  end if;  
end process;

o_mapped <= std_logic_vector(to_signed(mapped, SAMPLE_SIZE));

end Behavioral;
