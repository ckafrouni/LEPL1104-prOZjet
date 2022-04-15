PassedTests = {Cell.new 0}
TotalTests  = {Cell.new 0}

% Time in seconds corresponding to 5 samples.
FiveSamples = 0.00011337868

% Takes a list of samples, round them to 4 decimal places and multiply them by
% 10000. Use this to compare list of samples to avoid floating-point rounding
% errors.
fun {Normalize Samples}
   {Map Samples fun {$ S} {IntToFloat {FloatToInt S*10000.0}} end}
end

proc {Assert Cond Msg}
   TotalTests := @TotalTests + 1
   if {Not Cond} then
      {System.show Msg}
   else
      PassedTests := @PassedTests + 1
   end
end

proc {AssertEquals A E Msg}
   TotalTests := @TotalTests + 1
   if A \= E then
      {System.show Msg}
      {System.show actual(A)}
      {System.show expect(E)}
   else
      PassedTests := @PassedTests + 1
   end
end

% Prevent warnings if these are not used.
{ForAll [FiveSamples Normalize Assert AssertEquals] Wait}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEST PartitionToTimedNotes
NoteList = [a b c]
ExtNoteList = [note(name:a octave:4 sharp:false duration:1.0 instrument:none) note(name:b octave:4 sharp:false duration:1.0 instrument:none) note(name:c octave:4 sharp:false duration:1.0 instrument:none)]
NoteAndExtNote = [a note(name:b octave:4 sharp:false duration:1.0 instrument:none) c]

proc {TestNotes P2T}
   {AssertEquals {P2T NoteList} ExtNoteList 'note partition'}
   {AssertEquals {P2T ExtNoteList} ExtNoteList 'extnote partition'}
   {AssertEquals {P2T NoteAndExtNote} ExtNoteList 'mix note and extnote partition'}
end

proc {TestChords P2T}
   {AssertEquals {P2T [NoteList]} [ExtNoteList] 'single chord partition'}
   {AssertEquals {P2T [ExtNoteList]} [ExtNoteList] 'single ext_chord partition'}
end

D = [duration(seconds:4 [a b])]
proc {TestDuration P2T}
   {AssertEquals {P2T D}.1 note(name:a octave:4 sharp:false duration:2.0 instrument:none) 'duration two notes'}
end

proc {TestStretch P2T}
   skip
end

proc {TestDrone P2T}
   skip
end

P = [transpose(semitones:3 [c#4 d])]
R = [note(name:e octave:4 sharp:false duration:1.0 instrument:none) note(name:f octave:4 sharp:false duration:1.0 instrument:none)]
proc {TestTranspose P2T}
   {AssertEquals {P2T P} R 'Transpose'}
end

proc {TestP2TChaining P2T}
   % test a partition with multiple transformations
   skip
end

proc {TestEmptyChords P2T}
   skip
end
   
proc {TestP2T P2T}
   {TestNotes P2T}
   {TestChords P2T}
   {TestDuration P2T}
   {TestStretch P2T}
   {TestDrone P2T}
   {TestTranspose P2T}
   {TestP2TChaining P2T}
   {TestEmptyChords P2T}   
   {AssertEquals {P2T nil} nil 'nil partition'}
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEST Mix

proc {TestSamples P2T Mix}
   skip
end

proc {TestPartition P2T Mix}
   skip
end

proc {TestWave P2T Mix}
   skip
end

proc {TestMerge P2T Mix}
   skip
end

proc {TestReverse P2T Mix}
   skip
end

proc {TestRepeat P2T Mix}
   skip
end

proc {TestLoop P2T Mix}
   skip
end

proc {TestClip P2T Mix}
   skip
end

proc {TestEcho P2T Mix}
   skip
end

proc {TestFade P2T Mix}
   skip
end

proc {TestCut P2T Mix}
   skip
end

proc {TestMix P2T Mix}
   {TestSamples P2T Mix}
   {TestPartition P2T Mix}
   {TestWave P2T Mix}
   {TestMerge P2T Mix}
   {TestReverse P2T Mix}
   {TestRepeat P2T Mix}
   {TestLoop P2T Mix}
   {TestClip P2T Mix}
   {TestEcho P2T Mix}
   {TestFade P2T Mix}
   {TestCut P2T Mix}
   {AssertEquals {Mix P2T nil} nil 'nil music'}
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

proc {Test Mix P2T}
   {Property.put print print(width:100)}
   {Property.put print print(depth:100)}
   {System.show 'tests have started'}
   {TestP2T P2T}
   {System.show 'P2T tests have run'}
   {TestMix P2T Mix}
   {System.show 'Mix tests have run'}
   {System.show test(passed:@PassedTests total:@TotalTests)}
end