--****************************************************************
--Microsemi Corporation Proprietary and Confidential
--Copyright 2016 Microsemi Corporation.  All rights reserved
--
--ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
--ACCORDANCE WITH THE MICROSEMI LICENSE AGREEMENT AND MUST BE APPROVED
--IN ADVANCE IN WRITING.
--
--Description: CoreDDS
--             Dynamic RAM wrapper
--
--Rev:
--v3.0 11/1/2016
--
--SVN Revision Information:
--SVN$Revision:$
--SVN$Date:$
--
--Resolved SARS
--
--Notes:
--
--****************************************************************

--                    ######     #    #     #
--                    #     #   # #   ##   ##  ####
--                    #     #  #   #  # # # # #
--                    ######  #     # #  #  #  ####
--                    #   #   ####### #     #      #
--                    #    #  #     # #     # #    #
--                    #     # #     # #     #  ####
LIBRARY ieee;
  USE ieee.std_logic_1164.all;
  USE ieee.numeric_std.all;
USE work.dds_rtl_pack.all;

ENTITY COREDDS_C0_COREDDS_C0_0_wrapRam IS
  GENERIC (
    LOGDEPTH        : INTEGER := 8;
    WIDTH           : INTEGER := 32;
    FPGA_FAMILY     : INTEGER := 26;
    URAM_MAXDEPTH   : INTEGER := 0;
    PIPE4         : INTEGER := 0;
    PIPE4EXT      : INTEGER := 0;
    PIPE5         : INTEGER := 0;
    SIMUL_RAM       : INTEGER := 0  );
  PORT (
    rClk            : IN STD_LOGIC;
    wClk            : IN STD_LOGIC;
    D               : IN STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
    Q               : OUT STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
    wA              : IN STD_LOGIC_VECTOR(LOGDEPTH-1 DOWNTO 0);
    rA              : IN STD_LOGIC_VECTOR(LOGDEPTH-1 DOWNTO 0);
    wEn             : IN STD_LOGIC  );
END ENTITY COREDDS_C0_COREDDS_C0_0_wrapRam;

ARCHITECTURE rtl OF COREDDS_C0_COREDDS_C0_0_wrapRam IS

  COMPONENT COREDDS_C0_COREDDS_C0_0_dds_g4_uram
    PORT( rD    : out   std_logic_vector(WIDTH-1 downto 0);
          wD    : in    std_logic_vector(WIDTH-1 downto 0);
          rA : in    std_logic_vector(LOGDEPTH-1 downto 0);
          wA : in    std_logic_vector(LOGDEPTH-1 downto 0);
          wClk  : in    std_logic;
          wEn   : in    std_logic;
          A_CLK : in    std_logic;
          --unused ports
--03/31/17          pipe_rst  : in  std_logic;
          B_DOUT: out   std_logic_vector(WIDTH-1 downto 0);
          B_ADDR: in    std_logic_vector(LOGDEPTH-1 downto 0);
          B_BLK : in    std_logic;
          wBlk  : in    std_logic );
  END COMPONENT;

  COMPONENT COREDDS_C0_COREDDS_C0_0_dds_g4_lsram
      PORT (
        rClk  : in    std_logic;
        wClk  : in    std_logic;
        wEn     : in    std_logic;
        rEn     : in    std_logic;
        DI      : in    std_logic_vector(WIDTH-1 downto 0);
        RADDR   : in    std_logic_vector(LOGDEPTH-1 downto 0);
        WADDR   : in    std_logic_vector(LOGDEPTH-1 downto 0);
--03/31/17        pipe_rst: in    std_logic;
        DO      : out   std_logic_vector(WIDTH-1 downto 0)  );
  END COMPONENT;

  COMPONENT COREDDS_C0_COREDDS_C0_0_dds_g5_uram
      PORT (
        rD     : out   std_logic_vector(WIDTH-1 downto 0);  
        wD     : in    std_logic_vector(WIDTH-1 downto 0);
        rAddr  : in    std_logic_vector(LOGDEPTH-1 downto 0);
        wAddr  : in    std_logic_vector(LOGDEPTH-1 downto 0);
        wClk   : in    std_logic;
        rClk   : in    std_logic;
        wEn    : in    std_logic  );
  END COMPONENT;

  COMPONENT COREDDS_C0_COREDDS_C0_0_dds_g5_lsram
      PORT (
        RCLOCK  : in    std_logic;
        WCLOCK  : in    std_logic;
        WRB     : in    std_logic;
        RDB     : in    std_logic;
        DI      : in    std_logic_vector(WIDTH-1 downto 0);
        RADDR   : in    std_logic_vector(LOGDEPTH-1 downto 0);
        WADDR   : in    std_logic_vector(LOGDEPTH-1 downto 0);
        DO      : out   std_logic_vector(WIDTH-1 downto 0)  );
  END COMPONENT;

  constant DEPTH  : INTEGER := 2**LOGDEPTH;
  SIGNAL rA_r     : STD_LOGIC_VECTOR(LOGDEPTH-1 DOWNTO 0);
  
