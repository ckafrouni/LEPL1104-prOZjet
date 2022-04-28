% of partition(P) 								then {SamplePartition {P2T P}}
% [] samples(S) 									then S
% [] wave(Filename) 							then {Project.readFile Filename}
% [] merge(Ms) 									then {MergeMusics Ms P2T}
% [] reverse(Ms) 								then {List.reverse {Mix P2T Ms}}
% [] repeat(amount:N Ms) 						then {RepeatFilter N {Mix P2T Ms}}
% [] loop(seconds:S Ms) 						then {LoopFilter S {Mix P2T Ms}}
% [] cut(start:S finish:F Ms) 				then {CutFilter S F {Mix P2T Ms}}
% [] clip(low:LowS high:HighS Ms) 			then {ClipFilter LowS HighS {Mix P2T Ms}}
% [] echo(delay:D decay:F Ms)				then {EchoFilter D F {Mix P2T Ms} P2T} 
% [] fade(start:Time_in out:Time_out Ms) then {FadeFilter Time_in Time_out {Mix P2T Ms}}

% of nil then [nil]			% Item is an empty chord (nil is and empty list thus an empty chords)
% [] _|_ then	[{List.map I ExtendNoteOrSilence}] 				% Item is a chord
% [] drone(note:X amount:N) then {DroneTransform {ExtendItem X} N}
% [] stretch(factor:F Is) then {StretchTransform {PartitionToTimedList Is} F}
% [] duration(seconds:D Is) then {DurationTransform {PartitionToTimedList Is} D}
% [] transpose(semitones:N Is) then {TransposeTransform {PartitionToTimedList Is} N}
% else [{ExtendNoteOrSilence I}] 		% Item is a note/silence



local
	N1 = note(name:f sharp:true octave:4 duration:1.5 instrument:none)
	Ac1 = [c5 d5 e5]
	Ac2 = [c4 e4 g4]
	Ac3 = [c5 e5 g5]
	B1 = duration(seconds:3.0 [drone(amount:5 note:Ac1) drone(amount:3 note:Ac2) drone(amount:2 note:Ac3)])

	Partition = [N1 B1 silence c]
	% Partition = {Flatten [B1]}
	% Partition = [a b c d e]
in
   % This is a music :)
   [partition(Partition)]
end