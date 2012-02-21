.init_heap_size	0
	jmp	min_caml_start
min_caml_start:
	mov	%g31, %g1
	subi	%g1, %g1, 32
	addi	%g28, %g0, 1
	addi	%g29, %g0, -1
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	sti	%g2, %g31, 28
	subi	%g2, %g31, 4
	subi	%g1, %g1, 4
	call	min_caml_create_array
	ldi	%g2, %g31, 28
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	sti	%g2, %g31, 28
	subi	%g2, %g31, 8
	call	min_caml_create_array
	ldi	%g2, %g31, 28
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	sti	%g2, %g31, 28
	subi	%g2, %g31, 12
	call	min_caml_create_array
	ldi	%g2, %g31, 28
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	sti	%g2, %g31, 28
	subi	%g2, %g31, 16
	call	min_caml_create_array
	ldi	%g2, %g31, 28
	addi	%g3, %g0, 1
	addi	%g4, %g0, 1
	sti	%g2, %g31, 28
	subi	%g2, %g31, 20
	call	min_caml_create_array
	ldi	%g2, %g31, 28
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	sti	%g2, %g31, 28
	subi	%g2, %g31, 24
	call	min_caml_create_array
	addi	%g1, %g1, 4
	ldi	%g2, %g31, 28
	addi	%g3, %g0, 0
	sti	%g3, %g31, 4
	addi	%g3, %g0, 0
	sti	%g3, %g31, 8
	input	%g5
	addi	%g3, %g0, 48
	jlt	%g5, %g3, jle_else.1655
	addi	%g3, %g0, 57
	jlt	%g3, %g5, jle_else.1657
	addi	%g3, %g0, 0
	jmp	jle_cont.1658
jle_else.1657:
	addi	%g3, %g0, 1
jle_cont.1658:
	jmp	jle_cont.1656
jle_else.1655:
	addi	%g3, %g0, 1
jle_cont.1656:
	jne	%g3, %g0, jeq_else.1659
	ldi	%g3, %g31, 8
	jne	%g3, %g0, jeq_else.1661
	addi	%g3, %g0, 1
	sti	%g3, %g31, 8
	jmp	jeq_cont.1662
jeq_else.1661:
jeq_cont.1662:
	ldi	%g3, %g31, 4
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g4, %g4, %g3
	subi	%g3, %g5, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 4
	addi	%g6, %g0, 1
	subi	%g1, %g1, 4
	call	read_int_token.312
	addi	%g1, %g1, 4
	jmp	jeq_cont.1660
jeq_else.1659:
	addi	%g6, %g0, 0
	subi	%g1, %g1, 4
	call	read_int_token.312
	addi	%g1, %g1, 4
jeq_cont.1660:
	mov	%g4, %g3
	subi	%g1, %g1, 4
	call	print_int.333
	addi	%g1, %g1, 4
	halt

!==============================
! args = [%g6, %g5]
! fargs = []
! use_regs = [%g6, %g5, %g4, %g3, %g27, %f15, %dummy]
! ret type = Int
!================================
read_int_token.312:
	input	%g4
	addi	%g3, %g0, 48
	jlt	%g4, %g3, jle_else.1663
	addi	%g3, %g0, 57
	jlt	%g3, %g4, jle_else.1665
	addi	%g3, %g0, 0
	jmp	jle_cont.1666
jle_else.1665:
	addi	%g3, %g0, 1
jle_cont.1666:
	jmp	jle_cont.1664
jle_else.1663:
	addi	%g3, %g0, 1
jle_cont.1664:
	jne	%g3, %g0, jeq_else.1667
	ldi	%g3, %g31, 8
	jne	%g3, %g0, jeq_else.1668
	addi	%g3, %g0, 45
	jne	%g5, %g3, jeq_else.1670
	addi	%g3, %g0, -1
	sti	%g3, %g31, 8
	jmp	jeq_cont.1671
jeq_else.1670:
	addi	%g3, %g0, 1
	sti	%g3, %g31, 8
jeq_cont.1671:
	jmp	jeq_cont.1669
jeq_else.1668:
jeq_cont.1669:
	ldi	%g3, %g31, 4
	slli	%g5, %g3, 3
	slli	%g3, %g3, 1
	add	%g5, %g5, %g3
	subi	%g3, %g4, 48
	add	%g3, %g5, %g3
	sti	%g3, %g31, 4
	input	%g5
	addi	%g3, %g0, 48
	jlt	%g5, %g3, jle_else.1672
	addi	%g3, %g0, 57
	jlt	%g3, %g5, jle_else.1674
	addi	%g3, %g0, 0
	jmp	jle_cont.1675
jle_else.1674:
	addi	%g3, %g0, 1
jle_cont.1675:
	jmp	jle_cont.1673
jle_else.1672:
	addi	%g3, %g0, 1
jle_cont.1673:
	jne	%g3, %g0, jeq_else.1676
	ldi	%g3, %g31, 8
	jne	%g3, %g0, jeq_else.1677
	addi	%g3, %g0, 45
	jne	%g4, %g3, jeq_else.1679
	addi	%g3, %g0, -1
	sti	%g3, %g31, 8
	jmp	jeq_cont.1680
jeq_else.1679:
	addi	%g3, %g0, 1
	sti	%g3, %g31, 8
jeq_cont.1680:
	jmp	jeq_cont.1678
jeq_else.1677:
jeq_cont.1678:
	ldi	%g3, %g31, 4
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g4, %g4, %g3
	subi	%g3, %g5, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 4
	addi	%g6, %g0, 1
	jmp	read_int_token.312
jeq_else.1676:
	ldi	%g3, %g31, 8
	jne	%g3, %g28, jeq_else.1681
	ldi	%g3, %g31, 4
	return
jeq_else.1681:
	ldi	%g3, %g31, 4
	sub	%g3, %g0, %g3
	return
jeq_else.1667:
	jne	%g6, %g0, jeq_else.1682
	input	%g5
	addi	%g3, %g0, 48
	jlt	%g5, %g3, jle_else.1683
	addi	%g3, %g0, 57
	jlt	%g3, %g5, jle_else.1685
	addi	%g3, %g0, 0
	jmp	jle_cont.1686
jle_else.1685:
	addi	%g3, %g0, 1
jle_cont.1686:
	jmp	jle_cont.1684
jle_else.1683:
	addi	%g3, %g0, 1