BEGIN

  rA_reg_0 : dds_kitDelay_reg_attr
    GENERIC MAP(BITWIDTH => LOGDEPTH,
                DELAY    => PIPE4EXT )
    PORT MAP (nGrst => '1', rst => '0', 
      clk   => rClk, clkEn => '1', 
      inp   => rA, 
      outp  => rA_r );

  dbg_model : IF (SIMUL_RAM = 1) GENERATE
    simul_ram_0 : dds_kitRam_fabric
      GENERIC MAP (
        WIDTH     => WIDTH,
        LOGDEPTH  => LOGDEPTH,
        DEPTH     => DEPTH,
        RA_PIPE   => PIPE4,
        RD_PIPE   => PIPE5 )
      PORT MAP (
        nGrst        => '1',
        RCLOCK       => rClk,
        WCLOCK       => wClk,
        WRB          => wEn,
        RDB          => '1',
        rstDataPipe  => '0',
        DI           => D,
        RADDR        => rA_r,
        WADDR        => wA,
        DO           => Q  );
  END GENERATE;
  
  -- Note: PIPE 5 is inferred in .gen file
  --    (see gen_ramGen.cpp/ram_config_file_generator)
  
  -- G4.  Use uRAM if appropriate
  G4_uram : IF ((SIMUL_RAM=0) AND (DEPTH<=URAM_MAXDEPTH) AND ((FPGA_FAMILY=19) 
                            OR (FPGA_FAMILY=24) OR (FPGA_FAMILY=25))) GENERATE
    uram_g4_0 : COREDDS_C0_COREDDS_C0_0_dds_g4_uram
      PORT MAP (
        rD      => Q,
        wD      => D,
        rA   => rA_r,
        wA   => wA,
        wClk    => wClk,
        wEn     => wEn,
        A_CLK   => rClk,      --actgen
        --unused ports
--03/31/17        pipe_rst  => '0',
        B_DOUT  => open,
        B_ADDR  => (others=>'1'),
        B_BLK   => '0',
        wBlk    => '1'  );
  END GENERATE;

  -- G4.  Use Large SRAM otherwise
  G4_lsram : IF ((SIMUL_RAM=0) AND (DEPTH>URAM_MAXDEPTH) AND ((FPGA_FAMILY=19) 
                        OR (FPGA_FAMILY=24) OR (FPGA_FAMILY=25))) GENERATE
    lsram_g4_0 : COREDDS_C0_COREDDS_C0_0_dds_g4_lsram
      PORT MAP (
        rClk    => rClk,
        wClk    => wClk,
        wEn     => wEn,
        rEn     => '1',
        DI      => D,
        RADDR   => rA_r,
        WADDR   => wA,
--03/31/17        pipe_rst  => '0',  
        DO      => Q      );
  END GENERATE;
  -- G5.  Use uRAM if appropriate
  PF_uram_rClk: IF((SIMUL_RAM=0) AND (DEPTH<=URAM_MAXDEPTH) AND ((FPGA_FAMILY=26) OR (FPGA_FAMILY=27))
                          AND ((PIPE5 = 1) OR (PIPE4 = 1))) 
                          GENERATE --If any pipe's on, then rClk port is present
    uram_g5_0 : COREDDS_C0_COREDDS_C0_0_dds_g5_uram
      PORT MAP (
        rD     => Q,
        wD     => D,
        rAddr  => rA_r,
        wAddr  => wA,
        wClk   => wClk,
        rClk   => rClk,
        wEn    => wEn  );
  END GENERATE;
  
-- Excluding unrealistic scenario: start
  -- G5 uRam with no rA or rD pipe.  rClk port is out. 
  -- Apparently read is controlled solely by rA
