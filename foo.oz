% %%%% Test/brouillon pour la fonction Fade
% % local
% %     fun {MultList L1 L2}
% %         {List.zip L1 L2 fun {$ Xi Yi} Xi*Yi end $}
% %     end

% %     fun {MakeListOfN Len N} 					% utile pour plusieurs fonctions par la suite
% %         {Map {List.make Len $} fun {$ X} N end}
% %     end

% %     fun {GetFadeList SampleSize}
% %         % Return a list to multiply the music with          ex. if samplesize = 5
% %         Factor = 1.0/{IntToFloat SampleSize}                % --> 1/5
% %         L = {MakeListOfN SampleSize 1.0}                    % --> [1 1 1 1 1] 
% %     in
% %         {Append [0.0] {List.mapInd L fun {$ I A} {IntToFloat I} * Factor end $}} % --> [0 0.2 0.4 0.8 1]
% %     end
    
% %     Sample = [1.0 1.0 1.0 1.0 1.0 1.0]

% %     FadedSample = {MultList Sample {GetFadeList 5 }}
% %     FadedSampleReverse = {MultList Sample {Reverse {GetFadeList 5 }}}
% % in
% %     {Browse FadedSample}
% %     {Browse FadedSampleReverse}

% %     {Browse ok }
% % end

% %%% Test pour le Empty chords

% local
%     fun {ExtendNoteOrSilence Note}
%         case Note
%         of note(duration:_ instrument:_ name:_ octave:_ sharp:_) then Note
%         [] silence(duration:_) then Note
%         [] silence then silence(duration:1.0)
%         [] Name#Octave then note(name:Name octave:Octave sharp:true duration:1.0 instrument:none)
%         [] Atom then
%             {Browse 'atom'}
%             case {AtomToString Atom}
%             of [_] then note(name:Atom octave:4 sharp:false duration:1.0 instrument:none)
%             [] [N O] then note(name:{StringToAtom [N]} octave:{StringToInt [O]} sharp:false duration:1.0 instrument: none)
%             else 
%                 {Browse autre}
%                 nil
%             end
%         else nil
%         end
%      end


%     %Music = [partition([a b [nil] c])]
%     Chord =  nil
% Res
% in
%     %{Browse Music}
%     case Chord 
%     of nil then {Browse vide }
%     [] H|T then
%         case H#T
%         of nil#nil then {Browse H#T}
%         else 
%             Res = [{List.map Chord ExtendNoteOrSilence }]
%             {Browse Res}
%             %{Browse 'head'#H} 
%             %{Browse 'Tail'#T}
%         end

%     end

% end

% local 
%     Is = [nil]
%     Ls = [1 2 3 4 ]
%     fun {CalcAi I} X in 
%         case I of nil then 0.0
%         else
%             X = 2.0 * {IntToFloat I}
%             0.5 * X 
%         end
%     end
% in
%     {Browse {Append {Map Is CalcAi } {Map Ls CalcAi } }}
% end

% {Browse {Append [ 1 2] {Append nil {Append [3 4] nil } } } }


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % TESTS
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% %Music1 = [partition([a b]) partition([c d])]
% % Music=[echo(delay:1.5 decay:0.4 [partition([
% % 	stretch(factor:0.5 [[c e g] [d f a] [e g b]]) a b c
% % ])])]
% %Music2 = [wave('wave/animals/cat.wav')]

% Music = [echo(delay:2.0/44100.0 decay:0.5 [samples([1.0 1.0 1.0 1.0])])]
% %Music = [merge([0.5#Music1 0.5#Music2])]
% %Music = [repeat(amount:3 [partition([c d e f])])]

% % Music = [loop(seconds:3.5 [partition([c g])])]

% %% test clip
% % Lo = ~0.2
% % Hi = 0.3
% % Ms = [0.1 0.6 ~0.6 ~0.1 0.0]
% % Music = [clip(low:Lo high:Hi [samples(Ms)])]

% %% test cut
% % Ms = [1.0 1.0 0.2 0.2 0.2 0.2 1.0 1.0 1.0]
% % Music = [cut(start:2.0/44100.0 finish:13.0/44100.0 [samples(Ms)])]

% % Music=[echo(delay:3.0/44100.0 decay:0.5 [samples([0.1 0.2 0.3 0.4 0.5])] )]
% % Delay = 5/44100.0
% % Decay = 0.5
% % In = [0.2 0.2 0.4 0.4 0.6 0.6]
% % Out= [0.2 0.2 0.4 0.4 0.6 0.7 0.1 0.2 0.2 0.3 0.3]
% % Music=[echo(delay:5.0/44100.0 decay:0.5 [samples([0.2 0.2 0.4 0.4 0.6 0.6])] )]


% %% test fade
% % Ms = [1.0 1.0 1.0 1.0 1.0 1.0 0.2 0.2 0.2 0.2 1.0 1.0 1.0 1.0 1.0 1.0]
% % Ms = [a a a a a a a]
% % Music = [fade(start:2.0 finish:3.0 [partition(Ms)])]
% % Ms = [1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0]
% % Music = [fade(start:6.0/44100.0 finish:6.0/44100. [samples(Ms)])]
% % Music = [partition([duration(1:[a] seconds:0.00011338)])]

% % Test empty chords

% % Music = [
% % 	partition(
% % 		[duration(seconds:2.0 
% % 		   [note(duration:2.0 instrument:none name:b octave:3 sharp:false)
% % 			nil
% % 		   note(duration:2.0 instrument:none name:a octave:3 sharp:false)] 
% % 		)]
% % 	)]