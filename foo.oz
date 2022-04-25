%%%% Test/brouillon pour la fonction Fade
% local
%     fun {MultList L1 L2}
%         {List.zip L1 L2 fun {$ Xi Yi} Xi*Yi end $}
%     end

%     fun {MakeListOfN Len N} 					% utile pour plusieurs fonctions par la suite
%         {Map {List.make Len $} fun {$ X} N end}
%     end

%     fun {GetFadeList SampleSize}
%         % Return a list to multiply the music with          ex. if samplesize = 5
%         Factor = 1.0/{IntToFloat SampleSize}                % --> 1/5
%         L = {MakeListOfN SampleSize 1.0}                    % --> [1 1 1 1 1] 
%     in
%         {Append [0.0] {List.mapInd L fun {$ I A} {IntToFloat I} * Factor end $}} % --> [0 0.2 0.4 0.8 1]
%     end
    
%     Sample = [1.0 1.0 1.0 1.0 1.0 1.0]

%     FadedSample = {MultList Sample {GetFadeList 5 }}
%     FadedSampleReverse = {MultList Sample {Reverse {GetFadeList 5 }}}
% in
%     {Browse FadedSample}
%     {Browse FadedSampleReverse}

%     {Browse ok }
% end

%%% Test pour le Empty chords

local
    fun {ExtendNoteOrSilence Note}
        case Note
        of note(duration:_ instrument:_ name:_ octave:_ sharp:_) then Note
        [] silence(duration:_) then Note
        [] silence then silence(duration:1.0)
        [] Name#Octave then note(name:Name octave:Octave sharp:true duration:1.0 instrument:none)
        [] Atom then
            {Browse 'atom'}
            case {AtomToString Atom}
            of [_] then note(name:Atom octave:4 sharp:false duration:1.0 instrument:none)
            [] [N O] then note(name:{StringToAtom [N]} octave:{StringToInt [O]} sharp:false duration:1.0 instrument: none)
            else 
                {Browse autre}
                nil
            end
        else nil
        end
     end


    %Music = [partition([a b [nil] c])]
    Chord =  [nil]
Res
in
    %{Browse Music}
    case Chord 
    of nil then {Browse vide }
    [] H|T then
        case H#T
        of nil#nil then {Browse H#T}
        else 
            Res = [{List.map Chord ExtendNoteOrSilence }]
            {Browse Res}
            %{Browse 'head'#H} 
            %{Browse 'Tail'#T}
        end

    end

end

local 
    Is = [nil]
    Ls = [1 2 3 4 ]
    fun {CalcAi I} X in 
        case I of nil then 0.0
        else
            X = 2.0 * {IntToFloat I}
            0.5 * X 
        end
    end
in
    {Browse {Append {Map Is CalcAi } {Map Ls CalcAi } }}
end

% %% out :
% 'TestEmptyChords:duration'
% actual([note(duration:2 instrument:none name:a octave:0 sharp:false) note(duration:2 instrument:none name:b octave:1 sharp:true)])
% expect([note(duration:2 instrument:none name:a octave:0 sharp:false) note(duration:2 instrument:none name:b octave:1 sharp:true) nil])