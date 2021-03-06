;******************************************************************************
;*
;* Copyright (c) 2000-2001 Fabrice Bellard <fabrice@bellard.org>
;* Copyright (c)      Nick Kurshev <nickols_k@mail.ru>
;* Copyright (c) 2002 Michael Niedermayer <michaelni@gmx.at>
;* Copyright (c) 2002 Zdenek Kabelac <kabi@informatics.muni.cz>
;* Copyright (c) 2013 Daniel Kang
;*
;* SIMD-optimized halfpel functions
;*
;* This file is part of FFmpeg.
;*
;* FFmpeg is free software; you can redistribute it and/or
;* modify it under the terms of the GNU Lesser General Public
;* License as published by the Free Software Foundation; either
;* version 2.1 of the License, or (at your option) any later version.
;*
;* FFmpeg is distributed in the hope that it will be useful,
;* but WITHOUT ANY WARRANTY; without even the implied warranty of
;* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;* Lesser General Public License for more details.
;*
;* You should have received a copy of the GNU Lesser General Public
;* License along with FFmpeg; if not, write to the Free Software
;* Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
;******************************************************************************

%include "libavutil/x86/x86util.asm"

SECTION_RODATA
cextern pb_1
cextern pw_2

SECTION_TEXT

; void ff_put_pixels8_x2(uint8_t *block, const uint8_t *pixels, ptrdiff_t line_size, int h)
%macro PUT_PIXELS8_X2 0
cglobal put_pixels8_x2, 4,5
    lea          r4, [r2*2]
.loop:
    mova         m0, [r1]
    mova         m1, [r1+r2]
    PAVGB        m0, [r1+1]
    PAVGB        m1, [r1+r2+1]
    mova       [r0], m0
    mova    [r0+r2], m1
    add          r1, r4
    add          r0, r4
    mova         m0, [r1]
    mova         m1, [r1+r2]
    PAVGB        m0, [r1+1]
    PAVGB        m1, [r1+r2+1]
    add          r1, r4
    mova       [r0], m0
    mova    [r0+r2], m1
    add          r0, r4
    sub         r3d, 4
    jne .loop
    REP_RET
%endmacro

INIT_MMX mmxext
PUT_PIXELS8_X2
INIT_MMX 3dnow
PUT_PIXELS8_X2


; void ff_put_pixels16_x2(uint8_t *block, const uint8_t *pixels, ptrdiff_t line_size, int h)
%macro PUT_PIXELS_16 0
cglobal put_pixels16_x2, 4,5
    lea          r4, [r2*2]
.loop:
    mova         m0, [r1]
    mova         m1, [r1+r2]
    mova         m2, [r1+8]
    mova         m3, [r1+r2+8]
    PAVGB        m0, [r1+1]
    PAVGB        m1, [r1+r2+1]
    PAVGB        m2, [r1+9]
    PAVGB        m3, [r1+r2+9]
    mova       [r0], m0
    mova    [r0+r2], m1
    mova     [r0+8], m2
    mova  [r0+r2+8], m3
    add          r1, r4
    add          r0, r4
    mova         m0, [r1]
    mova         m1, [r1+r2]
    mova         m2, [r1+8]
    mova         m3, [r1+r2+8]
    PAVGB        m0, [r1+1]
    PAVGB        m1, [r1+r2+1]
    PAVGB        m2, [r1+9]
    PAVGB        m3, [r1+r2+9]
    add          r1, r4
    mova       [r0], m0
    mova    [r0+r2], m1
    mova     [r0+8], m2
    mova  [r0+r2+8], m3
    add          r0, r4
    sub         r3d, 4
    jne .loop
    REP_RET
%endmacro

INIT_MMX mmxext
PUT_PIXELS_16
INIT_MMX 3dnow
PUT_PIXELS_16


; void ff_put_no_rnd_pixels8_x2(uint8_t *block, const uint8_t *pixels, ptrdiff_t line_size, int h)
%macro PUT_NO_RND_PIXELS8_X2 0
cglobal put_no_rnd_pixels8_x2, 4,5
    mova         m6, [pb_1]
    lea          r4, [r2*2]
.loop:
    mova         m0, [r1]
    mova         m2, [r1+r2]
    mova         m1, [r1+1]
    mova         m3, [r1+r2+1]
    add          r1, r4
    psubusb      m0, m6
    psubusb      m2, m6
    PAVGB        m0, m1
    PAVGB        m2, m3
    mova       [r0], m0
    mova    [r0+r2], m2
    mova         m0, [r1]
    mova         m1, [r1+1]
    mova         m2, [r1+r2]
    mova         m3, [r1+r2+1]
    add          r0, r4
    add          r1, r4
    psubusb      m0, m6
    psubusb      m2, m6
    PAVGB        m0, m1
    PAVGB        m2, m3
    mova       [r0], m0
    mova    [r0+r2], m2
    add          r0, r4
    sub         r3d, 4
    jne .loop
    REP_RET
