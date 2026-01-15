--------------------------------------------------------------------
-- BPStartStop_tb
--
-- Goal:
--   - Instantiate the StartStop IP
--   - Generate a clock
--   - Apply reset
--   - Apply several button presses and observe 'move' toggling
--
-- What to verify in simulation:
--   1) After reset, move must be 0 (stopped).
--   2) First button press: move becomes 1 (start).
--   3) Second button press: move becomes 0 (stop).
--   4) Reset at any time forces move back to 0.
--------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity BPStartStop_tb is
end BPStartStop_tb;

architecture sim of BPStartStop_tb is

    -- TB signals
    signal clk    : std_logic := '0';
    signal reset  : std_logic := '0';
    signal button : std_logic := '0';
    signal move   : std_logic;

    -- 50 MHz clock period (20 ns)
    constant clk_period : time := 20 ns;

begin

    -- UUT instantiation (Unit Under Test)

    UUT: entity work.BPStartStop
        port map (
            clk    => clk,
            reset  => reset,
            button => button,
            move   => move
        );

    -- Clock generation: runs until 100 ms

    clk_proc : process
    begin
        while now < 100 ms loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Sequence of reset and button presses.
    -- Note: button pulses are 100 ns wide here.
    -- The toggle is sampled on rising edges of clk.

    stim_proc: process
    begin
        -- Initial reset pulse (forces move to 0)
        reset <= '1';
        wait for 50 ns;
        reset <= '0';

        -- 1st button press: expected move toggles to 1
        wait for 150 ns;
        button <= '1';
        wait for 100 ns;
        button <= '0';

        -- 2nd button press: expected move toggles back to 0
        wait for 200 ns;
        button <= '1';
        wait for 100 ns;
        button <= '0';

        -- 3rd button press: expected move toggles to 1
        wait for 200 ns;
        button <= '1';
        wait for 100 ns;
        button <= '0';

        -- Apply reset: expected move forced to 0 immediately
        wait for 200 ns;
        reset <= '1';
        wait for 100 ns;
        reset <= '0';

        -- 4th button press: expected move toggles to 1
        wait for 200 ns;
        button <= '1';
        wait for 100 ns;
        button <= '0';

        -- 5th button press: expected move toggles to 0
        wait for 200 ns;
        button <= '1';
        wait for 100 ns;
        button <= '0';

        wait;
    end process;

end sim;
