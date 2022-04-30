local
	Seq1 = [stretch(factor: 0.2 [[d6 d5] [e6 e5] [c6 c5]
										stretch(factor:2.0 [[a5 a4]])
										[b5 b4]
										stretch(factor:2.0 [[g5 g4]])])]
	Seq2 = [transpose(semitones:~12 Seq1)]
	Seq3 = [stretch(factor:0.2 [[d4 d3] [e4 e3] [c4 c3]
										stretch(factor:2.0 [[a3 a2]])
										[b3 b2] [a3 a2] [g#3 g#2]
										stretch(factor:2.0 [[g3 g2] silence])
										[g3 b3 d4 g4 b4 d5 g5]
										duration(seconds:1.5 [silence])
										[d4 g3 b3] d#4
										])]
in
	[partition({List.flatten [Seq1 Seq2 Seq3]})]
end