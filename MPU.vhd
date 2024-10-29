library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MPU is

    Port (
        ce_n, we_n, oe_n: in std_logic;
        intr: out std_logic;
        address: in std_logic_vector(15 downto 0);
        data: inout std_logic_vector(15 downto 0);
        clk: in std_logic;
        reset: in std_logic
    );

end MPU;

architecture Behavioral of MPU is

    type Matrix is array (63 downto 0) of std_logic_vector(15 downto 0);
    signal memory: Matrix;  

    signal temp_result: std_logic_vector(31 downto 0);  -- Resultado temporário

    signal i: integer range 0 to 15;                   -- Índices para percorrer as matrizes
    signal j, k: integer range 0 to 3;
	 signal memory_aux: integer range 0 to 63;
     

    -- Definindo os estados da FSM
    type state_type is (IDLE, READ_WR, O_MATRIX, W_MATRIX, WRITE_DATA, DECODE, EXCEPTION, EXECUTE, COMPLETE);
    signal CURRENT_STATE: state_type;

    signal operation: std_logic_vector(2 downto 0) := (others => '0');  -- Tipo de operação (add, sub, etc.)
    signal inteiro: std_logic_vector(15 downto 0) := (others => '0');  -- Sinal do inteiro para o FILL

begin

    process(clk, reset)

    begin

        if reset = '1' then

            for i in 0 to 63 loop

                memory(i) <= (others => '0');

            end loop;

            CURRENT_STATE <= IDLE;

            intr <= '0';

            data <= (others => 'Z');

        elsif rising_edge(clk) then

            case CURRENT_STATE is

                when IDLE =>

                    intr <= '0';

                    if ce_n = '0' then

                        CURRENT_STATE <= READ_WR;

                    end if;

                when READ_WR =>

                    if ce_n = '0' and we_n = '0' then

                        CURRENT_STATE <= W_MATRIX;

                    elsif ce_n ='0' and oe_n = '0' then

                        CURRENT_STATE <= O_MATRIX;

                    end if;

                when O_MATRIX =>

                    memory_aux <= to_integer(unsigned(address));
                    
                    data <= memory(memory_aux);

                when W_MATRIX =>

                    if address > "0000000000001111" then

                        CURRENT_STATE <= WRITE_DATA;

                    elsif address = "0000000000000000" then

                        CURRENT_STATE <= DECODE;

                    end if;

                when WRITE_DATA =>

                    memory_aux <= to_integer(unsigned(address));  -- verificar problema
                    memory(memory_aux) <= data;

                when DECODE =>

                    case data(15 downto 13) is

                        when "000" => operation <= "000"; -- add
                        when "001" => operation <= "001"; -- sub
                        when "010" => operation <= "010"; -- mul
                        when "011" => operation <= "011"; -- mac
                        when "100" => operation <= "100"; -- fill
                        when "101" => operation <= "101"; -- identity
                        when others => operation <= "111"; -- comando inválido                            

                    end case;

                    CURRENT_STATE <= EXECUTE;

                when EXECUTE =>
					 
                    case operation is
						  
						  
                        when "000" =>  -- ADD
								
                            for i in 0 to 15 loop
									 
                                memory(i + 16) <= std_logic_vector(unsigned(memory(i + 32)) + unsigned(memory(i + 48)));
										  
                            end loop;
									 

                        when "001" =>  -- SUB
								
                            for i in 0 to 15 loop
									 
                                memory(i + 16) <= std_logic_vector(unsigned(memory(i + 32)) - unsigned(memory(i + 48)));
										  
                            end loop;
									 

                        when "010" =>  -- MUL

                            for i in 0 to 3 loop
									 
                                    temp_result <= (others => '0');

                                for j in 0 to 3 loop
										  
                                    for k in 0 to 3 loop
                                    
                                        temp_result <= std_logic_vector(unsigned(temp_result) + unsigned(memory(i*4 + j + 32)) * unsigned(memory(48 + j + k*4)));
                                    
                                    end loop;
												
									memory(i*4 + j + 16) <= temp_result(15 downto 0);
												
                                end loop;
										  
                            end loop;
									 

                        when "011" =>  -- MAC (MUL + C)
								
							for i in 0 to 3 loop
									 
                                temp_result <= (others => '0');

                                for j in 0 to 3 loop
										  
                                    for k in 0 to 3 loop
                                    
                                        temp_result <= std_logic_vector(unsigned(temp_result) + unsigned(memory(i*4 + j + 32)) * unsigned(memory(48 + j + k*4)));
                                    
                                    end loop;
                                    
                                    memory(i*4 + j + 16) <= std_logic_vector(unsigned(memory(i*4 + j + 16)) + unsigned(temp_result(15 downto 0)));
												
                                end loop;
										  
                            end loop;
				 
									 
                        when "100" =>  -- FILL (preencher matriz com valor)
                
                            case data (12 downto 11) is
    
                                when "00" => 

                                    inteiro <= "00000"&data(10 downto 0); 

                                    for i in 0 to 15 loop
                
                                        memory(i + 32) <= inteiro;  --iA
                    
                                    end loop;

                                when "01" =>

                                    inteiro <= "00000"&data(10 downto 0);

                                    for i in 0 to 15 loop
                
                                        memory(i + 48) <= inteiro;   --iB
                    
                                    end loop;

                                when "10" =>

                                    inteiro <= "00000"&data(10 downto 0); 

                                    for i in 0 to 15 loop
                
                                        memory(i + 16) <= inteiro;   --iC
                    
                                    end loop;
                                    
                                when others =>
                                
                                    CURRENT_STATE <= IDLE; -- NÃO FAZ NADA

                            end case;
									

                        when "101" =>  -- IDENTITY (matriz identidade)
								
                            for i in 0 to 15 loop
									 
                                if i mod 5 = 0 then
										  
                                    memory(i + 16) <= "0000000000000001";  -- 1 na diagonal
												
                                else
										  
                                    memory(i + 16) <= (others => '0');  -- 0 nas outras posições
												
                                end if;
										  
                            end loop;
		 
									 
						when others =>
								
							CURRENT_STATE <= EXCEPTION;

                    end case;
						  

                    CURRENT_STATE <= COMPLETE;

                when COMPLETE =>
					 
                    intr <= '1';  -- Levanta o sinal de interrupção
						  
                    CURRENT_STATE <= IDLE;  -- Volta para o estado de espera (IDLE)

                when EXCEPTION =>

                    intr <= '1';

                when others =>
					 
                    CURRENT_STATE <= IDLE;

            end case;

        end if;

    end process;

end Behavioral;
