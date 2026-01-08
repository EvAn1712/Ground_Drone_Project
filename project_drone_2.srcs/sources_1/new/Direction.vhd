----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/17/2025 10:00:50 AM
-- Design Name: 
-- Module Name: Direction - Behavioral
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

entity Direction is
    Port (
        clk : in std_logic;
        reset : in std_logic;

        refPwmFst : in std_logic;
        refPwmStd : in std_logic;
        refPwmSlw : in std_logic;

        sensorLeft : in std_logic;
        sensorRight : in std_logic;

        state_move : in std_logic;

        motorLeft : out std_logic;
        motorRight : out std_logic;
        mode_right : out std_logic_vector(1 downto 0);
        mode_left : out std_logic_vector(1 downto 0)
    );
end Direction;

architecture Behavioral of Direction is
begin
    process(sensorLeft, sensorRight, state_move, refPwmFst, refPwmStd, refPwmSlw)
    begin
        if state_move = '0' then 
            motorLeft <= '0';
            motorRight <= '0';
            mode_left <= "01";   -- Normal mode when stopped
            mode_right <= "01";  -- Normal mode when stopped
        else
            if sensorLeft = '0' and sensorRight = '0' then
                motorLeft <= refPwmFst;
                motorRight <= refPwmFst;
                mode_left <= "10";   -- Fast mode
                mode_right <= "10";  -- Fast mode

            elsif sensorLeft = '1' and sensorRight = '0' then
                motorLeft <= refPwmSlw;
                motorRight <= refPwmFst;
                mode_left <= "00";   -- Slow mode
                mode_right <= "10";  -- Fast mode

            elsif sensorLeft = '0' and sensorRight = '1' then
                motorLeft <= refPwmFst;
                motorRight <= refPwmSlw;
                mode_left <= "10";   -- Fast mode
                mode_right <= "00";  -- Slow mode

            else
                motorLeft <= refPwmStd;
                motorRight <= refPwmStd;
                mode_left <= "01";   -- Normal mode
                mode_right <= "01";  -- Normal mode
            end if;
        end if;
    end process;
end Behavioral;