--  PF_uram_no_rClk : IF ((SIMUL_RAM = 0) AND (DEPTH <= URAM_MAXDEPTH) AND 
--              (FPGA_FAMILY = 26) AND (PIPE5 = 0) AND (PIPE4 = 0)) GENERATE
--    uram_g5_0 : COREDDS_C0_COREDDS_C0_0_dds_g5_uram
--      PORT MAP (
--        rD     => Q,
--        wD     => D,
--        rAddr  => rA,
--        wAddr  => wA,
--        wClk   => wClk,
--        wEn    => wEn  );
--  END GENERATE;
-- Excluding unrealistic scenario: end
  
  -- PIPE 5 is inferred in .gen file. 
  -- See gen_ramGen.cpp/ram_config_file_generator
  -- G5.  Use Large SRAM otherwise
  PF_lsram : IF ((SIMUL_RAM=0) AND (DEPTH>URAM_MAXDEPTH) AND ((FPGA_FAMILY=26) OR (FPGA_FAMILY=27))) 
                                                                      GENERATE
    lsram_g5_0 : COREDDS_C0_COREDDS_C0_0_dds_g5_lsram
      PORT MAP (
        RCLOCK  => rClk,
        WCLOCK  => wClk,
        WRB     => wEn,
        RDB     => '1',
        DI      => D,
        RADDR   => rA_r,
        WADDR   => wA,
        DO      => Q  );
  END GENERATE;
  
END ARCHITECTURE rtl;




-- Quarter-wave LUT and read sample tweaking
LIBRARY ieee;
  USE ieee.std_logic_1164.all;
  USE ieee.numeric_std.all;
USE work.dds_rtl_pack.all;

ENTITY COREDDS_C0_COREDDS_C0_0_qrtr_lut IS
  GENERIC (
    QUANTIZER_BITS  : INTEGER := 8;		--Logdepth for the full-wave LUT
    WIDTH           : INTEGER := 32;
    FPGA_FAMILY     : INTEGER := 26;
    URAM_MAXDEPTH   : INTEGER := 0;
    PIPE4           : INTEGER := 0;
    PIPE4EXT        : INTEGER := 0;
    PIPE5           : INTEGER := 0;
    PIPE6           : INTEGER := 0;
    PIPE7           : INTEGER := 0;
    SIMUL_RAM       : INTEGER := 0;
    SIN_ON          : INTEGER := 1;
    COS_ON          : INTEGER := 1;
    SIN_POLARITY    : INTEGER := 0;
    COS_POLARITY    : INTEGER := 0  );
  PORT (
    nGrst           : IN STD_LOGIC;
    wClk            : IN STD_LOGIC;
    rClk            : IN STD_LOGIC;
    wEn             : IN STD_LOGIC;
    wA              : IN STD_LOGIC_VECTOR(QUANTIZER_BITS-4 DOWNTO 0);
    full_wave_addr  : IN STD_LOGIC_VECTOR(QUANTIZER_BITS-1 DOWNTO 0);
    sino            : OUT STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
    coso            : OUT STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0)  );
END ENTITY COREDDS_C0_COREDDS_C0_0_qrtr_lut;