jle_cont.1684:
	jne	%g3, %g0, jeq_else.1687
	ldi	%g3, %g31, 8
	jne	%g3, %g0, jeq_else.1688
	addi	%g3, %g0, 45
	jne	%g4, %g3, jeq_else.1690
	addi	%g3, %g0, -1
	sti	%g3, %g31, 8
	jmp	jeq_cont.1691
jeq_else.1690:
	addi	%g3, %g0, 1
	sti	%g3, %g31, 8
jeq_cont.1691:
	jmp	jeq_cont.1689
jeq_else.1688:
jeq_cont.1689:
	ldi	%g3, %g31, 4
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g4, %g4, %g3
	subi	%g3, %g5, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 4
	addi	%g6, %g0, 1
	jmp	read_int_token.312
jeq_else.1687:
	addi	%g6, %g0, 0
	jmp	read_int_token.312
jeq_else.1682:
	ldi	%g3, %g31, 8
	jne	%g3, %g28, jeq_else.1692
	ldi	%g3, %g31, 4
	return
jeq_else.1692:
	ldi	%g3, %g31, 4
	sub	%g3, %g0, %g3
	return

!==============================
! args = [%g4, %g6, %g9, %g10]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g10, %f15]
! ret type = Int
!================================
div_binary_search.328:
	add	%g3, %g9, %g10
	srli	%g5, %g3, 1
	mul	%g7, %g5, %g6
	sub	%g3, %g10, %g9
	jlt	%g28, %g3, jle_else.1693
	mov	%g3, %g9
	return
jle_else.1693:
	jlt	%g7, %g4, jle_else.1694
	jne	%g7, %g4, jeq_else.1695
	mov	%g3, %g5
	return
jeq_else.1695:
	add	%g3, %g9, %g5
	srli	%g7, %g3, 1
	mul	%g8, %g7, %g6
	sub	%g3, %g5, %g9
	jlt	%g28, %g3, jle_else.1696
	mov	%g3, %g9
	return
jle_else.1696:
	jlt	%g8, %g4, jle_else.1697
	jne	%g8, %g4, jeq_else.1698
	mov	%g3, %g7
	return
jeq_else.1698:
	add	%g3, %g9, %g7
	srli	%g8, %g3, 1
	mul	%g5, %g8, %g6
	sub	%g3, %g7, %g9
	jlt	%g28, %g3, jle_else.1699
	mov	%g3, %g9
	return
jle_else.1699:
	jlt	%g5, %g4, jle_else.1700
	jne	%g5, %g4, jeq_else.1701
	mov	%g3, %g8
	return
jeq_else.1701:
	add	%g3, %g9, %g8
	srli	%g5, %g3, 1
	mul	%g7, %g5, %g6
	sub	%g3, %g8, %g9
	jlt	%g28, %g3, jle_else.1702
	mov	%g3, %g9
	return
jle_else.1702:
	jlt	%g7, %g4, jle_else.1703
	jne	%g7, %g4, jeq_else.1704
	mov	%g3, %g5
	return
jeq_else.1704:
	mov	%g10, %g5
	jmp	div_binary_search.328
jle_else.1703:
	mov	%g10, %g8
	mov	%g9, %g5
	jmp	div_binary_search.328
jle_else.1700:
	add	%g3, %g8, %g7
	srli	%g5, %g3, 1
	mul	%g9, %g5, %g6
	sub	%g3, %g7, %g8
	jlt	%g28, %g3, jle_else.1705
	mov	%g3, %g8
	return
jle_else.1705:
	jlt	%g9, %g4, jle_else.1706
	jne	%g9, %g4, jeq_else.1707
	mov	%g3, %g5
	return
jeq_else.1707:
	mov	%g10, %g5
	mov	%g9, %g8
	jmp	div_binary_search.328
jle_else.1706:
	mov	%g10, %g7
	mov	%g9, %g5
	jmp	div_binary_search.328
jle_else.1697:
	add	%g3, %g7, %g5
	srli	%g8, %g3, 1
	mul	%g9, %g8, %g6
	sub	%g3, %g5, %g7
	jlt	%g28, %g3, jle_else.1708
	mov	%g3, %g7
	return
jle_else.1708:
	jlt	%g9, %g4, jle_else.1709
	jne	%g9, %g4, jeq_else.1710
	mov	%g3, %g8
	return
jeq_else.1710:
	add	%g3, %g7, %g8
	srli	%g5, %g3, 1
	mul	%g9, %g5, %g6
	sub	%g3, %g8, %g7
	jlt	%g28, %g3, jle_else.1711
	mov	%g3, %g7
	return
jle_else.1711:
	jlt	%g9, %g4, jle_else.1712
	jne	%g9, %g4, jeq_else.1713
	mov	%g3, %g5
	return
jeq_else.1713:
	mov	%g10, %g5
	mov	%g9, %g7
	jmp	div_binary_search.328
jle_else.1712:
	mov	%g10, %g8
	mov	%g9, %g5
	jmp	div_binary_search.328
jle_else.1709:
	add	%g3, %g8, %g5
	srli	%g7, %g3, 1
	mul	%g9, %g7, %g6
	sub	%g3, %g5, %g8
	jlt	%g28, %g3, jle_else.1714
	mov	%g3, %g8
	return
jle_else.1714:
	jlt	%g9, %g4, jle_else.1715
	jne	%g9, %g4, jeq_else.1716
	mov	%g3, %g7
	return
jeq_else.1716:
	mov	%g10, %g7
	mov	%g9, %g8
	jmp	div_binary_search.328
jle_else.1715:
	mov	%g10, %g5
	mov	%g9, %g7
	jmp	div_binary_search.328
jle_else.1694:
	add	%g3, %g5, %g10
	srli	%g8, %g3, 1
	mul	%g7, %g8, %g6
	sub	%g3, %g10, %g5
	jlt	%g28, %g3, jle_else.1717
	mov	%g3, %g5
	return
jle_else.1717:
	jlt	%g7, %g4, jle_else.1718
	jne	%g7, %g4, jeq_else.1719
	mov	%g3, %g8
	return
jeq_else.1719:
	add	%g3, %g5, %g8
	srli	%g7, %g3, 1
	mul	%g9, %g7, %g6
	sub	%g3, %g8, %g5
	jlt	%g28, %g3, jle_else.1720
	mov	%g3, %g5
	return
