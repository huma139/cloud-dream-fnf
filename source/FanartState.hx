package;

import lime.app.Application;
import flixel.system.FlxSound;
import flixel.util.FlxTimer;
import flixel.addons.transition.FlxTransitionableState;
import vlc.MP4Handler;
import flixel.input.keyboard.FlxKey;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxObject;
import sys.FileSystem;
import sys.io.File;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.addons.util.FlxAsyncLoop;
import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxEase;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.graphics.FlxGraphic;
import flixel.FlxSprite;
using StringTools;

class FanartState extends MusicBeatState {

    var imgArray:Array<Array<String>> = [];

    var curSelect:Int = 0;
    var image:FlxSprite;
    var bg:FlxSprite;
    var black:FlxSprite;
    var camFollow:FlxObject;

    var parentImgSlideshow:FlxTypedGroup<FlxSprite>;
    var imgCount:FlxText;
    var artist:FlxText;
    var instruction:FlxText;
    var grpUI:FlxTypedGroup<FlxText>;
    
    var asyncLoop:FlxAsyncLoop;
    var loadBar:FlxSprite;
    var targetShit:Float = 0;

    public static var startTheDark = false;

    override function create() {
        super.create();

        // Paths.clearStoredMemory();
		// Paths.clearUnusedMemory();

        var fileListDump = CoolUtil.coolTextFile(Paths.txt('fanartlists'));

        black = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
        black.scrollFactor.set();
        black.screenCenter();

        if (startTheDark) {
            bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height);
            imgArray = danArray().copy();
        } else {
            for (i in fileListDump) {
                imgArray.push(i.split('_'));
            }
            if (FlxG.random.bool(30))
                imgArray.insert(FlxG.random.int(1, imgArray.length), danArray()[FlxG.random.int(0,danArray().length-1)]);
            
            bg = new FlxSprite().loadGraphic(Paths.image('newbg'));
        }

        bg.scrollFactor.set();
        bg.screenCenter();
        add(bg);
        bg.alpha = 0;

        stopIt = false;

        camFollow = new FlxObject(0, 0, 1, 1);
        add(camFollow);
        FlxG.camera.focusOn(camFollow.getPosition());

        parentImgSlideshow = new FlxTypedGroup<FlxSprite>();
        add(parentImgSlideshow);

        asyncLoop = new FlxAsyncLoop(imgArray.length, generateImage, 5);
        add(asyncLoop);

        grpUI = new FlxTypedGroup<FlxText>();
        add(grpUI);

        imgCount = new FlxText();
        imgCount.fieldWidth = FlxG.width;
        imgCount.setFormat("VCR OSD Mono", 30, FlxColor.WHITE);
        imgCount.alignment = RIGHT;
        imgCount.scrollFactor.set();
        grpUI.add(imgCount);

        artist = new FlxText();
        artist.fieldWidth = FlxG.width;
        artist.setFormat("VCR OSD Mono", 30, FlxColor.WHITE);
        artist.setBorderStyle(OUTLINE, FlxColor.BLACK);
        artist.alignment = CENTER;
        artist.scrollFactor.set();
        grpUI.add(artist);

        if (!startTheDark) {
            instruction = new FlxText();
            instruction.text = 'Scroll or press UP/DOWN\nto navigate.';
            instruction.fieldWidth = FlxG.width;
            instruction.setFormat("VCR OSD Mono", 25, FlxColor.WHITE);
            instruction.setBorderStyle(OUTLINE, FlxColor.BLACK);
            instruction.alignment = CENTER;
            instruction.screenCenter(Y);
            instruction.scrollFactor.set();
            grpUI.add(instruction);
            FlxTween.tween(instruction, {'scale.y': 1.5}, 0.5, {type: PINGPONG, ease: FlxEase.quartInOut});
        }

        parentImgSlideshow.visible = grpUI.visible = canPress = false;

