--
-- Entity: set_curr_state
-- Architecture: structural
-- Description: Sets current state to next state at falling edge.
--

library STD;
library IEEE;
use IEEE.std_logic_1164.all;

entity set_curr_state is
    generic (
        RESET_VALUE : std_logic := '0'  
    );
    port(
        CLK           : in  std_logic;
        RESET         : in  std_logic;  
        next_state    : in std_logic;
        curr_state : out std_logic
    );
end set_curr_state;

architecture structural of set_curr_state is
    
    component dlatch is 
        port (
            d : in std_logic;
            clk : in std_logic;
            q : out std_logic;
            qbar: out std_logic
        );
    end component;
    
    component inverter is
        port(
            input  : in  std_logic;
            output : out std_logic
        );
    end component;
    
    component mux2to1 is  
        port (
            D0 : in  std_logic;
            D1 : in  std_logic;
            S  : in  std_logic;
            Y  : out std_logic
        );
    end component;
    
    signal clk_out1, clk_out2, inv_clk : std_logic;
    signal d_with_reset : std_logic;  
    signal reset_const : std_logic;   
    
begin
    -- Convert generic to signal
    reset_const <= RESET_VALUE;
    
    -- Mux to select between next_state and reset value
    reset_mux: mux2to1 port map(
        D0 => next_state,   -- Normal operation
        D1 => reset_const,  -- Reset value
        S  => RESET,        -- Select reset when high
        Y  => d_with_reset
    );
    
    inv: inverter port map(
        input  => CLK,
        output => inv_clk
    );
    
    -- Master latch
    dlatch1: dlatch port map(
        d    => d_with_reset,  
        clk  => CLK,
        q    => clk_out2,
        qbar => open
    );
    
    -- Slave latch
    dlatch2: dlatch port map(
        d    => clk_out2,
        clk  => inv_clk,
        q    => curr_state,
        qbar => open
    );
    
end structural;