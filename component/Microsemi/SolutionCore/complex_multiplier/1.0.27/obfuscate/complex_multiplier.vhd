library Ieee;
use IEEE.std_logic_1164.all;
use ieee.NUMERIC_STD.all;
use IEEE.sTD_LOGIC_SIGNED.all;
entity COMPLEX_MULTIPLIER is
generic (G_AWIDTH: INTEGER := 16;
G_BWIDTH: integer := 16;
G_3DSP: INTEGER := 1;
G_DOROUND: inTEGER := 0;
g_cwidth: INTEGER := 33); port (clock_i: in std_logic;
nreSET_I: in std_logic;
AREAL_I: in STD_LOgic_vector(g_aWIDTH-1 downto 0);
aimag_i: in STD_logic_vector(G_AWIDTH-1 downto 0);
BREAL_I: in std_logic_vector(G_BWIDTH-1 downto 0);
BIMAG_I: in std_logic_vector(G_BWIDth-1 downto 0);
creal_o: out STD_LOGIC_Vector(g_cwidth-1 downto 0);
cimag_o: out STD_LOGIC_vector(G_cwidth-1 downto 0));
end complex_multiPLIER;

architecture O of COMplex_multiplier is

constant l: std_logic_vector(47 downto 0) := ( others => '0');

constant I: std_LOGIC_VECTOR(17 downto 0) := ( others => '0');

signal ol: std_logic_vector(47 downto 0);

signal LL: std_logic_vECTOR(47 downto 0);

signal IL: std_logic_vector(g_awidth+g_bwidth downto 0);

signal OI: Std_logic_vector(g_awidth+G_BWIDTH downto 0);

signal Li: std_logIC_VECTOR(G_CWIDTH-1 downto 0);

signal ii: STD_LOgic_vector(G_CWIDTH-1 downto 0);

signal O0: std_logiC_VECTOR(47 downto 0);

signal L0: std_logic_VECTOR(47 downto 0);

signal I0: std_logic_vector(17 downto 0);

signal O1: std_lOGIC_VECTOR(17 downto 0);

signal l1: STD_LOGIC_vector(17 downto 0);

signal I1: std_logic_vector(17 downto 0);

signal OOL: STD_LOGIC_VECTOR(17 downto 0);

signal lol: STD_LOGIC_VECTOR(17 downto 0);

signal IOL: std_logic_vector(17 downto 0);

signal OLL: std_logic_vector(17 downto 0);

signal lll: STD_LOGIC_vector(17 downto 0);

signal ILL: STD_LOGIC_VECTOR(17 downto 0);

signal OIl: std_logic_VECTOR(17 downto 0);

signal lil: STD_LOGIc_vector(17 downto 0);

component macC_PA
port (A: in STD_LOGIC_vector(17 downto 0);
al_n: in std_logIC;
ARSHFT17: in STD_LOGIC;
arshft17_ad_n: in STd_logic;
arshft17_bypass: in std_logic;
arshft17_en: in std_logic;
arsHFT17_SD_N: in std_logic;
arshft17_SL_N: in std_logic;
a_bypass: in Std_logic;
a_en: in STD_logic;
a_srst_n: in STD_LOGIC;
b: in STD_logic_vector(17 downto 0);
B_BYPASS: in STD_LOGIc;
B_en: in STD_LOGIC;
B_SRST_N: in std_LOGIC;
C: in std_logic_vector(47 downto 0);
carRYIN: in STD_LOGIC;
CDIN: in std_logic_vecTOR(47 downto 0);
Cdin_fdbk_sel: in std_logic_vector(1 downto 0);
cdin_fdbk_sel_aD_N: in std_logic_vECTOR(1 downto 0);
cdin_fdbk_sel_bypASS: in STD_Logic;
cdin_fdbK_SEL_EN: in STD_LOGIC;
CDIN_FDBK_SEL_SD_N: in STD_logic_vector(1 downto 0);
cdin_fdbk_sel_sl_n: in STD_LOGIC;
clk: in std_logic;
c_arst_n: in STD_logic;
C_BYPASS: in std_logic;
c_en: in sTD_LOGIC;
C_SRST_N: in STD_LOGIC;
d: in std_logic_vector(17 downto 0);
Dotp: in std_logic;
d_arst_n: in std_loGIC;
D_BYPASS: in STD_LOgic;
D_EN: in std_logic;
D_SRST_N: in std_logic;
OVFL_CARRYOUT_sel: in std_logic;
pasub: in std_logic;
PASUB_AD_N: in STD_LOGIc;
pasub_bypass: in STD_LOGIC;
PASUB_en: in STD_LOGIC;
PASUB_SD_N: in STD_LOGIC;
pasub_sl_n: in std_logic;
p_bypasS: in STD_LOGIC;
p_en: in std_logic;
P_SRst_n: in STD_Logic;
SIMD: in STD_LOGIC;
sub: in stD_LOGIC;
SUB_AD_N: in STD_LOGIC;
sub_bypass: in std_logic;
SUB_EN: in std_logic;
SUB_SD_N: in STD_logic;
sub_sl_n: in std_logic;
CDout: out Std_logic_vector(47 downto 0);
ovfl_carryout: out STD_LOGIC;
p: out std_logic_vector(47 downto 0));
end component;

