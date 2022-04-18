----------------------------------------------------------------------------------
-- Name: Wesley Grignani
-- Laboratory of Embedded and Distributed Systems (LEDS) - UNIVALI
----------------------------------------------------------------------------------
-- Description: control unity for encoder stage 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.ccsds123_B2_package.all;

entity control_block is
  port ( i_clk                   : in  std_logic;
         i_rst                   : in  std_logic;
         i_start                 : in  std_logic;
         i_verify_t              : in  std_logic;  -- sinal para informar se t>=0
         i_select_coding         : in  std_logic;  -- selecionar qual caminho de codificação ira fazer
         i_kz_equal_zero         : in  std_logic;
         i_uz_equal_zero         : in  std_logic;
         o_en_coding_kz          : out std_logic;
         o_en_coding_umax        : out std_logic;
         o_enable_kzcalc         : out std_logic;  
         o_en_coding_procedure   : out std_logic;
         o_en_acc_counter_update : out std_logic;
         o_rd_counter            : out std_logic;
         o_wr_counter            : out std_logic;
         o_rd_accumulator        : out std_logic;
         o_wr_accumulator        : out std_logic;
         o_addr_mem              : out std_logic_vector(P-1 downto 0);
         o_rst_kz_uz_register    : out std_logic;
         o_en_decounter_kz       : out std_logic;
         o_en_decounter_uz       : out std_logic;
         o_en_kz_register        : out std_logic;
         o_en_uz_register        : out std_logic;
         o_en_verify_t           : out std_logic;
         o_stage_kz              : out std_logic_vector(1 downto 0);
         o_stage_umax            : out std_logic);
end control_block;

architecture Behavioral of control_block is

type t_STATE is (s_init, s_verify_t, s_write_dsample, s_write_dsample_aux, s_kz_calc, s_coding_procedure, s_coding_procedure_verify, s_encode_kz, s_encode_umax, s_acc_counter_update); -- new fsm type
signal r_STATE : t_STATE; -- state register
signal w_NEXT  : t_STATE; -- next state

begin

  -- state transition process
  p_STATE : process (i_rst, i_clk)
  begin
    if (i_rst = '1') then
      r_STATE <= s_init; -- estado inicial
    elsif (rising_edge(i_clk)) then
      r_STATE <= w_NEXT; -- proximo estado
    end if;
  end process;
  
  p_NEXT : process (r_STATE)
  begin
    
    case (r_STATE) is
    
      when s_init => if(i_start = '1') then 
                       w_NEXT <= s_verify_t;
                     else 
                       w_NEXT <= s_init;
                     end if;
      
      when s_verify_t => if(i_verify_t = '0') then -- (i.e t > 0)
                           w_NEXT <= s_kz_calc;
                         else  -- (t = 0)
                           w_NEXT <= s_write_dsample;
                         end if;
      
      when s_write_dsample => if(UMAX >= 0) then 
                                w_NEXT <= s_write_dsample_aux;
                              else 
                                w_NEXT <= s_init;
                              end if; 
      
      when s_write_dsample_aux => w_NEXT <= s_write_dsample;
      
      when s_kz_calc => w_NEXT <= s_coding_procedure;
      
      when s_coding_procedure => w_NEXT <= s_coding_procedure_verify;
      
      when s_coding_procedure_verify => if(i_select_coding = '1') then
                                          w_NEXT <= s_encode_kz; --vai para o caminho de uz < UMAX
                                        else
                                          w_NEXT <= s_encode_umax; -- else
                                        end if;
      
      -- Aqui criar logica para fazer o encode de kz e a logica de encode de umax 
                                        
      when s_acc_counter_update => w_NEXT <= s_init;
      
      when others => w_NEXT <= s_init;
    end case;
  end process;
  
  
  o_enable_kzcalc <= '1' when r_STATE = s_kz_calc else '0';
  o_en_coding_procedure <= '1' when r_STATE = s_coding_procedure else '0';
  o_en_acc_counter_update <= '1' when r_STATE = s_acc_counter_update else '0';
  o_en_coding_kz <= '1' when r_STATE = s_encode_kz else '0'; 
  o_en_coding_umax <= '1' when r_STATE = s_encode_umax else '0';
  o_rd_counter <= '1' when r_STATE = s_kz_calc or r_STATE = s_acc_counter_update else '0';
  o_wr_counter <= '1' when r_STATE = s_acc_counter_update else '0'; 
  o_rd_accumulator <= '1' when r_STATE = s_kz_calc or r_STATE = s_acc_counter_update else '0';
  o_wr_accumulator <= '1' when r_STATE = s_acc_counter_update else '0'; 
  -- FALTA CRIAR ESTADOS AINDA PARA ATIVAR ESSES SINAIS DE BAIXO
  o_addr_mem <= "00000";
  o_rst_kz_uz_register <= '0';
  o_en_decounter_kz <= '0';
  o_en_decounter_uz <= '0';
  o_en_kz_register <= '0';
  o_en_uz_register <= '0';
  o_en_verify_t <= '0';
  o_stage_kz <= "00";
  o_stage_umax  <= '0';
  
end Behavioral;
