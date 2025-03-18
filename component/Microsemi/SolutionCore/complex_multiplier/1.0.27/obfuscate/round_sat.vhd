library ieee;
use ieee.std_logic_1164.all;
use Ieee.numeric_std.all;
entity round_SAT is
generic (g_UNRND_DATA_WIdth: POSITIVE := 33;
G_RND_DATA_WIDTH: POSITIVE := 16;
g_unRND_FRACT_BITS: POSITIVE := 30;
g_rnd_fract_biTS: POSITIVE := 15); port (clock_i: in std_LOGIC;
nRESET_I: in STD_LOGIC;
data_i: in std_LOGIC_VECTOR(g_unrnd_datA_WIDTH-1 downto 0);
DATA_O: out STD_LOGIC_vector(G_RND_DATA_WIDTH-1 downto 0));
end ROUND_SAT;

architecture O of round_sAT is

constant o1l: STD_LOGIC_VECTor(g_rnd_fract_bITS-1 downto 0) := ( others => '1');

constant l1l: STD_LOGIC_VECTOR(G_RND_fract_bits-1 downto 0) := ( others => '0');

constant I1l: std_logic_vector(G_UNRND_FRACT_BITS-G_RND_FRAct_bits-2 downto 0) := ( others => '0');

signal ooi: STD_LOGIc;

signal loi: STD_LOGIC;

signal IOI: Std_logic;

signal OLI: STD_LOGIC;

begin
loi <= data_i(G_UNRND_data_width-1);
OLi <= '0' when (data_i(G_Unrnd_fract_bits-g_rND_FRACT_BITS-2 downto 0) = i1L and LOI = '1') else
(data_i(g_unrnd_fract_bits-g_rnd_fract_bits-1));
ooI <= '1' when (((LOI&data_i(g_unrnd_fract_BITS-1 downto g_uNRND_FRACT_BITS-g_rnD_FRACT_BITS)) = ('0'&O1l)) or ioi = '1') else
'0';
IOI <= '0';
LLI:
process (NRESET_I,clock_i)
begin
if (nreset_i = '0') then
data_o <= ( others => '0');
elsif (RISING_EDGE(CLOCK_I)) then
if (OOI = '1') then
if (LOI = '0') then
data_o <= '0'&o1l;
else
DATA_O <= '1'&L1L;
end if;
else
data_o <= std_logic_vector(SIGNED(data_i(g_unrnd_fRACT_BITS downto G_UNRNd_fract_bits-g_rnd_fract_bits))+signeD(l1l&OLI));
end if;
end if;
end process LLI;
end o;
