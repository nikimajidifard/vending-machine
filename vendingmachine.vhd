library ieee;
use IEEE.std_logic_1164.all;


entity FSM is
port (CLK : in std_logic; 
 RSTn : in std_logic;
 CoinIn : in std_logic_vector (1 downto 0); 
 Soda : out std_logic; --Is Soda dispensed ?
 CoinOut : out std_logic_vector (1 downto 0) 
 );

end entity;

architecture behavior of FSM is

type state_type is (idle, 
 put_money, 
 in_1,in_3,in_6,in_5, 
 change_1, 
 soda_out 
 ); 
signal current_s,next_s: state_type; 

begin

process(CLK,RSTn)
begin
 if(RSTn = '0') then
 current_s <= idle; 
 elsif(clk'event and clk = '1') then
 current_s <= next_s;
 end if;
end process;
--------------------

process(current_s,CoinIn)
begin
case current_s is
 when idle => 
 Soda <= '0';
 CoinOut <= "00";
 next_s <= put_money;
 ------------------------------------------------------
 when put_money => --wait for money to be entered
 if(CoinIn = "00")then
 Soda <= '0';
 CoinOut <= "00";
 next_s <= put_money;
 elsif(CoinIn = "01")then --insert 1$
 Soda <= '0';
 CoinOut <= "00";
 next_s <= in_1;
 elsif(CoinIn = "10")then --insert 2$
 Soda <= '0';
 CoinOut <= "00";
 next_s <= soda_out;
 elsif(CoinIn = "11")then --insert 5$
 Soda <= '0';
 CoinOut <= "00";
 next_s <= in_5;
 end if;
 ------------------------------------------------------
 when in_1 => 
 if(CoinIn = "00") then--stay on the same state
 Soda <= '0';
 CoinOut <= "00";
 next_s <= in_1;
 elsif(CoinIn = "01") then--inserted another 1$
 Soda <= '0';
 CoinOut <= "00";
 next_s <= soda_out;
 elsif(CoinIn = "10") then--inserted another 2$
 Soda <= '0';
 CoinOut <= "00";
 next_s <= in_3;
 elsif(CoinIn = "11") then
 Soda <= '0';
 CoinOut <= "10";
 next_s <= in_6;
 end if;
 ------------------------------------------------------
 when in_3 =>
 Soda <= '0';
 CoinOut <= "01";
 next_s <= soda_out;
 ------------------------------------------------------
 when in_6 =>
 Soda <= '0';
 CoinOut <= "01";
 next_s <= in_5;
 ------------------------------------------------------
 when in_5 => -- input = 5 coin
 Soda <= '0';
 CoinOut <= "10";
 next_s <= change_1;
 ------------------------------------------------------
 when change_1 => -- input = 5 coin
 Soda <= '0';
 CoinOut <= "01";
 next_s <= soda_out;
 ------------------------------------------------------
 when soda_out =>
 Soda <= '1';
 CoinOut <= "00";
 next_s <= put_money; 
end case;
end process;

end behavior;



-- testbench
library ieee;
use ieee.std_logic_1164.all;

entity FSM_tb is
end entity;

architecture tb_arch of FSM_tb is
    constant CLK_PERIOD: time := 10 ns; -- Clock period
    
    signal CLK: std_logic := '0'; -- Clock signal
    signal RSTn: std_logic := '1'; -- Reset signal
    signal CoinIn: std_logic_vector(1 downto 0); -- Coin input signal
    signal Soda: std_logic := '0'; -- Soda output signal
    signal CoinOut: std_logic_vector(1 downto 0); -- Coin output signal
    
begin
    -- Instantiate the FSM entity
    DUT: entity work.FSM
        port map (
            CLK => CLK,
            RSTn => RSTn,
            CoinIn => CoinIn,
            Soda => Soda,
            CoinOut => CoinOut
        );

    -- Clock process
    CLK_process: process
    begin
        while now < 200 ns loop
            CLK <= '0';
            wait for CLK_PERIOD/2;
            CLK <= '1';
            wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process CLK_process;

    
    stimulus: process
    begin
        -- Reset
        RSTn <= '0';
        wait for CLK_PERIOD;
        RSTn <= '1';

        wait for CLK_PERIOD;

        -- Scenario 1: No money
        CoinIn <= "00";
        wait for CLK_PERIOD * 2;
        
        -- Scenario 2: Insert 1$ followed by another 1$
        CoinIn <= "01";
        wait for CLK_PERIOD;
        CoinIn <= "01";
        wait for CLK_PERIOD * 2;
        
        -- Scenario 3: Insert 1$ followed by 2$
        CoinIn <= "01";
        wait for CLK_PERIOD;
        CoinIn <= "10";
        wait for CLK_PERIOD * 2;
        
        -- Scenario 4: Insert 1$ followed by 5$
        CoinIn <= "01";
        wait for CLK_PERIOD;
        CoinIn <= "11";
        wait for CLK_PERIOD * 2;
        
        -- Scenario 5: Insert 2$
        CoinIn <= "10";
        wait for CLK_PERIOD * 2;

        -- End simulation
        wait;
    end process stimulus;

end architecture tb_arch;
