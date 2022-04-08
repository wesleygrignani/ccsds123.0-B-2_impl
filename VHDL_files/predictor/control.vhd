----------------------------------------------------------------------------------
-- Name: Wesley Grignani
-- Laboratory of Embedded and Distributed Systems (LEDS) - UNIVALI
----------------------------------------------------------------------------------
-- State machine and control signals for datapath 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.ccsds123_b2_package.all;

entity control is
  port ( i_clk              : in  std_logic;
         i_rst              : in  std_logic;
         i_start            : in  std_logic;
         i_z                : integer range 0 to 5;
         i_control_counter  : in  std_logic_vector(P-1 downto 0);
         o_enable_ls        : out std_logic;
         o_enable_ldiff     : out std_logic;
         o_enable_central   : out std_logic;
         o_enable_high      : out std_logic;
         o_enable_double    : out std_logic;
         o_enable_qnt       : out std_logic;
         o_sel_mux_weight   : out std_logic;
         o_rst              : out std_logic;
         o_init_weight      : out std_logic;
         o_wr_weights       : out std_logic;
         o_rd_weights       : out std_logic;
         o_wr_localdiff     : out std_logic;
         o_rd_localdiff     : out std_logic;
         o_enable_mapped    : out std_logic;
         o_enable_first_mem : out std_logic;
         o_rst_counter      : out std_logic;
         o_enable_counter   : out std_logic;
         o_en_update_weight : out std_logic
         );
end control;

architecture Behavioral of control is

type t_STATE is (s_first,s_first_mem, s_mem_init, s_mem_init_aux, s_init, s_ls, s_first_central, s_ldiff_central, s_central_aux, s_high, s_double, s_qnt, s_mapped, s_update_weights, s_update_weights_aux); -- new FSM type
signal r_STATE : t_STATE; -- state register
signal w_NEXT  : t_STATE; -- next state

begin

  -- STATE TRANSITION PROCESS
  p_STATE : process (i_rst, i_clk)
  begin
    if (i_rst = '1') then
      r_STATE <= s_init; -- estado inicial
    elsif (rising_edge(i_clk)) then
      r_STATE <= w_NEXT; -- proximo estado
    end if;
  end process;
  
    
  -- NEXT STATE PROCESS 
  p_NEXT : process (r_STATE, i_start, i_z, i_control_counter)
  variable v_cont_aux : integer := 0;
  begin
    
    case (r_STATE) is
      
      when s_first => w_NEXT <= s_first_mem;                    
      
      when s_first_mem => w_NEXT <= s_mem_init;
      
      when s_mem_init => if (not(to_integer(signed (i_control_counter)) < (P-1))) then
                           w_NEXT <= s_init;
                         else 
                           w_NEXT <= s_mem_init_aux;
                         end if;
      
      when s_mem_init_aux => w_NEXT <= s_mem_init;                          
      
      when s_init => if (i_start = '1') then
                       w_NEXT <= s_ls; 
                     else 
                       w_NEXT <= s_init;
                     end if; 
      
      when s_ls => w_NEXT <= s_first_central;
      
      -- mudar essa parte para não precisar utilizar variavel 
      -- depois verificar se o contador esta atualizando corretamente conforme a banda atual da amostra
      when s_first_central => if (i_z = 0) then 
                                w_NEXT <= s_high;
                              else
                                if(i_z < P) then 
                                  v_cont_aux := i_z - 1;
                                  w_NEXT <= s_ldiff_central;
                                else
                                  v_cont_aux := P-1;
                                  w_NEXT <= s_ldiff_central;
                                end if;
                              end if;
                                                   
      when s_ldiff_central => if (to_integer(signed(i_control_counter)) = v_cont_aux) then 
                                w_NEXT <= s_high;
                              else 
                                w_NEXT <= s_central_aux;
                              end if;
                              
      when s_central_aux => w_NEXT <= s_ldiff_central;
      
      when s_high => w_NEXT <= s_double;
      
      when s_double => w_NEXT <= s_qnt;
      
      when s_qnt => w_NEXT <= s_mapped;
      
      when s_mapped => w_NEXT <= s_update_weights;
      
      when s_update_weights => if (not(to_integer(signed(i_control_counter)) < (P-1))) then  
                                 w_NEXT <= s_init;
                               else 
                                 w_NEXT <= s_update_weights_aux;
                               end if;
      
      when s_update_weights_aux => w_NEXT <= s_update_weights;
      
      when others => w_NEXT <= s_init;
    end case;
  end process;
  
  
  -- CONTROL SIGNALS 
  
  o_rst              <= '1' when r_STATE = s_init else '0';
          
  o_wr_localdiff     <= '1' when r_STATE = s_mapped else '0'; 
  
  o_rd_localdiff     <= '1' when r_STATE = s_central_aux else '0';
  
  o_enable_ls        <= '1' when r_STATE = s_ls else '0';
  
  o_wr_weights       <= '1' when r_STATE = s_mem_init_aux or r_STATE = s_first or r_STATE = s_first_mem or r_STATE = s_update_weights_aux else '0';
  
  o_rd_weights       <= '1' when r_STATE = s_central_aux else '0';
  
  o_enable_ldiff     <= '1' when r_STATE = s_first_central else '0';
  
  o_enable_central   <= '1' when (r_STATE = s_first_central and i_z /= 0) or r_STATE = s_central_aux else '0';
  
  o_enable_high      <= '1' when r_STATE = s_high else '0';
  
  o_enable_double    <= '1' when r_STATE = s_double else '0';
  
  o_enable_qnt       <= '1' when r_STATE = s_qnt else '0';
  
  o_enable_mapped    <= '1' when r_STATE = s_mapped else '0';
  
  o_init_weight      <= '1' when r_STATE = s_mem_init_aux or r_STATE = s_first or r_STATE = s_first_mem else '0';
  
  o_enable_first_mem <= '1' when r_STATE = s_first else '0';
  
  o_en_update_weight <= '1' when r_STATE = s_update_weights else '0';
  
  o_sel_mux_weight   <= '1' when r_STATE = s_mem_init or r_STATE = s_mem_init_aux or r_STATE = s_first_mem else '0';
  
  o_rst_counter      <= '1' when (r_STATE = s_init and i_start = '1') or (r_STATE = s_ldiff_central and (to_integer(signed(i_control_counter)) = i_z-1)) else '0';
  
  o_enable_counter   <= '1' when (r_STATE = s_mem_init and (to_integer(signed (i_control_counter)) < (P-1))) or (r_STATE = s_ldiff_central and (to_integer(signed(i_control_counter)) /= i_z-1)) or (r_STATE = s_update_weights_aux) else '0';
  
  
end Behavioral;
