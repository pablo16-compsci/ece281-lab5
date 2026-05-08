--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


entity top_basys3 is
    port(
        -- inputs
        clk     :   in std_logic; -- native 100MHz FPGA clock
        sw      :   in std_logic_vector(7 downto 0); -- operands and opcode
        btnU    :   in std_logic; -- reset
        btnC    :   in std_logic; -- fsm cycle
        btnL : in  std_logic;
        -- outputs
        led :   out std_logic_vector(15 downto 0);
        -- 7-segment display segments (active-low cathodes)
        seg :   out std_logic_vector(6 downto 0);
        -- 7-segment display active-low enables (anodes)
        an  :   out std_logic_vector(3 downto 0)
    );
end top_basys3;

architecture top_basys3_arch of top_basys3 is 
	component controller_fsm is
        port (
            i_reset : in  std_logic;
            i_adv   : in  std_logic;
            o_cycle : out std_logic_vector(3 downto 0)
        );
    end component;
    component ALU is
        port (
            i_A      : in  std_logic_vector(7 downto 0);
            i_B      : in  std_logic_vector(7 downto 0);
            i_op     : in  std_logic_vector(2 downto 0);
            o_result : out std_logic_vector(7 downto 0);
            o_flags  : out std_logic_vector(3 downto 0)
        );
    end component;
    component twos_comp is
        port (
            i_bin  : in  std_logic_vector(7 downto 0);
            o_sign : out std_logic;
            o_hund : out std_logic_vector(3 downto 0);
            o_tens : out std_logic_vector(3 downto 0);
            o_ones : out std_logic_vector(3 downto 0)
        );
    end component;
    component TDM4 is
        generic (
            constant k_WIDTH : natural := 4
        );
        port (
            i_clk   : in  std_logic;
            i_reset : in  std_logic;
            i_D3    : in  std_logic_vector(k_WIDTH - 1 downto 0);
            i_D2    : in  std_logic_vector(k_WIDTH - 1 downto 0);
            i_D1    : in  std_logic_vector(k_WIDTH - 1 downto 0);
            i_D0    : in  std_logic_vector(k_WIDTH - 1 downto 0);
            o_data  : out std_logic_vector(k_WIDTH - 1 downto 0);
            o_sel   : out std_logic_vector(3 downto 0)
        );
    end component;
    component sevenseg_decoder is
        port (
            i_Hex   : in  std_logic_vector(3 downto 0);
            o_seg_n : out std_logic_vector(6 downto 0)
        );
    end component;
    component clock_divider is
        generic (
            constant k_DIV : natural := 2
        );
        port (
            i_clk   : in  std_logic;
            i_reset : in  std_logic;
            o_clk   : out std_logic
        );
    end component;
    component button_debounce is
        port (
            clk    : in  std_logic;
            reset  : in  std_logic;
            button : in  std_logic;
            action : out std_logic
        );
    end component;
    signal w_btnC_clean  : std_logic;
    signal w_cycle       : std_logic_vector(3 downto 0);
    signal r_cycle_prev  : std_logic_vector(3 downto 0) := "0001";
    signal r_A           : std_logic_vector(7 downto 0) := (others => '0');
    signal r_B           : std_logic_vector(7 downto 0) := (others => '0');
    signal w_alu_result  : std_logic_vector(7 downto 0);
    signal w_alu_flags   : std_logic_vector(3 downto 0);
    signal w_display_bin : std_logic_vector(7 downto 0);
    signal w_sign        : std_logic;
    signal w_hund        : std_logic_vector(3 downto 0);
    signal w_tens        : std_logic_vector(3 downto 0);
    signal w_ones        : std_logic_vector(3 downto 0);
    signal w_tdm_clk     : std_logic;
    signal w_tdm_data    : std_logic_vector(3 downto 0);
    signal w_tdm_sel     : std_logic_vector(3 downto 0);
    signal w_seg_decoded : std_logic_vector(6 downto 0);
    constant C_BLANK : std_logic_vector(6 downto 0) := "1111111";
    constant C_MINUS : std_logic_vector(6 downto 0) := "0111111";

  
begin
	debounce_btnC : button_debounce
        port map (
            clk    => clk,
            reset  => btnU,
            button => btnC,
            action => w_btnC_clean
        );
    controller_inst : controller_fsm
        port map (
            i_reset => btnU,
            i_adv   => w_btnC_clean,
            o_cycle => w_cycle
        );
     process(clk)
    begin
        if rising_edge(clk) then
            if btnU = '1' then
                r_A          <= (others => '0');
                r_B          <= (others => '0');
                r_cycle_prev <= "0001";
            else
                r_cycle_prev <= w_cycle;

                if w_cycle(1) = '1' and r_cycle_prev(1) = '0' then
                    r_A <= sw;
                end if;

                if w_cycle(2) = '1' and r_cycle_prev(2) = '0' then
                    r_B <= sw;
                end if;
            end if;
        end if;
    end process;
    alu_inst : ALU
        port map (
            i_A      => r_A,
            i_B      => r_B,
            i_op     => sw(2 downto 0),
            o_result => w_alu_result,
            o_flags  => w_alu_flags
        );
    with w_cycle select
        w_display_bin <= (others => '0') when "0001",
                         r_A             when "0010",
                         r_B             when "0100",
                         w_alu_result    when "1000",
                         (others => '0') when others;
    twos_comp_inst : twos_comp
        port map (
            i_bin  => w_display_bin,
            o_sign => w_sign,
            o_hund => w_hund,
            o_tens => w_tens,
            o_ones => w_ones
        );
    clk_div_inst : clock_divider
        generic map (
            k_DIV => 50000
        )
        port map (
            i_clk   => clk,
            i_reset => btnL,
            o_clk   => w_tdm_clk
        );
    tdm_inst : TDM4
        generic map (
            k_WIDTH => 4
        )
        port map (
            i_clk   => w_tdm_clk,
            i_reset => btnL,
            i_D3    => "0000",
            i_D2    => w_hund,
            i_D1    => w_tens,
            i_D0    => w_ones,
            o_data  => w_tdm_data,
            o_sel   => w_tdm_sel
        );
     sevenseg_inst : sevenseg_decoder
        port map (
            i_Hex   => w_tdm_data,
            o_seg_n => w_seg_decoded
        );
    an <= "1111" when w_cycle(0) = '1' else
          w_tdm_sel;

    seg <= C_BLANK when w_cycle(0) = '1' else
           C_MINUS when w_tdm_sel = "0111" and w_sign = '1' else
           C_BLANK when w_tdm_sel = "0111" and w_sign = '0' else
           w_seg_decoded;
    led(3 downto 0)   <= w_cycle;
    led(15 downto 12) <= w_alu_flags;
    led(11 downto 4)  <= (others => '0');

	
	
	
end top_basys3_arch;
