--
-- Entity: latch_cache_address
-- Architecture: structural
-- Description: Sets cache address at falling edge when start is 1 and state is idle.
--
library IEEE;
use IEEE.std_logic_1164.all;

entity latch_cache_address is
    port(
    	CLK  		: in std_logic;
        address     : in  std_logic_vector(5 downto 0);
        enable      : in  std_logic;
        RESET       : in std_logic;
        address_out : out std_logic_vector(5 downto 0)
    );
end latch_cache_address;

architecture structural of latch_cache_address is
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
    
    -- Stores the address to be inputted based on enables.
    signal address_at : std_logic_vector(5 downto 0);

begin

    -- Sets new data if enable is high, else it stays same.
    if_enable: for i in 0 to 5 generate
        enable_mux: mux2to1 port map(
            D0 => address_out(i),  -- hold old value when ENABLE is low.
            D1 => address(i),      
            S  => enable,    
            Y  => address_at(i)
        );
    end generate;

    -- Sets the address.
    set_address: for i in 0 to 5 generate
        set_addr: latch_at_negedge port map(
            CLK             => CLK,
            RESET           => RESET,
            CD_or_CA        => address_at(i),
            cache_data_addr => address_out(i)
        );
    end generate;

end architecture;



