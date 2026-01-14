----------------------------------------------------------------------------------
-- Company: ISAE-SUPAERO
-- Engineer: 
-- 
-- Create Date: 11/12/2025 04:05:56 PM
-- Module Name: BPStartStop_tb - Behavioral
-- Project Name: CHINNAYA Evan - Drone
--
-- Goal:
--   - Instantiate the PWM IP (UUT)
--   - Generate a 50 MHz clock (20 ns period)
--   - Apply a reset pulse at the beginning
--   - Run the simulation long enough to observe PWM behavior
--
-- Note:
--   This testbench is minimal: it does not measure the duty cycle numerically,
--   but it allows observing the 50 Hz PWM waveforms in the simulator.
------------------------------------------------------------------

library ieee;
use IEEE.STD_LOGIC_1164.ALL;

entity PWM_tb is
end PWM_tb;

architecture sim of PWM_tb is

    -- Testbench signals connected to the UUT (Unit Under Test)
    signal clk     : std_logic := '0';
    signal reset   : std_logic := '1';
    signal pwm_fst : std_logic;
    signal pwm_std : std_logic;
    signal pwm_slw : std_logic;

    -- 50 MHz clock => 20 ns period
    constant clk_period : time := 20 ns;

begin

    -- ------------------------------------------------------------
    -- UUT instantiation: connects TB signals to PWM entity ports.
    -- ------------------------------------------------------------
    uut: entity work.PWM
        port map (
            clk => clk,
            reset => reset,
            pwm_fst => pwm_fst,
            pwm_std => pwm_std,
            pwm_slw => pwm_slw
        );

    -- ------------------------------------------------------------
    -- Clock process:
    -- Generates a 50 MHz clock for 100 ms of simulation time.
    -- ------------------------------------------------------------
    clk_proc : process
    begin
        while now < 100 ms loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- ------------------------------------------------------------
    -- Stimulus process:
    -- 1) Keep reset active at start, then release it after 100 ns.
    -- 2) Wait long enough to observe several PWM periods.
    -- 3) Print the current state of each PWM output (informative only).
    -- ------------------------------------------------------------
    stim_proc: process
    begin
        -- Initial reset asserted (reset='1' by default)
        wait for 100 ns;
        reset <= '0'; -- release reset

        -- Observe PWM outputs during simulation
        wait for 100 ms;

        -- Simple reports (not a duty-cycle measurement)
        report "PWM First Speed: " & std_logic'image(pwm_fst);
        report "PWM Standard Speed: " & std_logic'image(pwm_std);
        report "PWM Slow Speed: " & std_logic'image(pwm_slw);

        wait;
    end process;

end sim;
