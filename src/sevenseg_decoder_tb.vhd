----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/01/2026 10:36:41 PM
-- Design Name: 
-- Module Name: sevenseg_decoder_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity sevenseg_decoder_tb is

end sevenseg_decoder_tb;

architecture Behavioral of sevenseg_decoder_tb is
    component sevenseg_decoder is
        port(
            i_Hex : in std_logic_vector(3 downto 0);
            o_seg_n : out std_logic_vector(6 downto 0)
        );
     end component;
     signal w_hex : std_logic_vector(3 downto 0);
     signal w_seg_n : std_logic_vector(6 downto 0);

begin
    sevenseg_decoder_ins : sevenseg_decoder
        port map(
            i_Hex => w_hex,
            o_seg_n => w_seg_n
            );
            
    test_process : process
    begin
        w_hex <= x"0"; wait for 10 ns;
        assert (w_seg_n = "1000000") report "error with 0" severity failure;
        w_hex <= x"1"; wait for 10 ns;
        assert (w_seg_n = "1111001") report "error with 1" severity failure;
        w_hex <= x"2"; wait for 10 ns;
        assert (w_seg_n = "0100100") report "error with 2" severity failure;
        w_hex <= x"3"; wait for 10 ns;
        assert (w_seg_n = "0110000") report "error with 3" severity failure;
        w_hex <= x"4"; wait for 10 ns;
        assert (w_seg_n = "0011001") report "error with 4" severity failure;
        w_hex <= x"5"; wait for 10 ns;
        assert (w_seg_n = "0010010") report "error with 5" severity failure;
        w_hex <= x"6"; wait for 10 ns;
        assert (w_seg_n = "0000010") report "error with 6" severity failure;
        w_hex <= x"7"; wait for 10 ns;
        assert (w_seg_n = "1111000") report "error with 7" severity failure;
        w_hex <= x"8"; wait for 10 ns;
        assert (w_seg_n = "0000000") report "error with 8" severity failure;
        w_hex <= x"9"; wait for 10 ns;
        assert (w_seg_n = "0011000") report "error with 9" severity failure;
        w_hex <= x"A"; wait for 10 ns;
        assert (w_seg_n = "0001000") report "error with A" severity failure;
        w_hex <= x"B"; wait for 10 ns;
        assert (w_seg_n = "0000011") report "error with B" severity failure;
        w_hex <= x"C"; wait for 10 ns;
        assert (w_seg_n = "0100111") report "error with C" severity failure;
        w_hex <= x"D"; wait for 10 ns;
        assert (w_seg_n = "0100001") report "error with D" severity failure;
        w_hex <= x"E"; wait for 10 ns;
        assert (w_seg_n = "0000110") report "error with E" severity failure;
        w_hex <= x"F"; wait for 10 ns;
        assert (w_seg_n = "0001110") report "error with F" severity failure;
        report "sevenseg_decoder_tb: all passed" severity note;
        wait;
        end process;
end Behavioral;
