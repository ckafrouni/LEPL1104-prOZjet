/****************************************
 * PrOZjet 2022 - Oz Player - LINFO1104 *
 * ------------------------------------ *
 * KAFROUNI christophe ------- 57961800 *
 * KENDA Tom ----------------- 32001700 *
 ****************************************/


local
	[Project] = {Link ['Project2022.ozf']}
	Time = {Link ['x-oz://boot/Time']}.1.getReferenceTime

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
			else case {AtomToString Note}
				of [_] then note(name:Note octave:4 sharp:false duration:1.0 instrument:none)
				[] [N O] then note(name:{StringToAtom [N]} octave:{StringToInt [O]} sharp:false duration:1.0 instrument: none)
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

	fun {SampleFromNote Note}

		fun {GetHeight Note} 
			% C3 C#3 D3 D#3 E3 F3 F#3 G3 G#3 A3 A#3 B3 C4 C#4 D4 D#4 E4 F4 F#4 G4 G#4 |A4| A#4 B4 C5 C#5 D5 D#5 E5 F5 F#5 G5 G#5 A5 A#5 B5
			fun {HeightAcc Note Acc}
				if Note.name == a andthen Note.sharp == false then 12*(Note.octave-4)-Acc
				else {HeightAcc {TransposeTransform [Note] 1}.1 Acc+1} end
			end
		in case Note of silence(duration:_) then 0 else {HeightAcc Note 0} end end

		fun {CalcAi I} X in			% fonction qui calcule Ai pour chaque pas de temps
				X = 2.0 * 3.14159265359 * Freq * {IntToFloat I}
				0.5 * {Sin X/44100.0}
		end
		Height Freq 
		SampleSize = Note.duration * 44100.0
		Is = {List.number 0 {FloatToInt SampleSize}-1 1}
	in
		case Note 
		of silence(duration:_) then {List.map Is fun {$ _} 0.0 end}
		else
			Height = {IntToFloat {GetHeight Note}} % float
			Freq = {Pow 2.0 (Height/12.0)} * 440.0
			{List.map Is CalcAi}
		end
	end

	fun {SampleFromChord Chord}
		SampleSize = {StringToFloat (Chord.1).duration} * 44100.0
		fun {Sum X Y} X+Y end
		fun {Go Chord Acc}
			case Chord
			of nil then Acc
			[] Note|T then {Go T {List.zip Acc {SampleFromNote Note} Sum $}}
			end
		end
		Start = {Map {List.make {FloatToInt SampleSize} $} fun {$ X} 0.0 end}

	in {Map {Go Chord Start} fun {$ X} X/{IntToFloat {Length Chord}} end} end

	/* 
	* Take an extended partition, e.g. [note(duration:2 instrument:none name:a octave:0 sharp:false) ... nil ...]
	* check if it is not empty, then check if each element is a chord or a note,
	* and then turn each note into a sample and finally append all the sample together
	*/
	fun {SamplePartition ExtPart}
		case ExtPart
		of nil then nil
		[] H|T then
			case H
			of nil then {Append nil {SamplePartition T}}				% if H is nil (empty chord) then it is deleted from the partition (empty chord duration = 0)
			[] _|_ then {Append {SampleFromChord H} {SamplePartition T}}
			else {Append {SampleFromNote H} {SamplePartition T}} 
			end
		end
	end

	fun {MakeListOfN Len N} 					% utile pour plusieurs fonctions par la suite
		{Map {List.make Len $} fun {$ X} N end}
	end

	fun {MergeMusics MusicsWithInts P2T}
		% [0.1#Mu1 0.4#Mu2 0.5#Mu3]
		fun {Scale Mus}
			case Mus
			of F#M then {Map {Mix P2T M} fun {$ X} F*X end}
			else nil
			end
		end

		fun {GetMaxLength Xs Cur}
			case Xs
			of H|T then
				if {Length H} > Cur then {GetMaxLength T {Length H}}
				else {GetMaxLength T Cur} end
			[] nil then Cur
			end
		end

		fun {MakeDiffs Ms Max}
			{Map Ms fun {$ M} Max-{Length M} end}
		end

		fun {CompleteWith0 M Diff}
			{Append M {MakeListOfN Diff 0.0}}
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
		Ms = {Map MusicsWithInts Scale}
		Max = {GetMaxLength Ms 0}
		Diffs = {MakeDiffs Ms Max}
		Final = {List.zip Ms Diffs CompleteWith0 $}
		{SumMs Final {MakeListOfN Max 0.0}}
	end

	fun {RepeatFilter N Music}
		if N==0 then nil
		else {Flatten Music|{RepeatFilter N-1 Music}} % {Flatten Music|Music|nil}
		end
	end

	fun {LoopFilter S Music}
		% SPEC: S est un float
		TotalLen = {FloatToInt S * 44100.0}
		Len = {Length Music}
		NRepeat = TotalLen div Len
		NTake = TotalLen mod Len
	in
		{Append {RepeatFilter NRepeat Music} {List.take Music NTake}}
	end

	fun {CutFilter Start Finish Music}
		% SPEC : start and finish doivent être > 0
		% Note : Start est exclu mais Finish est inclu (dans la liste final)
		SampleStart = {FloatToInt Start * 44100.0}
		SampleFinish = {FloatToInt Finish * 44100.0}
		TotalLen = SampleFinish - SampleStart
		
		CuttedMusic = {List.take {List.drop Music SampleStart} TotalLen } % drop before the start and then take until the finish
		SilenceLen
	in
		if SampleFinish > {Length Music} then
			SilenceLen = TotalLen - {Length CuttedMusic}  % Taille manquante (silence)
			{Append CuttedMusic {MakeListOfN SilenceLen 0.0} }  
		else
			CuttedMusic 				
		end
	end

	fun {ClipFilter Low High Music}
		{List.map Music fun {$ X} if X < Low then Low elseif X > High then High else X end end}
	end

	fun {EchoFilter Delay Decay Ms P2T}
		Echo = {List.append {MakeListOfN {FloatToInt Delay*44100.0} 0.0} Ms}
		DecayedEcho = {List.map Echo fun {$ X} X*Decay end}
		NewMs = {List.append Ms {MakeListOfN {FloatToInt Delay*44100.0} 0.0}}
	in 
		{List.zip DecayedEcho NewMs fun {$ X Y} X+Y end}
	end

	% Fade Filter
	fun {FadeFilter Time_in Time_out Music}

		fun {MultList L1 L2} {List.zip L1 L2 fun {$ Xi Yi} Xi*Yi end $} end % multiply 2 lists element wize

		fun {GetFadeFilter SampleSize}
			% Return a list to multiply the music with          ex. if samplesize = 5
			Factor = 1.0/({IntToFloat SampleSize})         % --> 1/5
			L = {MakeListOfN SampleSize-1 1.0}                    % --> [1 1 1 1] 
		in {Append [0.0] {List.mapInd L fun {$ I A} {IntToFloat I} * Factor end $}} end % --> [0 0.2 0.4 0.8]

		Time_in_S = {FloatToInt Time_in * 44100.0}
		Time_out_S = {FloatToInt Time_out * 44100.0}
		Middle_len  = {Length Music} - (Time_out_S) - (Time_in_S)

		Finish_time = {Length Music} - (Time_out_S)

		StartSample  = {List.take Music (Time_in_S) }
		FinalSample  = {List.drop Music Finish_time}   %Note pour économiser la mémoire on pourrait mettre le calcul de finish dedant direct

		MiddleSample = {List.take {List.drop Music (Time_in_S)} Middle_len } % drop before the start and then take until the finish

		FadedStart = {MultList StartSample {GetFadeFilter Time_in_S }}
		FadedFinal = {MultList FinalSample {Reverse {GetFadeFilter Time_out_S }}}	
	in {Append {Append FadedStart MiddleSample} FadedFinal } end


	%----------------------------------------------------------------------------%
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
			[] _ then nil
			end
		end
	in {Flatten {Map Music Go}} end

	% pour la soumision finale :
	Music = {Project.load 'example.dj.oz'}
	Start
in
	Start = {Time}
	{ForAll [ExtendNoteOrSilence Music] Wait}
	{Browse {Project.run Mix PartitionToTimedList Music 'out.wav'}}
	{Browse {IntToFloat {Time}-Start} / 1000.0}
end