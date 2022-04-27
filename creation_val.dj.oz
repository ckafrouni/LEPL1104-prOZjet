%This creation was made by Sacha Baum (20781700) and Valentin Lemaire (16341700)

    local   
        %IntroMusic (Tune1 Tune2 Tune1 Tune3 Tune1  Tune2  Tune4 Tune5) | X2 but second time is slightly shorter
        %           (Acc1  Acc2  Acc1  Acc3  Acc1  Acc2bis (   Acc4  )) | 
    
        Intro1 = [stretch(factor: 0.2 [[d6 d5] [e6 e5] [c6 c5] stretch(factor:2.0 [[b5 b4]]) [c6 c5] stretch(factor:2.0 [[a5 a4]])])]
        Intro2 = [transpose(semitones:~12 Intro1)]
        Intro3 =  [stretch(factor:0.2 [[d4 d3] [e4 e3] [c4 c3] stretch(factor:2.0 [[b3 b2]]) [c4 c3] [b3 b2] [a#3 a#2] stretch(factor:2.0 [[g3 g2] silence]) [g4 b4 e5 g5 g2 g1] duration(seconds:1.5 [silence]) [d4 g3 b3] d#4])]
    
        IntroMusic = [partition(Intro1) partition(Intro2) partition(Intro3)]
    
        %%%
    
        Tune1= [e4 stretch(factor:2.0 [c5]) e4 stretch(factor:2.0 [c5]) e4 stretch(factor:6.0 [c5])]
    
        Accompaniment1 = [stretch(factor:2.0 [c3 [e3 g3 c4] [g2 g3] [g3 a#3 c4] [f2 f3] [a3 c4]])]
    
        %%%
    
        Tune2 =[silence [c5 e5 c6] [d5 f5 d6] [d#5 f#5 d#6] [e5 g5 e6] [c5 e5 c6] [d5 f5 d6] stretch(factor:2.0 [[e5 g5 e6]]) [b4 d5 b5] stretch(factor:2.0 [[d5 f5 d6]])  stretch(factor:6.0 [[c5 e5 c6]]) d4 d#4]
    
        MusicTune2bis = [cut(start:0.0 finish:3.2 [partition([stretch(factor:0.2 Tune2)])])]
    
        Accompaniment2 = [stretch(factor:2.0 [[e2 e3] [g3 c4] g2 [e3 g3 c4] g2 [f3 g3 b3] c2 [e3 g3 c4] [e3 g3 c4] [g3 b3]])]
    
        Accompaniment2bis = [stretch(factor:2.0 [[e2 e3] [g3 c4] g2 [e3 g3 c4] g2 [f3 g3 b3] c2 [e3 g3 c4]])]
    
        %%%
    
        Tune3 = [duration(seconds:2.0 [silence])
                 [a4 c5 a5] [g4 c5 g5] [f#4 c5 f#5] [a4 a5] [c5 c6] stretch(factor:2.0 [[e5 e6]]) [d5 d6] 
                 [c5 c6] [a4 a5] stretch(factor:6.0 [[d5 f5 d6]]) d4 d#4
                ]
    
        Accompaniment3 = [stretch(factor:2.0 [[e2 e3] [d#2 d#3] [d2 d3] [d3 f#3 a3 c4] d3 [f#3 a3 c4] [g3 b3] [g2 g3] [a2 a3] [b2 b3]])]
    
        %%%
    
        Tune4 = [[c5 c6] [d5 d6] [e5 e6]]
     
        Tune5 = [silence [c5 c6] [d5 d6] [c5 c6] [e5 e6] [c5 c6] [d5 d6] stretch(factor:2.0 [[e5 e6]])
                 [c5 c6] [d5 d6] [c5 c6] [e5 g5 e6] [c5 e5 c6] [d5 f5 d6] stretch(factor:2.0 [[e5 g5 e6]])
                 [b4 d5 b5] stretch(factor:2.0 [[d5 f5 d6]])  stretch(factor:6.0 [[c5 e5 c6]]) d4 d#4
                ]
    
        Accompaniment4 = [stretch(factor:2.0 [[g3 c4 e4] silence [c3 c4] [g3 c4 e4] [a#2 a#3] [g3 c4 e4] [a2 a3] [a3 c4 f4] [g#2 g#3] [a3 c4 f4] [g2 g3] [g3 c4 e4] g2 [g3 b3] [c3 g3 c4] [g2 g3] [a2 a3]])] 
    
        %%%
    
        Intro = fade(start:0.4 out:0.0 [merge([0.4#IntroMusic])])
    
        Part1 = merge([0.2#[partition([stretch(factor:0.2 Tune1)])] 0.2#[partition([stretch(factor:0.2 Accompaniment1)])]])
    
        Part2 = merge([0.5#[partition([stretch(factor:0.2 Tune2)])] 0.5#[partition([stretch(factor:0.2 Accompaniment2)])]])
    
        Part3 = merge([0.5#[partition([stretch(factor:0.2 Tune3)])] 0.5#[partition([stretch(factor:0.2 Accompaniment3)])]])
    
        Part2bis = merge([0.5#MusicTune2bis 0.5#[partition([stretch(factor:0.2 Accompaniment2bis)])]])
        Tune4WithRepeat = [repeat(amount:2.0 [partition([stretch(factor:0.2 Tune4)])]) partition([stretch(factor:0.2 Tune5)])]
    
        Part4 = merge([0.5#Tune4WithRepeat 0.5#[partition([stretch(factor:0.2 Accompaniment4)])]])
    
        %%%
    
        Music1 = [Part1
                  Part2
                  Part1
                  Part3
                  Part1
                  Part2bis
                  Part4
                 ]
    
        End = [partition([stretch(factor:1.2 [[c5 e5 c6 c3 g3 c4]])])]
    
        Music2 = [Intro loop(seconds:50.0 Music1) fade(start:0.0 out:0.8 End)]
    
        Music3 = [clip(low:~1.0 high:1.0 Music2)]
    
        Music = [lissage(Music3)]
    
    in 
        Music
    end