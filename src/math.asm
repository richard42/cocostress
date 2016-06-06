*********************************************************************************
* CoCo3 RAM Stress Tester - math.asm
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
* Math_Divide16by8:
*
* This routine divides a 16-bit unsigned integer by an 8-bit unsigned integer,
* producing a 16-bit quotient and 8-bit remainder. The algorithm was taken from:
*     http://www.programmersheaven.com/mb/pharabee/175172/175172/motorola-6809--divison-routines-anyone/
*
* - IN:      Math_Dividend_16, Math_Divisor_8
* - OUT:     Math_Quotient_16, Math_Remainder_8
* - Trashed: A,B,X,Y
***********************************************************

Math_Dividend_16        rmd     1
Math_Divisor_8          rmb     1
Math_Quotient_16        rmd     1
Math_Remainder_8        rmb     1
*
* 16-bit by 8-bit division
* Timing = 18 + 16*(45) + 30 = 768 clock cycles
*
LoopCount@              rmb     1
*
Math_Divide16by8:
            ldx         #16                     * 3
            sta         LoopCount@              * 5
            ldy         #0                      * 4 (clear remainder)
            ldd         Math_Dividend_16        * 6 (working quotient)
DivLoop@
            rolb                                * 2
            eorb        #1                      * 2
            rola                                * 2
            exg         d,y                     * 8
            rola                                * 2
            bcc         >                       * handle remainder overflow into bit 8
            suba        Math_Divisor_8
            andcc       #$FE                    * clear carry flag
            bra         DivLoop_NoBorrow@
!           suba        Math_Divisor_8          * 5
            bcc         DivLoop_NoBorrow@       * 3
            adda        Math_Divisor_8          * 5
DivLoop_NoBorrow@
            exg         d,y                     * 8
            leax        -1,x                    * 5
            bne         DivLoop@                * 3
            rolb                                * 2
            eorb        #1                      * 2
            rola                                * 2
            std         Math_Quotient_16        * 6
            exg         d,y                     * 8
            sta         Math_Remainder_8        * 5
            rts                                 * 5