ARCHITECTURE rtl OF COREDDS_C0_COREDDS_C0_0_qrtr_lut IS
  COMPONENT COREDDS_C0_COREDDS_C0_0_dds_qrtr_sin
    PORT ( 
      index : IN std_logic_vector(QUANTIZER_BITS-4 DOWNTO 0); 
      sine  : OUT std_logic_vector(WIDTH-1 DOWNTO 0)); 
  END COMPONENT; 

  COMPONENT COREDDS_C0_COREDDS_C0_0_dds_qrtr_cos
    PORT ( 
      index : IN std_logic_vector(QUANTIZER_BITS-4 DOWNTO 0); 
      cosine : OUT std_logic_vector(WIDTH-1 DOWNTO 0)); 
  END COMPONENT; 

  COMPONENT COREDDS_C0_COREDDS_C0_0_wrapRam IS
    GENERIC (
      LOGDEPTH        : INTEGER := 8;
      WIDTH           : INTEGER := 32;
      FPGA_FAMILY     : INTEGER := 26;
      URAM_MAXDEPTH   : INTEGER := 0;
      PIPE4           : INTEGER := 0;
      PIPE4EXT        : INTEGER := 0;
      PIPE5           : INTEGER := 0;
      SIMUL_RAM       : INTEGER := 0  );
    PORT (
      rClk            : IN STD_LOGIC;
      wClk            : IN STD_LOGIC;
      D               : IN STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
      Q               : OUT STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
      wA              : IN STD_LOGIC_VECTOR(LOGDEPTH-1 DOWNTO 0);
      rA              : IN STD_LOGIC_VECTOR(LOGDEPTH-1 DOWNTO 0);
      wEn             : IN STD_LOGIC  );
  END COMPONENT;
  
  SIGNAL sine_ww     : STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
  SIGNAL cosine_ww   : STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
  SIGNAL blue        : STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
  SIGNAL red         : STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
  SIGNAL Q_blue      : STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
  SIGNAL Q_red       : STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
  SIGNAL Q_blue_t    : STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
  SIGNAL Q_red_t     : STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
  SIGNAL rA_qrtr_dir : STD_LOGIC_VECTOR(QUANTIZER_BITS-4 DOWNTO 0);
  SIGNAL rA_qrtr_rev : STD_LOGIC_VECTOR(QUANTIZER_BITS-4 DOWNTO 0);
  SIGNAL rA_qrtr     : STD_LOGIC_VECTOR(QUANTIZER_BITS-4 DOWNTO 0);
  SIGNAL sine_w      : STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
  SIGNAL cosine_w    : STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
  SIGNAL mapBits, mapBits_w : STD_LOGIC_VECTOR(2 DOWNTO 0);
  SIGNAL sine        : STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
  SIGNAL cosine      : STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
  SIGNAL mapBits_oneHot : STD_LOGIC_VECTOR(7 DOWNTO 0);
  
