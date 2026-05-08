----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2025 02:50:18 PM
-- Design Name: 
-- Module Name: ALU - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU is
    Port ( i_A : in STD_LOGIC_VECTOR (7 downto 0);
           i_B : in STD_LOGIC_VECTOR (7 downto 0);
           i_op : in STD_LOGIC_VECTOR (2 downto 0);
           o_result : out STD_LOGIC_VECTOR (7 downto 0);
           o_flags : out STD_LOGIC_VECTOR (3 downto 0));
end ALU;

architecture Behavioral of ALU is
    signal w_result : STD_LOGIC_VECTOR(7 downto 0);
    signal w_add_u9 : unsigned(8 downto 0);
    signal w_sub_u9 : unsigned(8 downto 0);
    signal w_N : STD_LOGIC;
    signal w_Z : STD_LOGIC;
    signal w_C : STD_LOGIC;
    signal w_V : STD_LOGIC;
begin
    w_add_u9 <= resize(unsigned(i_A), 9) + resize(unsigned(i_B), 9);
    w_sub_u9 <= resize(unsigned(i_A), 9) +
                resize(unsigned(not i_B), 9) +
                to_unsigned(1, 9);
    process(i_A, i_B, i_op, w_add_u9, w_sub_u9)
    begin
        case i_op is
            when "000" =>
                w_result <= std_logic_vector(w_add_u9(7 downto 0));
            when "001" =>
                w_result <= std_logic_vector(w_sub_u9(7 downto 0));
            when "010" =>
                w_result <= i_A and i_B;
            when "011" =>
                w_result <= i_A or i_B;
            when others =>
                w_result <= (others => '0');
        end case;
    end process;
    o_result <= w_result;
    w_N <= w_result(7);
    w_Z <= '1' when w_result = x"00" else '0';
    w_C <= w_add_u9(8) when i_op = "000" else
           w_sub_u9(8) when i_op = "001" else
           '0';
    w_V <= '1' when i_op = "000" and i_A(7) = i_B(7) and w_result(7) /= i_A(7) else
           '1' when i_op = "001" and i_A(7) /= i_B(7) and w_result(7) /= i_A(7) else
           '0';
    o_flags <= w_N & w_Z & w_C & w_V;
end Behavioral;
