*********************************************************************************
* CoCo 3 RAM Stress Tester - memory.asm
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


***********************************************************
* MemMgr_MapPage
* - IN:      D = physical RAM page ($000-$3ff)
*            U = GIME memory map register ($FFA0-$FFAF)
* - OUT: 
* - Trashed: Upper 4 bits of A are cleared
***********************************************************

MemMgr_MapPage
            lsla
            lsla
            lsla
            lsla
            sta         $FF9B
            stb         ,u
            lsra
            lsra
            lsra
            lsra
            rts

***********************************************************
* MemMgr_BlockStoreConst
* - IN:      A = constant byte value to store, X = destination block number
* - OUT: 
* - Trashed: U
***********************************************************

MemMgr_BlockStoreConst
            exg         x,d
            ldu         #$FFA3
            jsr         MemMgr_MapPage
            exg         x,d
            ldu         #$6000
StoreLoop@
            sta         ,u
            sta         1,u
            sta         2,u
            sta         3,u
            sta         4,u
            sta         5,u
            sta         6,u
            sta         7,u
            leau        8,u
            cmpu        #$8000
            bne         StoreLoop@
            rts


***********************************************************
* MemMgr_BlockStoreRandom
* - IN:      X = destination block number
* - OUT: 
* - Trashed: A,B,U
***********************************************************

MemMgr_BlockStoreRandom
            tfr         x,d
            ldu         #$FFA3
            jsr         MemMgr_MapPage
            ldu         #$6000
StoreLoop@
            jsr         Util_Random
            sta         ,u+
            cmpu        #$8000
            bne         StoreLoop@
            rts


***********************************************************
* MemMgr_CopyPhysicalBlock
* - IN:      X = source block number, Y = destination block number
* - OUT: 
* - Trashed: A,B,X,Y,U
***********************************************************

MemMgr_CopyPhysicalBlock
            tfr         x,d
            ldu         #$FFA2
            jsr         MemMgr_MapPage
            tfr         y,d
            leau        1,u
            jsr         MemMgr_MapPage
            ldx         #$4000
            ldy         #$6000
CopyLoop@
            ldd         ,x++
            std         ,y++
            ldd         ,x++
            std         ,y++
            cmpx        #$6000
            bne         CopyLoop@
            rts


***********************************************************
* MemMgr_BlockCheckConst
* - IN:      A = expected byte value, X = destination block number
* - OUT: 
* - Trashed: X,U
***********************************************************

MemMgr_BlockCheckConst
            exg         x,d
            ldu         #$FFA2
            jsr         MemMgr_MapPage
            exg         x,d
            ldu         #$4000
CheckLoop@
            cmpa        ,u+
            bne         Error@
LoopTail@
            cmpu        #$6000
            bne         CheckLoop@
            rts
Error@
            pshs        a,x,u
            ldb         #1                      * number of repeated errors detected (max=3)
            cmpa        ,-u
            beq         ReadOK@
            incb
            cmpa        ,u
            beq         ReadOK@
            incb
ReadOK@
            stb         <ErrorRepeatCount
            ldb         ,u                      * A is expected value, B is actual value
            tfr         d,y                     * now expected/actual values are in Y
            tfr         u,d
            anda        #$1f
            exg         d,x                     * D is the physical memory block, 8k block offset is in X
            jsr         MemMgr_LogError
            puls        a,x,u
            bra         LoopTail@

***********************************************************
* MemMgr_BlockCheckRandom
* - IN:      X = destination block number
* - OUT: 
* - Trashed: D,U
***********************************************************

MemMgr_BlockCheckRandom
            tfr         x,d
            ldu         #$FFA2
            jsr         MemMgr_MapPage
            ldu         #$4000
CheckLoop@
            jsr         Util_Random
            cmpa        ,u+
            bne         Error@
LoopTail@
            cmpu        #$6000
            bne         CheckLoop@
            rts
Error@
            pshs        u,x
            ldb         #1                      * number of repeated errors detected (max=3)
            cmpa        ,-u
            beq         ReadOK@
            incb
            cmpa        ,u
            beq         ReadOK@
            incb
ReadOK@
            stb         <ErrorRepeatCount
            ldb         ,u                      * A is expected value, B is actual value
            tfr         d,y                     * now expected/actual values are in Y
            tfr         u,d
            anda        #$1f
            exg         d,x                     * D is the physical memory block, 8k block offset is in X
            jsr         MemMgr_LogError
            puls        u,x
            bra         LoopTail@

***********************************************************
* MemMgr_LogError
* - IN:      D = physical RAM block
*            X = memory block offset (0-$1fff)
*            Y = expected/actual byte values
* - OUT:     N/A
* - Trashed: A,B,X,Y,U
***********************************************************
*
*
MemMgr_LogError
            * move all of the list items down by one
            pshs        d,x,y
            ldu         #ErrorInfoList+8*7
            lda         #7
Loop1@
            ldx         -8,u
            stx         ,u
            ldx         -6,u
            stx         2,u
            ldx         -4,u
            stx         4,u
            ldx         -2,u
            stx         6,u
            leau        -8,u
            deca
            bne         Loop1@
            * store the info for this error at the top of the list
            ldd         <CurVerifyType
            std         ,u
            puls        d,x,y
            std         2,u
            stx         4,u
            sty         6,u
            * increment and redraw the error counter
            ldd         <ErrorCount
            addd        #1
            std         <ErrorCount
            ldx         #Test_Line2+28
            jsr         Util_WordToAsciiDecimal
            jsr         PrintLine4
            * redraw the list
            ldd         <ErrorCount
            cmpd        #8
            blo         >
            ldd         #8
!           clra
!           pshs        a,b
            jsr         PrintErrorLine
            puls        a,b
            inca
            decb
            bne         <
            rts
            

