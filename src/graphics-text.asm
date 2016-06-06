*********************************************************************************
* CoCo 3 RAM Stress Tester - graphics-text.asm
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
* Gfx_DrawTextLine:
*
* - IN:      A=Y coordinate in rows (0-199)
*            B=X coordinate in bytes (pixel pairs, 0-159)
*            X=pointer to NULL-terminated string
* - OUT:     N/A
* - Trashed: A,B,X,Y,U
***********************************************************
*
Gfx_DrawTextLine
            pshs        x
            adda        #2                      * chars took a 2-pixel haircut to save RAM
            jsr         Gfx_GetPixelAddress     * start by getting starting memory location
MapScreenWindow@
            tfr         a,b
            incb
            clr         $FF9B
            sta         $FFA4                   * map screen buffer to $8000-$BFFF
            stb         $FFA5
            leay        $8000,y                 * Y now points to starting destination byte
LetterLoop@
            puls        u
            ldb         ,u+                     * get next character
            bne         >                       * if non-0 character, continue forward
            rts                                 * otherwise we're done
*
* Locals
ColorMaskVal@   fcb     $00,$0f,$f0,$ff
RowCounter@     rmb     1
*
!           pshs        u
            subb        #$20                    * first printable character map is 32
            ldx         #Gfx_FontData
            ldu         #ColorMaskVal@
            lda         #12                     * 12 lines per char
            mul
            leax        d,x                     * X is pointer to 8x12 bitmap for current character
            lda         #12
            sta         RowCounter@
RowLoop@
            lda         ,x
            clrb
            lsla
            rolb
            lsla
            rolb
            ldb         b,u
            stb         ,y
            clrb
            lsla
            rolb
            lsla
            rolb
            ldb         b,u
            stb         1,y
            clrb
            lsla
            rolb
            lsla
            rolb
            ldb         b,u
            stb         2,y
            lsla
            rola
            rola
            ldb         a,u
            stb         3,y
            leax        1,x                     * advance bitmap pointer to next row
            leay        256,y                   * advance destination pixel pointer to next line
            dec         RowCounter@
            bne         RowLoop@
            leay        -3068,y                 * move pixel pointer up 12 rows and right 8 pixels (4 bytes)
            bra        LetterLoop@              * do next character in line

            * font data were generated with: hexdump -e '"            fcb     " 16/1 "$%02X," "\n"' ~/Desktop/pgcfont.bin > ../font.asm
