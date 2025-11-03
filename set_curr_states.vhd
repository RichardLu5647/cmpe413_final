--
-- Entity: set_curr_states
-- Architecture: structural
-- Description: Sets all the states to their next state at falling edge.
--

library STD;
library IEEE;
use IEEE.std_logic_1164.all;

entity set_curr_states is
    port(
        CLK           : in  std_logic;
        RESET         : in  std_logic;  
        next_state    : in std_logic_vector (21 downto 0);
        curr_state : out std_logic_vector (21 downto 0)
    );
end set_curr_states;

architecture structural of set_curr_states is
    
    component set_curr_state is
    generic(
    	RESET_VALUE : std_logic := '0'
    );
    port(
        CLK           : in  std_logic;
        RESET		  : in std_logic;
        next_state    : in std_logic;
        curr_state : out std_logic
    );
    end component;  
    
begin

    -- Sets the IDLE state.
    state0: set_curr_state 
    generic map (RESET_VALUE => '1')
    port map(
        CLK => CLK,
        RESET => RESET,
        next_state => next_state(0),
        curr_state => curr_state(0)
    );

    -- Sets the other current states to next states at falling edges.
    set_1_to_21: for i in 1 to 21 generate
        state_i: set_curr_state port map(
        CLK => CLK,
        RESET => RESET,
        next_state => next_state(i),
        curr_state => curr_state(i)
    );
    end generate;
    
end structural;