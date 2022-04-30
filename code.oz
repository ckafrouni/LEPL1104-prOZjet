/****************************************
 * PrOZjet 2022 - Oz Player - LINFO1104 *
 * ------------------------------------ *
 * KAFROUNI christophe ------- 57961800 *
 * KENDA Tom ----------------- 32001700 *
 ****************************************/


local
	[Project] = {Link ['Project2022.ozf']}
	Time = {Link ['x-oz://boot/Time']}.1.getReferenceTime

	/*********** Helper functions ************/
	/*
	 * Helper function to create a list of size Len with value N
	 * Params: Len: integer, N: Anything
	 * Returns: list
	 */
	 fun {MakeListOfN Len N} 					% utile pour plusieurs fonctions par la suite
		{List.map {List.make Len $} fun {$ X} N end}
	end


	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% PartitionToTimedList FUNCTION
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	/**
	 * Converts a <partition> to a <flat partition>. Meaning the result is only
	 * composed of <extended sounds>. ie: <extended notes>|<extended chords>
	 * Params: Partition: <partition>
	 * Return: <flat partition>
	 */
	 fun {PartitionToTimedList Partition}
		fun {ExtendItem I}
			% Return: List of <extended sound>
			case I 
			of _|_ 									then [{List.map I ExtendNoteOrSilence}] % Item is a chord
			[] drone(note:X amount:N) 			then {DroneTransform {ExtendItem X} N}
			[] stretch(factor:F Is) 			then {StretchTransform {PartitionToTimedList Is} F}
			[] duration(seconds:D Is) 			then {DurationTransform {PartitionToTimedList Is} D}
			[] transpose(semitones:N Is)		then {TransposeTransform {PartitionToTimedList Is} N}
			else [{ExtendNoteOrSilence I}] end % Item is a note/silence/nil
		end
		fun {AccItems Acc X} {List.append Acc {ExtendItem X}} end
	in {List.foldL Partition AccItems nil} end

	/********** Utilities *********/
	/**
	 * Checks if X is already in an extended format.
	 * Returns: true|false
	 */
	fun {IsExtended X}
		case X
		of note(duration:_ instrument:_ name:_ octave:_ sharp:_) then true
		[] silence(duration:_) then true
		[] nil then true % Format for an empty chord
		else false end 
	end

	/**
	 * Converts a note to its extended form.
	 * Params: Note: <note>|<extended note>
	 * Return: <extended note>
	 */
	 fun {ExtendNoteOrSilence Note}
		if {IsExtended Note} then Note
		else case Note
			of silence then silence(duration:1.0)
			[] Name#Octave then note(name:Name octave:Octave sharp:true duration:1.0 instrument:none)
			else case {Atom.toString Note}
				of [_] then note(name:Note octave:4 sharp:false duration:1.0 instrument:none)
				[] [N O] then note(name:{String.toAtom [N]} octave:{String.toInt [O]} sharp:false duration:1.0 instrument: none)
				else raise {VirtualString.toAtom 'Could not convert: '#Note} end end
			end
		end
	end


	/****** Transformations *******/

	/**
	 * Repeats a drone or a chord multiple times.
	 * Params: 
	 * 	X: <extended note>|<extended chord>
	 *		N: integer
	 * Return: <flat partition>
	 */
	fun {DroneTransform X N}
		fun {AccItem Acc _} {List.append X Acc} end
	in {List.foldL {List.make N} AccItem nil} end


	/**
	 * Stretch every item in the partition by a factor.
	 * Params: 
	 * 	Partition: <flat partition> (List of extended sounds)
	 *		Factor: float
	 * Return: <flat partition>
	 */
	 fun {StretchTransform Partition Factor}
		fun {MapItem I} 
			case I 
			of nil then nil
			[] _|_ then {List.map I MapItem}
			[] silence(duration:X) then silence(duration:X*Factor)
			[] note(duration:D instrument:I name:N octave:O sharp:S) then note(duration:D*Factor instrument:I name:N octave:O sharp:S)
			end
		end 
	in {List.map Partition MapItem} end

	/**
	 * Set partition's total length to Duration. 
	 *	Every item is stretched accordingly.
	 * Params: 
	 * 	Partition: <flat partition> (List of extended sounds)
	 *		Duration: float
	 * Return: <flat partition>
	 */
	 fun {DurationTransform Partition Duration}
		fun {AccTime Acc X}
			case X 
			of nil then Acc
			[] Note|_ then Note.duration + Acc
			else X.duration + Acc end
		end
		Factor = Duration/{List.foldL Partition AccTime 0.0}   
	in {StretchTransform Partition Factor} end

	/**
	 * Adds N semitones to every item in the Partition,
	 *	ignoring silences.
	 * Params: 
	 * 	Partition: <flat partition> (List of extended sounds)
	 *		N: integer
	 * Return: <flat partition>
	 */
	 fun {TransposeTransform Partition N}	
		% C C# D D# E F F# G G# A A# B
		fun {AddSemitone Note}
			if Note.sharp == true then case Note.name
				of c then note(name:d sharp:false octave:Note.octave duration:Note.duration instrument:Note.instrument)
				[] d then note(name:e sharp:false octave:Note.octave duration:Note.duration instrument:Note.instrument)
				[] e then note(name:f sharp:true octave:Note.octave duration:Note.duration instrument:Note.instrument)
				[] f then note(name:g sharp:false octave:Note.octave duration:Note.duration instrument:Note.instrument)
				[] g then note(name:a sharp:false octave:Note.octave duration:Note.duration instrument:Note.instrument)
				[] a then note(name:b sharp:false octave:Note.octave duration:Note.duration instrument:Note.instrument)
				[] b then note(name:c sharp:true octave:Note.octave+1 duration:Note.duration instrument:Note.instrument)
				else raise {VirtualString.toAtom 'Could not add semitone to: '#Note} end end
			else case Note.name
				of c then note(name:c sharp:true octave:Note.octave duration:Note.duration instrument:Note.instrument)
				[] d then note(name:d sharp:true octave:Note.octave duration:Note.duration instrument:Note.instrument)
				[] e then note(name:f sharp:false octave:Note.octave duration:Note.duration instrument:Note.instrument) 
				[] f then note(name:f sharp:true octave:Note.octave duration:Note.duration instrument:Note.instrument)
				[] g then note(name:g sharp:true octave:Note.octave duration:Note.duration instrument:Note.instrument)
				[] a then note(name:a sharp:true octave:Note.octave duration:Note.duration instrument:Note.instrument)
				[] b then note(name:c sharp:false octave:Note.octave+1 duration:Note.duration instrument:Note.instrument)
				else raise {VirtualString.toAtom 'Could not add semitone to: '#Note} end end
			end
		end
		fun {RemoveSemitone Note}
			% C C# D D# E F F# G G# A A# B
			if Note.sharp == true then note(name:Note.name sharp:false octave:Note.octave duration:Note.duration instrument:Note.instrument)
			else case Note.name
				of c then note(name:b sharp:false octave:Note.octave-1 duration:Note.duration instrument:Note.instrument)
				[] d then note(name:c sharp:true octave:Note.octave duration:Note.duration instrument:Note.instrument)
				[] e then note(name:d sharp:true octave:Note.octave duration:Note.duration instrument:Note.instrument)
				[] f then note(name:e sharp:false octave:Note.octave duration:Note.duration instrument:Note.instrument)
				[] g then note(name:f sharp:true octave:Note.octave duration:Note.duration instrument:Note.instrument)
				[] a then note(name:g sharp:true octave:Note.octave duration:Note.duration instrument:Note.instrument) 
				[] b then note(name:a sharp:true octave:Note.octave duration:Note.duration instrument:Note.instrument) end
			end
		end

		fun {TransposeUp I}
			case I 
			of nil then nil
			[] note(name:_ sharp:_ octave:_ duration:_ instrument:_) then {AddSemitone I}
			[] _|_ then {List.map I AddSemitone} end
		end
		fun {TransposeDown I}
			case I 
			of nil then nil
			[] note(name:_ sharp:_ octave:_ duration:_ instrument:_) then {RemoveSemitone I}
			[] _|_ then {List.map I RemoveSemitone} end
		end
	in
		if N > 0 then {TransposeTransform {List.map Partition TransposeUp} N-1}
		elseif N < 0 then {TransposeTransform {List.map Partition TransposeDown} N+1}
		else Partition
		end
	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Mix FUNCTION
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	/**
	 * Samples a Music, by applying filter, or transformations on Music.
	 * Params: 
	 * 	Music: <music>
	 * 	P2T: function that can convert a <partition> into a <flat partition>
	 * Return: <samples> meaning it returns a list of samples bounded between [~1.0;1.0].
	 */
	fun {Mix P2T Music}
		fun {Go Part}
			case Part
			of partition(P) 								then {SamplePartition {P2T P}}
			[] samples(S) 									then S
			[] wave(Filename) 							then {Project.readFile Filename}
			[] merge(Ms) 									then {MergeMusics Ms P2T}
			[] reverse(Ms) 								then {List.reverse {Mix P2T Ms}}
			[] repeat(amount:N Ms) 						then {RepeatFilter N {Mix P2T Ms}}
			[] loop(seconds:S Ms) 						then {LoopFilter S {Mix P2T Ms}}
			[] cut(start:S finish:F Ms) 				then {CutFilter S F {Mix P2T Ms}}
			[] clip(low:LowS high:HighS Ms) 			then {ClipFilter LowS HighS {Mix P2T Ms}}
			[] echo(delay:D decay:F Ms)				then {EchoFilter D F {Mix P2T Ms} P2T} 
			[] fade(start:Time_in out:Time_out Ms) then {FadeFilter Time_in Time_out {Mix P2T Ms}}
			else raise {VirtualString.toAtom 'Invalid part: '#Part} end end
		end
	in {List.flatten {List.map Music Go}} end

	/*************** Sampling ****************/
	/**
	 * Samples a partition.
	 * The function traverses the partition, calling the 
	 * appropriate function to convert a note, a chord, or a silence
	 * Params: ExtPart: <flat partition>
	 * Return: <samples>
	 */
	fun {SamplePartition ExtPart}
		fun {SampleNote Note}
			fun {GetHeight Note} 
				fun {HeightAcc Note Acc}
					if Note.name == a andthen Note.sharp == false then 12*(Note.octave-4)-Acc
					else {HeightAcc {TransposeTransform [Note] 1}.1 Acc+1} end
				end
			in {HeightAcc Note 0} end
	
			fun {CalcAi I} X in
				% Calculates sample at index I
				X = 2.0 * 3.14159265359 * Freq * {Int.toFloat I}
				0.5 * {Sin X/44100.0}
			end

			Height		= {Int.toFloat {GetHeight Note}}
			Freq			= {Pow 2.0 (Height/12.0)} * 440.0
			SampleSize	= Note.duration * 44100.0
			Is				= {List.number 0 {Float.toInt SampleSize}-1 1}

		in {List.map Is CalcAi} end

		fun {SampleChord Chord}
			SampleSize = {String.toFloat (Chord.1).duration} * 44100.0
			fun {Sum X Y} X+Y end
			fun {Go Chord Acc}
				case Chord
				of nil then Acc
				[] Note|T then {Go T {List.zip Acc {SampleNote Note} Sum $}}
				end
			end
			Start = {List.map {List.make {Float.toInt SampleSize} $} fun {$ X} 0.0 end}
		in {List.map {Go Chord Start} fun {$ X} X/{Int.toFloat {List.length Chord}} end} end

		fun {SampleSilence Silence}
			{List.map {List.make {Float.toInt Silence.duration * 44100.0}} fun {$ _} 0.0 end}
		end

		fun {AccSamples Acc Item}
			case Item
			of nil then Acc
			[] _|_ then {List.append Acc {SampleChord Item}}
			[] silence(duration:_) then {List.append Acc {SampleSilence Item}}
			[] Note then {List.append Acc {SampleNote Note}} end
		end
	in {List.foldL ExtPart AccSamples nil} end


	/*************** Transformations ****************/
	/**
	 * Merges <musics> by applying specific ratios.
	 * Params: 
	 * 	MusicsWithInts: List of float#<music>
	 * 		[0.1#Mu1 0.4#Mu2 0.5#Mu3]
	 * Return: <samples>
	 */
	fun {MergeMusics MusicsWithInts P2T}
		fun {Scale Mus}
			case Mus
			of F#M then {List.map {Mix P2T M} fun {$ X} F*X end}
			else nil end
		end

		fun {GetMaxLength Xs Cur}
			case Xs
			of H|T then
				if {List.length H} > Cur then {GetMaxLength T {List.length H}}
				else {GetMaxLength T Cur} end
			[] nil then Cur
			end
		end

		fun {MakeDiffs Ms Max}
			{List.map Ms fun {$ M} Max-{List.length M} end}
		end

		fun {CompleteWith0 M Diff}
			{List.append M {MakeListOfN Diff 0.0}}
		end

		fun {SumMs Ms Acc}
			case Ms
			of nil then Acc
			[] H|T then 
				{SumMs T
					{List.zip Acc H fun {$ X Y} X+Y end $}}
			end
		end
		Ms Max Diffs Final
	in
		Ms = {List.map MusicsWithInts Scale}
		Max = {GetMaxLength Ms 0}
		Diffs = {MakeDiffs Ms Max}
		Final = {List.zip Ms Diffs CompleteWith0 $}
		{SumMs Final {MakeListOfN Max 0.0}}
	end


	/*************** Filters ****************/
	/**
	 * Repeats Music N times.
	 * Params: Music: <music>, N: integer
	 * Return: <samples>
	 */
	fun {RepeatFilter N Music}
		if N==0 then nil
		else {List.flatten Music|{RepeatFilter N-1 Music}} % {List.flatten Music|Music|nil}
		end
	end

	/**
	 * Loops Music for S seconds.
	 * Params: Music: <music>, S: float
	 * Return: <samples>
	 */
	fun {LoopFilter S Music}
		TotalLen = {Float.toInt S * 44100.0}
		Len = {List.length Music}
		NRepeat = TotalLen div Len
		NTake = TotalLen mod Len
	in {List.append {RepeatFilter NRepeat Music} {List.take Music NTake}} end

	/**
	 * Keeps Music between Start and Finish.
	 * Params: Music: <music>, Start: positive float, Finish: positive float
	 * Return: <samples>
	 */
	fun {CutFilter Start Finish Music}
		% Note : Start is excluded qnd Finish is included
		SampleStart = {Float.toInt Start * 44100.0}
		SampleFinish = {Float.toInt Finish * 44100.0}
		TotalLen = SampleFinish - SampleStart
		
		CuttedMusic = {List.take {List.drop Music SampleStart} TotalLen } % drop before the start and then take until the finish
		SilenceLen
	in
		if SampleFinish > {List.length Music} then
			SilenceLen = TotalLen - {List.length CuttedMusic}  % Taille manquante (silence)
			{List.append CuttedMusic {MakeListOfN SilenceLen 0.0} }  
		else CuttedMusic end
	end

	/**
	 * Bounds the Music sample between Low and High
	 * Params: Music: <music>, Low: float in [~1.0;1.0], High: float in [~1.0;1.0]
	 * Return: <samples>
	 */
	fun {ClipFilter Low High Music}
		{List.map Music fun {$ X} if X < Low then Low elseif X > High then High else X end end}
	end

	/**
	 * Echos the Music, the music is repeated after a delay, at a dimished intensity.
	 * Params: Music: <music>, Delay: float, Decay: float in [0.0;1.0]
	 * Return: <samples>
	 */
	fun {EchoFilter Delay Decay Music P2T}
		Echo = {List.append {MakeListOfN {Float.toInt Delay*44100.0} 0.0} Music}
		DecayedEcho = {List.map Echo fun {$ X} X*Decay end}
		NewMusic = {List.append Music {MakeListOfN {Float.toInt Delay*44100.0} 0.0}}
	in  {List.zip DecayedEcho NewMusic fun {$ X Y} X+Y end} end

	/**
	 * Increases the Music's intensity at the start, and decreases it in the end
	 * for a Time_in and Time_out delay.
	 * Params: Music: <music>, Time_in: float, Time_out: float
	 * Return: <samples>
	 */
	fun {FadeFilter FStart FOut Music}
		Tmp MiddleSection
		fun {DoFade Ms}
			F = 1.0/{Int.toFloat {List.length Ms}}
		in {List.mapInd Ms fun {$ I X} {Int.toFloat I-1}*F*X end} end

		StartSize 	= {Float.toInt FStart*44100.0}
		OutSize 		= {Float.toInt FOut*44100.0}
		MiddleSize 	= {List.length Music} - (StartSize+OutSize)

		StartSection 	= {List.takeDrop Music StartSize $ Tmp}
		OutSection 		= {List.takeDrop Tmp MiddleSize MiddleSection $}

		FadedStart 	= {DoFade StartSection}
		FadedOut 	= {List.reverse {DoFade {List.reverse OutSection}}}

	in {List.append {List.append FadedStart MiddleSection} FadedOut} end


	%----------------------------------------------------------------------------%

	% pour la soumision finale :
	Music = {Project.load 'example.dj.oz'}
	Start
in
	Start = {Time}
	{ForAll [ExtendNoteOrSilence Music] Wait}
	{Browse {Project.run Mix PartitionToTimedList Music 'out.wav'}}
	{Browse {Int.toFloat {Time}-Start} / 1000.0}
end