jle_else.1720:
	jlt	%g9, %g4, jle_else.1721
	jne	%g9, %g4, jeq_else.1722
	mov	%g3, %g7
	return
jeq_else.1722:
	add	%g3, %g5, %g7
	srli	%g8, %g3, 1
	mul	%g9, %g8, %g6
	sub	%g3, %g7, %g5
	jlt	%g28, %g3, jle_else.1723
	mov	%g3, %g5
	return
jle_else.1723:
	jlt	%g9, %g4, jle_else.1724
	jne	%g9, %g4, jeq_else.1725
	mov	%g3, %g8
	return
jeq_else.1725:
	mov	%g10, %g8
	mov	%g9, %g5
	jmp	div_binary_search.328
jle_else.1724:
	mov	%g10, %g7
	mov	%g9, %g8
	jmp	div_binary_search.328
jle_else.1721:
	add	%g3, %g7, %g8
	srli	%g5, %g3, 1
	mul	%g9, %g5, %g6
	sub	%g3, %g8, %g7
	jlt	%g28, %g3, jle_else.1726
	mov	%g3, %g7
	return
jle_else.1726:
	jlt	%g9, %g4, jle_else.1727
	jne	%g9, %g4, jeq_else.1728
	mov	%g3, %g5
	return
jeq_else.1728:
	mov	%g10, %g5
	mov	%g9, %g7
	jmp	div_binary_search.328
jle_else.1727:
	mov	%g10, %g8
	mov	%g9, %g5
	jmp	div_binary_search.328
jle_else.1718:
	add	%g3, %g8, %g10
	srli	%g7, %g3, 1
	mul	%g5, %g7, %g6
	sub	%g3, %g10, %g8
	jlt	%g28, %g3, jle_else.1729
	mov	%g3, %g8
	return
jle_else.1729:
	jlt	%g5, %g4, jle_else.1730
	jne	%g5, %g4, jeq_else.1731
	mov	%g3, %g7
	return
jeq_else.1731:
	add	%g3, %g8, %g7
	srli	%g5, %g3, 1
	mul	%g9, %g5, %g6
	sub	%g3, %g7, %g8
	jlt	%g28, %g3, jle_else.1732
	mov	%g3, %g8
	return
jle_else.1732:
	jlt	%g9, %g4, jle_else.1733
	jne	%g9, %g4, jeq_else.1734
	mov	%g3, %g5
	return
jeq_else.1734:
	mov	%g10, %g5
	mov	%g9, %g8
	jmp	div_binary_search.328
jle_else.1733:
	mov	%g10, %g7
	mov	%g9, %g5
	jmp	div_binary_search.328
jle_else.1730:
	add	%g3, %g7, %g10
	srli	%g5, %g3, 1
	mul	%g8, %g5, %g6
	sub	%g3, %g10, %g7
	jlt	%g28, %g3, jle_else.1735
	mov	%g3, %g7
	return
jle_else.1735:
	jlt	%g8, %g4, jle_else.1736
	jne	%g8, %g4, jeq_else.1737
	mov	%g3, %g5
	return
jeq_else.1737:
	mov	%g10, %g5
	mov	%g9, %g7
	jmp	div_binary_search.328
jle_else.1736:
	mov	%g9, %g5
	jmp	div_binary_search.328

!==============================
! args = [%g4]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g14, %g13, %g12, %g11, %g10, %f15, %dummy]
! ret type = Unit
!================================
print_int.333:
	jlt	%g4, %g0, jge_else.1738
	mvhi	%g3, 1525
	mvlo	%g3, 57600
	jlt	%g3, %g4, jle_else.1739
	jne	%g3, %g4, jeq_else.1741
	addi	%g5, %g0, 1
	jmp	jeq_cont.1742
jeq_else.1741:
	addi	%g5, %g0, 0
jeq_cont.1742:
	jmp	jle_cont.1740
jle_else.1739:
	mvhi	%g3, 3051
	mvlo	%g3, 49664
	jlt	%g3, %g4, jle_else.1743
	jne	%g3, %g4, jeq_else.1745
	addi	%g5, %g0, 2
	jmp	jeq_cont.1746
jeq_else.1745:
	addi	%g5, %g0, 1
jeq_cont.1746:
	jmp	jle_cont.1744
jle_else.1743:
	addi	%g5, %g0, 2
jle_cont.1744:
jle_cont.1740:
	mvhi	%g3, 1525
	mvlo	%g3, 57600
	mul	%g3, %g5, %g3
	sub	%g4, %g4, %g3
	jlt	%g0, %g5, jle_else.1747
	addi	%g13, %g0, 0
	jmp	jle_cont.1748
jle_else.1747:
	addi	%g3, %g0, 48
	add	%g3, %g3, %g5
	output	%g3
	addi	%g13, %g0, 1
jle_cont.1748:
	mvhi	%g6, 152
	mvlo	%g6, 38528
	addi	%g12, %g0, 0
	addi	%g11, %g0, 10
	addi	%g10, %g0, 5
	mvhi	%g5, 762
	mvlo	%g5, 61568
	sti	%g4, %g1, 0
	jlt	%g5, %g4, jle_else.1749
	jne	%g5, %g4, jeq_else.1751
	addi	%g3, %g0, 5
	jmp	jeq_cont.1752
jeq_else.1751:
	addi	%g9, %g0, 2
	mvhi	%g5, 305
	mvlo	%g5, 11520
	jlt	%g5, %g4, jle_else.1753
	jne	%g5, %g4, jeq_else.1755
	addi	%g3, %g0, 2
	jmp	jeq_cont.1756
jeq_else.1755:
	addi	%g10, %g0, 1
	mvhi	%g5, 152
	mvlo	%g5, 38528
	jlt	%g5, %g4, jle_else.1757
	jne	%g5, %g4, jeq_else.1759
	addi	%g3, %g0, 1
	jmp	jeq_cont.1760
jeq_else.1759:
	mov	%g9, %g12
	subi	%g1, %g1, 8
	call	div_binary_search.328
	addi	%g1, %g1, 8
jeq_cont.1760:
	jmp	jle_cont.1758
jle_else.1757:
	mov	%g27, %g10
	mov	%g10, %g9
	mov	%g9, %g27
	subi	%g1, %g1, 8
	call	div_binary_search.328
	addi	%g1, %g1, 8
