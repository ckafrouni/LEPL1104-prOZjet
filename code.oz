local
   % See project statement for API details.
   [Project] = {Link ['Project2022.ozf']}
   Time = {Link ['x-oz://boot/Time']}.1.getReferenceTime

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   % Translate a note to the extended notation.
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
         end
      end
   end

   fun {DroneTransform NoteOrChord Amount}
		{List.foldR 
			{List.map {List.make Amount} fun {$ _} NoteOrChord end}
			List.append nil}
   end

   fun {StretchTransform Partition Factor}
      fun {Mapper I} 
         case I of _|_ then {List.map I Mapper}
         [] silence(duration:X) then silence(duration:X*Factor)
         [] note(duration:D instrument:I name:N octave:O sharp:S) then
            note(duration:D*Factor instrument:I name:N octave:O sharp:S)
         end
      end 
   in {List.map Partition Mapper} end

   fun {DurationTransform Partition Duration}
      fun {AccTime X Acc}
         case X of Note|_ then Note.duration + Acc
         [] _ then X.duration + Acc end
      end
      CurrentLength = {List.foldR Partition AccTime 0.0}
      Factor = Duration/CurrentLength   
   in {StretchTransform Partition Factor} end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % TODO:
   % <transformation> ::=
   %    | transpose(semitones:<integer> <partition>)
   %    ;
   fun {PartitionToTimedList Partition}
		% Return: <extended sound> wrapped in brackets
		fun {ExtendItem I}
			case I of nil then nil
			[] _|_ then [{List.map I ExtendNoteOrSilence}] % Item is a chord
			[] drone(note:X amount:N) then {DroneTransform {ExtendItem X} N}
			[] stretch(factor:F Is) then {StretchTransform {PartitionToTimedList Is} F}
			[] duration(seconds:D Is) then {DurationTransform {PartitionToTimedList Is} D}
			% [] transpose(semitones:N Is) then {TransposeTransform {PartitionToTimedList Is} N}
			else [{ExtendNoteOrSilence I}] % Item is a note/silence
			end
		end
      Result in
      {List.map Partition ExtendItem Result}
      {List.foldR Result List.append nil}
   end
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	%-------- A RETRAVAILLER 

	   % @ pre Note est un element de type <extendedNote>
   % @ post retourne un element de type <extendedNote> décalé d'un demi-ton vers le haut
   %          imprime non-existante si on essaye de transposer b14
   fun{AddSemi Note}
      if Note.sharp == false then
	 		if {Not (Note.name==e orelse Note.name==b)} then
	    		note(name:Note.name octave:Note.octave sharp:true duration:Note.duration instrument:Note.instrument)
	 		elseif Note.name==e then
	       	note(name:f octave:Note.octave sharp:Note.sharp duration:Note.duration instrument:Note.instrument)
	    	elseif Note.octave>=14 then 'non-existante'
	      else note(name:c octave:(Note.octave+1) sharp:Note.sharp duration:Note.duration instrument:Note.instrument)
	 		end
      else
			case Note.name
			of c then note(name:d octave:Note.octave sharp:false duration:Note.duration instrument:Note.instrument)
			[] d then note(name:e octave:Note.octave sharp:false duration:Note.duration instrument:Note.instrument)
			[] f then note(name:g octave:Note.octave sharp:false duration:Note.duration instrument:Note.instrument)
			[] g then note(name:a octave:Note.octave sharp:false duration:Note.duration instrument:Note.instrument)
			[] a then note(name:b octave:Note.octave sharp:false duration:Note.duration instrument:Note.instrument)
			end
      end
   end

	   % @pre Note est un élément de type <extended note>
   % @post retourne une <extended note> transposee d'un demi-ton vers le bas
   %       imprime non-existante si on essaye de transposer c-1
   fun{RemoveSemi Note}
      if Note.sharp==true then
	 		note(name:Note.name octave:Note.octave sharp:false duration:Note.duration instrument:Note.instrument)
      else case Note.name 
			of c then
	      	local X=Note.octave-1 in
					if X<~1 then 'non-existante'
					else note(name:b octave:X sharp:Note.sharp duration:Note.duration instrument:Note.instrument)
					end
				end
			[]f then note(name:e octave:Note.octave sharp:Note.sharp duration:Note.duration instrument:Note.instrument)
			[]a then note(name:g octave:Note.octave sharp:true duration:Note.duration instrument:Note.instrument)
			[]b then note(name:a octave:Note.octave sharp:true duration:Note.duration instrument:Note.instrument)
			[]d then note(name:c octave:Note.octave sharp:true duration:Note.duration instrument:Note.instrument)
			[]e then note(name:d octave:Note.octave sharp:true duration:Note.duration instrument:Note.instrument)
			[]g then note(name:f octave:Note.octave sharp:true duration:Note.duration instrument:Note.instrument)
			end
      end
   end

	   %@pre prend une <extended note> en argument
   %@post renvoie le nombre de demi-ton qui separe cette note et la note "c" de la meme octave que la note en argument
   fun{CountSemiFromC Note}
      local fun{CountAcc Note Ref Acc}
	       if Ref.name==Note.name andthen Ref.octave==Note.octave andthen Ref.sharp==Note.sharp then Acc
	       else
		  {CountAcc Note {AddSemi Ref} Acc+1}
	       end
	    end
      in
	 {CountAcc Note note(name:c octave:Note.octave sharp:false duration:1.0 instrument:none) 0}
      end
   end

	fun{GetHeight Note}
		case Note of silence(duration:_) then 0
			else if Note.octave =<4 then 12*(Note.octave-4)+{CountSemiFromC Note}-9
			elseif Note.octave >4 then 3+12*(Note.octave-4-1)+{CountSemiFromC Note}
			end
		end
	end

