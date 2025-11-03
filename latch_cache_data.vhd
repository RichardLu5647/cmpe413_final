--
-- Entity: latch_cache_data
-- Architecture: structural
-- Description: Sets cache data at falling edge when start is 1 and state is idle.
--
library IEEE;
use IEEE.std_logic_1164.all;

entity latch_cache_data is
    port(
    	CLK  		: in std_logic;
        data     : in  std_logic_vector(7 downto 0);
        enable      : in  std_logic;
        RESET       : in std_logic;
        data_out : out std_logic_vector(7 downto 0)
    );
end latch_cache_data;

architecture structural of latch_cache_data is
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
    signal data_at : std_logic_vector(7 downto 0);

begin

    -- Sets new data if enable is high, else it stays same.
    if_enable: for i in 0 to 7 generate
        enable_mux: mux2to1 port map(
            D0 => data_out(i),  -- hold old value when ENABLE is low.
            D1 => data(i),      
            S  => enable,    
            Y  => data_at(i)
        );
    end generate;

    -- Sets the data.
    set_data: for i in 0 to 7 generate
        set_data: latch_at_negedge port map(
            CLK             => CLK,
            RESET           => RESET,
            CD_or_CA        => data_at(i),
            cache_data_addr => data_out(i)
        );
    end generate;

end architecture;