jle_cont.1758:
jeq_cont.1756:
	jmp	jle_cont.1754
jle_else.1753:
	addi	%g11, %g0, 3
	mvhi	%g5, 457
	mvlo	%g5, 50048
	jlt	%g5, %g4, jle_else.1761
	jne	%g5, %g4, jeq_else.1763
	addi	%g3, %g0, 3
	jmp	jeq_cont.1764
jeq_else.1763:
	mov	%g10, %g11
	subi	%g1, %g1, 8
	call	div_binary_search.328
	addi	%g1, %g1, 8
jeq_cont.1764:
	jmp	jle_cont.1762
jle_else.1761:
	mov	%g9, %g11
	subi	%g1, %g1, 8
	call	div_binary_search.328
	addi	%g1, %g1, 8
jle_cont.1762:
jle_cont.1754:
jeq_cont.1752:
	jmp	jle_cont.1750
jle_else.1749:
	addi	%g9, %g0, 7
	mvhi	%g5, 1068
	mvlo	%g5, 7552
	jlt	%g5, %g4, jle_else.1765
	jne	%g5, %g4, jeq_else.1767
	addi	%g3, %g0, 7
	jmp	jeq_cont.1768
jeq_else.1767:
	addi	%g11, %g0, 6
	mvhi	%g5, 915
	mvlo	%g5, 34560
	jlt	%g5, %g4, jle_else.1769
	jne	%g5, %g4, jeq_else.1771
	addi	%g3, %g0, 6
	jmp	jeq_cont.1772
jeq_else.1771:
	mov	%g9, %g10
	mov	%g10, %g11
	subi	%g1, %g1, 8
	call	div_binary_search.328
	addi	%g1, %g1, 8
jeq_cont.1772:
	jmp	jle_cont.1770
jle_else.1769:
	mov	%g10, %g9
	mov	%g9, %g11
	subi	%g1, %g1, 8
	call	div_binary_search.328
	addi	%g1, %g1, 8
jle_cont.1770:
jeq_cont.1768:
	jmp	jle_cont.1766
jle_else.1765:
	addi	%g10, %g0, 8
	mvhi	%g5, 1220
	mvlo	%g5, 46080
	jlt	%g5, %g4, jle_else.1773
	jne	%g5, %g4, jeq_else.1775
	addi	%g3, %g0, 8
	jmp	jeq_cont.1776
jeq_else.1775:
	subi	%g1, %g1, 8
	call	div_binary_search.328
	addi	%g1, %g1, 8
jeq_cont.1776:
	jmp	jle_cont.1774
jle_else.1773:
	mov	%g9, %g10
	mov	%g10, %g11
	subi	%g1, %g1, 8
	call	div_binary_search.328
	addi	%g1, %g1, 8
jle_cont.1774:
jle_cont.1766:
jle_cont.1750:
	mvhi	%g5, 152
	mvlo	%g5, 38528
	mul	%g5, %g3, %g5
	ldi	%g4, %g1, 0
	sub	%g4, %g4, %g5
	jlt	%g0, %g3, jle_else.1777
	jne	%g13, %g0, jeq_else.1779
	addi	%g14, %g0, 0
	jmp	jeq_cont.1780
jeq_else.1779:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g14, %g0, 1
jeq_cont.1780:
	jmp	jle_cont.1778
jle_else.1777:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g14, %g0, 1
jle_cont.1778:
	mvhi	%g6, 15
	mvlo	%g6, 16960
	addi	%g12, %g0, 0
	addi	%g11, %g0, 10
	addi	%g10, %g0, 5
	mvhi	%g5, 76
	mvlo	%g5, 19264
	sti	%g4, %g1, 4
	jlt	%g5, %g4, jle_else.1781
	jne	%g5, %g4, jeq_else.1783
	addi	%g3, %g0, 5
	jmp	jeq_cont.1784
jeq_else.1783:
	addi	%g9, %g0, 2
	mvhi	%g5, 30
	mvlo	%g5, 33920
	jlt	%g5, %g4, jle_else.1785
	jne	%g5, %g4, jeq_else.1787
	addi	%g3, %g0, 2
	jmp	jeq_cont.1788
jeq_else.1787:
	addi	%g10, %g0, 1
	mvhi	%g5, 15
	mvlo	%g5, 16960
	jlt	%g5, %g4, jle_else.1789
	jne	%g5, %g4, jeq_else.1791
	addi	%g3, %g0, 1
	jmp	jeq_cont.1792
jeq_else.1791:
	mov	%g9, %g12
	subi	%g1, %g1, 12
	call	div_binary_search.328
	addi	%g1, %g1, 12
jeq_cont.1792:
	jmp	jle_cont.1790
jle_else.1789:
	mov	%g27, %g10
	mov	%g10, %g9
	mov	%g9, %g27
	subi	%g1, %g1, 12
	call	div_binary_search.328
	addi	%g1, %g1, 12
jle_cont.1790:
jeq_cont.1788:
	jmp	jle_cont.1786
jle_else.1785:
	addi	%g11, %g0, 3
	mvhi	%g5, 45
	mvlo	%g5, 50880
	jlt	%g5, %g4, jle_else.1793
	jne	%g5, %g4, jeq_else.1795
	addi	%g3, %g0, 3
	jmp	jeq_cont.1796
jeq_else.1795:
	mov	%g10, %g11
	subi	%g1, %g1, 12
	call	div_binary_search.328
	addi	%g1, %g1, 12
jeq_cont.1796:
	jmp	jle_cont.1794
jle_else.1793:
	mov	%g9, %g11
	subi	%g1, %g1, 12
	call	div_binary_search.328
	addi	%g1, %g1, 12
jle_cont.1794:
jle_cont.1786:
jeq_cont.1784:
	jmp	jle_cont.1782
jle_else.1781:
	addi	%g9, %g0, 7
	mvhi	%g5, 106
	mvlo	%g5, 53184
	jlt	%g5, %g4, jle_else.1797
	jne	%g5, %g4, jeq_else.1799
	addi	%g3, %g0, 7
	jmp	jeq_cont.1800
jeq_else.1799:
	addi	%g11, %g0, 6
	mvhi	%g5, 91
	mvlo	%g5, 36224
	jlt	%g5, %g4, jle_else.1801
	jne	%g5, %g4, jeq_else.1803
	addi	%g3, %g0, 6
	jmp	jeq_cont.1804
