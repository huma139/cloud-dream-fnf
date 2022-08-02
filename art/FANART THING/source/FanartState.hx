package;

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

    var curSelect:Int = 0;
    var parentImgSlideshow:FlxSpriteGroup;
    
    var asyncLoop:FlxAsyncLoop;
    var loadBar:FlxSprite;
    var targetShit:Float = 0;

    override function create() {
        super.create();
        
        parentImgSlideshow = new FlxSpriteGroup();
        // parentImgSlideshow.scale.set(0.6,0.6);
        add(parentImgSlideshow);

        asyncLoop = new FlxAsyncLoop(imageArray().length, generateImage, 5);
        add(asyncLoop);

        parentImgSlideshow.visible = false;

        loadBar = new FlxSprite(0, FlxG.height - 40).makeGraphic(FlxG.width - 100, 20, FlxColor.WHITE);
        loadBar.screenCenter(X);
        loadBar.antialiasing = ClientPrefs.globalAntialiasing;
        add(loadBar);

    }

    function imageArray():Array<Array<String>> {
        var fileListDump = CoolUtil.coolTextFile(Paths.txt('fanartlists'));
        var imgArray:Array<Array<String>> = [];
        for (i in fileListDump) {
            imgArray.push(i.split('_'));
        }
        return imgArray;
    }
   
    function generateImage(i:Int) {
        var name = imageArray()[i][0] + '_' + imageArray()[i][1];
        trace(name);
        var image:FlxSprite = new FlxSprite();
        switch (imageArray()[i][2]) {
            case 'gif':
                image.frames = Paths.getSparrowAtlas('fanarts/gif_spritesheet/' + name);
                image.animation.addByPrefix(name, name, 24, true);
                image.animation.play(name);
            default:
                image.loadGraphic(Paths.image('fanarts/' + name));
        }
        image.setGraphicSize(0, Std.int(FlxG.height));
        image.updateHitbox();
        image.screenCenter();
        image.antialiasing = ClientPrefs.globalAntialiasing;
        image.ID = i;
        parentImgSlideshow.add(image);
        change();

        targetShit = (parentImgSlideshow.length/imageArray().length);
        loadBar.scale.x += 0.5 * (targetShit - loadBar.scale.x);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        if (!asyncLoop.started)
        {
            asyncLoop.start();
        }
        else if (asyncLoop.finished)
        {
            parentImgSlideshow.visible = true;
            loadBar.visible = false;
            asyncLoop.kill();
            asyncLoop.destroy();
        }
        var leftP = controls.UI_LEFT_P;
        var rightP = controls.UI_RIGHT_P;
        if (leftP)
            change(-1);
        if (rightP)
            change(1);
    }

    var twn:FlxTween;

    function change(i:Int = 0) {
        curSelect += i;
        if (curSelect < 0)
            curSelect = parentImgSlideshow.length -1;
        if (curSelect >= parentImgSlideshow.length)
            curSelect = 0;

        var name = imageArray()[curSelect][0] + '_' + imageArray()[curSelect][1];

        for (img in parentImgSlideshow) {
            img.alive=false;
            img.alpha=0;
            if (img.ID == curSelect) {
                img.alive = true;
                if (twn != null)
                    twn.cancel();
                twn = FlxTween.tween(img, {alpha: 1}, 0.1, {
                    onComplete: function(t:FlxTween) {
                        twn = null;
                }});
                img.animation.play(name, true);
            }
            
        }

    }
}