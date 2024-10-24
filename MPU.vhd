library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

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
    
    type matrix is array (3 downto 0, 3 downto 0) of std_logic_vector(15 downto 0); -- Matriz 4x4 de 16 bits
    signal A, B, C: matrix := (others => (others => (others => '0')));  -- Inicializa as matrizes com zero
    signal command: std_logic_vector(15 downto 0) := (others => '0');  -- Inicializa o comando
    signal temp_result: std_logic_vector(31 downto 0);  -- Resultado temporário
    signal row, col: integer range 0 to 3;  -- Índices para percorrer as linhas e colunas

    -- Definindo os estados da FSM
    type state_type is (IDLE, READ_CMD, EXECUTE, COMPLETE);
    signal CURRENT_STATE, next_state: state_type;
    signal operation: std_logic_vector(2 downto 0) := (others => '0');  -- Tipo de operação (add, sub, etc.)

begin

    -- Atualiza o estado atual na borda do clock

	

		
    -- FSM para controlar o fluxo de execução
	 
    process(clk, reset)

    begin

        if reset = '1' then
		  
			  CURRENT_STATE <= IDLE;
			  intr <= '0';
			  
		  elsif rising_edge(clk) then
		  
			  case CURRENT_STATE is
			  
					when IDLE =>
					
						 intr <= '0';
						 
						 if ce_n = '1' then
						 
							CURRENT_STATE <= CURRENT_STATE
							
						elsif ce_n = '0' then
						
							CURRENT_STATE <= DECODE
							
						end if;

					when DECODE =>
					
						if ce_n = '0' and we_n = '0' then
						
							CURRENT_STATE <= W_MATRIX
							
						elsif ce_n ='0' and oe_n = '0' then
						
							CURRENT_STATE <= O_MATRIX
						
						end if;
					
					when O_MATRIX =>
						
					when W_MATRIX =>
						
						if address > "0000000000001111" then
							
							CURRENT_STATE <= WRITE_DATA
						
						elsif address = "0000000000000000" then
						
							CURRENT_STATE <= DECODE
						
						end if;						
							
					when DECODE =>
						
						case data is
							
							when data(15 downto 12) 
							
            when EXECUTE =>

                case operation is
					 
                    when "000" =>  -- ADD

                        for row in 0 to 3 loop

                            for col in 0 to 3 loop

                                C(row, col) <= A(row, col) + B(row, col);  -- Soma matriz A e B

                            end loop;

                        end loop;

                    when "001" =>  -- SUB

                        for row in 0 to 3 loop

                            for col in 0 to 3 loop

                                C(row, col) <= A(row, col) - B(row, col);  -- Subtrai matriz B de A

                            end loop;

                        end loop;

                    when "010" =>  -- MUL

                        for row in 0 to 3 loop

                            for col in 0 to 3 loop

                                temp_result <= (others => '0');

                                for k in 0 to 3 loop

                                    temp_result <= temp_result + A(row, k) * B(k, col);

                                end loop;

                                C(row, col) <= temp_result(15 downto 0);

                            end loop;


                           
                        end loop;

                    when "011" =>  -- MAC (C = C + A * B)

                        for row in 0 to 3 loop

                            for col in 0 to 3 loop

                                temp_result <= (others => '0');

                                for k in 0 to 3 loop

                                    temp_result <= temp_result + A(row, k) * B(k, col);

                                end loop;

                                C(row, col) <= C(row, col) + temp_result(15 downto 0);

                            end loop;

                        end loop;

                    when "100" =>  -- FILL (preencher matriz com valor)

                        for row in 0 to 3 loop

                            for col in 0 to 3 loop

                                C(row, col) <= (others => '1');  -- Exemplo: preenche com 1s

                            end loop;

                        end loop;

                    when "101" =>  -- IDENTITY (matriz identidade)

                        for row in 0 to 3 loop

                            for col in 0 to 3 loop

                                if row = col then

                                    C(row, col) <= "0000000000000001"; -- 1s na diagonal

                                else

                                    C(row, col) <= (others => '0'); -- 0s nas outras posições

                                end if;

                            end loop;

                        end loop;

                    when others =>  -- Comando inválido

                        for row in 0 to 3 loop

                            for col in 0 to 3 loop

                                C(row, col) <= (others => '0');  -- ZERA A MATRIZ

                            end loop;

                        end loop;

                end case;

                next_state <= COMPLETE;

            when COMPLETE =>

                intr <= '1';  -- Levanta o sinal de interrupção

                next_state <= IDLE;  -- Volta para o estado de espera (IDLE)

            when others =>

                next_state <= IDLE;

        end case;
		  
		end if;

    end process;

    

end Behavioral;
