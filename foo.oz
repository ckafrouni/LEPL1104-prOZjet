% declare L1
% L1 = [1.0 1.0 1.0 0.5 0.5 ]
% Factor = 1.0/{IntToFloat{Length L1}}
% {Browse [1 1 1 1 1 1] }
% {Browse {Append [0.0] {List.mapInd L1 fun {$ I A} A # {IntToFloat I} * Factor end}}}

local
    fun {MultList L1 L2}
        {List.zip L1 L2 fun {$ Xi Yi} Xi*Yi end $}
    end

    fun {MakeListOfN Len N} 					% utile pour plusieurs fonctions par la suite
        {Map {List.make Len $} fun {$ X} N end}
    end

    fun {GetFadeList SampleSize}
        % Return a list to multiply the music with          ex. if samplesize = 5
        Factor = 1.0/{IntToFloat SampleSize}                % --> 1/5
        L = {MakeListOfN SampleSize 1.0}                    % --> [1 1 1 1 1] 
    in
        {Append [0.0] {List.mapInd L fun {$ I A} {IntToFloat I} * Factor end $}} % --> [0 0.2 0.4 0.8 1]
    end
    
    Sample = [1.0 1.0 1.0 1.0 1.0 1.0]

    FadedSample = {MultList Sample {GetFadeList 5 }}
    FadedSampleReverse = {MultList Sample {Reverse {GetFadeList 5 }}}
in
    {Browse FadedSample}
    {Browse FadedSampleReverse}

    {Browse ok }
end


% declare
% L3 = [0.0 0.2 0.4 0.6 0.8 1.0]
% L4 = 
% L2 = {List.zip L3 L4  fun {$ Xi Yi} Xi*Yi end $}

% {Browse L2}
% 


