----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/17/2025 11:50:04 AM
-- Design Name: 
-- Module Name: Top - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Top is
  Port ( 
    clk : in std_logic;
    reset : in std_logic;

    sensorLeft : in std_logic;
    sensorRight : in std_logic;

    ButtonStart : in std_logic;

    motorLeft : out std_logic;
    motorRight : out std_logic;
    seg : out std_logic_vector(6 downto 0);
    an : out std_logic_vector(3 downto 0)
  );
end Top;

architecture Behavioral of Top is

    signal pwm_fst_s : std_logic;
    signal pwm_std_s : std_logic;
    signal pwm_slw_s : std_logic;

    signal move_s : std_logic;

    signal mode_right_s : std_logic_vector(1 downto 0);
    signal mode_left_s : std_logic_vector(1 downto 0);

begin
    I_PWM: entity work.PWM
        port map (
            clk => clk,
            reset => reset,
            pwm_fst => pwm_fst_s,
            pwm_std => pwm_std_s,
            pwm_slw => pwm_slw_s
        );

    I_BPStartStop: entity work.BPStartStop
        port map (
            clk => clk,
            reset => reset,
            button => ButtonStart,
            move => move_s
        );

    I_Direction: entity work.Direction
        port map (
            clk => clk,
            reset => reset,
            refPwmFst => pwm_fst_s,
            refPwmStd => pwm_std_s,
            refPwmSlw => pwm_slw_s,
            sensorLeft => sensorLeft,
            sensorRight => sensorRight,
            state_move => move_s,
            motorLeft => motorLeft,
            motorRight => motorRight,
            mode_right => mode_right_s,
            mode_left => mode_left_s
        );

    I_SevenSegment: entity work.SevenSegmentDisplay
        port map (
            clk => clk,
            reset => reset,
            mode_right => mode_right_s,
            mode_left => mode_left_s,
            seg => seg,
            an => an
        );

end Behavioral;
