----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/17/2025 12:16:47 PM
-- Design Name: 
-- Module Name: Direction_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity Direction_tb is
end Direction_tb;

architecture sim of Direction_tb is
    signal clk : std_logic := '0';
    signal reset : std_logic := '1';

    signal refFst : std_logic:= '0';
    signal refStd : std_logic := '0';
    signal refSlw : std_logic := '0';

    signal sensorL : std_logic := '0';
    signal sensorR : std_logic := '0';

    signal state_move : std_logic := '0';

    signal motorL : std_logic;
    signal motorR : std_logic;
    signal mode_right_tb : std_logic_vector(1 downto 0);
    signal mode_left_tb : std_logic_vector(1 downto 0);

    constant clk_period : time := 20 ns;

begin
    UUT : entity work.Direction
        port map (
            clk => clk,
            reset => reset,
            refPwmFst => refFst,
            refPwmStd => refStd,
            refPwmSlw => refSlw,
            sensorLeft => sensorL,
            sensorRight => sensorR,
            state_move => state_move,
            motorLeft => motorL,
            motorRight => motorR,
            mode_right => mode_right_tb,
            mode_left => mode_left_tb
        );

    clk_proc :process
    begin
        while now < 20 ms loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    ref_proc: process
    begin
        loop
            refFst <= '1';
            wait for 1 us;
            refFst <= '0';
            wait for 1 us;
            if now > 20 ms then
                exit;
            end if;
        end loop;
    end process;

    ref2_proc: process
    begin
        loop
            refStd <= '1';
            wait for 2 us;
            refStd <= '0';
            wait for 2 us;
            if now > 20 ms then
                exit;
            end if;
        end loop;
    end process;

    ref3_proc: process
    begin
        loop
            refSlw <= '1';
            wait for 4 us;
            refSlw <= '0';
            wait for 4 us;
            if now > 20 ms then
                exit;
            end if;
        end loop;
    end process;

    stim_proc: process
    begin
        wait for 100 ns;
        reset <= '0';
        state_move <= '1';

        -- Test case 1: Both sensors off, state_move = '1'
        sensorL <= '0';
        sensorR <= '0';
        wait for 5 ms;

        -- Test case 2: Left sensor on, right sensor off
        sensorL <= '1';
        sensorR <= '0';
        wait for 5 ms;

        -- Test case 3: Left sensor off, right sensor on
        sensorL <= '0';
        sensorR <= '1';
        wait for 5 ms;

        -- Test case 4: Both sensors on
        sensorL <= '1';
        sensorR <= '1';
        wait for 5 ms;

        -- Test case 5: state_move = '0'
        state_move <= '0';
        wait for 2 ms;

        wait;
    end process;


end sim;
