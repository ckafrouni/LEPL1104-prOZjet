/* *** PrOZjet 2022 - Oz Player - LINFO 1401 ***
Christophe KAFROUNI – 
Tom KENDA 			– 32001700
*/

local
   % See project statement for API details.
   [Project] = {Link ['Project2022.ozf']}
   Time = {Link ['x-oz://boot/Time']}.1.getReferenceTime

	
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% PartitionToTimedList FUNCTION
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	/**
	 * Function converts a note to its extended form. 
	 * Params: Note: <note>|<extended note>
	 * Return: <extended note>
	 */
   fun {ExtendNoteOrSilence Note}
      case Note
      of note(duration:_ instrument:_ name:_ octave:_ sharp:_) then Note
      [] silence(duration:_) then Note
      [] silence then silence(duration:1.0)
      [] Name#Octave then note(name:Name octave:Octave sharp:true duration:1.0 instrument:none)
      [] Atom then
		case {AtomToString Atom}
        of [_] then note(name:Atom octave:4 sharp:false duration:1.0 instrument:none)
        [] [N O] then note(name:{StringToAtom [N]} octave:{StringToInt [O]} sharp:false duration:1.0 instrument: none)
        else nil % si un a un accord vide [nil] ca rentre ici car nil est une atom
		end
	  else nil
      end
   end

	/**
	 * Repeats a drone or a chord multiple times.
	 * Params: 
	 * 	X: <extended note>|<extended chord>
	 *		N: integer
	 * Return: <flat partition>
	 */
   fun {DroneTransform X N}
		{List.foldR 
			{List.map {List.make N} fun {$ _} X end}
			List.append nil}
   end

	/**
	 * Stretch every item in the partition by a factor.
	 * Params: 
	 * 	Partition: <flat partition> (List of extended sounds)
	 *		Factor: float
	 * Return: <flat partition>
	 */
   fun {StretchTransform Partition Factor}
      fun {Mapper I} 
         case I of _|_ then {List.map I Mapper}
         [] silence(duration:X) then silence(duration:X*Factor)
         [] note(duration:D instrument:I name:N octave:O sharp:S) then
            note(duration:D*Factor instrument:I name:N octave:O sharp:S)
         end
      end 
   in {List.map Partition Mapper} end
	
	/**
	 * Set partition's total length to Duration. 
	 *	Every item is stretched accordingly.
	 * Params: 
	 * 	Partition: <flat partition> (List of extended sounds)
	 *		Duration: float
	 * Return: <flat partition>
	 */
   fun {DurationTransform Partition Duration}
      fun {AccTime X Acc}
         case X of Note|_ then Note.duration + Acc
         [] _ then X.duration + Acc end
      end
      CurrentLength = {List.foldR Partition AccTime 0.0}
      Factor = Duration/CurrentLength   
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
				[] f then note(name:g sharp:false octave:Note.octave duration:Note.duration instrument:Note.instrument)
				[] g then note(name:a sharp:false octave:Note.octave duration:Note.duration instrument:Note.instrument)
				[] a then note(name:b sharp:false octave:Note.octave duration:Note.duration instrument:Note.instrument) end
			else case Note.name
				of c then note(name:c sharp:true octave:Note.octave duration:Note.duration instrument:Note.instrument)
				[] d then note(name:d sharp:true octave:Note.octave duration:Note.duration instrument:Note.instrument)
				[] f then note(name:f sharp:true octave:Note.octave duration:Note.duration instrument:Note.instrument)
				[] g then note(name:g sharp:true octave:Note.octave duration:Note.duration instrument:Note.instrument)
				[] a then note(name:a sharp:true octave:Note.octave duration:Note.duration instrument:Note.instrument)
				[] e then note(name:f sharp:false octave:Note.octave duration:Note.duration instrument:Note.instrument) 
				[] b then note(name:c sharp:false octave:Note.octave+1 duration:Note.duration instrument:Note.instrument) end
			end
		end
		fun {RemoveSemitone Note}
			if Note.sharp == true then case Note.name
				of c then note(name:c sharp:false octave:Note.octave duration:Note.duration instrument:Note.instrument)
				[] d then note(name:d sharp:false octave:Note.octave duration:Note.duration instrument:Note.instrument)
				[] f then note(name:f sharp:false octave:Note.octave duration:Note.duration instrument:Note.instrument)
				[] g then note(name:g sharp:false octave:Note.octave duration:Note.duration instrument:Note.instrument)
				[] a then note(name:a sharp:false octave:Note.octave duration:Note.duration instrument:Note.instrument) end
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
			case I of note(name:_ sharp:_ octave:_ duration:_ instrument:_) then {AddSemitone I}
			[] _|_ then {List.map I AddSemitone} end
		end
		fun {TransposeDown I}
			case I of note(name:_ sharp:_ octave:_ duration:_ instrument:_) then {RemoveSemitone I}
			[] _|_ then {List.map I RemoveSemitone} end
		end
	in
		if N > 0 then {TransposeTransform {List.map Partition TransposeUp} N-1}
		elseif N < 0 then {TransposeTransform {List.map Partition TransposeDown} N+1}
		else Partition
		end
	end

   %----------------------------------------------------------------------------%
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
			of nil then nil
			[] H|T then Res in 			% Item is a chord
				case H#T 
				of nil#nil then [nil] 	% Item is an empty chord
				else 					% else : normal chord
					%{Browse 'chord : '#[{List.map I ExtendNoteOrSilence}]}
					[{List.map I ExtendNoteOrSilence}]
				end
			[] drone(note:X amount:N) then {DroneTransform {ExtendItem X} N}
			[] stretch(factor:F Is) then {StretchTransform {PartitionToTimedList Is} F}
			[] duration(seconds:D Is) then {DurationTransform {PartitionToTimedList Is} D}
			[] transpose(semitones:N Is) then {TransposeTransform {PartitionToTimedList Is} N}
			else 
				%{Browse 'Note : '#[{ExtendNoteOrSilence I}]}  
				[{ExtendNoteOrSilence I}] 		% Item is a note/silence
			end
		end
      Result Res
	in
      {List.map Partition ExtendItem Result}
      Res = {List.foldR Result List.append nil}
	  %{Browse 'Res P2T'#Res} 
	  Res
   end
	

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% MIX FUNCTIONS
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	fun {SampleFromNote Note}
		fun {GetHeight Note} 
			% 12*(O-4)-Counter
			% C3 C#3 D3 D#3 E3 F3 F#3 G3 G#3 A3 A#3 B3 C4 C#4 D4 D#4 E4 F4 F#4 G4 G#4 |A4| A#4 B4 C5 C#5 D5 D#5 E5 F5 F#5 G5 G#5 A5 A#5 B5
			fun {HeightAcc Note Acc}
				%{Browse 'heightacc:'#Note}
				if Note.name == a andthen Note.sharp == false then 12*(Note.octave-4)-Acc
				else {HeightAcc {TransposeTransform [Note] 1}.1 Acc+1} end
			end
		in 
			case Note 
			of silence(duration:_) then 0 
			else {HeightAcc Note 0} 
			end 
		end

		case Note
		of nil then Is = [nil] 		% si accord vide
		else 						% si note normal
			Height = {IntToFloat {GetHeight Note}} % float
			Freq = {Pow 2.0 (Height/12.0)} * 440.0
			SampleSize = {StringToFloat Note.duration} * 44100.0
			Is = {List.number 1 {FloatToInt SampleSize} 1}
		end
		fun {CalcAi I} X in			% fonction qui calcule Ai pour chaque pas de temps
			case I of nil then 0.0 	% si accord vide %%%%%%%%%% j'ai pas trouvé d'autre manière de faire ... on peut pas juste skip et pas mettre de chiffre ..?
			else					% si accord normal
				X = 2.0 * 3.14159265359 * Freq * {IntToFloat I}
				0.5 * {Sin X/SampleSize $} 
			end
		end
	Is Height Freq SampleSize
	in
		% {Browse {Map Is CalcAi}}
		{Map Is CalcAi}
	end

	fun {SampleFromChord Chord}
		SampleSize = {StringToFloat (Chord.1).duration} * 44100.0
		fun {Sum X Y} X+Y end
		fun {Go Chord Acc}
			case Chord
			of nil then Acc
			[] Note|T then 
				{Go T
					{List.zip Acc {SampleFromNote Note} Sum $}}
			end
		end
		Start = {Map {List.make {FloatToInt SampleSize} $} fun {$ X} 0.0 end}
	in
		{Map {Go Chord Start} fun {$ X} X/{IntToFloat {Length Chord}} end}
	end

	fun {SamplePartition ExtPart}
		case ExtPart
		of nil then nil
		[] H|T then
			case H
			of _|_ then {Append {SampleFromChord H} {SamplePartition T}}
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

%%% Filter function --

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

	fun {ClipFilter LowS HighS Music}
		LenLowS = {Length LowS}
		LenHighS = {Length HighS}
		LenMusic = {Length Music}
		NewLowS NewHighS TmpMusic
	in
		if LenLowS > LenMusic then NewLowS = {List.take LowS LenMusic}
		elseif LenLowS < LenMusic then NewLowS = {Append LowS {MakeListOfN (LenMusic-LenLowS) ~1.0}}
		else NewLowS = LowS end

		if LenHighS > LenMusic then NewHighS = {List.take HighS LenMusic}
		elseif LenHighS < LenMusic then NewHighS = {Append HighS {MakeListOfN (LenMusic-LenHighS) 1.0}}
		else NewHighS = HighS end

		TmpMusic = {List.zip NewHighS Music fun {$ X Y} {Min X Y} end $}
		{List.zip NewLowS TmpMusic fun {$ X Y} {Max X Y} end $}
	end

	fun {EchoFilter Delay Decay Ms P2T}
		Echo = {List.append {MakeListOfN {FloatToInt Delay*44100.0} 0.0} Ms}
	in {MergeMusics [Decay#[samples(Echo)] 1.0-Decay#[samples(Ms)]] P2T} end

	% Fade Filter
	fun {FadeFilter Time_in Time_out Music}

		fun {MultList L1 L2} {List.zip L1 L2 fun {$ Xi Yi} Xi*Yi end $}
		end % multiply 2 lists element wize

		fun {GetFadeFilter SampleSize}
			% Return a list to multiply the music with          ex. if samplesize = 5
			Factor = 1.0/{IntToFloat SampleSize}                % --> 1/5
			L = {MakeListOfN SampleSize 1.0}                    % --> [1 1 1 1 1] 
		in
			{Append [0.0] {List.mapInd L fun {$ I A} {IntToFloat I} * Factor end $}} % --> [0 0.2 0.4 0.8 1]
		end

		Time_in_S = {FloatToInt Time_in * 44100.0}
		Time_out_S = {FloatToInt Time_out * 44100.0}
		Middle_len  = {Length Music} - (Time_out_S+1) - (Time_in_S+1)

		Finish_time = {Length Music} - (Time_out_S+1)

		StartSample  = {List.take Music (Time_in_S+1) }
		FinalSample  = {List.drop Music Finish_time}   %Note pour économiser la mémoire on pourrait mettre le calcul de finish dedant direct
		MiddleSample = {List.take {List.drop Music (Time_in_S+1)} Middle_len } % drop before the start and then take until the finish

		FadedStart = {MultList StartSample {GetFadeFilter Time_in_S }}
		FadedFinal = {MultList FinalSample {Reverse {GetFadeFilter Time_out_S }}}	
	in
		{Append {Append FadedStart MiddleSample} FadedFinal }
	end

	%----------------------------------------------------------------------------%
	% TODO
   % <music> ::= nil | <part> '|' <music>
	% <filter> ::= 
	% 		fade(start:<duration> out:<duration> <music>)
   fun {Mix P2T Music}
		fun {Go Part}
			case Part
			of partition(P) 					then {SamplePartition {P2T P}}
			[] samples(S) 						then S
			[] wave(Filename) 					then {Project.readFile Filename}
			[] merge(Ms) 						then {MergeMusics Ms P2T}
			[] reverse(Ms) 						then {List.reverse {Mix P2T Ms}}
			[] repeat(amount:N Ms) 				then {RepeatFilter N {Mix P2T Ms}}
			[] loop(seconds:S Ms) 				then {LoopFilter S {Mix P2T Ms}}
			[] cut(start:S finish:F Ms) 		then {CutFilter S F {Mix P2T Ms}}
			[] clip(low:LowS high:HighS Ms) 	then {ClipFilter LowS HighS {Mix P2T Ms}}
			[] echo(delay:D decay:F Ms)			then {EchoFilter D F {Mix P2T Ms} P2T} 
			[] fade(start:Time_in finish:Time_out Ms) then {FadeFilter Time_in Time_out {Mix P2T Ms}}
			[] _ then nil
			end
		end
	in
		%{Browse 'Res Mix'#{Flatten {Map Music Go}}} 
		{Flatten {Map Music Go}}
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % TESTS
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   
	%Music1 = [partition([a b]) partition([c d])]
	% Music=[echo(delay:1.5 decay:0.4 [partition([
	% 	stretch(factor:0.5 [[c e g] [d f a] [e g b]]) a b c
	% ])])]
	%Music2 = [wave('wave/animals/cat.wav')]

	%Music = [merge([0.5#[samples([0.2 0.2 0.2])] 0.5#[samples([0.6 0.6 ])]])]
	%Music = [merge([0.5#Music1 0.5#Music2])]
	%Music = [repeat(amount:3 [partition([c d e f])])]

	% Music = [loop(seconds:3.5 [partition([c g])])]

	%% test clip
	% LoS = [~0.5 ~0.5 ~0.5 ~0.5 ~0.5]
	% HiS = [0.5 0.5 0.5 0.5 0.5 0.5]
	% Ms = [0.1 0.6 ~0.6 ~0.1 0.0 0.0]
	% Music = [clip(low:LoS high:HiS [samples(Ms)])]

    %% test cut
	% Ms = [1.0 1.0 0.2 0.2 0.2 0.2 1.0 1.0 1.0]
	% Music = [cut(start:2.0/44100.0 finish:13.0/44100.0 [samples(Ms)])]

	% Music=[echo(delay:3.0/44100.0 decay:0.5 [samples([0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9])] )]
    
	%% test fade
	% Ms = [1.0 1.0 1.0 1.0 1.0 1.0 0.2 0.2 0.2 0.2 1.0 1.0 1.0 1.0 1.0 1.0]
	% Ms = [a a a a a a a]
	% Music = [fade(start:2.0 finish:3.0 [partition(Ms)])]

	% Test empty chords
	Music = [partition([a b [nil] ])]
	
	
	% pour la soumision finale :
	% Music = {Project.load 'example.dj.oz'}

   Start

   % Uncomment next line to insert your tests.
   %\insert 'tests.oz'
   % !!! Remove this before submitting.
in
   Start = {Time}

   % Uncomment next line to run your tests.
   %{Test Mix PartitionToTimedList}

   % Add variables to this list to avoid "local variable used only once"
   % warnings.
   {ForAll [ExtendNoteOrSilence Music] Wait}
   
   % Calls your code, prints the result and outputs the result to `out.wav`.
   % You don't need to modify this.
   {Browse {Project.run Mix PartitionToTimedList Music 'out.wav'}}
   
   % Shows the total time to run your code.
   {Browse {IntToFloat {Time}-Start} / 1000.0}
end