BEGIN
  -- Tables to download into RAM's.
  -- If both SIN_POLARITY==1 && COS_POLARITY==1, the tables contain negative
  -- data. Then read modification is the same as for positive plarities
  qrtr_sin_tbl_0 : COREDDS_C0_COREDDS_C0_0_dds_qrtr_sin
    PORT MAP (  index  => wA,
                sine   => blue );
  qrtr_cos_tbl_0 : COREDDS_C0_COREDDS_C0_0_dds_qrtr_cos
    PORT MAP (  index   => wA,
                cosine  => red );
  
  qrtr_blue_ram_0 : COREDDS_C0_COREDDS_C0_0_wrapRam
    GENERIC MAP (
      LOGDEPTH       => QUANTIZER_BITS-3,
      WIDTH          => WIDTH,
      FPGA_FAMILY    => FPGA_FAMILY,
      URAM_MAXDEPTH  => URAM_MAXDEPTH,
      PIPE4        => PIPE4,
      PIPE4EXT       => PIPE4EXT,
      PIPE5        => PIPE5,
      SIMUL_RAM      => SIMUL_RAM  )
    PORT MAP (
      rClk  => rClk,
      wClk  => wClk,
      D     => blue,
      Q     => Q_blue,
      wA    => wA,
      rA    => rA_qrtr,
      wEn   => wEn  );
  
  qrtr_red_ram_0 : COREDDS_C0_COREDDS_C0_0_wrapRam
    GENERIC MAP (
      LOGDEPTH       => QUANTIZER_BITS-3,
      WIDTH          => WIDTH,
      FPGA_FAMILY    => FPGA_FAMILY,
      URAM_MAXDEPTH  => URAM_MAXDEPTH,
      PIPE4        => PIPE4,
      PIPE4EXT       => PIPE4EXT,
      PIPE5        => PIPE5,
      SIMUL_RAM      => SIMUL_RAM  )
    PORT MAP (
      rClk  => rClk,
      wClk  => wClk,
      D     => red,
      Q     => Q_red,
      wA    => wA,
      rA    => rA_qrtr,
      wEn   => wEn  );
  
  --  ----------  Read LUT's
  --  --------  Modify addr to accomodate to quarter wave
  mapBits_w <= full_wave_addr(QUANTIZER_BITS-1 DOWNTO QUANTIZER_BITS-3);
  -- mapBits controls quarter wave tweaking. Delay it to match the RAM pipes
  -- but make the delay one clock less, as the mapBits_oneHot introduces the 
  -- one-clk delay. Having one-hot signals improves performance. Note: It is 
  -- possible to get PIPE4+PIPE5+PIPE6-1 delay, as PIPE4=1 permanently
  balance_dly_0 : dds_kitDelay_reg 
    GENERIC MAP (
      BITWIDTH  => 3, 
      DELAY     => PIPE4+PIPE4EXT+PIPE5+PIPE6-1 )  
    PORT MAP (
      nGrst => nGrst, 
      rst   => '0', 
      clk   => rClk, 
      clkEn => '1',
      inp   => mapBits_w, 
      outp  => mapBits );
      
  PROCESS (rClk)
  BEGIN
    IF (rClk'EVENT AND rClk = '1') THEN
      CASE mapBits IS
        WHEN "000" => mapBits_oneHot <= "00000001";
        WHEN "001" => mapBits_oneHot <= "00000010";
        WHEN "010" => mapBits_oneHot <= "00000100";
        WHEN "011" => mapBits_oneHot <= "00001000";
        WHEN "100" => mapBits_oneHot <= "00010000";
        WHEN "101" => mapBits_oneHot <= "00100000";
        WHEN "110" => mapBits_oneHot <= "01000000";
        WHEN "111" => mapBits_oneHot <= "10000000";
        WHEN OTHERS => NULL;
      END CASE;
    END IF;
  END PROCESS;
      

  -- qrtr_wave_addr
  rA_qrtr_dir <= full_wave_addr(QUANTIZER_BITS-4 DOWNTO 0);
  -- octavo-1-qrtr_wave_addr
  rA_qrtr_rev <= NOT(full_wave_addr(QUANTIZER_BITS-4 DOWNTO 0));
  -- Quarter-wave address
  rA_qrtr <= rA_qrtr_dir WHEN (mapBits_w(0) = '0') ELSE rA_qrtr_rev;
  
  -- Optionally infer a pipeline btw RAM output and fabric
  pipe6_0 : dds_kitDelay_reg
    GENERIC MAP ( BITWIDTH  => WIDTH,
                  DELAY     => PIPE6  )
    PORT MAP (
      nGrst  => nGrst,
      rst    => '0',
      clk    => rClk,
      clkEn  => '1',
      inp    => Q_blue,
      outp   => Q_blue_t  );
    
  pipe6_1 : dds_kitDelay_reg
    GENERIC MAP ( BITWIDTH  => WIDTH,
                  DELAY     => PIPE6  )
    PORT MAP (
      nGrst  => nGrst,
      rst    => '0',
      clk    => rClk,
      clkEn  => '1',
      inp    => Q_red,
      outp   => Q_red_t  );

  --  --------  Tweak Quarter-wave LUT outputs
  pos_sine : IF ((SIN_ON /= 0) AND (SIN_POLARITY=0)) GENERATE		--Positive Sine
    PROCESS (Q_blue_t, Q_red_t, mapBits_oneHot)
    BEGIN
      CASE mapBits_oneHot IS
        WHEN "00000001" => sine_w <= Q_blue_t;
        WHEN "00000010" => sine_w <= Q_red_t;
        WHEN "00000100" => sine_w <= Q_red_t;
        WHEN "00001000" => sine_w <= Q_blue_t;
        WHEN "00010000" => sine_w <= STD_LOGIC_VECTOR(-(signed(Q_blue_t)));
        WHEN "00100000" => sine_w <= STD_LOGIC_VECTOR(-(signed(Q_red_t)));
        WHEN "01000000" => sine_w <= STD_LOGIC_VECTOR(-(signed(Q_red_t)));
        WHEN "10000000" => sine_w <= STD_LOGIC_VECTOR(-(signed(Q_blue_t)));
        WHEN OTHERS => NULL;
      END CASE;
    END PROCESS;
  END GENERATE;
  
  neg_sine : IF ((SIN_ON /= 0) AND (SIN_POLARITY=1)) GENERATE		--Negative Sine
--11/09/16    PROCESS (full_wave_addr, mapBits)
    PROCESS (Q_blue_t, Q_red_t, mapBits_oneHot)
    BEGIN
      CASE mapBits_oneHot IS
        WHEN "00000001" => sine_w <= STD_LOGIC_VECTOR(-(signed(Q_blue_t)));
        WHEN "00000010" => sine_w <= STD_LOGIC_VECTOR(-(signed(Q_red_t)));
        WHEN "00000100" => sine_w <= STD_LOGIC_VECTOR(-(signed(Q_red_t)));
        WHEN "00001000" => sine_w <= STD_LOGIC_VECTOR(-(signed(Q_blue_t)));
        WHEN "00010000" => sine_w <= Q_blue_t;
        WHEN "00100000" => sine_w <= Q_red_t;
        WHEN "01000000" => sine_w <= Q_red_t;
        WHEN "10000000" => sine_w <= Q_blue_t;
        WHEN OTHERS => NULL;
      END CASE;
    END PROCESS;
  END GENERATE;
  
  pos_cosine : IF ((COS_ON/=0) AND (COS_POLARITY=0)) GENERATE	--Positive Cos
--11/09/16    PROCESS (full_wave_addr, mapBits)
    PROCESS (Q_blue_t, Q_red_t, mapBits_oneHot)
    BEGIN
      CASE mapBits_oneHot IS
        WHEN "00000001" => cosine_w <= Q_red_t;
        WHEN "00000010" => cosine_w <= Q_blue_t;
        WHEN "00000100" => cosine_w <= STD_LOGIC_VECTOR(-(signed(Q_blue_t)));
        WHEN "00001000" => cosine_w <= STD_LOGIC_VECTOR(-(signed(Q_red_t)));
        WHEN "00010000" => cosine_w <= STD_LOGIC_VECTOR(-(signed(Q_red_t)));
        WHEN "00100000" => cosine_w <= STD_LOGIC_VECTOR(-(signed(Q_blue_t)));
        WHEN "01000000" => cosine_w <= Q_blue_t;
        WHEN "10000000" => cosine_w <= Q_red_t;
        WHEN OTHERS => NULL;
      END CASE;
    END PROCESS;
  END GENERATE;
  
  neg_cosine : IF ((COS_ON /= 0) AND (COS_POLARITY=1)) GENERATE	--Negative Cos
--11/09/16    PROCESS (full_wave_addr, mapBits)
    PROCESS (Q_blue_t, Q_red_t, mapBits_oneHot)
    BEGIN
      CASE mapBits_oneHot IS
        WHEN "00000001" => cosine_w <= STD_LOGIC_VECTOR(-(signed(Q_red_t)));
        WHEN "00000010" => cosine_w <= STD_LOGIC_VECTOR(-(signed(Q_blue_t)));
        WHEN "00000100" => cosine_w <= Q_blue_t;
        WHEN "00001000" => cosine_w <= Q_red_t;
        WHEN "00010000" => cosine_w <= Q_red_t;
        WHEN "00100000" => cosine_w <= Q_blue_t;
        WHEN "01000000" => cosine_w <= STD_LOGIC_VECTOR(-(signed(Q_blue_t)));
        WHEN "10000000" => cosine_w <= STD_LOGIC_VECTOR(-(signed(Q_red_t)));
        WHEN OTHERS => NULL;
      END CASE;
    END PROCESS;
  END GENERATE;


  -- Infer Qrtr-wave Pipe7
  pipe_7_sin : IF (SIN_ON /= 0) GENERATE
    pipe7_qrtr_0 : dds_kitDelay_reg
      GENERIC MAP ( BITWIDTH  => WIDTH,
                    DELAY     => PIPE7  )
      PORT MAP (
        nGrst  => nGrst,
        rst    => '0',
        clk    => rClk,
        clkEn  => '1',
        inp    => sine_w,
        outp   => sino );
  END GENERATE;
  
  pipe_7_cos : IF (COS_ON /= 0) GENERATE
    pipe7_qrtr_1 : dds_kitDelay_reg
      GENERIC MAP ( BITWIDTH  => WIDTH,
                    DELAY     => PIPE7  )
      PORT MAP (
        nGrst  => nGrst,
        rst    => '0',
        clk    => rClk,
        clkEn  => '1',
        inp    => cosine_w,
        outp   => coso  );
  END GENERATE;
  
END ARCHITECTURE rtl;



LIBRARY ieee;
  USE ieee.std_logic_1164.all;
  USE ieee.numeric_std.all;
USE work.dds_rtl_pack.all;

ENTITY COREDDS_C0_COREDDS_C0_0_sin_cos_lut IS
  GENERIC (
    QUANTIZER_BITS  : INTEGER := 8;		--Logdepth for the full-wave LUT
    WIDTH           : INTEGER := 32;
    QUARTER_WAVE    : INTEGER := 1;
    SIN_ON          : INTEGER := 1;
    COS_ON          : INTEGER := 1;
    SIN_POLARITY    : INTEGER := 0;
    COS_POLARITY    : INTEGER := 0;
    FPGA_FAMILY     : INTEGER := 26;
    URAM_MAXDEPTH   : INTEGER := 0;
    PIPE4           : INTEGER := 0;
    PIPE4EXT        : INTEGER := 0;
    PIPE5           : INTEGER := 0;
    PIPE6           : INTEGER := 0;
    PIPE7           : INTEGER := 0;
    SIMUL_RAM       : INTEGER := 0  );
  PORT (    
    nGrst           : IN STD_LOGIC;
    wClk            : IN STD_LOGIC;
    rClk            : IN STD_LOGIC;
    wEn             : IN STD_LOGIC;
    wA              : IN STD_LOGIC_VECTOR(intMux(QUANTIZER_BITS, QUANTIZER_BITS-3, QUARTER_WAVE=1)-1 DOWNTO 0);
    full_wave_addr  : IN STD_LOGIC_VECTOR(QUANTIZER_BITS-1 DOWNTO 0);
    sino            : OUT STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
    coso            : OUT STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0)  );
    
  attribute syn_noclockbuf: Boolean;                    --03/09/17
  attribute syn_noclockbuf of wA : signal is true;     --03/09/17
    