%endmacro

INIT_MMX mmxext
PUT_NO_RND_PIXELS8_X2
INIT_MMX 3dnow
PUT_NO_RND_PIXELS8_X2


; void ff_put_no_rnd_pixels8_x2_exact(uint8_t *block, const uint8_t *pixels, ptrdiff_t line_size, int h)
%macro PUT_NO_RND_PIXELS8_X2_EXACT 0
cglobal put_no_rnd_pixels8_x2_exact, 4,5
    lea          r4, [r2*3]
    pcmpeqb      m6, m6
.loop:
    mova         m0, [r1]
    mova         m2, [r1+r2]
    mova         m1, [r1+1]
    mova         m3, [r1+r2+1]
    pxor         m0, m6
    pxor         m2, m6
    pxor         m1, m6
    pxor         m3, m6
    PAVGB        m0, m1
    PAVGB        m2, m3
    pxor         m0, m6
    pxor         m2, m6
    mova       [r0], m0
    mova    [r0+r2], m2
    mova         m0, [r1+r2*2]
    mova         m1, [r1+r2*2+1]
    mova         m2, [r1+r4]
    mova         m3, [r1+r4+1]
    pxor         m0, m6
    pxor         m1, m6
    pxor         m2, m6
    pxor         m3, m6
    PAVGB        m0, m1
    PAVGB        m2, m3
    pxor         m0, m6
    pxor         m2, m6
    mova  [r0+r2*2], m0
    mova    [r0+r4], m2
    lea          r1, [r1+r2*4]
    lea          r0, [r0+r2*4]
    sub         r3d, 4
    jg .loop
    REP_RET
%endmacro

INIT_MMX mmxext
PUT_NO_RND_PIXELS8_X2_EXACT
INIT_MMX 3dnow
PUT_NO_RND_PIXELS8_X2_EXACT


; void ff_put_pixels8_y2(uint8_t *block, const uint8_t *pixels, ptrdiff_t line_size, int h)
%macro PUT_PIXELS8_Y2 0
cglobal put_pixels8_y2, 4,5
    lea          r4, [r2*2]
    mova         m0, [r1]
    sub          r0, r2
.loop:
    mova         m1, [r1+r2]
    mova         m2, [r1+r4]
    add          r1, r4
    PAVGB        m0, m1
    PAVGB        m1, m2
    mova    [r0+r2], m0
    mova    [r0+r4], m1
    mova         m1, [r1+r2]
    mova         m0, [r1+r4]
    add          r0, r4
    add          r1, r4
    PAVGB        m2, m1
    PAVGB        m1, m0
    mova    [r0+r2], m2
    mova    [r0+r4], m1
    add          r0, r4
    sub         r3d, 4
    jne .loop
    REP_RET
%endmacro

INIT_MMX mmxext
PUT_PIXELS8_Y2
INIT_MMX 3dnow
PUT_PIXELS8_Y2


; void ff_put_no_rnd_pixels8_y2(uint8_t *block, const uint8_t *pixels, ptrdiff_t line_size, int h)
%macro PUT_NO_RND_PIXELS8_Y2 0
cglobal put_no_rnd_pixels8_y2, 4,5
    mova         m6, [pb_1]
    lea          r4, [r2+r2]
    mova         m0, [r1]
    sub          r0, r2
.loop:
    mova         m1, [r1+r2]
    mova         m2, [r1+r4]
    add          r1, r4
    psubusb      m1, m6
    PAVGB        m0, m1
    PAVGB        m1, m2
    mova    [r0+r2], m0
    mova    [r0+r4], m1
    mova         m1, [r1+r2]
    mova         m0, [r1+r4]
    add          r0, r4
    add          r1, r4
    psubusb      m1, m6
    PAVGB        m2, m1
    PAVGB        m1, m0
    mova    [r0+r2], m2
    mova    [r0+r4], m1
    add          r0, r4
    sub         r3d, 4
    jne .loop
    REP_RET
%endmacro

INIT_MMX mmxext
PUT_NO_RND_PIXELS8_Y2
INIT_MMX 3dnow
PUT_NO_RND_PIXELS8_Y2


; void ff_put_no_rnd_pixels8_y2_exact(uint8_t *block, const uint8_t *pixels, ptrdiff_t line_size, int h)
%macro PUT_NO_RND_PIXELS8_Y2_EXACT 0
cglobal put_no_rnd_pixels8_y2_exact, 4,5
    lea          r4, [r2*3]
    mova         m0, [r1]
    pcmpeqb      m6, m6
    add          r1, r2
    pxor         m0, m6
