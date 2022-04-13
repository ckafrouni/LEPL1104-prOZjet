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
	Res2={PartitionToTimedList [b drone(note:a 2) [a b]]} %[[a a] b]
	%Res2={PartitionToTimedList [a duration(seconds:5 [b c d])]}

in
	{Browse Res2}
end