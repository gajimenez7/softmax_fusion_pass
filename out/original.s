	.text
	.file	"LLVMDialectModule"
	.section	.rodata.cst4,"aM",@progbits,4
	.p2align	2, 0x0                          # -- Begin function softmax
.LCPI0_0:
	.long	0xce6e6b28                      # float -1.0E+9
	.text
	.globl	softmax
	.p2align	4, 0x90
	.type	softmax,@function
softmax:                                # @softmax
	.cfi_startproc
# %bb.0:
	pushq	%r15
	.cfi_def_cfa_offset 16
	pushq	%r14
	.cfi_def_cfa_offset 24
	pushq	%r12
	.cfi_def_cfa_offset 32
	pushq	%rbx
	.cfi_def_cfa_offset 40
	pushq	%rax
	.cfi_def_cfa_offset 48
	.cfi_offset %rbx, -40
	.cfi_offset %r12, -32
	.cfi_offset %r14, -24
	.cfi_offset %r15, -16
	movq	%rsi, %rbx
	movq	48(%rsp), %r14
	movslq	80(%rsp), %r15
	movss	.LCPI0_0(%rip), %xmm2           # xmm2 = mem[0],zero,zero,zero
	xorl	%eax, %eax
	jmp	.LBB0_1
	.p2align	4, 0x90
.LBB0_4:                                #   in Loop: Header=BB0_1 Depth=1
	incq	%rax
.LBB0_1:                                # =>This Inner Loop Header: Depth=1
	cmpq	%r15, %rax
	jge	.LBB0_5
# %bb.2:                                #   in Loop: Header=BB0_1 Depth=1
	movss	(%rbx,%rax,4), %xmm0            # xmm0 = mem[0],zero,zero,zero
	cvtss2sd	%xmm0, %xmm0
	xorps	%xmm1, %xmm1
	cvtss2sd	%xmm2, %xmm1
	ucomisd	%xmm1, %xmm0
	jbe	.LBB0_4
# %bb.3:                                #   in Loop: Header=BB0_1 Depth=1
	xorps	%xmm2, %xmm2
	cvtsd2ss	%xmm0, %xmm2
	jmp	.LBB0_4
.LBB0_5:
	xorl	%r12d, %r12d
	movss	%xmm2, 4(%rsp)                  # 4-byte Spill
	cmpq	%r15, %r12
	jge	.LBB0_8
	.p2align	4, 0x90
.LBB0_7:                                # =>This Inner Loop Header: Depth=1
	movss	(%rbx,%r12,4), %xmm0            # xmm0 = mem[0],zero,zero,zero
	subss	%xmm2, %xmm0
	callq	expf@PLT
	movss	4(%rsp), %xmm2                  # 4-byte Reload
                                        # xmm2 = mem[0],zero,zero,zero
	movss	%xmm0, (%r14,%r12,4)
	incq	%r12
	cmpq	%r15, %r12
	jl	.LBB0_7
.LBB0_8:
	xorps	%xmm0, %xmm0
	xorl	%eax, %eax
	cmpq	%r15, %rax
	jge	.LBB0_11
	.p2align	4, 0x90
.LBB0_10:                               # =>This Inner Loop Header: Depth=1
	addss	(%r14,%rax,4), %xmm0
	incq	%rax
	cmpq	%r15, %rax
	jl	.LBB0_10
.LBB0_11:
	xorl	%eax, %eax
	cmpq	%r15, %rax
	jge	.LBB0_14
	.p2align	4, 0x90
.LBB0_13:                               # =>This Inner Loop Header: Depth=1
	movss	(%r14,%rax,4), %xmm1            # xmm1 = mem[0],zero,zero,zero
	divss	%xmm0, %xmm1
	movss	%xmm1, (%r14,%rax,4)
	incq	%rax
	cmpq	%r15, %rax
	jl	.LBB0_13
.LBB0_14:
	addq	$8, %rsp
	.cfi_def_cfa_offset 40
	popq	%rbx
	.cfi_def_cfa_offset 32
	popq	%r12
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end0:
	.size	softmax, .Lfunc_end0-softmax
	.cfi_endproc
                                        # -- End function
	.section	".note.GNU-stack","",@progbits
