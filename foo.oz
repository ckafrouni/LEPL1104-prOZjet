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



	X = {VirtualString.toAtom 'wave/instruments/'#1#'_'#2#3#'.wav'}
in
	{Browse X}
end

{Browse {VirtualString.toAtom 'a'#&5 } }

{Browse {AtomToString &t}}