        loadBar = new FlxSprite(0, FlxG.height - 40).makeGraphic(FlxG.width - 100, 20, FlxColor.WHITE);
        loadBar.screenCenter(X);
        loadBar.scrollFactor.set();
        loadBar.antialiasing = ClientPrefs.globalAntialiasing;
        add(loadBar);
    }

    // function imgArray:Array<Array<String>> {
    //     var fileListDump = CoolUtil.coolTextFile(Paths.txt('fanartlists'));
    //     var imgArray:Array<Array<String>> = [];
    //     for (i in fileListDump) {
    //         imgArray.push(i.split('_'));
    //     }
    //     return imgArray;
    // }

    function danArray():Array<Array<String>> {
        var danArr:Array<Array<String>> = [];
        for (n in 1...4){
            danArr.push(['DarkMaie$n', 'Dannihilation', 'png', 'twitter.com/Dannihilation7']);
        }
        return danArr;
    }
   
    function generateImage(i:Int) {
        var name = imgArray[i][0] + '_' + imgArray[i][1];
        // trace(name);
        var image:FlxSprite = new FlxSprite(0,(FlxG.height-100)*i);
        switch (imgArray[i][2]) {
            case 'gif':
                image.frames = Paths.getSparrowAtlas('fanarts/gif_spritesheet/$name');
                image.animation.addByPrefix(name, name, 24, true);
                image.animation.play(name);
            default:
                image.loadGraphic(Paths.image('fanarts/$name'));
        }
        image.scrollFactor.set(0,1);
        image.setGraphicSize(0, Std.int(FlxG.height-150));
        image.updateHitbox();
        image.screenCenter(X);
        image.antialiasing = ClientPrefs.globalAntialiasing;
        image.ID = i;
        parentImgSlideshow.add(image);
        change();

        targetShit = (parentImgSlideshow.length/imgArray.length);
        loadBar.scale.x += 0.5 * (targetShit - loadBar.scale.x);
    }

    var canPress = false;
    var stopIt = false;
    var allowedKeys:String = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    var keysBuffer:String = '';
    override function update(elapsed:Float) {
        super.update(elapsed);
        var lerpVal:Float = CoolUtil.boundTo(elapsed * 16, 0, 1);
		FlxG.camera.follow(camFollow, null, lerpVal);

        var curN = Std.string(curSelect+1);
        var totalN = Std.string(imgArray.length);
        imgCount.text = '$curN / $totalN';

        var artistName = imgArray[curSelect][1];
        artist.text = 'Artist:\n$artistName';
        artist.y = FlxG.height - artist.height - 20;

        if (!asyncLoop.started)
        {
            asyncLoop.start();
        }
        else if (asyncLoop.finished)
        {
            loadBar.visible = false;
            asyncLoop.kill();
            asyncLoop.destroy();
            parentImgSlideshow.visible = grpUI.visible = true;
            if (!startTheDark)
                FlxTween.tween(bg, {alpha: 1}, 0.2);
            canPress = true;
        }
            
        if (canPress && !stopIt) {
            if (controls.UI_UP_P)
                change(-1);
            if (controls.UI_DOWN_P)
                change(1);
    
            if (FlxG.mouse.wheel != 0)
                change(-FlxG.mouse.wheel);
    
            var fbID = imgArray[curSelect][3];
            if (startTheDark) {
                if ((controls.ACCEPT || controls.BACK) && !(controls.ACCEPT && controls.BACK)) {
                    stopIt = true;
                    bg.alpha = 1;
                    new FlxTimer().start(0.45, function(tm:FlxTimer) {
                        bg.alpha = 0;
                    });
                    FlxG.sound.play(Paths.sound('sfxx'), 1, false, null, true, function() {
                        FlxG.openURL(fbID);
                        FlxTransitionableState.skipNextTransIn = true;
                        if (FlxG.sound.music.playing) {
                            FlxG.sound.music.stop();
                        }
                        FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.7);
                        MusicBeatState.switchState(new MainMenuState());
                    });
                    
                }
            } else {
                if (controls.ACCEPT) {
                    FlxG.openURL('https://www.facebook.com/profile.php?id=$fbID');
                }
        
                if (controls.BACK) {
                    MusicBeatState.switchState(new MainMenuState());
                }

                if (controls.UI_UP_P || controls.UI_DOWN_P || FlxG.mouse.wheel != 0) {
                    FlxTween.tween(instruction, {alpha: 0}, 0.4, {onComplete: function(t:FlxTween) {
                        instruction.kill();
                    }});
                }

                if (FlxG.keys.firstJustPressed() != FlxKey.NONE)
                {
                    var keyPressed:FlxKey = FlxG.keys.firstJustPressed();
                    var keyName:String = Std.string(keyPressed);
                    if(allowedKeys.contains(keyName)) {
                        keysBuffer += keyName;
                        if(keysBuffer.length >= 32) keysBuffer = keysBuffer.substring(1);
                        // trace('Test! Allowed Key pressed!!! Buffer: ' + keysBuffer);
        
                        var word:String = 'DARK'; 
                        if (keysBuffer.contains(word))
                        {
                            trace(word);
                            if (FlxG.sound.music.playing) {
                                FlxG.sound.music.stop();
                            }
                            FlxG.sound.playMusic(Paths.music('ff'));
                            startTheDark = true;
                            MusicBeatState.resetState();
                            keysBuffer = '';
                        }
                    }
                }

                if (imgArray[curSelect][1] == 'Dannihilation') {
                    stopIt = true;
                    if (FlxG.sound.music.playing) {
                        FlxG.sound.music.stop();
                    }
                    bg.loadGraphicFromSprite(black);

                    var dateNow:String = Date.now().toString();
                    dateNow = dateNow.replace(" ", "_").replace("-","").replace(":", "");
                    var pathCode = './crash/codeCodeCodeCodeCodeCodeCodeCode$dateNow.txt';
                    var um = 'RE9OVCBUWVBFIENPREU=';
                    var msg = '$um\n\ndark\nDark';
                    for (i in 0...50) {
                        msg += '\nDARK';
                    }
                    var msgBox = 'Cra sh   dump   sA vved [sAved in\n] /crash --FOl der\n\nCrash Folder.\n\n\n\n\nCrash Folder.\n\n\n\n\n$um';

                    if (!FileSystem.exists("./crash/"))
                        FileSystem.createDirectory("./crash/");

                    new FlxTimer().start(0.5, function(tm:FlxTimer) {
                        File.saveContent(pathCode, msg + "\n");
                        Application.current.window.alert(msgBox, "CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCcc");
                        FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.7);
                        FlxTransitionableState.skipNextTransIn = true;
                        MusicBeatState.switchState(new MainMenuState());
                    });
                }
            }
        }
    }

    var twn:FlxTween;

    function change(i:Int = 0) {
        curSelect += i;
        if (curSelect < 0)
            curSelect = 0;
        if (curSelect >= imgArray.length)
            curSelect = imgArray.length -1;

        FlxG.sound.play(Paths.sound('scrollMenu'),0.6);

        var name = imgArray[curSelect][0] + '_' + imgArray[curSelect][1];
        // var newImg:FlxGraphic = Paths.image('fanarts/' + name);

        for (img in parentImgSlideshow) {
            img.alive=false;
            img.alpha=0.5;
            if (img.ID == curSelect) {
                img.alive = true;
                // if (twn != null)
                //     twn.cancel();
                // twn = FlxTween.tween(img, {alpha: 1}, 0.1, {
                //     onComplete: function(t:FlxTween) {
                //         twn = null;
                // }});
                img.alpha = 1;
                camFollow.setPosition(img.getMidpoint().x, img.getMidpoint().y);
                img.centerOffsets();
                img.animation.play(name, true);
            }
        }

        // if (image.graphic != newImg) {
        //     switch (imgArray[curSelect][2]) {
        //         case 'gif':
        //             image.frames = Paths.getSparrowAtlas('fanarts/gif_spritesheet/' + name);
        //             image.animation.addByPrefix(name, name, 24, true);
        //             image.animation.play(name);
        //         default:
        //             image.loadGraphic(newImg);
        //     }
        //     image.setGraphicSize(0, Std.int(FlxG.height-200));
        //     image.updateHitbox();
        //     image.screenCenter();
        //     image.alpha = 0;

        //     if (twn != null)
        //         twn.cancel();

        //     twn = FlxTween.tween(image, {alpha: 1}, 0.1, {onComplete: function(t:FlxTween) {
        //         twn = null;
        //     }});

        // }

      


    }
}