.loop:
    mova         m1, [r1]
    mova         m2, [r1+r2]
    pxor         m1, m6
    pxor         m2, m6
    PAVGB        m0, m1
    PAVGB        m1, m2
    pxor         m0, m6
    pxor         m1, m6
    mova       [r0], m0
    mova    [r0+r2], m1
    mova         m1, [r1+r2*2]
    mova         m0, [r1+r4]
    pxor         m1, m6
    pxor         m0, m6
    PAVGB        m2, m1
    PAVGB        m1, m0
    pxor         m2, m6
    pxor         m1, m6
    mova  [r0+r2*2], m2
    mova    [r0+r4], m1
    lea          r1, [r1+r2*4]
    lea          r0, [r0+r2*4]
    sub         r3d, 4
    jg .loop
    REP_RET
%endmacro

INIT_MMX mmxext
PUT_NO_RND_PIXELS8_Y2_EXACT
INIT_MMX 3dnow
PUT_NO_RND_PIXELS8_Y2_EXACT


; void ff_avg_pixels8(uint8_t *block, const uint8_t *pixels, ptrdiff_t line_size, int h)
%macro AVG_PIXELS8 0
cglobal avg_pixels8, 4,5
    lea          r4, [r2*2]
.loop:
    mova         m0, [r0]
    mova         m1, [r0+r2]
    PAVGB        m0, [r1]
    PAVGB        m1, [r1+r2]
    mova       [r0], m0
    mova    [r0+r2], m1
    add          r1, r4
    add          r0, r4
    mova         m0, [r0]
    mova         m1, [r0+r2]
    PAVGB        m0, [r1]
    PAVGB        m1, [r1+r2]
    add          r1, r4
    mova       [r0], m0
    mova    [r0+r2], m1
    add          r0, r4
    sub         r3d, 4
    jne .loop
    REP_RET
%endmacro

INIT_MMX 3dnow
AVG_PIXELS8


; void ff_avg_pixels8_x2(uint8_t *block, const uint8_t *pixels, ptrdiff_t line_size, int h)
%macro PAVGB_MMX 4
    movu   %3, %1
    por    %3, %2
    pxor   %2, %1
    pand   %2, %4
    psrlq  %2, 1
    psubb  %3, %2
    SWAP   %2, %3
%endmacro

%macro AVG_PIXELS8_X2 0
cglobal avg_pixels8_x2, 4,5
    lea          r4, [r2*2]
%if notcpuflag(mmxext)
    pcmpeqd      m5, m5
    paddb        m5, m5
%endif
.loop:
    mova         m0, [r1]
    mova         m2, [r1+r2]
%if notcpuflag(mmxext)
    PAVGB_MMX    [r1+1], m0, m3, m5
    PAVGB_MMX    [r1+r2+1], m2, m4, m5
    PAVGB_MMX    [r0], m0, m3, m5
    PAVGB_MMX    [r0+r2], m2, m4, m5
%else
    PAVGB        m0, [r1+1]
    PAVGB        m2, [r1+r2+1]
    PAVGB        m0, [r0]
    PAVGB        m2, [r0+r2]
%endif
    add          r1, r4
    mova       [r0], m0
    mova    [r0+r2], m2
    mova         m0, [r1]
    mova         m2, [r1+r2]
%if notcpuflag(mmxext)
    PAVGB_MMX    [r1+1], m0, m3, m5
    PAVGB_MMX    [r1+r2+1], m2, m4, m5
%else
    PAVGB        m0, [r1+1]
    PAVGB        m2, [r1+r2+1]
%endif
    add          r0, r4
    add          r1, r4
%if notcpuflag(mmxext)
    PAVGB_MMX    [r0], m0, m3, m5
    PAVGB_MMX    [r0+r2], m2, m4, m5
%else
    PAVGB        m0, [r0]
    PAVGB        m2, [r0+r2]
%endif
    mova       [r0], m0
    mova    [r0+r2], m2
    add          r0, r4
    sub         r3d, 4
    jne .loop
    REP_RET
%endmacro

INIT_MMX mmx
AVG_PIXELS8_X2
INIT_MMX mmxext
AVG_PIXELS8_X2
INIT_MMX 3dnow
AVG_PIXELS8_X2


; void ff_avg_pixels8_y2(uint8_t *block, const uint8_t *pixels, ptrdiff_t line_size, int h)
%macro AVG_PIXELS8_Y2 0
cglobal avg_pixels8_y2, 4,5
    lea          r4, [r2*2]
    mova         m0, [r1]
    sub          r0, r2
