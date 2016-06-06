*********************************************************************************
* CoCo 3 RAM Stress Tester - graphics-bkgrnd.asm
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
* Gfx_GetPixelAddress:
*
* - IN:      A=Y coordinate in rows (0-199)
*            B=X coordinate in bytes (pixel pairs, 0-159)
* - OUT:     A=page number, Y=offset
* - Trashed: A,B,Y
***********************************************************
*
Gfx_GetPixelAddress
            pshs        a
            anda        #$1f
            tfr         d,y
            puls        a
            lsra
            lsra
            lsra
            lsra
            lsra
            adda        #$30
            rts

