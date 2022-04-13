local
	fun {NoteToExtended Note}
      case Note
      of Name#Octave then
         note(name:Name octave:Octave sharp:true duration:1.0 instrument:none)
      [] Atom then
         case {AtomToString Atom}
         of [_] then
            note(name:Atom octave:4 sharp:false duration:1.0 instrument:none)
         [] [N O] then
            note(name:{StringToAtom [N]}  octave:{StringToInt [O]} sharp:false duration:1.0 instrument: none)
         end
      end
   end

   fun {ChordToExtended Chord}
		case Chord of nil then nil
		[] H|T then 
			case H of note(name:_ octave:_ sharp:_ duration:_ instrument:_) then H|{ChordToExtended T}
			else {NoteToExtended H}|{ChordToExtended T}
			end
		end
	end

   fun {DroneNote Note N}
		if N==0 then nil
		else 
			case Note 
			of note(name:_ octave:_ sharp:_ duration:_ instrument:_) then Note|{DroneNote Note N-1}
			else 
				{DroneNote {NoteToExtended Note} N}
			end
		end
	end

	fun {StretchExtend Facteur ExtPartition}
		% loop sur Extpartition et multiplier temps par facteur
		case ExtPartition
		of nil then nil
		[] H|T then
			case H
			of _|_ then {StretchExtend Facteur H}|{StretchExtend Facteur T}
			[] note(name:N octave:O sharp:S duration:D instrument:I) then
				local Res in
					Res = Facteur * {StringToFloat D}
					note(name:N octave:O sharp:S duration:Res instrument:I)|{StretchExtend Facteur T}
				end
			end
		end
	end

	fun {GetTotalTime ExtPartition}
		fun {Go ExtPartition Acc}
			case ExtPartition
			of nil then Acc
			[] H|T then
				case H
				of H1|_ then {Go T Acc+{StringToFloat H1.duration}}
				else {Go T Acc+{StringToFloat H.duration}}
				end
			end
		end
	in
		{Go ExtPartition 0.0}
	end

	fun {DurationExtend NewLength ExtPartition}
		CurrentLength = {GetTotalTime ExtPartition}
		Facteur = NewLength/CurrentLength
	in
		{StretchExtend Facteur ExtPartition}
	end

	% fun {TransposeExtend N ExtPartition}
	% 	TABLE = semitones(
	% 			'c':'c#'
	% 			'c#':'d'
	% 			'd''d#'
	% 			'd#':'e'
	% 			'e':'f'
	% 			'f':'f#'
	% 			'f#':'g'
	% 			'g':'g#'
	% 			'g#':'a'
	% 			'a''a#'
	% 			'a#':'b'
	% 			'b':'c'
	% 	)

	% 	TABLE = semitones(
	% 		n(name:c sharp:true)
	% 		n(name:d sharp:false)
	% 		n(name:d sharp:true)
	% 		n(name:e sharp:false)
	% 		n(name:f sharp:false)
	% 		n(name:f sharp:true)
	% 		n(name:g sharp:false)
	% 		n(name:g sharp:true)
	% 		n(name:a sharp:false)
	% 		n(name:a sharp:true)
	% 		n(name:b sharp:false)
	% 		n(name:c sharp:false)
	% 		)

	% 	fun {TransposeNote N Note}
	% 		% note(name:d sharp:true octave:5 duration:2 ..)
	% 		% OldNote = Note
	% 		if N /= 0 then
	% 			NewNote = note(name:TABLE.(Note.name) sharp:false octave:Note.octave )
	% 			{TransposeNote N TABLE.Note.name} 
	% 	end

	% in
	% 	case ExtPartition
	% 	of nil then nil
	% 	[] H|T then
	% 		case H
	% 		of H|T then
	% 		else {TransposeNote N H}
	% 	end
	% end


   /***************************************************************************/

	class PtItem
		attr value

		meth init(S)
			value := S
		end

		meth get(R)
			R = @value
		end

		/**
		 * <extended sound> ::= <extended note>|<extended chord>
		 */
		meth is_extended_sound(S)
			case @value
			of silence(duration:_ ) then S = true
			[] note(name:_ octave:_ sharp:_ duration:_ instrument:_ ) then S = true
			else S = false
			end
		end

		/**
		 * Etends la valeur en attribue
		 */
		meth extend
			case @value
			of _|_ then value := [{ChordToExtended @value}]
			[] drone(note:N Amount) then 
				case N of Note then value := {DroneNote Note Amount} end
			[] duration(seconds:S Partition) then 
				value := {DurationExtend {StringToFloat S} {PartitionToTimedList Partition}}
			[] stretch(factor:F Partition) then
				value := {StretchExtend {StringToFloat F} {PartitionToTimedList Partition}}
			% [] transpose(semitones:N Partition) then
			% 	value := {TransposeExtend {StringToFloat N} {PartitionToTimedList Partition}}
			else value := {NoteToExtended @value}
			end
		end
	end

   fun {PartitionToTimedList Partition}
		fun {Go Partition Acc}
			case Partition
			of nil then Acc
			[] H|T then
				local Item ExtSound in
					Item = {New PtItem init(H)}
					if {Item is_extended_sound($)} then
						ExtSound = {Item get($)}
					else
						{Item extend}
						ExtSound = {Item get($)}
					end
					case ExtSound 
					of _|_ then {Go T {Append Acc ExtSound}}
					else {Go T {Append Acc [ExtSound]}}
					end
				end
			end
		end
	in
		{Go Partition nil}
	end

	%%%%%%%%%%%
	%Res1={PartitionToTimedList [a [b b] note(name:e octave:5 sharp: true duration:1 instrument:none) silence(duration:1) [f g] a]}
	%Res2={PartitionToTimedList [b drone(note:a 2) [a b]]} %[[a a] b]
	Res2={PartitionToTimedList [a duration(seconds:5 [b [a g] d])]}
	%Res2={PartitionToTimedList [stretch(factor:2.3 [a [a b] a]) c]} %[[a a] b]

in
	{Browse Res2}
end

{Browse 1}