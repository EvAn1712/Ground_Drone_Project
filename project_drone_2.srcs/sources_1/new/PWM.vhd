library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity PWM is
  Port ( 
    clk : in std_logic;
    reset : in std_logic;
    pwm_fst : out std_logic;
    pwm_std : out std_logic;
    pwm_slw : out std_logic
  );
end PWM;

architecture Behavioral of PWM is
    constant TICKS_200US : integer := 10000;
    signal tick_cnt : unsigned (13 downto 0) := (others => '0');
    signal tick : std_logic := '0';

    signal pwmcnt : unsigned (6 downto 0) := (others => '0');

begin
    process(clk, reset)

    begin
        if reset = '1' then
            tick_cnt <= (others => '0');
            tick <= '0';
        elsif rising_edge(clk) then
            if tick_cnt = TICKS_200US - 1 then
                tick_cnt <= (others => '0');
                tick <= '1';
            else
                tick_cnt <= tick_cnt + 1;
                tick <= '0';
            end if;
        end if;
    end process;

    process(clk, reset)
    begin
        if reset = '1' then
            pwmcnt <= (others => '0');
        elsif rising_edge(clk) then
            if tick = '1' then
                if pwmcnt = 99 then
                    pwmcnt <= (others => '0');
                else
                    pwmcnt <= pwmcnt + 1;
                end if;
            end if;
        end if;
    end process;

    pwm_fst <= '1' when pwmcnt < 95 else '0';
    pwm_std <= '1' when pwmcnt < 50 else '0';
    pwm_slw <= '1' when pwmcnt < 15 else '0';

end Behavioral;
