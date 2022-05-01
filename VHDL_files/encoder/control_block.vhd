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
         o_sel_mux_acc           : out std_logic;  
         o_sel_mux_count         : out std_logic; 
         o_en_init_mem           : out std_logic; 
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

type t_STATE is (s_init_mem, s_init_mem_aux, -- memory initialization states 
                 s_init, s_verify_t, s_write_dsample, s_write_dsample_aux, s_kz_calc, s_coding_procedure, s_coding_procedure_verify, s_encode_kz, s_encode_umax, s_acc_counter_update, -- states of encode
                 s_encode_kz_s1, s_encode_kz_s1_aux, s_encode_kz_s2, s_encode_kz_s3, s_encode_kz_s3_aux, -- encode kz states
                 s_encode_umax_s1, s_encode_umax_s1_aux, s_encode_umax_s2, s_encode_umax_s2_aux); -- encode umax states

signal r_STATE : t_STATE; -- state register
signal w_NEXT  : t_STATE; -- next state
signal w_addr_mem, w_count_init : integer range 0 to NBANDS := 0; 

begin

  -- state transition process
  p_STATE : process (i_rst, i_clk)
  begin
    if (i_rst = '1') then
      r_STATE <= s_init_mem; -- estado inicial
    elsif (rising_edge(i_clk)) then
      r_STATE <= w_NEXT; -- proximo estado
    end if;
  end process;
  
  p_NEXT : process (r_STATE, i_start, i_verify_t, i_select_coding, i_uz_equal_zero, i_kz_equal_zero)
  begin
    
    case (r_STATE) is
      
      -- Inicialização das memorias acumulador e contador
      when s_init_mem => if(w_count_init < (NBANDS-1)) then
                           w_NEXT <= s_init_mem_aux;
                         else 
                           w_NEXT <= s_init;
                           w_addr_mem <= 0;
                           w_count_init <= 0;
                         end if;
      
      when s_init_mem_aux => w_NEXT <= s_init_mem;
                             w_count_init <= w_count_init + 1;
                             w_addr_mem <= w_addr_mem + 1;  
      
      when s_init => if(i_start = '1') then 
                       w_NEXT <= s_verify_t;
                     else 
                       w_NEXT <= s_init;
                     end if;
      
      when s_verify_t => if(i_verify_t = '0') then -- i.e (t > 0)
                           w_NEXT <= s_kz_calc;
                         else  -- (t = 0)
                           w_NEXT <= s_write_dsample;
                         end if;
      
      when s_write_dsample => if(D >= 0) then 
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
            
      -- QUANDO ESTIVER NO CAMINHO DE CODIFICAÇÃO (uz < UMAX)
      when s_encode_kz => w_NEXT <= s_encode_kz_s1;
      -- fica nesse estagio ate uz ser zero, pois precisamos escrever 0's uz.
      when s_encode_kz_s1 => if(i_uz_equal_zero = '1') then
                               w_NEXT <= s_encode_kz_s2;
                             else 
                               w_NEXT <= s_encode_kz_s1_aux;
                             end if;
      
      when s_encode_kz_s1_aux => w_NEXT <= s_encode_kz_s1;
      
      -- estagio 2 (só precisamos escrever um bit 1)
      when s_encode_kz_s2 => w_NEXT <= s_encode_kz_s3;
      
      -- estagio 3 (escrever os kz bits menos significativos do mapped)
      when s_encode_kz_s3 => if(i_kz_equal_zero = '1') then
                               w_NEXT <= s_acc_counter_update;
                             else 
                               w_NEXT <= s_encode_kz_s3_aux;
                             end if;
                             
      when s_encode_kz_s3_aux => w_NEXT <= s_encode_kz_s3;
      
      
      -- QUANDO ESTIVER NO CAMINHO DE CODIFICAÇÃO UMAX
      when s_encode_umax => w_NEXT <= s_encode_umax_s1;
      
      when s_encode_umax_s1 => if(UMAX < 0) then 
                                 w_NEXT <= s_encode_umax_s2;
                               else
                                 w_NEXT <= s_encode_umax_s1_aux;
                               end if;
                               
      when s_encode_umax_s1_aux => w_NEXT <= s_encode_umax_s1;
      
      when s_encode_umax_s2 => if (D > 0) then
                                 w_NEXT <= s_encode_umax_s2_aux;
                               else
                                 w_NEXT <= s_acc_counter_update;
                               end if;
                               
      
      -- ATUALIZAÇÃO DO CONTADOR E ACUMULADOR
                                        
      when s_acc_counter_update => w_NEXT <= s_init;
      
      when others => w_NEXT <= s_init;
      
    end case;
  end process;
  
  
  --FAZER OS ESTADOS PARA INICIAR A MEMORIA E CONTROLAR OS SELETORES DOS MULTIPLEXADORES 
  o_en_init_mem <= '1' when r_STATE = s_init_mem else '0';
  
  o_sel_mux_acc <= '1' when r_STATE = s_init_mem or r_STATE = s_init_mem_aux else '0';
  
  o_sel_mux_count <= '1' when r_STATE = s_init_mem or r_STATE = s_init_mem_aux else '0';
  
  -- sinal para ativar o bloco que calcula a variavel KZ
  o_enable_kzcalc <= '1' when r_STATE = s_kz_calc else '0';
  
  -- sinal para ativar o bloco coding procedure, que faz o calculo da variavel UZ e da seleção de codificação (t=0 ou t>0)
  o_en_coding_procedure <= '1' when r_STATE = s_coding_procedure else '0';
  
  -- sinal para ativar o bloco que atualiza o valor do contador e acumulador 
  o_en_acc_counter_update <= '1' when r_STATE = s_acc_counter_update else '0';
  
  -- sinal para ativar a codificação do caminho kz
  o_en_coding_kz <= '1' when r_STATE = s_encode_kz_s1 or r_STATE = s_encode_kz_s2 or r_STATE = s_encode_kz_s3 else '0'; 
  
  -- sinal para ativar a codificação pelo caminho UMAX
  o_en_coding_umax <= '1' when r_STATE = s_encode_umax else '0';
  
  -- sinal de leitura da memoria do contador
  o_rd_counter <= '1' when r_STATE = s_kz_calc or r_STATE = s_acc_counter_update else '0';
  
  -- sinal de escrita da memoria do contador
  o_wr_counter <= '1' when r_STATE = s_acc_counter_update or r_STATE = s_init_mem_aux or (r_STATE = s_init_mem and w_count_init = 0) else '0'; 
  
  -- sinal de leitura da memoria do acumulador
  o_rd_accumulator <= '1' when r_STATE = s_kz_calc or r_STATE = s_acc_counter_update else '0';
  
  -- sinal de escrita da memoria do acumulador
  o_wr_accumulator <= '1' when r_STATE = s_acc_counter_update or r_STATE = s_init_mem_aux or (r_STATE = s_init_mem and w_count_init = 0) else '0'; 
  
  -- endereço de memoria para o contador e acumulador
  o_addr_mem <= std_logic_vector(to_unsigned(w_addr_mem, NBANDS));
  
  -- sinal para resetar os registradores uz e kz utilizados nos estagios de codificação
  o_rst_kz_uz_register <= '1' when r_STATE = s_init else '0';
  
  -- decounter para o registrador kz no estagio de codificação de kz bits do mapped 
  o_en_decounter_kz <= '1' when r_STATE = s_encode_kz_s3_aux else '0';
  
  -- decounter para o registrador uz no estagio de codificação de 0 uz bits
  o_en_decounter_uz <= '1' when r_STATE = s_encode_kz_s1_aux else '0';
  
  -- sinal de enable para registrar o valor de kz apos seu calculo
  o_en_kz_register <= '1' when r_STATE = s_coding_procedure else '0';
  
  -- sinal de enable para registrar o valor de uz apos seu calculo
  o_en_uz_register <= '1' when r_STATE = s_coding_procedure_verify else '0';
  
  -- sinal para registrar o valor t para o datapath
  o_en_verify_t <= '1' when r_STATE = s_init else '0';
  
  -- estagios de codificação para o (uz < umax)
  o_stage_kz <= "00" when r_STATE = s_encode_kz_s1 else
                "01" when r_STATE = s_encode_kz_s2 else
                "10" when r_STATE = s_encode_kz_s3 else "00";
  
  -- estagios de codificação para o UMAX
  o_stage_umax  <= '1' when r_STATE = s_encode_umax_s1 else '0';
  
end Behavioral;