jeq_else.1803:
	mov	%g9, %g10
	mov	%g10, %g11
	subi	%g1, %g1, 12
	call	div_binary_search.328
	addi	%g1, %g1, 12
jeq_cont.1804:
	jmp	jle_cont.1802
jle_else.1801:
	mov	%g10, %g9
	mov	%g9, %g11
	subi	%g1, %g1, 12
	call	div_binary_search.328
	addi	%g1, %g1, 12
jle_cont.1802:
jeq_cont.1800:
	jmp	jle_cont.1798
jle_else.1797:
	addi	%g10, %g0, 8
	mvhi	%g5, 122
	mvlo	%g5, 4608
	jlt	%g5, %g4, jle_else.1805
	jne	%g5, %g4, jeq_else.1807
	addi	%g3, %g0, 8
	jmp	jeq_cont.1808
jeq_else.1807:
	subi	%g1, %g1, 12
	call	div_binary_search.328
	addi	%g1, %g1, 12
jeq_cont.1808:
	jmp	jle_cont.1806
jle_else.1805:
	mov	%g9, %g10
	mov	%g10, %g11
	subi	%g1, %g1, 12
	call	div_binary_search.328
	addi	%g1, %g1, 12
jle_cont.1806:
jle_cont.1798:
jle_cont.1782:
	mvhi	%g5, 15
	mvlo	%g5, 16960
	mul	%g5, %g3, %g5
	ldi	%g4, %g1, 4
	sub	%g4, %g4, %g5
	jlt	%g0, %g3, jle_else.1809
	jne	%g14, %g0, jeq_else.1811
	addi	%g13, %g0, 0
	jmp	jeq_cont.1812
jeq_else.1811:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g13, %g0, 1
jeq_cont.1812:
	jmp	jle_cont.1810
jle_else.1809:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g13, %g0, 1
jle_cont.1810:
	mvhi	%g6, 1
	mvlo	%g6, 34464
	addi	%g12, %g0, 0
	addi	%g11, %g0, 10
	addi	%g10, %g0, 5
	mvhi	%g5, 7
	mvlo	%g5, 41248
	sti	%g4, %g1, 8
	jlt	%g5, %g4, jle_else.1813
	jne	%g5, %g4, jeq_else.1815
	addi	%g3, %g0, 5
	jmp	jeq_cont.1816
jeq_else.1815:
	addi	%g9, %g0, 2
	mvhi	%g5, 3
	mvlo	%g5, 3392
	jlt	%g5, %g4, jle_else.1817
	jne	%g5, %g4, jeq_else.1819
	addi	%g3, %g0, 2
	jmp	jeq_cont.1820
jeq_else.1819:
	addi	%g10, %g0, 1
	mvhi	%g5, 1
	mvlo	%g5, 34464
	jlt	%g5, %g4, jle_else.1821
	jne	%g5, %g4, jeq_else.1823
	addi	%g3, %g0, 1
	jmp	jeq_cont.1824
jeq_else.1823:
	mov	%g9, %g12
	subi	%g1, %g1, 16
	call	div_binary_search.328
	addi	%g1, %g1, 16
jeq_cont.1824:
	jmp	jle_cont.1822
jle_else.1821:
	mov	%g27, %g10
	mov	%g10, %g9
	mov	%g9, %g27
	subi	%g1, %g1, 16
	call	div_binary_search.328
	addi	%g1, %g1, 16
jle_cont.1822:
jeq_cont.1820:
	jmp	jle_cont.1818
jle_else.1817:
	addi	%g11, %g0, 3
	mvhi	%g5, 4
	mvlo	%g5, 37856
	jlt	%g5, %g4, jle_else.1825
	jne	%g5, %g4, jeq_else.1827
	addi	%g3, %g0, 3
	jmp	jeq_cont.1828
jeq_else.1827:
	mov	%g10, %g11
	subi	%g1, %g1, 16
	call	div_binary_search.328
	addi	%g1, %g1, 16
jeq_cont.1828:
	jmp	jle_cont.1826
jle_else.1825:
	mov	%g9, %g11
	subi	%g1, %g1, 16
	call	div_binary_search.328
	addi	%g1, %g1, 16
jle_cont.1826:
jle_cont.1818:
jeq_cont.1816:
	jmp	jle_cont.1814
jle_else.1813:
	addi	%g9, %g0, 7
	mvhi	%g5, 10
	mvlo	%g5, 44640
	jlt	%g5, %g4, jle_else.1829
	jne	%g5, %g4, jeq_else.1831
	addi	%g3, %g0, 7
	jmp	jeq_cont.1832
jeq_else.1831:
	addi	%g11, %g0, 6
	mvhi	%g5, 9
	mvlo	%g5, 10176
	jlt	%g5, %g4, jle_else.1833
	jne	%g5, %g4, jeq_else.1835
	addi	%g3, %g0, 6
	jmp	jeq_cont.1836
jeq_else.1835:
	mov	%g9, %g10
	mov	%g10, %g11
	subi	%g1, %g1, 16
	call	div_binary_search.328
	addi	%g1, %g1, 16
jeq_cont.1836:
	jmp	jle_cont.1834
jle_else.1833:
	mov	%g10, %g9
	mov	%g9, %g11
	subi	%g1, %g1, 16
	call	div_binary_search.328
	addi	%g1, %g1, 16
jle_cont.1834:
jeq_cont.1832:
	jmp	jle_cont.1830
jle_else.1829:
	addi	%g10, %g0, 8
	mvhi	%g5, 12
	mvlo	%g5, 13568
	jlt	%g5, %g4, jle_else.1837
	jne	%g5, %g4, jeq_else.1839
	addi	%g3, %g0, 8
	jmp	jeq_cont.1840
jeq_else.1839:
	subi	%g1, %g1, 16
	call	div_binary_search.328
	addi	%g1, %g1, 16
jeq_cont.1840:
	jmp	jle_cont.1838
jle_else.1837:
	mov	%g9, %g10
	mov	%g10, %g11
	subi	%g1, %g1, 16
	call	div_binary_search.328
	addi	%g1, %g1, 16
jle_cont.1838:
jle_cont.1830:
jle_cont.1814:
	mvhi	%g5, 1
	mvlo	%g5, 34464
	mul	%g5, %g3, %g5
	ldi	%g4, %g1, 8
	sub	%g4, %g4, %g5
	jlt	%g0, %g3, jle_else.1841
	jne	%g13, %g0, jeq_else.1843
	addi	%g14, %g0, 0
	jmp	jeq_cont.1844
