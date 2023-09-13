; uint16_t checksum_fast(uint16_t size)
; IP/UDP checksum routine based on ADCQ opcodes
; Input data needs to be placed at $C800
; Data size needs to be provided in AX (A lo, X hi)
; Result checksum is returned in AX (A lo, X hi)
.global checksum_fast
.section .text.checksum_fast,"ax",@progbits
checksum_fast:
        tay                     ; keep data size lo in y
        stx __rc2
        phz
        ldz __rc2               ; remember sizehi in z

        cld

        lda #$c8
        clc
        adc __rc2
        tab

        tya
        and #$03                ; size lo mod 4
        beq multiple_of_four    ; is size multiple of 4?
        eor #$03                ; determine zeros to fill to align to 4 bytes
        tax
        sty 1f+1                 ; size low = write address in basepage
        lda #$00                ; fill with 0
1:
        sta $00,x               ; self modifying code! is replaced with zero fill address
        dex                     ; next byte to zeroise
        bpl 1b                  ; all bytes done?
        tya
        and #$fc                ; round down to multiple of four
        beq start_at_zero
        bra start               ; start sum loop

multiple_of_four:
        tya                     ; get size lo
        sec                     ; reduce by 4
        sbc #$04                ; to get to first read address
        beq start_at_zero       ; if size lo was 4
        bcs start               ; if size lo was zero
        tay
        tba                     ; decrement bp
        dec
        dez                     ; also adapt size hi copy in z
        tab
        tya                     ; load size lo
        bne start               ; start at page boundary?

start_at_zero:
        dez
        bmi just_four
        stz _sizehi
        clc
        neg
        neg
        lda $00
        bra next_page

just_four:
        neg
        neg
        lda $00
        bra done

start:
        stz _sizehi
        clc
        sta add+3
        lda #$00
        tax
        tay
        taz
        bra add

sum_loop:
        sta add+3               ; A contains new data read ptr
        pla                     ; restore lo of 2 bit sum
add:
        ; actual 32 bit checksum loop (looping per page)
        neg
        neg
        adc $00                 ; self-mod code (replaced by data read ptr)
dec_data_ptr:
        pha
        lda add+3
        dec
        dec
        dec
        dec
        bne sum_loop

        ; finally add first 32 bit word
        pla
        neg
        neg
        adc $00

        ; next page or done?
        dec _sizehi
        bmi done

next_page:
        ; move to next page and reset quad counter (add+3)
        ; carry needs to stay unchanged until we jump back to sum_loop
        pha                     ; remember lo of 32 bit sum
        tba                     ; move on to previous page
        dec
        tab
        lda #$fc                ; complete page (first quad at $fc)
        bra sum_loop            ; continue loop

done:
        neg
        neg
        sta _result              ; chks lo = result[0] + result[2]
        adc _result+2
        tay                     ; Y = chks lo
        lda #$00                ; A is free now, use it to
        tab                     ; reset bp to zp
        txa
        adc _result+3            ; chks hi = result[1] + result[3]
        bcc 1f                  ; carry still set?
        iny                     ; increase chks lo
        bne 1f                  ; overflow?
        inc                     ; increase chks hi
        bne 1f                  ; still carry?
        iny                     ; increase chks lo again
1:
        eor #$ff                ; invert chks hi
        tax                     ; keep in x as return value
        tya                     ; A = chks lo
        eor #$ff                ; invert chks lo
        plz
        rts                     ; return chks (AX)

.section .data.checksum
_sizehi:
        .byte 0
_result:
        .dword 0
