library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- ------------------------------------------------------------
-- Direction IP (FSM)
--
-- Goal:
--   Drive motor PWM selection according to:
--     - sensorLeft / sensorRight (1 = black line detected)
--     - state_move (1 = drone enabled, 0 = drone stopped)
--
-- Inputs:
--   - clk, reset : system clock + asynchronous reset
--   - refPwmFst / refPwmStd / refPwmSlw : PWM references from PWM IP
--   - sensorLeft, sensorRight : infrared sensors
--   - state_move : start/stop command from StartStop IP
--
-- Outputs:
--   - motorLeft, motorRight : actual PWM signals sent to motors
--   - mode_left, mode_right : speed encoding for 7-seg display
--        "00" stop, "01" slow, "10" standard, "11" fast
--
-- FSM States:
--   STOPPED  : motors off
--   STRAIGHT : std/std
--   TURN_L   : left slow, right fast
--   TURN_R   : left fast, right slow
--   LOST     : slow/slow
--
-- ------------------------------------------------------------

entity Direction is
    Port (
        clk         : in  std_logic;
        reset       : in  std_logic;

        refPwmFst    : in  std_logic;
        refPwmStd    : in  std_logic;
        refPwmSlw    : in  std_logic;

        sensorLeft   : in  std_logic;
        sensorRight  : in  std_logic;

        state_move   : in  std_logic;

        motorLeft    : out std_logic;
        motorRight   : out std_logic;
        mode_right   : out std_logic_vector(1 downto 0);
        mode_left    : out std_logic_vector(1 downto 0)
    );
end Direction;

architecture Behavioral of Direction is

    -- State type definition (small FSM)

    type state_t is (STOPPED, STRAIGHT, TURN_L, TURN_R, LOST);

    -- Current and next state registers
    signal state_reg  : state_t := STOPPED;
    signal state_next : state_t := STOPPED;

begin

    -- State register (sequential logic)
    --  - Asynchronous reset forces STOPPED state
    --  - Otherwise state updates on rising edge of clk

    process(clk, reset)
    begin
        if reset = '1' then
            state_reg <= STOPPED;
        elsif rising_edge(clk) then
            state_reg <= state_next;
        end if;
    end process;

    -- Next-state logic (combinational)
    -- Computes the next FSM state based on inputs.
    
    process(state_reg, state_move, sensorLeft, sensorRight)
    begin
        -- Default: remain in current state
        state_next <= state_reg;

        -- If drone is not allowed to move, always go to STOPPED
        if state_move = '0' then
            state_next <= STOPPED;

        else
            -- state_move = '1': decide state from sensors
            if (sensorLeft = '0' and sensorRight = '0') then
                state_next <= STRAIGHT;

            elsif (sensorLeft = '1' and sensorRight = '0') then
                state_next <= TURN_L;

            elsif (sensorLeft = '0' and sensorRight = '1') then
                state_next <= TURN_R;

            else
                -- (1,1): both sensors detect black => lost
                state_next <= LOST;
            end if;
        end if;
    end process;

    -- Output logic (Moore machine: outputs depend on state only)
    -- Motor outputs select one of the reference PWM signals.
    process(state_reg, refPwmFst, refPwmStd, refPwmSlw)
    begin
        -- Safe defaults
        motorLeft  <= '0';
        motorRight <= '0';
        mode_left  <= "00";
        mode_right <= "00";

        case state_reg is

            when STOPPED =>
                -- Motors off
                motorLeft  <= '0';
                motorRight <= '0';
                mode_left  <= "00";
                mode_right <= "00";

            when STRAIGHT =>
                -- Standard speed on both motors
                motorLeft  <= refPwmStd;
                motorRight <= refPwmStd;
                mode_left  <= "10";  -- standard
                mode_right <= "10";  -- standard

            when TURN_L =>
                -- Turn left: left slow, right fast
                motorLeft  <= refPwmSlw;
                motorRight <= refPwmFst;
                mode_left  <= "01";  -- slow
                mode_right <= "11";  -- fast

            when TURN_R =>
                -- Turn right: left fast, right slow
                motorLeft  <= refPwmFst;
                motorRight <= refPwmSlw;
                mode_left  <= "11";  -- fast
                mode_right <= "01";  -- slow

            when LOST =>
                -- Lost: both slow until border is found again
                motorLeft  <= refPwmSlw;
                motorRight <= refPwmSlw;
                mode_left  <= "01";  -- slow
                mode_right <= "01";  -- slow

        end case;
    end process;

end Behavioral;
