local
	fun {PartitionToTimedList Partition}
		case Partition
		of nil then nil
		[] H|T then
			local Item ExtSound in
				Item = {New PtItem init(H)}
				if {Item is_extended_sound($)} then
					ExtSound = {Item get($)}
				else
					{Item extend}
					ExtSound = {Item get($)}
				end
				ExtSound|{PartitionToTimedList T}
			end
		end
	end

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

	fun {DroneNote Note N}
		case Note 
		of note(name:_ octave:_ sharp:_ duration:_ instrument:_) then skip
		[] H|T then skip
	end

	fun {ChordToExtended Chord}
		case Chord of nil then nil
		[] H|T then {NoteToExtended H}|{ChordToExtended T}
		end
	end

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
			[] H|_ then {{New PtItem init(H)} is_extended_sound(S)}
				/* On vérifie uniquement un élément de l'accord:
				 * dans la spec, <extended chord> est une liste d'<extended note> uniquement 
				 */
			else S = false
			end
		end

		/**
		 * Etends la valeur en attribue
		 */
		meth extend
			case @value
			of _|_ then value := {ChordToExtended @value}
			[] drone(note:N Amount) then 
				case N of Note then value := {DroneNote Note Amount} end
			[] stretch() then value := {Stretch Partition Factor}
			else value := {NoteToExtended @value}
			end
		end
	end

in
	local 
		Res1={PartitionToTimedList [a [b b] note(name:e octave:5 sharp: true duration:1 instrument:none) silence(duration:1) [f g] a]}
		Res2={PartitionToTimedList [drone(note:a 2) b]}
	in
		{Browse Res2}
	end
end
