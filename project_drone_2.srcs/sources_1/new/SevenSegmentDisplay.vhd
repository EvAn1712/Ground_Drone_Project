----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/08/2026
-- Design Name: 
-- Module Name: SevenSegmentDisplay - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 7-segment display controller for Basys3 board
--              Displays wheel modes on 4 digits
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
use IEEE.NUMERIC_STD.ALL;

entity SevenSegmentDisplay is
    Port (
        clk : in std_logic;
        reset : in std_logic;
        mode_right : in std_logic_vector(1 downto 0);
        mode_left : in std_logic_vector(1 downto 0);
        seg : out std_logic_vector(6 downto 0);
        an : out std_logic_vector(3 downto 0)
    );
end SevenSegmentDisplay;

architecture Behavioral of SevenSegmentDisplay is
    -- Refresh counter for multiplexing (~1kHz per digit)
    -- 100MHz / 25000 = 4kHz total (1kHz per digit)
    constant REFRESH_COUNT : integer := 25000;
    signal refresh_counter : unsigned(15 downto 0) := (others => '0');
    signal digit_select : unsigned(1 downto 0) := (others => '0');
    
    -- BCD digits to display
    signal digit0 : std_logic_vector(3 downto 0);  -- Right digit of left wheel
    signal digit1 : std_logic_vector(3 downto 0);  -- Left digit of left wheel
    signal digit2 : std_logic_vector(3 downto 0);  -- Right digit of right wheel
    signal digit3 : std_logic_vector(3 downto 0);  -- Left digit of right wheel
    
    signal current_digit : std_logic_vector(3 downto 0);
    
    -- Function to convert BCD to 7-segment (cathode common, active low)
    function bcd_to_7seg(bcd : std_logic_vector(3 downto 0)) return std_logic_vector is
        variable seg_out : std_logic_vector(6 downto 0);
    begin
        case bcd is
            when "0000" => seg_out := "1000000"; -- 0
            when "0001" => seg_out := "1111001"; -- 1
            when "0010" => seg_out := "0100100"; -- 2
            when "0011" => seg_out := "0110000"; -- 3
            when "0100" => seg_out := "0011001"; -- 4
            when "0101" => seg_out := "0010010"; -- 5
            when "0110" => seg_out := "0000010"; -- 6
            when "0111" => seg_out := "1111000"; -- 7
            when "1000" => seg_out := "0000000"; -- 8
            when "1001" => seg_out := "0010000"; -- 9
            when others => seg_out := "1111111"; -- blank
        end case;
        return seg_out;
    end function;
    
begin
    -- Convert mode to BCD digits
    -- mode "00" -> display "01" (slow)
    -- mode "01" -> display "02" (normal)
    -- mode "10" -> display "03" (fast)
    
    -- Left wheel digits (rightmost on display)
    digit0 <= "0001" when mode_left = "00" else
              "0010" when mode_left = "01" else
              "0011" when mode_left = "10" else
              "0000";  -- Default: display 0
    digit1 <= "0000";  -- Always 0 for tens digit
    
    -- Right wheel digits (leftmost on display)
    digit2 <= "0001" when mode_right = "00" else
              "0010" when mode_right = "01" else
              "0011" when mode_right = "10" else
              "0000";  -- Default: display 0
    digit3 <= "0000";  -- Always 0 for tens digit
    
    -- Refresh counter and digit selector
    process(clk, reset)
    begin
        if reset = '1' then
            refresh_counter <= (others => '0');
            digit_select <= (others => '0');
        elsif rising_edge(clk) then
            if refresh_counter = REFRESH_COUNT - 1 then
                refresh_counter <= (others => '0');
                digit_select <= digit_select + 1;
            else
                refresh_counter <= refresh_counter + 1;
            end if;
        end if;
    end process;
    
    -- Digit multiplexing
    process(digit_select, digit0, digit1, digit2, digit3)
    begin
        case digit_select is
            when "00" =>
                an <= "1110";  -- Activate digit 0 (rightmost)
                current_digit <= digit0;
            when "01" =>
                an <= "1101";  -- Activate digit 1
                current_digit <= digit1;
            when "10" =>
                an <= "1011";  -- Activate digit 2
                current_digit <= digit2;
            when "11" =>
                an <= "0111";  -- Activate digit 3 (leftmost)
                current_digit <= digit3;
            when others =>
                an <= "1111";
                current_digit <= "1111";
        end case;
    end process;
    
    -- Convert current digit to 7-segment
    seg <= bcd_to_7seg(current_digit);
    
end Behavioral;