component round_sat
generic (g_unrnd_DATA_WIDTH: positive := 33;
g_rnd_datA_WIDTH: positIVE := 16;
g_unrnd_fract_bits: positive := 30;
G_RND_FRACT_BITS: positive := 15);
port (CLOCk_i: in std_logic;
nreset_i: in std_lOGIC;
dATA_I: in std_logic_vector(G_UNRND_data_width-1 downto 0);
DATA_o: out STD_LOGIC_VECTOR(g_RND_DATA_WIDTH-1 downto 0));
end component round_sat;

begin
i0 <= STD_LOGIC_VECTor(RESIZE(signed(areal_i),
18));
I1 <= STD_LOGIC_VECTOR(resiZE(sigNED(Aimag_i),
18));
iol <= STD_LOGIC_VECTOR(RESIZE(signed(breal_i),
18));
ill <= Std_logic_vector(RESIZE(SIGNED(BIMAG_I),
18));
iil:
process (nreset_i,CLOCK_I)
begin
if (nreset_i = '0') then
O1 <= ( others => '0');
OOL <= ( others => '0');
olL <= ( others => '0');
oil <= ( others => '0');
elsif (RISING_EDGE(clock_i)) then
O1 <= I0;
OOL <= i1;
oll <= iol;
OIL <= ill;
end if;
end process iil;
O0L:
if (G_3DSP = 1)
generate
L0L:
process (nreSET_I,clock_i)
begin
if (nreset_i = '0') then
l1 <= ( others => '0');
lol <= ( others => '0');
lll <= ( others => '0');
lil <= ( others => '0');
elsif (rising_edge(clock_i)) then
l1 <= o1;
LOL <= ool;
LLL <= oll;
LIL <= oil;
end if;
end process l0l;
macc_pa_0: macc_pa
port map (A => I0,
al_n => '1',
arshft17 => '0',
ARSHFT17_Ad_n => '1',
ARSHFT17_BYPASS => '1',
arshft17_en => '0',
arshft17_sd_n => '1',
arshft17_sl_n => '1',
a_bypass => '0',
A_EN => '1',
A_SRSt_n => NRESET_i,
b => iol,
b_bypass => '0',
b_en => '1',
B_srst_n => nrESET_I,
C => l,
CARRYIN => '0',
CDIN => l,
cdin_fdbk_sel => "00",
CDIN_FDBK_SEL_AD_n => "11",
cdin_fdbk_sel_bypasS => '0',
cdin_fDBK_SEL_EN => '1',
cdin_fdbk_sel_sd_N => "11",
CDIN_FDBK_SEL_SL_n => '1',
clk => clock_i,
C_ARST_N => nreset_i,
c_byPASS => '0',
C_EN => '1',
C_SRST_N => nresET_I,
D => ILL,
DOTP => '0',
D_arst_n => '1',
d_bypass => '0',
d_en => '1',
d_srst_n => NRESET_I,
OVFl_carryout_sel => '0',
PASUB => '0',
PASUB_AD_N => '1',
PASUB_bypass => '0',
PASUB_EN => '1',
PASUB_SD_N => '1',
pasub_sl_n => '1',
P_BYPASS => '0',
P_EN => '1',
P_SRST_N => NRESET_I,
SIMD => '0',
SUB => '0',
SUB_AD_N => '1',
sub_byPASS => '0',
sub_en => '1',
sub_sd_n => '1',
sub_sl_n => '1',
cdout => open ,
OVFL_carryout => open ,
p => o0);
macc_pa_1: MACC_PA
port map (A => LIL,
AL_N => '1',
arshft17 => '0',
ARSHFT17_AD_N => '1',
arshft17_bypass => '1',
ARSHFT17_EN => '0',
ARSHFT17_SD_N => '1',
arshft17_sl_n => '1',
a_bYPASS => '0',
A_EN => '1',
A_Srst_n => nreset_i,
b => LOL,
B_BYPASS => '0',
b_en => '1',
B_SRST_N => NRESET_I,
C => O0,
CARRYIN => '0',
cdin => L,
CDIN_FDBK_SEL => "00",
CDIN_FDBK_SEL_ad_n => "11",
cdin_fdbk_sel_bypasS => '0',
CDIN_FDBK_SEL_EN => '1',
CDIN_FDBK_SEL_SD_N => "11",
cdin_FDBK_SEL_SL_N => '1',
CLK => CLOCK_I,
c_ARST_N => nreset_i,
C_BYPASS => '0',
C_EN => '1',
C_SRST_N => NReset_i,
D => L1,
dotp => '0',
D_ARSt_n => '1',
d_bypass => '0',
D_EN => '1',
d_srST_N => NRESET_i,
ovfl_CARRYOUT_SEL => '0',
PASUB => '0',
PASUB_ad_n => '1',
PASUB_BYPASS => '0',
PASUB_EN => '1',
PASUB_SD_N => '1',
PASUB_SL_n => '1',
p_bypass => '0',
p_en => '1',
p_srst_n => nreset_i,
simd => '0',
sub => '1',
sub_ad_n => '1',
sub_bypass => '0',
sub_EN => '1',
sub_sd_n => '1',
SUB_SL_N => '1',
cdouT => open ,
OVFL_carryout => open ,
p => ol);
macc_pa_2: macc_pa
port map (a => LLL,
AL_N => '1',
ARSHFT17 => '0',
arshft17_ad_N => '1',
ARSHFT17_BYPASs => '1',
ARSHFT17_EN => '0',
Arshft17_sd_n => '1',
ARSHFT17_SL_N => '1',
a_bypass => '0',
a_en => '1',
A_SRST_N => nreset_i,
b => LOL,
B_BYPASS => '0',
B_EN => '1',
B_srst_n => NRESET_I,
C => o0,
carryin => '0',
cdin => L,
CDIN_FDBK_SEL => "00",
CDIN_FDBK_SEL_ad_n => "11",
cdin_fdbk_sel_bypass => '0',
cdin_fdbk_sel_en => '1',
CDIN_FDbk_sel_sd_n => "11",
CDIN_FDBK_sel_sl_n => '1',
clk => CLOCK_I,
C_ARST_n => NRESET_I,
C_BYPASS => '0',
C_EN => '1',
C_srst_n => NRESET_I,
D => L1,
dotp => '0',
D_ARST_n => '1',
d_bypass => '0',
d_en => '1',
d_srst_n => nreset_i,
OVFL_CARRYOUT_Sel => '0',
pasub => '1',
PASUB_AD_N => '1',
PASUB_BYPASS => '0',
PASUB_En => '1',
pasub_sd_n => '1',
pasub_sl_n => '1',
p_BYPASS => '0',
P_EN => '1',
p_srst_n => nreset_i,
simd => '0',
sub => '0',
sub_ad_n => '1',
SUB_BYPASS => '0',
SUB_EN => '1',
sub_sd_n => '1',
SUB_SL_n => '1',
CDOUT => open ,
ovfl_carryout => open ,
P => LL);
IL <= Std_logic_vector(resize(signed(ol),
G_awidth+G_BWIDTH+1));
oi <= STD_Logic_vector(RESIze(siGNED(ll),
g_awidth+G_BWIDTH+1));
end generate;
i0l:
if (G_3DSP = 0)
generate
macC_PA_0: macc_pa
port map (a => I0,
AL_N => '1',
ARSHFt17 => '0',
arshft17_ad_n => '1',
arshft17_bypass => '0',
arshfT17_EN => '1',
arshft17_sd_n => '1',
ARSHFT17_SL_N => '1',
a_bypass => '0',
A_EN => '1',
a_srst_n => NRESET_I,
B => IOL,
B_BYPASS => '0',
b_en => '1',
b_srst_n => NRESET_i,
c => L,
carrYIN => '0',
cdin => L,
cdin_fdbk_sel => "00",
CDIN_Fdbk_sel_ad_n => "11",
cdin_fdbk_SEL_BYPASS => '0',
CDIN_FDBK_SEL_en => '1',
CDIN_FDbk_sel_sd_n => "11",
CDIN_FDBk_sel_sl_n => '1',
Clk => cloCK_I,
c_arst_n => '1',
c_bypass => '0',
c_en => '1',
c_srst_n => nreset_i,
d => I,
DOTP => '0',
d_arst_n => '1',
d_bypass => '0',
d_en => '1',
D_srst_n => nreSET_I,
OVFL_CArryout_sel => '0',
pasub => '0',
pasub_ad_n => '1',
pasub_bypass => '0',
PASUB_EN => '1',
PASUB_sd_n => '1',
pasub_sl_n => '1',
p_bypass => '0',
p_en => '1',
p_srst_n => NRESET_I,
SIMD => '0',
SUB => '0',
sub_ad_N => '1',
SUB_BYPASS => '0',
sub_en => '1',
sub_sd_N => '1',
sub_sl_n => '1',
CDOUT => O0,
ovfl_carryout => open ,
p => open );
macc_pa_1: macc_pa
port map (a => ool,
al_n => '1',
arSHFT17 => '0',
arshft17_ad_n => '1',
ARSHFT17_bypass => '0',
ARSHFT17_EN => '1',
arshft17_sd_n => '1',
arshft17_sl_n => '1',
a_bypass => '0',
a_eN => '1',
A_SRST_N => NREset_i,
b => oil,
b_bypass => '0',
b_en => '1',
b_srst_n => NRESET_I,
C => L,
carryin => '0',
CDIN => o0,
cdIN_FDBK_SEL => "11",
CDIN_FDBK_SEL_ad_n => "11",
cdin_FDBK_SEL_BYPASS => '0',
cdin_fdbk_sel_en => '1',
cdin_fdBK_SEL_SD_N => "11",
cdin_fdbk_sel_SL_N => '1',
clk => clOCK_I,
C_ARST_N => '1',
C_BYPASS => '0',
c_en => '1',
c_srst_N => nreset_I,
D => I,
DOTP => '0',
D_ARST_N => '1',
D_BYPASs => '0',
D_EN => '1',
D_SRST_N => nreset_i,
ovfl_carryOUT_SEL => '0',
pasub => '0',
pasub_ad_n => '1',
pasub_bypass => '0',
PASub_en => '1',
PASUB_SD_N => '1',
pasub_sl_n => '1',
p_bypass => '0',
P_EN => '1',
p_srst_n => nreset_i,
simd => '0',
SUB => '1',
SUB_AD_N => '1',
sub_bypass => '0',
sub_en => '1',
sub_sd_n => '1',
SUB_SL_N => '1',
CDOUT => open ,
OVFl_carryout => open ,
p => ol);
macc_pa_2: macc_pa
port map (a => i0,
al_n => '1',
arshft17 => '0',
arshft17_ad_n => '1',
arshFT17_BYPASS => '0',
ARSHFT17_EN => '1',
arshft17_sd_n => '1',
ARSHFt17_sl_n => '1',
a_bypass => '0',
a_en => '1',
a_srST_N => NRESET_I,
B => ILL,
B_BYPASS => '0',
B_EN => '1',
b_SRST_N => NRESEt_i,
c => L,
CARRYIN => '0',
CDIN => l,
CDIN_FDBK_sel => "00",
cdiN_FDBK_SEL_AD_N => "11",
cdin_fdbk_sel_bypass => '0',
CDIN_FDBK_SEL_EN => '1',
Cdin_fdbk_sel_sd_n => "11",
cdin_fdbk_seL_SL_N => '1',
clK => CLOCK_i,
c_arst_N => '1',
c_bYPASS => '0',
C_EN => '1',
C_SRST_N => nreset_i,
D => i,
dotp => '0',
d_arst_n => '1',
D_BYPASS => '0',
d_en => '1',
d_srst_N => NRESEt_i,
ovfL_CARRYOUT_SEL => '0',
PASUB => '0',
pasub_ad_n => '1',
PASUB_BYPASS => '0',
pasub_en => '1',
PASUB_SD_N => '1',
PASUB_SL_N => '1',
P_BYPASS => '0',
P_EN => '1',
p_sRST_N => NRESET_I,
SIMD => '0',
SUB => '0',
SUB_AD_N => '1',
SUB_BYPASS => '0',
SUB_EN => '1',
SUB_SD_N => '1',
sUB_SL_N => '1',
CDOUT => L0,
OVFL_CARRYOUT => open ,
p => open );
macc_pA_3: macc_pa
port map (a => OOL,
AL_N => '1',
ARSHFT17 => '0',
ARSHFT17_AD_N => '1',
ARSHFT17_BYPASS => '0',
arshft17_en => '1',
arshft17_sd_n => '1',
ARSHFT17_SL_N => '1',
a_bypass => '0',
a_en => '1',
a_sRST_N => nreset_i,
b => oLL,
B_BYPASS => '0',
b_en => '1',
B_SRST_N => nreSET_I,
c => L,
CARRYIN => '0',
cdin => L0,
CDIN_fdbk_sel => "11",
cdin_fdbk_sel_ad_n => "11",
cdin_fdbk_sel_bypass => '0',
CDIN_FDBK_SEL_EN => '1',
CDin_fdbk_sel_sd_n => "11",
CDIN_FDBK_sel_sl_n => '1',
clk => CLOCK_I,
C_ARST_N => '1',
c_bypass => '0',
C_EN => '1',
C_SRST_N => nreset_i,
D => I,
DOTP => '0',
d_arst_n => '1',
D_BYPASS => '0',
d_en => '1',
d_srst_n => NRESET_I,
ovfl_carryout_sel => '0',
pasub => '1',
PASUB_AD_N => '1',
pasub_bypass => '0',
pasub_en => '1',
PASUB_SD_n => '1',
Pasub_sl_n => '1',
p_bypaSS => '0',
p_en => '1',
P_SRST_N => nreset_i,
simd => '0',
SUB => '0',
SUB_AD_N => '1',
sub_bYPASS => '0',
SUB_EN => '1',
SUB_sd_n => '1',
SUb_sl_n => '1',
cdout => open ,
OVFL_carryout => open ,
p => LL);
IL <= STD_LOgic_vector(resize(SIGNED(ol),
g_awidth+g_bwidth+1));
OI <= std_logic_VECTOR(resize(SIGNED(LL),
g_awidth+g_bwidtH+1));
end generate;
NO_Round:
if (G_DOROUNd = 0)
generate
CREAL_O <= STd_logic_vector(IL);
cimag_o <= STD_logic_vector(oi);
end generate no_round;
round:
if (g_doround = 1)
generate
u_round_sat_creal: round_sat
generic map (g_unrnd_data_width => (g_awidth+g_BWIDTH+1),
g_rnd_data_width => G_CWIDTH,
G_UNRND_FRACT_BITS => (G_AWIDTH+G_bwidth),
G_rnd_fract_bits => g_CWIDTH-1)
port map (CLOCK_I => clock_i,
nreset_i => NRESET_I,
data_i => IL,
DATA_O => li);
u_round_sat_cimAG: round_sat
generic map (G_UNRND_DATA_width => (g_awidth+G_BWIDTH+1),
g_rnd_data_widtH => G_CWIDTH,
g_unrnd_fraCT_BITS => (g_awidth+G_Bwidth),
g_rnd_fRACT_BITS => g_cwidth-1)
port map (clock_i => CLOCK_i,
nreset_i => NRESET_I,
DAta_i => OI,
data_o => II);
creal_o <= li;
cimag_o <= II;
end generate ROUND;
end;