%-------- A RETRAVAILLER 

	fun {SampleFromNote Note}
		Height = {IntToFloat {GetHeight Note}} % float
		Freq = {Pow 2.0 (Height/12.0)} * 440.0
		SampleSize = {StringToFloat Note.duration} * 44100.0
		Is = {List.number 1 {FloatToInt SampleSize} 1}
		fun {CalcAi I} X in 
			X = 2.0 * 3.14 * Freq * {IntToFloat I}
			0.5 * {Sin X/SampleSize $} 
		end
	in
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

	fun {MergeMusics MusicsWithInts}
		% [0.1#Mu1 0.4#Mu2 0.5#Mu3]
		fun {Scale Mus}
			case Mus
			of F#M then {Map {Mix PartitionToTimedList M} fun {$ X} F*X end}
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

%%% Mix Function --
   fun {Mix P2T Music}
		fun {Go Part}
			case Part
			of partition(P) 						then {SamplePartition {P2T P}}
			[] samples(S) 							then S
			[] wave(Filename) 					then {Project.readFile Filename}
			[] merge(Ms) 							then {MergeMusics Ms}
			[] reverse(Ms) 						then {List.reverse {Mix P2T Ms}}
			[] repeat(amount:N Ms) 				then {RepeatFilter N {Mix P2T Ms}}
			[] loop(seconds:S Ms) 				then {LoopFilter S {Mix P2T Ms}}
			[] cut(start:S finish:F Ms) 		then {CutFilter S F {Mix P2T Ms}}
			[] clip(low:LowS high:HighS Ms) 	then {ClipFilter LowS HighS {Mix P2T Ms}}
			[] _ then nil
			end
		end
		Res
	in
		Res = {Flatten {Map Music Go}}
		{Browse Res} 
		Res
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % TEST
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   %Music = {Project.load 'joy.dj.oz'}
	%Music1 = [partition([a b]) partition([c d])]
	Music=[partition([
		stretch(factor:0.5 [[c e g] [d f a] [e g b]]) a b c
	])]
	%Music2 = [wave('wave/animals/cat.wav')]

	%Music = [merge([0.5#[sample([0.2 0.2 0.2])] 0.5#[sample([0.6 0.6 ])]])]
	%Music = [merge([0.5#Music1 0.5#Music2])]
	%Music = [repeat(amount:3 [partition([c d e f])])]

	% Music = [loop(seconds:3.5 [partition([c g])])]

	%% test clip
	% LoS = [~0.5 ~0.5 ~0.5 ~0.5 ~0.5]
	% HiS = [0.5 0.5 0.5 0.5 0.5 0.5]
	% Ms = [0.1 0.6 ~0.6 ~0.1 0.0 0.0]
	% Music = [clip(low:LoS high:HiS [sample(Ms)])]

    %% test cut
	% Ms = [1.0 1.0 0.2 0.2 0.2 0.2 1.0 1.0 1.0]
	% Music = [cut(start:2.0/44100.0 finish:13.0/44100.0 [sample(Ms)])]


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