jeq_else.1843:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g14, %g0, 1
jeq_cont.1844:
	jmp	jle_cont.1842
jle_else.1841:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g14, %g0, 1
jle_cont.1842:
	addi	%g6, %g0, 10000
	addi	%g12, %g0, 0
	addi	%g11, %g0, 10
	addi	%g10, %g0, 5
	mvhi	%g5, 0
	mvlo	%g5, 50000
	sti	%g4, %g1, 12
	jlt	%g5, %g4, jle_else.1845
	jne	%g5, %g4, jeq_else.1847
	addi	%g3, %g0, 5
	jmp	jeq_cont.1848
jeq_else.1847:
	addi	%g9, %g0, 2
	addi	%g5, %g0, 20000
	jlt	%g5, %g4, jle_else.1849
	jne	%g5, %g4, jeq_else.1851
	addi	%g3, %g0, 2
	jmp	jeq_cont.1852
jeq_else.1851:
	addi	%g10, %g0, 1
	addi	%g5, %g0, 10000
	jlt	%g5, %g4, jle_else.1853
	jne	%g5, %g4, jeq_else.1855
	addi	%g3, %g0, 1
	jmp	jeq_cont.1856
jeq_else.1855:
	mov	%g9, %g12
	subi	%g1, %g1, 20
	call	div_binary_search.328
	addi	%g1, %g1, 20
jeq_cont.1856:
	jmp	jle_cont.1854
jle_else.1853:
	mov	%g27, %g10
	mov	%g10, %g9
	mov	%g9, %g27
	subi	%g1, %g1, 20
	call	div_binary_search.328
	addi	%g1, %g1, 20
jle_cont.1854:
jeq_cont.1852:
	jmp	jle_cont.1850
jle_else.1849:
	addi	%g11, %g0, 3
	addi	%g5, %g0, 30000
	jlt	%g5, %g4, jle_else.1857
	jne	%g5, %g4, jeq_else.1859
	addi	%g3, %g0, 3
	jmp	jeq_cont.1860
jeq_else.1859:
	mov	%g10, %g11
	subi	%g1, %g1, 20
	call	div_binary_search.328
	addi	%g1, %g1, 20
jeq_cont.1860:
	jmp	jle_cont.1858
jle_else.1857:
	mov	%g9, %g11
	subi	%g1, %g1, 20
	call	div_binary_search.328
	addi	%g1, %g1, 20
jle_cont.1858:
jle_cont.1850:
jeq_cont.1848:
	jmp	jle_cont.1846
jle_else.1845:
	addi	%g9, %g0, 7
	mvhi	%g5, 1
	mvlo	%g5, 4464
	jlt	%g5, %g4, jle_else.1861
	jne	%g5, %g4, jeq_else.1863
	addi	%g3, %g0, 7
	jmp	jeq_cont.1864
jeq_else.1863:
	addi	%g11, %g0, 6
	mvhi	%g5, 0
	mvlo	%g5, 60000
	jlt	%g5, %g4, jle_else.1865
	jne	%g5, %g4, jeq_else.1867
	addi	%g3, %g0, 6
	jmp	jeq_cont.1868
jeq_else.1867:
	mov	%g9, %g10
	mov	%g10, %g11
	subi	%g1, %g1, 20
	call	div_binary_search.328
	addi	%g1, %g1, 20
jeq_cont.1868:
	jmp	jle_cont.1866
jle_else.1865:
	mov	%g10, %g9
	mov	%g9, %g11
	subi	%g1, %g1, 20
	call	div_binary_search.328
	addi	%g1, %g1, 20
jle_cont.1866:
jeq_cont.1864:
	jmp	jle_cont.1862
jle_else.1861:
	addi	%g10, %g0, 8
	mvhi	%g5, 1
	mvlo	%g5, 14464
	jlt	%g5, %g4, jle_else.1869
	jne	%g5, %g4, jeq_else.1871
	addi	%g3, %g0, 8
	jmp	jeq_cont.1872
jeq_else.1871:
	subi	%g1, %g1, 20
	call	div_binary_search.328
	addi	%g1, %g1, 20
jeq_cont.1872:
	jmp	jle_cont.1870
jle_else.1869:
	mov	%g9, %g10
	mov	%g10, %g11
	subi	%g1, %g1, 20
	call	div_binary_search.328
	addi	%g1, %g1, 20
jle_cont.1870:
jle_cont.1862:
jle_cont.1846:
	addi	%g5, %g0, 10000
	mul	%g5, %g3, %g5
	ldi	%g4, %g1, 12
	sub	%g4, %g4, %g5
	jlt	%g0, %g3, jle_else.1873
	jne	%g14, %g0, jeq_else.1875
	addi	%g13, %g0, 0
	jmp	jeq_cont.1876
jeq_else.1875:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g13, %g0, 1
jeq_cont.1876:
	jmp	jle_cont.1874
jle_else.1873:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g13, %g0, 1
jle_cont.1874:
	addi	%g6, %g0, 1000
	addi	%g12, %g0, 0
	addi	%g11, %g0, 10
	addi	%g10, %g0, 5
	addi	%g5, %g0, 5000
	sti	%g4, %g1, 16
	jlt	%g5, %g4, jle_else.1877
	jne	%g5, %g4, jeq_else.1879
	addi	%g3, %g0, 5
	jmp	jeq_cont.1880
jeq_else.1879:
	addi	%g9, %g0, 2
	addi	%g5, %g0, 2000
	jlt	%g5, %g4, jle_else.1881
	jne	%g5, %g4, jeq_else.1883
	addi	%g3, %g0, 2
	jmp	jeq_cont.1884
jeq_else.1883:
	addi	%g10, %g0, 1
	addi	%g5, %g0, 1000
	jlt	%g5, %g4, jle_else.1885
	jne	%g5, %g4, jeq_else.1887
	addi	%g3, %g0, 1
	jmp	jeq_cont.1888
jeq_else.1887:
	mov	%g9, %g12
	subi	%g1, %g1, 24
	call	div_binary_search.328
	addi	%g1, %g1, 24
jeq_cont.1888:
	jmp	jle_cont.1886
