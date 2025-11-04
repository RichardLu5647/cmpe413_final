--
-- Entity: latch_rd_wr
-- Architecture: structural
-- Description: Sets rd_wr data at falling edge when start is 1 and state is idle.
--
library IEEE;
use IEEE.std_logic_1164.all;

entity latch_rd_wr is
    port(
    	CLK  		: in std_logic;
        rd_wr     : in  std_logic;
        enable      : in  std_logic;
        RESET       : in std_logic;
        rd_wr_out : out std_logic
    );
end latch_rd_wr;

architecture structural of latch_rd_wr is
    component latch_at_negedge is
        port(
            CLK             : in  std_logic;
            RESET           : in  std_logic;  
            CD_or_CA        : in std_logic;
            cache_data_addr : out std_logic
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
    
    -- Stores the data to be inputted based on enables.
    signal rd_wr_at : std_logic;
    signal temp_rd_wr : std_logic;

begin

    -- Sets new rd_wr if enable is high, else it stays same.
    enable_mux: mux2to1 port map(
        D0 => temp_rd_wr,  -- hold old value when ENABLE is low.
        D1 => rd_wr,      
        S  => enable,    
        Y  => rd_wr_at
    );

    -- Sets the rd_wr.
    set_data: latch_at_negedge port map(
        CLK             => CLK,
        RESET           => RESET,
        CD_or_CA        => rd_wr_at,
        cache_data_addr => temp_rd_wr
    );

    rd_wr_out <= temp_rd_wr;

end architecture;