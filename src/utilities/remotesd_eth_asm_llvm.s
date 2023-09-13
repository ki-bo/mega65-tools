; void dma_copy_eth_io(void *src, void *dst, uint16_t size);
; dma copy with eth I/O personality enabled
.global dma_copy_eth_io
.section .text.dma_copy_eth_io,"ax",@progbits
dma_copy_eth_io:
        sta dma_copy_count
        stx dma_copy_count+1
        lda __rc2
        sta dma_copy_src
        lda __rc3
        sta dma_copy_src+1
        lda __rc4
        sta dma_copy_dst
        lda __rc5
        sta dma_copy_dst+1
        
        lda #$45
        sta $d02f 
        lda #$54
        sta $d02f 

        sta $d707
        .byte $00      ; end of job options
        .byte $00      ; copy
dma_copy_count:
        .word $0000    ; count
dma_copy_src:
        .word $0000    ; src
        .byte $80      ; src bank
dma_copy_dst:
        .word $0000    ; dst
        .byte $80      ; dst bank
        .byte $00      ; cmd hi
        .word $0000    ; modulo / ignored

        rts

; uint8_t cmp_c000_c200()
; compare 0xc000-0xc1ff with 0xc200-0xc3ff
; return 0 if equal, 1 if not equal
.global cmp_c000_c200
.section .text.cmp_c000_c200,"ax",@progbits
cmp_c000_c200:
        lda #$c0
        tab
        ldx #$00
1:
        lda $c200,x
        cmp $00,x
        bne 3f
        iny
        bne 1b
        lda #$c1
        tab
2:
        lda $c300,x
        cmp $00,x
        bne 3f
        iny
        bne 2b
        lda #$00
        tab
        tax
        rts        
3:
        lda #$00
        tab
        lda #$01
        rts

; uint8_t cmp_c000_c800()
; compare 0xc000-0xc1ff with 0xc822-0xca21
.global cmp_c000_c800
.section .text.cmp_c000_c800,"ax",@progbits
cmp_c000_c800:
        lda #$c0
        tab
        ldx #$00
1:
        lda $c822,x
        cmp $00,x
        bne 3f
        iny
        bne 1b
        lda #$c1
        tab
2:
        lda $c922,x
        cmp $00,x
        bne 3f
        iny
        bne 2b
        lda #$00
        tab
        tax
        rts        
3:
        lda #$00
        tab
        lda #$01
        rts