jle_else.1885:
	mov	%g27, %g10
	mov	%g10, %g9
	mov	%g9, %g27
	subi	%g1, %g1, 24
	call	div_binary_search.328
	addi	%g1, %g1, 24
jle_cont.1886:
jeq_cont.1884:
	jmp	jle_cont.1882
jle_else.1881:
	addi	%g11, %g0, 3
	addi	%g5, %g0, 3000
	jlt	%g5, %g4, jle_else.1889
	jne	%g5, %g4, jeq_else.1891
	addi	%g3, %g0, 3
	jmp	jeq_cont.1892
jeq_else.1891:
	mov	%g10, %g11
	subi	%g1, %g1, 24
	call	div_binary_search.328
	addi	%g1, %g1, 24
jeq_cont.1892:
	jmp	jle_cont.1890
jle_else.1889:
	mov	%g9, %g11
	subi	%g1, %g1, 24
	call	div_binary_search.328
	addi	%g1, %g1, 24
jle_cont.1890:
jle_cont.1882:
jeq_cont.1880:
	jmp	jle_cont.1878
jle_else.1877:
	addi	%g9, %g0, 7
	addi	%g5, %g0, 7000
	jlt	%g5, %g4, jle_else.1893
	jne	%g5, %g4, jeq_else.1895
	addi	%g3, %g0, 7
	jmp	jeq_cont.1896
jeq_else.1895:
	addi	%g11, %g0, 6
	addi	%g5, %g0, 6000
	jlt	%g5, %g4, jle_else.1897
	jne	%g5, %g4, jeq_else.1899
	addi	%g3, %g0, 6
	jmp	jeq_cont.1900
jeq_else.1899:
	mov	%g9, %g10
	mov	%g10, %g11
	subi	%g1, %g1, 24
	call	div_binary_search.328
	addi	%g1, %g1, 24
jeq_cont.1900:
	jmp	jle_cont.1898
jle_else.1897:
	mov	%g10, %g9
	mov	%g9, %g11
	subi	%g1, %g1, 24
	call	div_binary_search.328
	addi	%g1, %g1, 24
jle_cont.1898:
jeq_cont.1896:
	jmp	jle_cont.1894
jle_else.1893:
	addi	%g10, %g0, 8
	addi	%g5, %g0, 8000
	jlt	%g5, %g4, jle_else.1901
	jne	%g5, %g4, jeq_else.1903
	addi	%g3, %g0, 8
	jmp	jeq_cont.1904
jeq_else.1903:
	subi	%g1, %g1, 24
	call	div_binary_search.328
	addi	%g1, %g1, 24
jeq_cont.1904:
	jmp	jle_cont.1902
jle_else.1901:
	mov	%g9, %g10
	mov	%g10, %g11
	subi	%g1, %g1, 24
	call	div_binary_search.328
	addi	%g1, %g1, 24
jle_cont.1902:
jle_cont.1894:
jle_cont.1878:
	muli	%g5, %g3, 1000
	ldi	%g4, %g1, 16
	sub	%g4, %g4, %g5
	jlt	%g0, %g3, jle_else.1905
	jne	%g13, %g0, jeq_else.1907
	addi	%g14, %g0, 0
	jmp	jeq_cont.1908
jeq_else.1907:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g14, %g0, 1
jeq_cont.1908:
	jmp	jle_cont.1906
jle_else.1905:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g14, %g0, 1
jle_cont.1906:
	addi	%g6, %g0, 100
	addi	%g12, %g0, 0
	addi	%g11, %g0, 10
	addi	%g10, %g0, 5
	addi	%g5, %g0, 500
	sti	%g4, %g1, 20
	jlt	%g5, %g4, jle_else.1909
	jne	%g5, %g4, jeq_else.1911
	addi	%g3, %g0, 5
	jmp	jeq_cont.1912
jeq_else.1911:
	addi	%g9, %g0, 2
	addi	%g5, %g0, 200
	jlt	%g5, %g4, jle_else.1913
	jne	%g5, %g4, jeq_else.1915
	addi	%g3, %g0, 2
	jmp	jeq_cont.1916
jeq_else.1915:
	addi	%g10, %g0, 1
	addi	%g5, %g0, 100
	jlt	%g5, %g4, jle_else.1917
	jne	%g5, %g4, jeq_else.1919
	addi	%g3, %g0, 1
	jmp	jeq_cont.1920
jeq_else.1919:
	mov	%g9, %g12
	subi	%g1, %g1, 28
	call	div_binary_search.328
	addi	%g1, %g1, 28
jeq_cont.1920:
	jmp	jle_cont.1918
jle_else.1917:
	mov	%g27, %g10
	mov	%g10, %g9
	mov	%g9, %g27
	subi	%g1, %g1, 28
	call	div_binary_search.328
	addi	%g1, %g1, 28
jle_cont.1918:
jeq_cont.1916:
	jmp	jle_cont.1914
jle_else.1913:
	addi	%g11, %g0, 3
	addi	%g5, %g0, 300
	jlt	%g5, %g4, jle_else.1921
	jne	%g5, %g4, jeq_else.1923
	addi	%g3, %g0, 3
	jmp	jeq_cont.1924
jeq_else.1923:
	mov	%g10, %g11
	subi	%g1, %g1, 28
	call	div_binary_search.328
	addi	%g1, %g1, 28
jeq_cont.1924:
	jmp	jle_cont.1922
jle_else.1921:
	mov	%g9, %g11
	subi	%g1, %g1, 28
	call	div_binary_search.328
	addi	%g1, %g1, 28
jle_cont.1922:
jle_cont.1914:
jeq_cont.1912:
	jmp	jle_cont.1910
jle_else.1909:
	addi	%g9, %g0, 7
	addi	%g5, %g0, 700
	jlt	%g5, %g4, jle_else.1925
	jne	%g5, %g4, jeq_else.1927
	addi	%g3, %g0, 7
	jmp	jeq_cont.1928
jeq_else.1927:
	addi	%g11, %g0, 6
	addi	%g5, %g0, 600
	jlt	%g5, %g4, jle_else.1929
	jne	%g5, %g4, jeq_else.1931
	addi	%g3, %g0, 6
	jmp	jeq_cont.1932
jeq_else.1931:
	mov	%g9, %g10
	mov	%g10, %g11
	subi	%g1, %g1, 28
	call	div_binary_search.328
	addi	%g1, %g1, 28
