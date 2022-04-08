-----------------------------------------------------------------------------------------------------
-- Name: Wesley Grignani
-- Laboratory of Embedded and Distributed Systems (LEDS) - UNIVALI
-----------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.ccsds123_b2_package.all;

entity update_weights is
  port ( i_clk           : in  std_logic;
         i_enable        : in  std_logic;
         i_t             : in  integer range 0 to 255;
         i_sample        : in  std_logic_vector(SAMPLE_SIZE-1 downto 0);
         i_double_res    : in  std_logic_vector(MAX_SIZE-1 downto 0);
         i_weight_mem    : in  std_logic_vector(WEIGHT_SIZE-1 downto 0);
         i_localdiff_mem : in  std_logic_vector(DATA_SIZE-1 downto 0);
         o_new_weight    : out std_logic_vector(WEIGHT_SIZE-1 downto 0));
end update_weights;

architecture Behavioral of update_weights is

signal w_local_diff, w_weights, w_clipped, w_double_res_pred_err, w_double_res, w_p : integer := 0;

begin

  w_clipped <= to_integer(signed(i_sample));
  w_double_res <= to_integer(signed(i_double_res));
  w_double_res_pred_err <= (2*w_clipped) - w_double_res;
  
  process(i_clk, i_enable, i_weight_mem, i_t, w_double_res_pred_err)
  begin
    
    w_weights <= to_integer(signed (i_weight_mem));
    w_local_diff <= to_integer(signed (i_localdiff_mem));
    w_p <= V_MIN + ((i_t-5)/(2**T_INC));
   
    if(rising_edge(i_clk) and i_enable = '1') then
      if(i_t > 0) then
        if(w_p > V_MAX) then
          w_p <= V_MAX;
        elsif(w_p < V_MIN) then
          w_p <= V_MIN;
        else
          w_p <= w_p;
        end if;
        
        w_p <= w_p + D - OMEGA;
        
        if(w_double_res_pred_err > 0) then 
          w_weights <= w_weights + ((1 * ((1/(2**(w_p)))) * w_local_diff + 1) / 2);
        else 
          w_weights <= w_weights + ((-1 * ((1/(2**(w_p)))) * w_local_diff + 1) / 2);
        end if;
        
        if(w_weights > WMAX) then 
          w_weights <= WMAX;
        elsif(w_weights < WMIN) then 
          w_weights <= WMIN;
        else
          w_weights <= w_weights;
        end if;
      end if;
    end if;
  end process;  
  
o_new_weight <= std_logic_vector(to_signed(w_weights, WEIGHT_SIZE));

end Behavioral;
