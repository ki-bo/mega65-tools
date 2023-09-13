; void ip_checksum_recv();
; IP header checksum calculation
; Ethernet frame expected at $d800 (IP hdr start at $d810)
; Result checksum is returned in AX (A lo, X hi)
.global ip_checksum_recv
.section .text.ip_checksum_recv,"ax",@progbits
ip_checksum_recv:
        lda #$45
        sta $d02f 
        lda #$54
        sta $d02f 
        lda #$d8
        tab
        clc
        phz
        ldq $10
        adcq $14
        adcq $18
        adcq $1c
        adcq $20

        neg
        neg
        sta _result              ; chks lo = result[0] + result[2]
        adc _result+2
        tay                     ; Y = chks lo
        plz
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
        tax                     ; X = chks hi
        tya                     ; A = chks lo
        rts                     ; return chks (AX)

.section .data.ip_checksum_recv
_result:
        .dword 0