.loop:
    mova         m1, [r1+r2]
    mova         m2, [r1+r4]
    add          r1, r4
    PAVGB        m0, m1
    PAVGB        m1, m2
    mova         m3, [r0+r2]
    mova         m4, [r0+r4]
    PAVGB        m0, m3
    PAVGB        m1, m4
    mova    [r0+r2], m0
    mova    [r0+r4], m1
    mova         m1, [r1+r2]
    mova         m0, [r1+r4]
    PAVGB        m2, m1
    PAVGB        m1, m0
    add          r0, r4
    add          r1, r4
    mova         m3, [r0+r2]
    mova         m4, [r0+r4]
    PAVGB        m2, m3
    PAVGB        m1, m4
    mova    [r0+r2], m2
    mova    [r0+r4], m1
    add          r0, r4
    sub         r3d, 4
    jne .loop
    REP_RET
%endmacro

INIT_MMX mmxext
AVG_PIXELS8_Y2
INIT_MMX 3dnow
AVG_PIXELS8_Y2


; void ff_avg_pixels8_xy2(uint8_t *block, const uint8_t *pixels, ptrdiff_t line_size, int h)
; Note this is not correctly rounded, and is therefore used for
; not-bitexact output
%macro AVG_APPROX_PIXELS8_XY2 0
cglobal avg_approx_pixels8_xy2, 4,5
    mova         m6, [pb_1]
    lea          r4, [r2*2]
    mova         m0, [r1]
    PAVGB        m0, [r1+1]
.loop:
    mova         m2, [r1+r4]
    mova         m1, [r1+r2]
    psubusb      m2, m6
    PAVGB        m1, [r1+r2+1]
    PAVGB        m2, [r1+r4+1]
    add          r1, r4
    PAVGB        m0, m1
    PAVGB        m1, m2
    PAVGB        m0, [r0]
    PAVGB        m1, [r0+r2]
    mova       [r0], m0
    mova    [r0+r2], m1
    mova         m1, [r1+r2]
    mova         m0, [r1+r4]
    PAVGB        m1, [r1+r2+1]
    PAVGB        m0, [r1+r4+1]
    add          r0, r4
    add          r1, r4
    PAVGB        m2, m1
    PAVGB        m1, m0
    PAVGB        m2, [r0]
    PAVGB        m1, [r0+r2]
    mova       [r0], m2
    mova    [r0+r2], m1
    add          r0, r4
    sub         r3d, 4
    jne .loop
    REP_RET
%endmacro

INIT_MMX mmxext
AVG_APPROX_PIXELS8_XY2
INIT_MMX 3dnow
AVG_APPROX_PIXELS8_XY2


; void ff_avg_pixels16_xy2(uint8_t *block, const uint8_t *pixels, ptrdiff_t line_size, int h)
%macro AVG_PIXELS_XY2 0
%if cpuflag(sse2)
cglobal avg_pixels16_xy2, 4,5,8
%else
cglobal avg_pixels8_xy2, 4,5
%endif
    pxor        m7, m7
    mova        m6, [pw_2]
    movu        m0, [r1]
    movu        m4, [r1+1]
    mova        m1, m0
    mova        m5, m4
    punpcklbw   m0, m7
    punpcklbw   m4, m7
    punpckhbw   m1, m7
    punpckhbw   m5, m7
    paddusw     m4, m0
    paddusw     m5, m1
    xor         r4, r4
    add         r1, r2
.loop:
    movu        m0, [r1+r4]
    movu        m2, [r1+r4+1]
    mova        m1, m0
    mova        m3, m2
    punpcklbw   m0, m7
    punpcklbw   m2, m7
    punpckhbw   m1, m7
    punpckhbw   m3, m7
    paddusw     m0, m2
    paddusw     m1, m3
    paddusw     m4, m6
    paddusw     m5, m6
    paddusw     m4, m0
    paddusw     m5, m1
    psrlw       m4, 2
    psrlw       m5, 2
    mova        m3, [r0+r4]
    packuswb    m4, m5
    PAVGB       m4, m3
    mova   [r0+r4], m4
    add         r4, r2

    movu        m2, [r1+r4]
    movu        m4, [r1+r4+1]
    mova        m3, m2
    mova        m5, m4
    punpcklbw   m2, m7
    punpcklbw   m4, m7
    punpckhbw   m3, m7
    punpckhbw   m5, m7
    paddusw     m4, m2
    paddusw     m5, m3
    paddusw     m0, m6
    paddusw     m1, m6
    paddusw     m0, m4
    paddusw     m1, m5
    psrlw       m0, 2
    psrlw       m1, 2
    mova        m3, [r0+r4]
    packuswb    m0, m1
    PAVGB       m0, m3
    mova   [r0+r4], m0
    add         r4, r2
    sub        r3d, 2
    jnz .loop
    REP_RET
%endmacro

INIT_MMX mmxext
AVG_PIXELS_XY2
INIT_MMX 3dnow
AVG_PIXELS_XY2
