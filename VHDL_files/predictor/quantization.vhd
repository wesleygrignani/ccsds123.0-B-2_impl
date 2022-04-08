-----------------------------------------------------------------------------------------------------
-- Name: Wesley Grignani
-- Laboratory of Embedded and Distributed Systems (LEDS) - UNIVALI
-----------------------------------------------------------------------------------------------------
-- Module Name: quantization - Behavioral
-- Description: This block perform the quantization step, calculating the predicted 
-- sample, prediction residual and calculate the quantized index
-- The quantized index is used for calculate the mapped prediction residual
-----------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.ccsds123_b2_package.all;


entity quantization is
  port (i_clk             : in  std_logic;
        i_enable          : in  std_logic;
        i_sample          : in  std_logic_vector(SAMPLE_SIZE-1 downto 0);
        i_double_res      : in  std_logic_vector(MAX_SIZE-1 downto 0);
        i_t               : in  integer range 0 to 255;
        o_quantizer_index : out std_logic_vector(MAX_SIZE-1 downto 0));
end quantization;

architecture Behavioral of quantization is

signal predicted_residual, quantized_index, w_predicted_sample, w_sample_aux: integer := 0;

begin

  w_predicted_sample <= to_integer(signed(i_double_res) / 2);
  w_sample_aux <= to_integer(signed(i_sample));
  predicted_residual <= w_sample_aux - w_predicted_sample;
  
  process(i_clk, i_enable, predicted_residual, i_t)
  begin
    if(rising_edge(i_clk) and i_enable = '1') then
      if(i_t > 0) then
        if(predicted_residual > 0) then
          quantized_index <= 1*((abs(predicted_residual) + mz) / (2*mz + 1));
        else
          quantized_index <= -1*((abs(predicted_residual) + mz) / (2*mz + 1));
        end if;
      elsif(i_t = 0) then
        quantized_index <= predicted_residual;
      end if;
    end if;
  end process;

  o_quantizer_index <= std_logic_vector(to_signed(quantized_index, MAX_SIZE));

end Behavioral;
