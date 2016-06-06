*********************************************************************************
* CoCo 3 RAM Stress Tester - utility.asm
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
* Util_StrLen:
* - IN:      X=pointer to NULL-terminated string
* - OUT:     A=string length
* - Trashed: None
***********************************************************
Util_StrLen
            clra
StrLoop@
            tst         a,x
            beq         >
            inca
            bra         StrLoop@
!           rts

***********************************************************
* Util_Random:
* - IN:      
* - OUT:     A=psuedo-random number
* - Trashed: A,B
***********************************************************
Util_VarX       fcb     18
Util_VarA       fcb     166
Util_VarB       fcb     220
Util_VarC       fcb     64
*
Util_Random
            inc         <Util_VarX,PCR
            lda         <Util_VarA,PCR
            eora        <Util_VarC,PCR
            eora        <Util_VarX,PCR
            sta         <Util_VarA,PCR
            adda        <Util_VarB,PCR
            sta         <Util_VarB,PCR
            lsra             
            eora        <Util_VarA,PCR
            adda        <Util_VarC,PCR
            sta         <Util_VarC,PCR
            rts


***********************************************************
* Util_ByteToAsciiHex:
* - IN:      A = byte value to write
*            X = left-most byte of text string to fill
* - OUT:     
* - Trashed: A,B,U
***********************************************************
*
HexDigits@              fcc     '0123456789ABCDEF'
*
Util_ByteToAsciiHex:
            ldu         #HexDigits@
            tfr         a,b
            lsrb
            lsrb
            lsrb
            lsrb
            ldb         b,u
            stb         ,x
            anda        #$0f
            lda         a,u
            sta         1,x
            rts
***********************************************************
* Util_WordToAsciiHex:
* - IN:      D = word value to write
*            X = left-most byte of text string to fill
* - OUT:     
* - Trashed: A,B,U
***********************************************************
*
Util_WordToAsciiHex:
            ldu         #HexDigits@
            pshs        b
            tfr         a,b
            lsrb
            lsrb
            lsrb
            lsrb
            ldb         b,u
            stb         ,x
            anda        #$0f
            lda         a,u
            sta         1,x
            puls        a
            tfr         a,b
            lsrb
            lsrb
            lsrb
            lsrb
            ldb         b,u
            stb         2,x
            anda        #$0f
            lda         a,u
            sta         3,x
            rts

***********************************************************
* Util_WordToAsciiDecimal:
* - IN:      D = word to write
*            X = left-most byte of text string to fill
* - OUT:     
* - Trashed: A,B,U
***********************************************************
*
Util_WordToAsciiDecimal:
            * left-pad ascii buffer with zeroes
            ldu         #$3030
            stu         ,x++
            stu         ,x++
            leau        1,x
            * convert binary word to text by repeatedly dividing by 10
            std         Math_Dividend_16
            lda         #10
            sta         Math_Divisor_8
Loop1@
            jsr         Math_Divide16by8
            lda         Math_Remainder_8
            adda        #$30
            sta         ,-u
            ldd         Math_Quotient_16
            beq         >
            std         Math_Dividend_16
            bra         Loop1@
!           rts

