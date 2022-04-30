/****************************************
 * PrOZjet 2022 - Oz Player - LINFO1104 *
 * ------------------------------------ *
 * KAFROUNI christophe ------- 57961800 *
 * KENDA Tom ----------------- 32001700 *
 ****************************************/

local
	/**
	 * Main
	 *******************/
	
	% Section 1

	RH1 = [e4 
			 stretch(factor:2.0 [c5]) 
			 e4 
			 stretch(factor:2.0 [c5]) 
			 e4 
			 stretch(factor:6.0 [c5])]

	LH1 = [stretch(factor:2.0 [
		c3 [e3 g3 c4] [g2 g3] [g3 a#3 c4] [f2 f3] [a3 c4]
		])]

	% Section 2

	RH2 =[silence [c5 e5 c6] [d5 f5 d6] [d#5 f#5 d#6] [e5 g5 e6] [c5 e5 c6] [d5 f5 d6] 
			stretch(factor:2.0 [[e5 g5 e6]]) 
			[b4 d5 b5] 
			stretch(factor:2.0 [[d5 f5 d6]])  
			stretch(factor:6.0 [[c5 e5 c6]]) 
			d4 d#4]

	RH2a = [cut(start:0.0 finish:3.2 [partition([stretch(factor:0.2 RH2)])])]

	LH2 = [stretch(factor:2.0 [[e2 e3] [g3 c4] g2 [e3 g3 c4] g2 [f3 g3 b3] c2 [e3 g3 c4] [e3 g3 c4] [g3 b3]])]

	LH2a = [stretch(factor:2.0 [[e2 e3] [g3 c4] g2 [e3 g3 c4] g2 [f3 g3 b3] c2 [e3 g3 c4]])]

	% Section 3

	RH3 = [duration(seconds:2.0 [silence])
				[a4 c5 a5] [g4 c5 g5] [f#4 c5 f#5] [a4 a5] [c5 c6] stretch(factor:2.0 [[e5 e6]]) [d5 d6]
				[c5 c6] [a4 a5] stretch(factor:6.0 [[d5 f5 d6]]) d4 d#4
			]

	LH3 = [stretch(factor:2.0 [
		[e2 e3] [d#2 d#3] [d2 d3] [d3 f#3 a3 c4] d3 [f#3 a3 c4] [g3 b3] [g2 g3] [a2 a3] [b2 b3]])]

	% Section 4

	RH4 = [[c5 c6] [d5 d6] [e5 e6]]

	RH5 = [silence [c5 c6] [d5 d6] [c5 c6] [e5 e6] [c5 c6] [d5 d6] 
			stretch(factor:2.0 [[e5 e6]])
			[c5 c6] [d5 d6] [c5 c6] [e5 g5 e6] [c5 e5 c6] [d5 f5 d6] 
			stretch(factor:2.0 [[e5 g5 e6]])
			[b4 d5 b5] 
			stretch(factor:2.0 [[d5 f5 d6]])  
			stretch(factor:6.0 [[c5 e5 c6]])
			d4 d#4]

	LH4 = [stretch(factor:2.0 [
		[g3 c4 e4] silence [c3 c4] [g3 c4 e4] [a#2 a#3] [g3 c4 e4] [a2 a3] [a3 c4 f4] [g#2 g#3] [a3 c4 f4] [g2 g3] [g3 c4 e4] g2 [g3 b3] [c3 g3 c4] [g2 g3] [a2 a3]])]

	
	% Main partition

	M1 	= merge([0.2#[partition([stretch(factor:0.2 RH1)])] 
						0.2#[partition([stretch(factor:0.2 LH1)])]])
	M2 	= merge([0.5#[partition([stretch(factor:0.2 RH2)])] 
						0.5#[partition([stretch(factor:0.2 LH2)])]])
	M3 	= merge([0.5#[partition([stretch(factor:0.2 RH3)])] 
						0.5#[partition([stretch(factor:0.2 LH3)])]])
	M2a 	= merge([0.5#RH2a 
						0.5#[partition([stretch(factor:0.2 LH2a)])]])

	M4x 	= [repeat(amount:2 [partition([stretch(factor:0.2 RH4)])]) 
				partition([stretch(factor:0.2 RH5)])]
	M4 	= merge([0.5#M4x 
						0.5#[partition([stretch(factor:0.2 LH4)])]])


	/**
	 * Putting it all together!!
	 ****************************/
	Intro = wave('intro.wav')
	Main 	= [M1 M2 M1 M3 M1 M2a M4]
	End 	= partition([[c5 e5 c6 c3 g3 c4]])
in
	[cut(start:0.0 finish:31.5 {List.flatten [Intro Main ]}) End]
end