Gfx_FontData
            fcb     $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
            fcb     $00,$18,$3C,$3C,$3C,$18,$18,$00,$18,$18,$00,$00
            fcb     $66,$66,$66,$24,$00,$00,$00,$00,$00,$00,$00,$00
            fcb     $00,$6C,$6C,$FE,$6C,$6C,$6C,$FE,$6C,$6C,$00,$00
            fcb     $18,$7C,$C6,$C2,$C0,$7C,$06,$86,$C6,$7C,$18,$18
            fcb     $00,$00,$00,$C2,$C6,$0C,$18,$30,$66,$C6,$00,$00
            fcb     $00,$38,$6C,$6C,$38,$76,$DC,$CC,$CC,$76,$00,$00
            fcb     $30,$30,$30,$60,$00,$00,$00,$00,$00,$00,$00,$00
            fcb     $00,$0C,$18,$30,$30,$30,$30,$30,$18,$0C,$00,$00
            fcb     $00,$30,$18,$0C,$0C,$0C,$0C,$0C,$18,$30,$00,$00
            fcb     $00,$00,$00,$66,$3C,$FF,$3C,$66,$00,$00,$00,$00
            fcb     $00,$00,$00,$18,$18,$7E,$18,$18,$00,$00,$00,$00
            fcb     $00,$00,$00,$00,$00,$00,$00,$18,$18,$18,$30,$00
            fcb     $00,$00,$00,$00,$00,$FE,$00,$00,$00,$00,$00,$00
            fcb     $00,$00,$00,$00,$00,$00,$00,$00,$18,$18,$00,$00
            fcb     $00,$02,$06,$0C,$18,$30,$60,$C0,$80,$00,$00,$00
            fcb     $00,$7C,$C6,$CE,$DE,$F6,$E6,$C6,$C6,$7C,$00,$00
            fcb     $00,$18,$38,$78,$18,$18,$18,$18,$18,$7E,$00,$00
            fcb     $00,$7C,$C6,$06,$0C,$18,$30,$60,$C6,$FE,$00,$00
            fcb     $00,$7C,$C6,$06,$06,$3C,$06,$06,$C6,$7C,$00,$00
            fcb     $00,$0C,$1C,$3C,$6C,$CC,$FE,$0C,$0C,$1E,$00,$00
            fcb     $00,$FE,$C0,$C0,$C0,$FC,$06,$06,$C6,$7C,$00,$00
            fcb     $00,$38,$60,$C0,$C0,$FC,$C6,$C6,$C6,$7C,$00,$00
            fcb     $00,$FE,$C6,$06,$0C,$18,$30,$30,$30,$30,$00,$00
            fcb     $00,$7C,$C6,$C6,$C6,$7C,$C6,$C6,$C6,$7C,$00,$00
            fcb     $00,$7C,$C6,$C6,$C6,$7E,$06,$06,$0C,$78,$00,$00
            fcb     $00,$00,$18,$18,$00,$00,$00,$18,$18,$00,$00,$00
            fcb     $00,$00,$18,$18,$00,$00,$00,$18,$18,$30,$00,$00
            fcb     $00,$06,$0C,$18,$30,$60,$30,$18,$0C,$06,$00,$00
            fcb     $00,$00,$00,$00,$7E,$00,$00,$7E,$00,$00,$00,$00
            fcb     $00,$60,$30,$18,$0C,$06,$0C,$18,$30,$60,$00,$00
            fcb     $00,$7C,$C6,$C6,$0C,$18,$18,$00,$18,$18,$00,$00
            fcb     $00,$7C,$C6,$C6,$DE,$DE,$DE,$DC,$C0,$7C,$00,$00
            fcb     $00,$10,$38,$6C,$C6,$C6,$FE,$C6,$C6,$C6,$00,$00
            fcb     $00,$FC,$66,$66,$66,$7C,$66,$66,$66,$FC,$00,$00
            fcb     $00,$3C,$66,$C2,$C0,$C0,$C0,$C2,$66,$3C,$00,$00
            fcb     $00,$F8,$6C,$66,$66,$66,$66,$66,$6C,$F8,$00,$00
            fcb     $00,$FE,$66,$62,$68,$78,$68,$62,$66,$FE,$00,$00
            fcb     $00,$FE,$66,$62,$68,$78,$68,$60,$60,$F0,$00,$00
            fcb     $00,$3C,$66,$C2,$C0,$C0,$DE,$C6,$66,$3A,$00,$00
            fcb     $00,$C6,$C6,$C6,$C6,$FE,$C6,$C6,$C6,$C6,$00,$00
            fcb     $00,$3C,$18,$18,$18,$18,$18,$18,$18,$3C,$00,$00
            fcb     $00,$1E,$0C,$0C,$0C,$0C,$0C,$CC,$CC,$78,$00,$00
            fcb     $00,$E6,$66,$6C,$6C,$78,$6C,$6C,$66,$E6,$00,$00
            fcb     $00,$F0,$60,$60,$60,$60,$60,$62,$66,$FE,$00,$00
            fcb     $00,$C6,$EE,$FE,$FE,$D6,$C6,$C6,$C6,$C6,$00,$00
            fcb     $00,$C6,$E6,$F6,$FE,$DE,$CE,$C6,$C6,$C6,$00,$00
            fcb     $00,$38,$6C,$C6,$C6,$C6,$C6,$C6,$6C,$38,$00,$00
            fcb     $00,$FC,$66,$66,$66,$7C,$60,$60,$60,$F0,$00,$00
            fcb     $00,$7C,$C6,$C6,$C6,$C6,$D6,$DE,$7C,$0C,$0E,$00
            fcb     $00,$FC,$66,$66,$66,$7C,$6C,$66,$66,$E6,$00,$00
            fcb     $00,$7C,$C6,$C6,$60,$38,$0C,$C6,$C6,$7C,$00,$00
            fcb     $00,$7E,$7E,$5A,$18,$18,$18,$18,$18,$3C,$00,$00
            fcb     $00,$C6,$C6,$C6,$C6,$C6,$C6,$C6,$C6,$7C,$00,$00
            fcb     $00,$C6,$C6,$C6,$C6,$C6,$C6,$6C,$38,$10,$00,$00
            fcb     $00,$C6,$C6,$C6,$C6,$D6,$D6,$FE,$7C,$6C,$00,$00
            fcb     $00,$C6,$C6,$6C,$38,$38,$38,$6C,$C6,$C6,$00,$00
            fcb     $00,$66,$66,$66,$66,$3C,$18,$18,$18,$3C,$00,$00
            fcb     $00,$FE,$C6,$8C,$18,$30,$60,$C2,$C6,$FE,$00,$00
            fcb     $00,$3C,$30,$30,$30,$30,$30,$30,$30,$3C,$00,$00
            fcb     $00,$80,$C0,$E0,$70,$38,$1C,$0E,$06,$02,$00,$00
            fcb     $00,$3C,$0C,$0C,$0C,$0C,$0C,$0C,$0C,$3C,$00,$00
            fcb     $10,$38,$6C,$C6,$00,$00,$00,$00,$00,$00,$00,$00
            fcb     $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF
            fcb     $30,$30,$18,$00,$00,$00,$00,$00,$00,$00,$00,$00
            fcb     $00,$00,$00,$00,$78,$0C,$7C,$CC,$CC,$76,$00,$00
            fcb     $00,$E0,$60,$60,$78,$6C,$66,$66,$66,$7C,$00,$00
            fcb     $00,$00,$00,$00,$7C,$C6,$C0,$C0,$C6,$7C,$00,$00
            fcb     $00,$1C,$0C,$0C,$3C,$6C,$CC,$CC,$CC,$76,$00,$00
            fcb     $00,$00,$00,$00,$7C,$C6,$FE,$C0,$C6,$7C,$00,$00
            fcb     $00,$38,$6C,$64,$60,$F0,$60,$60,$60,$F0,$00,$00
            fcb     $00,$00,$00,$00,$76,$CC,$CC,$CC,$7C,$0C,$CC,$78
            fcb     $00,$E0,$60,$60,$6C,$76,$66,$66,$66,$E6,$00,$00
            fcb     $00,$18,$18,$00,$38,$18,$18,$18,$18,$3C,$00,$00
            fcb     $00,$06,$06,$00,$0E,$06,$06,$06,$06,$66,$66,$3C
            fcb     $00,$E0,$60,$60,$66,$6C,$78,$6C,$66,$E6,$00,$00
            fcb     $00,$38,$18,$18,$18,$18,$18,$18,$18,$3C,$00,$00
            fcb     $00,$00,$00,$00,$EC,$FE,$D6,$D6,$D6,$C6,$00,$00
            fcb     $00,$00,$00,$00,$DC,$66,$66,$66,$66,$66,$00,$00
            fcb     $00,$00,$00,$00,$7C,$C6,$C6,$C6,$C6,$7C,$00,$00
            fcb     $00,$00,$00,$00,$DC,$66,$66,$66,$7C,$60,$60,$F0
            fcb     $00,$00,$00,$00,$76,$CC,$CC,$CC,$7C,$0C,$0C,$1E
            fcb     $00,$00,$00,$00,$DC,$76,$66,$60,$60,$F0,$00,$00
            fcb     $00,$00,$00,$00,$7C,$C6,$70,$1C,$C6,$7C,$00,$00
            fcb     $00,$10,$30,$30,$FC,$30,$30,$30,$36,$1C,$00,$00
            fcb     $00,$00,$00,$00,$CC,$CC,$CC,$CC,$CC,$76,$00,$00
            fcb     $00,$00,$00,$00,$66,$66,$66,$66,$3C,$18,$00,$00
            fcb     $00,$00,$00,$00,$C6,$C6,$D6,$D6,$FE,$6C,$00,$00
            fcb     $00,$00,$00,$00,$C6,$6C,$38,$38,$6C,$C6,$00,$00
            fcb     $00,$00,$00,$00,$C6,$C6,$C6,$C6,$7E,$06,$0C,$F8
            fcb     $00,$00,$00,$00,$FE,$CC,$18,$30,$66,$FE,$00,$00
            fcb     $00,$0E,$18,$18,$18,$70,$18,$18,$18,$0E,$00,$00
            fcb     $00,$18,$18,$18,$18,$00,$18,$18,$18,$18,$00,$00
            fcb     $00,$70,$18,$18,$18,$0E,$18,$18,$18,$70,$00,$00
            fcb     $00,$76,$DC,$00,$00,$00,$00,$00,$00,$00,$00,$00
            fcb     $00,$00,$00,$10,$38,$6C,$C6,$C6,$FE,$00,$00,$00