END ENTITY COREDDS_C0_COREDDS_C0_0_sin_cos_lut;

ARCHITECTURE rtl OF COREDDS_C0_COREDDS_C0_0_sin_cos_lut IS
  COMPONENT COREDDS_C0_COREDDS_C0_0_dds_full_sin
    PORT ( 
      index : IN std_logic_vector(QUANTIZER_BITS-1 DOWNTO 0); 
      sine  : OUT std_logic_vector(WIDTH-1 DOWNTO 0)); 
  END COMPONENT; 

  COMPONENT COREDDS_C0_COREDDS_C0_0_dds_full_cos
    PORT ( 
      index : IN std_logic_vector(QUANTIZER_BITS-1 DOWNTO 0); 
      cosine : OUT std_logic_vector(WIDTH-1 DOWNTO 0)); 
  END COMPONENT; 

  COMPONENT COREDDS_C0_COREDDS_C0_0_wrapRam IS
    GENERIC (
      LOGDEPTH        : INTEGER;
      WIDTH           : INTEGER;
      FPGA_FAMILY     : INTEGER;
      URAM_MAXDEPTH   : INTEGER;
      PIPE4           : INTEGER;
      PIPE4EXT        : INTEGER;
      PIPE5           : INTEGER;
      SIMUL_RAM       : INTEGER );
    PORT (
      rClk            : IN STD_LOGIC;
      wClk            : IN STD_LOGIC;
      D               : IN STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
      Q               : OUT STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
      wA              : IN STD_LOGIC_VECTOR(LOGDEPTH-1 DOWNTO 0);
      rA              : IN STD_LOGIC_VECTOR(LOGDEPTH-1 DOWNTO 0);
      wEn             : IN STD_LOGIC  );
  END COMPONENT;

  COMPONENT COREDDS_C0_COREDDS_C0_0_qrtr_lut IS
    GENERIC (
        QUANTIZER_BITS  : INTEGER;	
        WIDTH           : INTEGER;
        FPGA_FAMILY     : INTEGER;
        URAM_MAXDEPTH   : INTEGER;
        PIPE4           : INTEGER;
        PIPE4EXT        : INTEGER := 0;
        PIPE5           : INTEGER;
        PIPE6           : INTEGER;
        PIPE7           : INTEGER;
        SIMUL_RAM       : INTEGER;
        SIN_ON          : INTEGER;
        COS_ON          : INTEGER;
        SIN_POLARITY    : INTEGER;
        COS_POLARITY    : INTEGER   );
     PORT (
        nGrst           : IN STD_LOGIC;
        wClk            : IN STD_LOGIC;
        rClk            : IN STD_LOGIC;
        wEn             : IN STD_LOGIC;
        wA              : IN STD_LOGIC_VECTOR(QUANTIZER_BITS-4 DOWNTO 0);
        full_wave_addr  : IN STD_LOGIC_VECTOR(QUANTIZER_BITS-1 DOWNTO 0);
        sino            : OUT STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
        coso            : OUT STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0)  );
  END COMPONENT;
  
  SIGNAL sine_ww     : STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
  SIGNAL cosine_ww   : STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
  SIGNAL sine_w      : STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
  SIGNAL cosine_w    : STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
  SIGNAL sine        : STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
  SIGNAL cosine      : STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
  
