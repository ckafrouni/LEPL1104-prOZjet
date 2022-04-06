declare
class PartitionItem
	attr item

	meth init(X)
		item := X
	end

	meth get(?X)
		X = @item
	end

	meth extendSound
		% Routing method to choose the appropriate toExt method
		case @item
		of H|T then {self toExt_chord}
		[] N then 	{self toExt_note}
		[] duration(T) then skip % TODO
		[] stretch(T) then skip % TODO
		[] drone(T) then skip % TODO
		[] transpose(T) then skip % TODO
		end
	end
	
	meth toExt_chord
		% Extended chords are composed of extended notes 
		fun {Extend Chord}
			case Chord
			of nil then nil
			[] H|T then
				case H
				of note(I) then
					% TODO check if all notes have equal duration else throw error
					I|{Extend T} % note is already extended
				[] I then note(I)|{Extend T}
				end
			end
		end
	in
		item := {Extend @item}
	end

	meth toExt_note
		item := note(@item)
	end
end

declare
fun {PartitionToTimedList Partition}
	case Partition
	of nil then nil
	[] H|T then
		local I in
			I = {New PartitionItem init(H)}
			{I extendSound}
			{I get($)}|{PartitionToTimedList T}
		end
	end
end


local Chord1 Chord2 in
	Chord1 = [a b c d]
	Chord2 = [f g]
	{Browse {PartitionToTimedList [Chord1 e Chord2]}}
end