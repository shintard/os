# レジスタをスタックに保存
.macro SAVE reg, offset
    sd \reg, \offset*8(sp) # regの値を`(offset*8) + sp`に保存
.endm

# レジスタをスタックから取り出す
.macro LOAD reg, offset
    ld \reg, \offset*8(sp)
.endm

    .section .text
    .global __interrupt

#### 割り込み処理、レジスタの値をスタックに保存する ####
__interrupt:
    # コンテキストに必要なスタックスペースを確保
    addi    sp, sp, -34*8
    # x1~x31 (n = 0, offset*x1+n, n < 31; n++) までのレジスタを保存する
    SAVE    x1, 1
    addi    x1, sp, 34*8 # x1 = sp + 34*8
    # 2(2*8(sp))にはスタックポインタのベース位置を格納する
    SAVE    x1, 2
    SAVE    x3, 3
    SAVE    x4, 4
    SAVE    x5, 5
    SAVE    x6, 6
    SAVE    x7, 7
    SAVE    x8, 8
    SAVE    x9, 9
    SAVE    x10, 10
    SAVE    x11, 11
    SAVE    x12, 12
    SAVE    x13, 13
    SAVE    x14, 14
    SAVE    x15, 15
    SAVE    x16, 16
    SAVE    x17, 17
    SAVE    x18, 18
    SAVE    x19, 19
    SAVE    x20, 20
    SAVE    x21, 21
    SAVE    x22, 22
    SAVE    x23, 23
    SAVE    x24, 24
    SAVE    x25, 25
    SAVE    x26, 26
    SAVE    x27, 27
    SAVE    x28, 28
    SAVE    x29, 29
    SAVE    x30, 30
    SAVE    x31, 31

    #### CSRレジスタの取り出しと保存 ####
    csrr    s1, sstatus
    csrr    s2, sepc
    SAVE    s1, 32
    SAVE    s2, 33

    #### 割り込み要因の格納と割り込み実行アドレスの格納 ####
    mv      a0, sp
    csrr    a1, scause
    csrr    a2, stval
    jal     handle_interrupt

    .globl __restore

#### レジスタの値をスタックから復元する、コンテキストからすべてのレジスタを復元し、####
#### コンテキスト内の例外が発生した位置に戻りながらユーザー状態に戻る ####

    # CSRの復元
    LOAD    s1, 32
    LOAD    s2, 33
    csrw    sstatus, s1
    csrw    sepc, s2

    LOAD    x1, 1
    LOAD    x3, 3
    LOAD    x4, 4
    LOAD    x5, 5
    LOAD    x6, 6
    LOAD    x7, 7
    LOAD    x8, 8
    LOAD    x9, 9
    LOAD    x10, 10
    LOAD    x11, 11
    LOAD    x12, 12
    LOAD    x13, 13
    LOAD    x14, 14
    LOAD    x15, 15
    LOAD    x16, 16
    LOAD    x17, 17
    LOAD    x18, 18
    LOAD    x19, 19
    LOAD    x20, 20
    LOAD    x21, 21
    LOAD    x22, 22
    LOAD    x23, 23
    LOAD    x24, 24
    LOAD    x25, 25
    LOAD    x26, 26
    LOAD    x27, 27
    LOAD    x28, 28
    LOAD    x29, 29
    LOAD    x30, 30
    LOAD    x31, 31

    LOAD    x2, 2
    # pcの値をsepcに設定しながらカーネル状態からユーザ状態に戻る(
    sret