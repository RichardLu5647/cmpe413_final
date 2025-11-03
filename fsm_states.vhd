--
-- Entity: fsm_states
-- Architecture: structural
-- Description: Activates states based on current parameters.
--

library STD;
library IEEE;
use IEEE.std_logic_1164.all;

entity fsm_states is
    port(
        CLK           : in  std_logic;
        RESET         : in  std_logic;  
        START         : in std_logic;
        is_hit        : in std_logic;
        rd_wr         : in std_logic;
        states        : in std_logic_vector (21 downto 0);
        next_states   : out std_logic_vector (21 downto 0)
    );
end fsm_states;

architecture structural of fsm_states is

    component and2 is
        port (
            input1   : in  std_logic;
            input2   : in  std_logic;
            output   : out std_logic
            );
    end component;

    component and3 is 
        port (
            A : in std_logic;
            B : in std_logic;
            C : in std_logic;
            Y : out std_logic
            );
    end component;

    component and4 is 
        port (
            A : in std_logic;
            B : in std_logic;
            C : in std_logic;
            D : in std_logic;
            Y : out std_logic
            );
    end component;

    component or2 is
        port (
            input1   : in  std_logic;
            input2   : in  std_logic;
            output   : out std_logic
            );
    end component;

    component or3 is
    port (
        input1   : in  std_logic;
        input2   : in  std_logic;
        input3   : in std_logic;
        output   : out std_logic
    	);
    end component;

    -- Conditions to go to IDLE
    signal go_to_idle_1, go_to_idle_2 : std_logic;

    -- Conditions to go to READ_DONE
    signal go_to_read_done_1, go_to_read_done_2 : std_logic;

    -- Conditions to go to WRITE_DONE
    signal go_to_write_done_1, go_to_write_done_2 : std_logic;
    
begin

    -- Go to IDLE after WRITE_MISS, READ_DONE, or WRITE_DONE.
    go_to_IDLE1: or3 port map(
        input1 => states(2),
        input2 => states(20),
        input3 => states(21),
        output => go_to_idle_1
    );

    -- Makes sure idle stays idle if not start.
    go_to_IDLE2: and2 port map(
        input1 => states(0),
        input2 => not START,
        output => go_to_idle_2
    );
    
    -- Go to IDLE
    IDLE: or2 port map(
    	input1 => go_to_idle_1,
        input2 => go_to_idle_2,
        output => next_states(0)
    );

    -- Go to TAG_CHECK
    TAG_CHECK: and3 port map(
        A => not states(1),
        B => states(0),
        C => START,
        Y => next_states(1)
    );

    -- Go to WRITE_MISS
    WRITE_MISS: and4 port map(
        A => not states(2),
        B => not rd_wr,
        C => states(1),
        D => not is_hit,
        Y => next_states(2)
    );

    -- Go to READ_MISS_REQUEST
    READ_MISS_REQUEST: and4 port map(
        A => not states(3),
        B => rd_wr,
        C => states(1),
        D => not is_hit,
        Y => next_states(3)
    );

    -- Go to READ_MISS_ENABLE_OFF
    READ_MISS_ENABLE_OFF: and2 port map(
        input1 => not states(4),
        input2 => states(3),
        output => next_states(4)
    );

    -- Go to READ_MISS_WAIT
    READ_MISS_WAIT: and2 port map(
        input1 => not states(5),
        input2 => states(4),
        output => next_states(5)
    );
    
    -- WAIT
    READ_MISS_WAIT1: and2 port map(
        input1 => not states(6),
        input2 => states(5),
        output => next_states(6)
    );
    
    -- WAIT
    READ_MISS_WAIT2: and2 port map(
        input1 => not states(7),
        input2 => states(6),
        output => next_states(7)
    );
    
    -- WAIT
    READ_MISS_WAIT3: and2 port map(
        input1 => not states(8),
        input2 => states(7),
        output => next_states(8)
    );
    
    -- WAIT
    READ_MISS_WAIT4: and2 port map(
        input1 => not states(9),
        input2 => states(8),
        output => next_states(9)
    );
    
    -- Go to READ_MISS_DATA0
    READ_MISS_DATA0: and2 port map(
        input1 => not states(10),
        input2 => states(9),
        output => next_states(10)
    );

    -- Go to DATA0_WAIT
    DATA0_WAIT: and2 port map(
        input1 => not states(11),
        input2 => states(10),
        output => next_states(11)
    );

    -- Go to READ_MISS_DATA1
    READ_MISS_DATA1: and2 port map(
        input1 => not states(12),
        input2 => states(11),
        output => next_states(12)
    );

    -- Go to DATA1_WAIT
    DATA1_WAIT: and2 port map(
        input1 => not states(13),
        input2 => states(12),
        output => next_states(13)
    );

    -- Go to READ_MISS_DATA2
    READ_MISS_DATA2: and2 port map(
        input1 => not states(14),
        input2 => states(13),
        output => next_states(14)
    );

    -- Go to DATA2_WAIT
    DATA2_WAIT: and2 port map(
        input1 => not states(15),
        input2 => states(14),
        output => next_states(15)
    );

    -- Go to READ_MISS_DATA3
    READ_MISS_DATA3: and2 port map(
        input1 => not states(16),
        input2 => states(15),
        output => next_states(16)
    );

    -- Go to WAIT_READ_MISS
    WAIT_READ_MISS: and2 port map(
        input1 => not states(17),
        input2 => states(16),
        output => next_states(17)
    );
    
    -- WAIT
    READ_MISS_WAIT5: and2 port map(
        input1 => not states(18),
        input2 => states(17),
        output => next_states(18)
    );

    -- Go to READ_MISS_OUTPUT
    READ_MISS_OUTPUT: and2 port map(
        input1 => not states(19),
        input2 => states(18),
        output => next_states(19)
    );

    -- Whether tag should go to read done.
    move_tag_to_read_done: and4 port map(
        A => is_hit,
        B => states(1),
        C => rd_wr,
        D => not states(20),
        Y => go_to_read_done_1
    );

    -- Whether read_miss should go to read done.
    move_read_miss_output_to_done: and2 port map(
        input1 => states(19),
        input2 => not states(20),
        output => go_to_read_done_2
    );

    -- Go to READ_DONE
    READ_DONE: or2 port map(
        input1 => go_to_read_done_1,
        input2 => go_to_read_done_2,
        output => next_states(20)
    );

    -- Whether tag should go to write done
    move_tag_check_to_write_done: and4 port map(
        A => is_hit,
        B => not rd_wr,
        C => not states(21),
        D => states(1),
        Y => go_to_write_done_1
    );
    
    -- Whether write miss should go to write done.
    move_write_miss_to_write_done: and2 port map(
        input1 => not states(21),
        input2 => states(2),
        output => go_to_write_done_2
    );

    -- Whether tag should go to write done.
    -- Go to WRITE_DONE
    WRITE_DONE: or2 port map(
        input1 => go_to_write_done_1,
        input2 => go_to_write_done_2,
        output => next_states(21)
    );
    
end structural;