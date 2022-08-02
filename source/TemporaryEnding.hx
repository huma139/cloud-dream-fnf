package;

import flixel.addons.transition.FlxTransitionableState;
import vlc.MP4Handler;
import flixel.input.keyboard.FlxKey;
import flixel.FlxG;
import flixel.addons.ui.FlxMultiGamepadAnalogStick.StickInput;
import flixel.text.FlxText;
using StringTools;

class TemporaryEnding extends MusicBeatState {
    var string = ["This is the end of the demo.", "Please wait a little longer", "XDDDD"];
    var text:Alphabet = null;

    override function create() {
        super.create();
        if (FlxG.sound.music.playing)
            FlxG.sound.music.stop();
    
    }

    function generateText() {
        text = new Alphabet(15, (FlxG.height/2) - 100, string[0], true, true);
        add(text);
    }
    
    function bye() {
        if (!FlxG.sound.music.playing) {
            FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.7); }
        MusicBeatState.switchState(new StoryMenuState());
    }
    var allowedKeys:String = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    var easterEggKeysBuffer:String = '';

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (controls.BACK) {
           bye();
        }

        if (FlxG.keys.firstJustPressed() != FlxKey.NONE)
        {
            var keyPressed:FlxKey = FlxG.keys.firstJustPressed();
            var keyName:String = Std.string(keyPressed);
            if(allowedKeys.contains(keyName)) {
                easterEggKeysBuffer += keyName;
                if(easterEggKeysBuffer.length >= 32) easterEggKeysBuffer = easterEggKeysBuffer.substring(1);
                // trace('Test! Allowed Key pressed!!! Buffer: ' + easterEggKeysBuffer);

                var word:String = 'MAIEROLL'; //just for being sure you're doing it right
                if (easterEggKeysBuffer.contains(word))
                {
                    trace('YOOO! ' + word);
                    // FlxG.sound.music.volume = 0;
                    var vid = new MP4Handler();
                    vid.playVideo(Paths.video('MAIE ROLL'));
                    vid.finishCallback = function () {
                        if (vid.isPlaying) {
                            vid.volume = 0;
                            // vid.dispose();
                        }
                        FlxTransitionableState.skipNextTransIn = true;
                        bye();
                        
                    }
                    easterEggKeysBuffer = '';
                }
            }
        }

        if (text != null) {
            if (controls.ACCEPT) {
                if (text.finishedText && text != null) {
                    text.killTheTimer();
                    text.kill();
                    remove(text);
                    text.destroy();
                    string.remove(string[0]);
                    if (string[0] == null) {
                        bye();
                    } else {
                        generateText();
                    }
                }
            }
        } else {
            generateText();
        }
    }
}