BEGIN

  full_wave_sine : IF ((QUARTER_WAVE = 0) AND (SIN_ON /= 0)) GENERATE
    -- Table to download into RAM's. Full wave SIN/COS_POLARITY is
    -- implemented in the tables. Nothing to do here
    full_sin_tbl_0 : COREDDS_C0_COREDDS_C0_0_dds_full_sin
      PORT MAP (  index  => wA,
                  sine   => sine  );
    
    -- RAM block
    full_sin_ram_0 : COREDDS_C0_COREDDS_C0_0_wrapRam
      GENERIC MAP (
        LOGDEPTH       => QUANTIZER_BITS,
        WIDTH          => WIDTH,
        FPGA_FAMILY    => FPGA_FAMILY,
        URAM_MAXDEPTH  => URAM_MAXDEPTH,
        PIPE4          => PIPE4,
        PIPE4EXT       => PIPE4EXT,
        PIPE5          => PIPE5,
        SIMUL_RAM      => SIMUL_RAM  )
      PORT MAP (
        rClk  => rClk,
        wClk  => wClk,
        D     => sine,
        Q     => sine_ww,
        wA    => wA,
        rA    => full_wave_addr,
        wEn   => wEn  );
    
    -- Infer Pipe6
    pipe6_full_0 : dds_kitDelay_reg
      GENERIC MAP ( BITWIDTH  => WIDTH,
                    DELAY     => PIPE6  )
      PORT MAP (
        nGrst  => nGrst,
        rst    => '0',
        clk    => rClk,
        clkEn  => '1',
        inp    => sine_ww,
        outp   => sino  );
  END GENERATE;
  
  full_wave_cosine : IF ((QUARTER_WAVE = 0) AND (COS_ON /= 0)) GENERATE
    -- Table to download into RAM's. Full wave SIN/COS_POLARITY is
    -- implemented in the tables. Nothing to do here    
    full_cos_tbl_0 : COREDDS_C0_COREDDS_C0_0_dds_full_cos
      PORT MAP (  index   => wA,
                  cosine  => cosine  );
    
    -- RAM block    
    full_cos_ram_0 : COREDDS_C0_COREDDS_C0_0_wrapRam
      GENERIC MAP (
        LOGDEPTH       => QUANTIZER_BITS,
        WIDTH          => WIDTH,
        FPGA_FAMILY    => FPGA_FAMILY,
        URAM_MAXDEPTH  => URAM_MAXDEPTH,
        PIPE4        => PIPE4,
        PIPE4EXT       => PIPE4EXT,
        PIPE5        => PIPE5,
        SIMUL_RAM      => SIMUL_RAM )
      PORT MAP (
        rclk  => rClk,
        wclk  => wClk,
        d     => cosine,
        q     => cosine_ww,
        wa    => wA,
        ra    => full_wave_addr,
        wen   => wEn  );
    
    -- Infer Pipe6
    pipe6_full_1 : dds_kitDelay_reg
      GENERIC MAP ( BITWIDTH  => WIDTH,
                    DELAY     => PIPE6  )
      PORT MAP (
        nGrst  => nGrst,
        rst    => '0',
        clk    => rClk,
        clkEn  => '1',
        inp    => cosine_ww,
        outp   => coso  );
  END GENERATE;
  
  qrtr_wave : IF (QUARTER_WAVE = 1) GENERATE
    -- Full-wave Logdepth
    grtr_lut_0 : COREDDS_C0_COREDDS_C0_0_qrtr_lut
      GENERIC MAP (
        QUANTIZER_BITS  => QUANTIZER_BITS,
        WIDTH           => WIDTH,
        FPGA_FAMILY     => FPGA_FAMILY,
        URAM_MAXDEPTH   => URAM_MAXDEPTH,
        PIPE4           => PIPE4,
        PIPE4EXT        => PIPE4EXT,
        PIPE5           => PIPE5,
        PIPE6           => PIPE6,
        PIPE7           => PIPE7,
        SIMUL_RAM       => SIMUL_RAM,
        SIN_ON          => SIN_ON,
        COS_ON          => COS_ON,
        SIN_POLARITY    => SIN_POLARITY,
        COS_POLARITY    => COS_POLARITY   )
      PORT MAP (
        nGrst           => nGrst,
        wClk            => wClk,
        rClk            => rClk,
        wEn             => wEn,
        wA              => wA,
        full_wave_addr  => full_wave_addr,
        sino            => sino,
        coso            => coso  );
  END GENERATE;
  
END ARCHITECTURE rtl;