jeq_cont.1932:
	jmp	jle_cont.1930
jle_else.1929:
	mov	%g10, %g9
	mov	%g9, %g11
	subi	%g1, %g1, 28
	call	div_binary_search.328
	addi	%g1, %g1, 28
jle_cont.1930:
jeq_cont.1928:
	jmp	jle_cont.1926
jle_else.1925:
	addi	%g10, %g0, 8
	addi	%g5, %g0, 800
	jlt	%g5, %g4, jle_else.1933
	jne	%g5, %g4, jeq_else.1935
	addi	%g3, %g0, 8
	jmp	jeq_cont.1936
jeq_else.1935:
	subi	%g1, %g1, 28
	call	div_binary_search.328
	addi	%g1, %g1, 28
jeq_cont.1936:
	jmp	jle_cont.1934
jle_else.1933:
	mov	%g9, %g10
	mov	%g10, %g11
	subi	%g1, %g1, 28
	call	div_binary_search.328
	addi	%g1, %g1, 28
jle_cont.1934:
jle_cont.1926:
jle_cont.1910:
	muli	%g5, %g3, 100
	ldi	%g4, %g1, 20
	sub	%g4, %g4, %g5
	jlt	%g0, %g3, jle_else.1937
	jne	%g14, %g0, jeq_else.1939
	addi	%g13, %g0, 0
	jmp	jeq_cont.1940
jeq_else.1939:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g13, %g0, 1
jeq_cont.1940:
	jmp	jle_cont.1938
jle_else.1937:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g13, %g0, 1
jle_cont.1938:
	addi	%g6, %g0, 10
	addi	%g12, %g0, 0
	addi	%g11, %g0, 10
	addi	%g10, %g0, 5
	addi	%g5, %g0, 50
	sti	%g4, %g1, 24
	jlt	%g5, %g4, jle_else.1941
	jne	%g5, %g4, jeq_else.1943
	addi	%g3, %g0, 5
	jmp	jeq_cont.1944
jeq_else.1943:
	addi	%g9, %g0, 2
	addi	%g5, %g0, 20
	jlt	%g5, %g4, jle_else.1945
	jne	%g5, %g4, jeq_else.1947
	addi	%g3, %g0, 2
	jmp	jeq_cont.1948
jeq_else.1947:
	addi	%g10, %g0, 1
	addi	%g5, %g0, 10
	jlt	%g5, %g4, jle_else.1949
	jne	%g5, %g4, jeq_else.1951
	addi	%g3, %g0, 1
	jmp	jeq_cont.1952
jeq_else.1951:
	mov	%g9, %g12
	subi	%g1, %g1, 32
	call	div_binary_search.328
	addi	%g1, %g1, 32
jeq_cont.1952:
	jmp	jle_cont.1950
jle_else.1949:
	mov	%g27, %g10
	mov	%g10, %g9
	mov	%g9, %g27
	subi	%g1, %g1, 32
	call	div_binary_search.328
	addi	%g1, %g1, 32
jle_cont.1950:
jeq_cont.1948:
	jmp	jle_cont.1946
jle_else.1945:
	addi	%g11, %g0, 3
	addi	%g5, %g0, 30
	jlt	%g5, %g4, jle_else.1953
	jne	%g5, %g4, jeq_else.1955
	addi	%g3, %g0, 3
	jmp	jeq_cont.1956
jeq_else.1955:
	mov	%g10, %g11
	subi	%g1, %g1, 32
	call	div_binary_search.328
	addi	%g1, %g1, 32
jeq_cont.1956:
	jmp	jle_cont.1954
jle_else.1953:
	mov	%g9, %g11
	subi	%g1, %g1, 32
	call	div_binary_search.328
	addi	%g1, %g1, 32
jle_cont.1954:
jle_cont.1946:
jeq_cont.1944:
	jmp	jle_cont.1942
jle_else.1941:
	addi	%g9, %g0, 7
	addi	%g5, %g0, 70
	jlt	%g5, %g4, jle_else.1957
	jne	%g5, %g4, jeq_else.1959
	addi	%g3, %g0, 7
	jmp	jeq_cont.1960
jeq_else.1959:
	addi	%g11, %g0, 6
	addi	%g5, %g0, 60
	jlt	%g5, %g4, jle_else.1961
	jne	%g5, %g4, jeq_else.1963
	addi	%g3, %g0, 6
	jmp	jeq_cont.1964
jeq_else.1963:
	mov	%g9, %g10
	mov	%g10, %g11
	subi	%g1, %g1, 32
	call	div_binary_search.328
	addi	%g1, %g1, 32
jeq_cont.1964:
	jmp	jle_cont.1962
jle_else.1961:
	mov	%g10, %g9
	mov	%g9, %g11
	subi	%g1, %g1, 32
	call	div_binary_search.328
	addi	%g1, %g1, 32
jle_cont.1962:
jeq_cont.1960:
	jmp	jle_cont.1958
jle_else.1957:
	addi	%g10, %g0, 8
	addi	%g5, %g0, 80
	jlt	%g5, %g4, jle_else.1965
	jne	%g5, %g4, jeq_else.1967
	addi	%g3, %g0, 8
	jmp	jeq_cont.1968
jeq_else.1967:
	subi	%g1, %g1, 32
	call	div_binary_search.328
	addi	%g1, %g1, 32
jeq_cont.1968:
	jmp	jle_cont.1966
jle_else.1965:
	mov	%g9, %g10
	mov	%g10, %g11
	subi	%g1, %g1, 32
	call	div_binary_search.328
	addi	%g1, %g1, 32
jle_cont.1966:
jle_cont.1958:
jle_cont.1942:
	muli	%g5, %g3, 10
	ldi	%g4, %g1, 24
	sub	%g4, %g4, %g5
	jlt	%g0, %g3, jle_else.1969
	jne	%g13, %g0, jeq_else.1971
	addi	%g5, %g0, 0
	jmp	jeq_cont.1972
jeq_else.1971:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g5, %g0, 1
jeq_cont.1972:
	jmp	jle_cont.1970
jle_else.1969:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g5, %g0, 1
jle_cont.1970:
	addi	%g3, %g0, 48
	add	%g3, %g3, %g4
	output	%g3
	return
jge_else.1738:
	addi	%g3, %g0, 45
	output	%g3
	sub	%g4, %g0, %g4
	jmp	print_int.333
