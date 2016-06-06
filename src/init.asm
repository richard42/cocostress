*********************************************************************************
* CoCo 3 RAM Stress Tester - init.asm
* Copyright (c) 2015-2016, Richard Goedeken
* All rights reserved.
*
*    This file is part of CoCo 3 RAM Stress Tester.
*
*    CoCo 3 RAM Stress Tester is free software: you can redistribute it
*    and/or modify it under the terms of the GNU General Public License
*    as published by the Free Software Foundation, either version 3 of
*    the License, or (at your option) any later version.
*
*    CoCo 3 RAM Stress Tester is distributed in the hope that it will be
*    useful, but WITHOUT ANY WARRANTY; without even the implied warranty
*    of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*    GNU General Public License for more details.
*
*    You should have received a copy of the GNU General Public License
*    along with CoCo 3 RAM Stress Tester.  If not, see:
*    <http://www.gnu.org/licenses/>.
*
*********************************************************************************
*
* This module contains code which is only used for program startup and can be
* safely overwritten after the test starts

* PIA default register value definitions
* CA1/CB1 are always interrupts, CA2/CB2 are always outputs
PIA0A_Ctrl          equ     %00110100           * CA2 = DAC SELA (low), Data Register, CA1 = HSync interrupt active low disabled
PIA0B_Ctrl          equ     %00110100           * CB2 = DAC SELB (low), Data Register, CB1 = VSync interrupt active low disabled

***********************************************************
* Init_SetupHardware:
* - IN:      
* - OUT:     
* - Trashed: A
***********************************************************
Init_SetupHardware
            clr         $FFD9                   * turbo cpu frequency
            orcc        #$50                    * disabled interrupts
            lda         #$FC                    * coco2 gfx, MMU enabled, coco3 IRQ and FIRQ handling enabled
                                                * fix $FE** page to high ram, standard SCS, rom: 16k internal / 16k cartridge
            sta         $FF90                   * set GIME init register 0
            * initialize PIA0 state
            lda         #(PIA0A_Ctrl)           * set CA1/CA2 pin modes, data register
            sta         $FF01
            lda         #(PIA0B_Ctrl)           * set CB1/CB2 pin modes, data register
            sta         $FF03
            * read both PIA data registers to clear any fired interrupts
            lda         $FF00
            lda         $FF02
            lda         $FF20
            lda         $FF22
            * Note that $FF92/93 are only writeable
            * Reading them will return the state of the hardware signals
            * It will not tell you which IRQs are enabled
            clr         $FF92                   * disable all IRQs
            clr         $FF93                   * disable all FIRQs
            andcc       #$AF                    * re-enable interrupts
            clr         $FF40                   * turn off drive motor
            rts


***********************************************************
* Init_DetectRAM
* - IN:      X = location to store memory size (text)
* - OUT: 
* - Trashed: D,X,Y,U
***********************************************************
*
Init_DetectRAM
            * pre-fill the memory size text with spaces and advance to the end
            ldd         #$2020
            std         ,x++
            std         ,x++
            pshs        x
            * set pattern values
            ldx         #$1234
            ldy         #$5678
            * set first word in first page to pattern A
            ldd         #$0000
            ldu         #$FFA2
            jsr         MemMgr_MapPage
            stx         $4000
DRLoop1@
            * set first word of next 128k block to pattern B
            addd        #$0010
            jsr         MemMgr_MapPage
            sty         $4000
            * if this this pattern B write was mirrored into any of the
            * earlier pages, then we found the memory limit
            pshs        a,b
DRLoop2@
            subd        #$0010
            jsr         MemMgr_MapPage
            cmpx        $4000
            bne         FoundLimit@
            cmpd        #$0000
            bne         DRLoop2@
            * the limit was not found, set the first word of current block to pattern A
            puls        a,b
            jsr         MemMgr_MapPage
            stx         $4000
            * go to the next 128k block
            cmpd        #$03f0
            bne         DRLoop1@
            * we searched entire 8MB space and it's all good
            ldd         #$0400
            pshs        a,b
FoundLimit@
            * set the starting and ending page numbers (128k is a special case)
            puls        a,b
            cmpd        #$10
            bne         MoreThan128k@
            ldx         #$30
            stx         <TestPageStart
            ldx         #$3f
            stx         <TestPageEnd
            bra         PrintMemSize@
MoreThan128k@
            ldx         #0
            stx         <TestPageStart
            subd        #1
            std         <TestPageEnd
            addd        #1
PrintMemSize@
            * we have memory size in 8k blocks in D. Multipy by 8 to get # of KB
            lslb
            rola
            lslb
            rola
            lslb
            rola
            * convert # of kilobytes to text by repeatedly dividing by 10
            puls        u
            std         Math_Dividend_16
            lda         #10
            sta         Math_Divisor_8
DRLoop3@
            jsr         Math_Divide16by8
            lda         Math_Remainder_8
            adda        #$30
            sta         ,-u
            ldd         Math_Quotient_16
            beq         >
            std         Math_Dividend_16
            bra         DRLoop3@
!           clr         $FF9B
            rts

***********************************************************
* Init_EnableGraphics:
* - IN:      
* - OUT:     
* - Trashed: A,B,X,Y
***********************************************************
Init_EnableGraphics
            jsr         Init_SetPalette
            orcc        #$50                    * disable interrupts
            lda         #$74                    * Coco3 gfx, MMU enabled, coco3 IRQ/FIRQ enabled
                                                * don't fix $FE** page to high ram, standard SCS, rom: 16k internal/16k cartridge
            sta         $FF90
            lda         #$20                    * 64k memory chips, 279nsec timer input, MMU register bank 0
            sta         $FF91
            lda         #$80                    * graphics mode, color output, 60 hz, max vertical res
            sta         $FF98
            lda         #$3E                    * 320 x 200 x 16 color
            sta         $FF99
            clr         $FF9C                   * clear vertical scroll (only used for text modes)
            ldd         #$C000                  * physical address $60000
            std         $FF9D                   * set GIME vertical offset register
            lda         #$80                    * set Horizontal virtual screen enable (256-byte rows)
            sta         $FF9F                   * set GIME horizontal offset register
            andcc       #$AF                    * re-enable interrupts
            clr         $FFB0                   * palette index 0: black
            lda         #63
            sta         $FFBF                   * palette index 15: white
            rts

***********************************************************
* Init_SetPalette:
*
* - IN:      None
* - OUT: 
* - Trashed: A,B,X,Y
***********************************************************

PaletteRGB              fcb     0,4,32,36,52,54,51,19,26,25,11,43,45,61,56,63

Init_SetPalette
            ldx         #PaletteRGB
            ldy         #$FFB0
            ldb         #16                     * set 16 palette entries
!           lda         ,x+
            sta         ,y+
            decb
            bne         <
            rts

