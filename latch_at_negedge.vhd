--
-- Entity: latch_at_negedge
-- Architecture: structural
-- Description: Flip flip that latches at negedge.
--
library STD;
library IEEE;
use IEEE.std_logic_1164.all;

entity latch_at_negedge is
    port(
        CLK             : in  std_logic;
        RESET           : in  std_logic;  
        CD_or_CA        : in std_logic;
        cache_data_addr : out std_logic
    );
end latch_at_negedge;

architecture structural of latch_at_negedge is
    
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
    
    -- Outputs from dlatches
    signal master_out, slave_out : std_logic;
    -- Inverted clk
    signal inv_clk : std_logic;
    -- Either 0 or data passed in.
    signal data : std_logic;   
    
begin
    
    -- Data becomes 0 when RESET is high otherwise its data passed in.
    reset_mux: mux2to1 port map(
        D0 => CD_or_CA,   
        D1 => '0',            
        S  => RESET,        
        Y  => data
    );
    
    inv: inverter port map(
        input  => CLK,
        output => inv_clk
    );
    
    -- Master latch
    dlatch1: dlatch port map(
        d    => data,  
        clk  => CLK,
        q    => master_out,
        qbar => open
    );
    
    -- Slave latch, data is set at falling edge.
    dlatch2: dlatch port map(
        d    => master_out,
        clk  => inv_clk,
        q    => cache_data_addr,
        qbar => open
    );
    
end structural;