--
-- Entity: tri_buffer
-- Architecture: structural
-- Description: Lets read data in when READ_MISS_DATA0 state is reached.
--
library IEEE;
use IEEE.std_logic_1164.all;

entity tri_buffer is
    port(
        data_in  : in  std_logic_vector(7 downto 0);
        enable   : in  std_logic;
        data_out : out std_logic_vector(7 downto 0)
    );
end tri_buffer;

architecture structural of tri_buffer is
    component tx is                      
        port ( sel   : in std_logic;
                selnot: in std_logic;
                input : in std_logic;
                output:out std_logic
            );
    end component;
    
    component inverter is 
    	port (
        	input : in std_logic;
            output : out std_logic
        );
    end component;

    -- sel not
    signal inv_enable : std_logic;

begin
    inv_en: inverter port map(
        input  => enable,
        output => inv_enable
    );

    -- Sets data equal to passed in data if enable.
    let_data_in: for i in 0 to 7 generate
        data_in_i: tx port map(
            sel    => enable,
            selnot => inv_enable,
            input  => data_in(i),
            output => data_out(i)
        );
    end generate;

end architecture;
