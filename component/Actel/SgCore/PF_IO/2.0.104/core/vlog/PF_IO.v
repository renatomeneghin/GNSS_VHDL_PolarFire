// *********************************************************************/ 
// Copyright (c) 2021 Microsemi Corporation.  All rights reserved.  
// 
// Any use or redistribution in part or in whole must be handled in 
// accordance with the Microsemi license agreement and must be approved 
// in advance in writing.  
//  
// File: pf_io.v
//     
//
// *********************************************************************

`timescale 1ns / 1ps

module PF_IO (   DELAY_LINE_OUT_OF_RANGE,
                    DELAY_LINE_MOVE,
                    DELAY_LINE_DIRECTION,
                    DELAY_LINE_LOAD,
                    RX_CLK,
                    TX_CLK,
                    ODT_EN,
                    INFF_SL,
                    INFF_EN,
                    OUTFF_SL,
                    OUTFF_EN,
                    AL_N,
                    PADIP,
                    PADIN,
                    PADOP,
                    PADON,
                    PADP,
                    PADN,
                    PADI,
                    PADO,
                    PAD,
                    DF,
                    DR,
                    D,
                    E,
                    QF,
                    QR,
                    Q,
                    Y );

parameter DIRECTION = 2'b0; // 0=>inout, 1=>input, 2=>output, 3=>tribuf
parameter DIFFERENTIAL = 1'b0; 
parameter INPUT_MODE = 2'b0; // 0=> bypass, 1=>sdr, 2 => ddr
parameter OUTPUT_MODE = 2'b0; // 0=> bypass, 1=>sdr, 2 => ddr
parameter OUTPUT_ENABLE_MODE = 2'b0; // 0=> bypass, 1=>sdr, 2 => ddr
parameter DYN_DELAY_LINE_EN = 1'b0;

localparam RX_CLK_EN =  ( DIRECTION == 2'b00 || DIRECTION == 2'b01 ) && ( INPUT_MODE != 2'b00 ) ? 1'b1 : 1'b0;
localparam TX_CLK_EN =  ( DIRECTION != 2'b01 ) && ( OUTPUT_MODE != 2'b00 || OUTPUT_ENABLE_MODE != 2'b00 ) ? 1'b1 : 1'b0;
localparam RX_MODE =    ( DIRECTION == 2'b00 || DIRECTION == 2'b01 ) && ( INPUT_MODE == 2'b10 ) ? 4'b0001 : 4'b0000;
localparam TX_MODE =    ( DIRECTION == 2'b00 || DIRECTION == 2'b10 || DIRECTION == 2'b11 ) ? 
                            ( ( OUTPUT_MODE == 2'b00 ) ? 7'b0000000 : 
                            ( ( OUTPUT_MODE == 2'b01 ) ? 7'b0100000 : 
                            ( ( OUTPUT_MODE == 2'b10 ) ? 7'b1000001 : 7'b0000000 ) ) ) : 7'b0000000;
localparam TX_OE_MODE = ( DIRECTION == 2'b00 || DIRECTION == 2'b11 ) ? 
                            ( ( OUTPUT_ENABLE_MODE == 2'b00 ) ? 3'b000 : 
                            ( ( OUTPUT_ENABLE_MODE == 2'b01 ) ? 3'b001 : 
                            ( ( OUTPUT_ENABLE_MODE == 2'b10 ) ? 3'b010 : 3'b111 ) ) ) : ( DIRECTION == 2'b10 ) ? 3'b000 : 3'b111;

localparam OEFF_SD_N = 1'b1;
localparam OEFF_AD_N = 1'b1;
localparam INFF_SD_N = 1'b1;
localparam INFF_AD_N = 1'b1;
localparam OUTFF_SD_N = 1'b1;
localparam OUTFF_AD_N = 1'b1;

// Enable the delay line. If DYN_DELAY_LINE_EN == 1'b0, it can be disabled in I/O editor per direction. Else the delay line is always enabled
localparam DELAY_LINE_MODE = ( DYN_DELAY_LINE_EN == 1'b0 ) ? 2'b00 : ( ( DIRECTION == 2'b01 ) ? 2'b01 : ( ( DIRECTION == 2'b00 ) ? 2'b11 : 2'b10 ) );

localparam DEFAULT_DELAY = ( DYN_DELAY_LINE_EN == 1'b0 ) ? 8'b00000000 : 8'b00000001; 


input DELAY_LINE_MOVE;
input DELAY_LINE_DIRECTION;
input DELAY_LINE_LOAD;
input RX_CLK;
input TX_CLK;
input ODT_EN;
input INFF_SL;
input INFF_EN;
input OUTFF_SL;
input OUTFF_EN;
input AL_N;
output DELAY_LINE_OUT_OF_RANGE;

input PADIP;
input PADIN;
input PADI;

output PADOP;
output PADON;
output PADO;

inout PADP;
inout PADN;
inout PAD;

input D, DF, DR;
input E;
output Q, QF, QR, Y; 

wire [9:0] rx_data_i;
wire [7:0] tx_data_i;
wire [3:0] oe_data_i;

assign tx_data_i = ( OUTPUT_MODE == 2'b00 || OUTPUT_MODE == 2'b01 ) ? {7'b0,D} : {6'b0,DF, DR};
assign oe_data_i = ( DIRECTION == 2'b10 ) ? 4'b1111 : {3'b0,E};
assign QF = rx_data_i[9];
assign QR = rx_data_i[8];
assign Y = rx_data_i[0];
assign Q = rx_data_i[1];

wire rx_p;
wire tx;
wire oe;

    generate
        if ( DIRECTION == 2'b00 ) begin : io // inout
            if ( DIFFERENTIAL == 1'b0 ) begin : se
                BIBUF ioa( .PAD( PAD ), .D( tx ), .E( oe ), .Y( rx_p ) );
            end else begin : diff
                BIBUF_DIFF ioa( .PADP( PADP ), .PADN( PADN ), .D( tx ), .E( oe ), .Y( rx_p ) );
            end
        end else if( DIRECTION == 2'b01 ) begin : i // input
            if ( DIFFERENTIAL == 1'b0 ) begin : se
                INBUF ioa( .PAD( PADI ), .Y( rx_p ) );
            end else begin : diff
                INBUF_DIFF ioa( .PADP( PADIP ), .PADN( PADIN ), .Y( rx_p ) );
            end
        end else if( DIRECTION == 2'b10 ) begin : o // output
            if ( DIFFERENTIAL == 1'b0 ) begin : se
                OUTBUF ioa( .PAD( PADO ), .D( tx ) );
                assign rx_p = 1'b0;
            end else begin : diff
                OUTBUF_DIFF ioa( .PADP( PADOP ), .PADN( PADON ), .D( tx ) );
                assign rx_p = 1'b0;
            end   
        end else if( DIRECTION == 2'b11 ) begin : tr // tribuf
            if ( DIFFERENTIAL == 1'b0 ) begin : se 
                TRIBUFF ioa( .PAD( PADO ), .D( tx ), .E( oe ) );
                assign rx_p = 1'b0;
            end else begin : diff
                TRIBUFF_DIFF ioa( .PADP( PADOP ), .PADN( PADON ), .D( tx ), .E( oe ) );
                assign rx_p = 1'b0;
            end
        end
    endgenerate

    IOD #(  .DATA_RATE(800.0), 
            .FORMAL_NAME("PF_IO"), 
            .INTERFACE_NAME("NA"), 
            .DELAY_LINE_SIMULATION_MODE("ENABLED"), 
            .RESERVED_0(1'b0), 
            .RX_CLK_EN(RX_CLK_EN),
            .RX_CLK_INV(1'b0),
            .TX_CLK_EN(TX_CLK_EN),
            .TX_CLK_INV(1'b0),
            .HS_IO_CLK_SEL(3'b000),
            .QDR_EN(1'b0),
            .EDGE_DETECT_EN(1'b0),
            .DELAY_LINE_MODE(DELAY_LINE_MODE),
            .RX_MODE(RX_MODE),
            .EYE_MONITOR_MODE(1'b0),
            .DYN_DELAY_LINE_EN(DYN_DELAY_LINE_EN[0]),
            .FIFO_WR_EN(1'b0),
            .EYE_MONITOR_EN(1'b0),
            .TX_MODE(TX_MODE),
            .TX_CLK_SEL(2'b00),
            .TX_OE_MODE(TX_OE_MODE),
            .TX_OE_CLK_INV(1'b0),
            .RX_DELAY_VAL(DEFAULT_DELAY),
            .RX_DELAY_VAL_X2(1'b0),
            .TX_DELAY_VAL(DEFAULT_DELAY),
            .EYE_MONITOR_WIDTH(3'b001),
            .EYE_MONITOR_WIDTH_SRC(1'b0),
            .RESERVED_1(1'b0),
            .DISABLE_LANECTRL_RESET(1'b1),
            .INPUT_DELAY_SEL(2'b00),
            .OEFF_EN_INV(1'b0),
            .INFF_EN_INV(1'b0),
            .OUTFF_EN_INV(1'b0) ) 
            I_IOD_0 (   .EYE_MONITOR_EARLY(),
                        .EYE_MONITOR_LATE(),
                        .RX_DATA(rx_data_i),  
                        .DELAY_LINE_OUT_OF_RANGE(DELAY_LINE_OUT_OF_RANGE),
                        .TX_DATA(tx_data_i), 
                        .OE_DATA(oe_data_i), 
                        .RX_BIT_SLIP(1'b0),
                        .EYE_MONITOR_CLEAR_FLAGS(1'b0), 
                        .DELAY_LINE_MOVE(DELAY_LINE_MOVE),
                        .DELAY_LINE_DIRECTION(DELAY_LINE_DIRECTION), 
                        .DELAY_LINE_LOAD(DELAY_LINE_LOAD),
                        .RX_CLK(RX_CLK),
                        .TX_CLK(TX_CLK), 
                        .ODT_EN(ODT_EN),
                        .INFF_SL(INFF_SL),
                        .INFF_EN(INFF_EN), 
                        .OUTFF_SL(OUTFF_SL),
                        .OUTFF_EN(OUTFF_EN),
                        .AL_N(AL_N), 
                        .OEFF_LAT_N(1'b1),
                        .OEFF_SD_N(OEFF_SD_N),
                        .OEFF_AD_N(OEFF_AD_N), 
                        .INFF_LAT_N(1'b1),
                        .INFF_SD_N(INFF_SD_N),
                        .INFF_AD_N(INFF_AD_N), 
                        .OUTFF_LAT_N(1'b1),
                        .OUTFF_SD_N(OUTFF_SD_N),
                        .OUTFF_AD_N(OUTFF_AD_N),
                        .RX_P(rx_p),
                        .RX_N(),
                        .TX_DATA_9(), 
                        .TX_DATA_8(),
                        .ARST_N(1'b1),
                        .RX_SYNC_RST(1'b1), 
                        .TX_SYNC_RST(1'b1),
                        .HS_IO_CLK(6'b0),
                        .RX_DQS_90(), 
                        .TX_DQS(1'b0),
                        .TX_DQS_270(1'b0),
                        .FIFO_WR_PTR(3'b0), 
                        .FIFO_RD_PTR(3'b0), 
                        .TX(tx),
                        .OE(oe),
                        .CDR_CLK(1'b0), 
                        .CDR_NEXT_CLK(1'b0),
                        .EYE_MONITOR_LANE_WIDTH(3'b0),
                        .DDR_DO_READ(),
                        .CDR_CLK_A_SEL_8(), 
                        .CDR_CLK_A_SEL_9(),
                        .CDR_CLK_A_SEL_10(),
                        .CDR_CLK_B_SEL(), 
                        .SWITCH(),
                        .CDR_CLR_NEXT_CLK_N(),
                        .TX_DATA_OUT_9(), 
                        .TX_DATA_OUT_8(),
                        .AL_N_OUT(),
                        .OUTFF_SL_OUT(),
                        .OUTFF_EN_OUT(),
                        .INFF_SL_OUT(),
                        .INFF_EN_OUT(),
                        .RX_CLK_OUT(),
                        .TX_CLK_OUT());
    

endmodule

