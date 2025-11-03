--
-- Entity: select_write_data
-- Architecture: structural
-- Description: Sets the write data based on fsm state.
--

library IEEE;
use IEEE.std_logic_1164.all;

entity select_write_data is
    port(
        latched_data : in std_logic_vector(7 downto 0);   -- Input 0
        memory_data: in std_logic_vector(7 downto 0);   -- Input 1
        S  : in std_logic;   -- Select (0=D0, 1=D1)
        Y  : out std_logic_vector(7 downto 0)   -- Output
    );
end select_write_data;

architecture structural of select_write_data is

    component mux2to1 is  
        port (
            D0 : in  std_logic;
            D1 : in  std_logic;
            S  : in  std_logic;
            Y  : out std_logic
        );
    end component;
    
begin

    -- Sets the write_data equal to memory or cache data depending on fsm state.
    if_enable: for i in 0 to 7 generate
        enable_mux: mux2to1 port map(
            D0 => latched_data(i),
            D1 => memory_data(i),      
            S  => S,    
            Y  => Y(i)
        );
    end generate;
    
end structural;