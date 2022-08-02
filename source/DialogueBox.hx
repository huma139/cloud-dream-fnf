package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.addons.ui.FlxUIButton;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using StringTools;

class DialogueBox extends FlxSpriteGroup
{
	var box:FlxSprite;

	var curPort:String = '';

	var curFrame:String = '';

	var dialogue:Alphabet;
	var dialogueList:Array<String> = [];

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???
	var swagDialogue:FlxTypeText;

	var dropText:FlxText;

	public var finishThing:Void->Void;

	var portraitLeft:Portrait;
	var portraitMid:Portrait;
	var portraitRight:Portrait;

	var handSelect:FlxSprite;
	var bg:FlxSprite;

	// var skipIns:FlxText;
	// var skipB:FlxUIButton;
	// var invTouch:FlxUIButton;

	public function new(talkingRight:Bool = true, ?dialogueList:Array<String>)
	{
		super();
		scrollFactor.set();
		bg = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		bg.screenCenter();

		if (PlayState.SONG.song.toLowerCase() == 'me-and-who')
			add(bg);

		box = new FlxSprite(0, -50);

		var hasDialog = false;
		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'me-and-who' | 'dithering' | 'dawn':
				hasDialog = true;
				box.loadGraphic(Paths.image('dialogueStuff/diabox'));
				box.antialiasing = FlxG.save.data.antialiasing;
				box.screenCenter(X);
		}

		this.dialogueList = dialogueList;

		if (!hasDialog)
			return;

		portraitLeft = new Portrait(60, (FlxG.height / 2) - 270 + 40, 'maie');
		add(portraitLeft);

		portraitMid = new Portrait(0, (FlxG.height / 2) - 270 + 55, 'maie-bf');
		portraitMid.screenCenter(X);
		portraitMid.x -= 90;
		add(portraitMid);

		portraitRight = new Portrait((FlxG.width / 2), (FlxG.height / 2) - 270 + 95, 'bf');
		add(portraitRight);

		hideAll();

		add(box);

		swagDialogue = new FlxTypeText(240, 500, Std.int(FlxG.width * 0.6), "", 30);
		swagDialogue.font = 'Pixel Arial 11 Bold';
		swagDialogue.color = 0xFF2473AC;
		swagDialogue.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.WHITE, 1.7, 1);
		swagDialogue.finishSounds = true;
		add(swagDialogue);
	}

	var dialogueStarted:Bool = false;
	var noskippin:Bool = false;
	var isEnding:Bool = false;
	var finishType:Bool = false;

	override function update(elapsed:Float)
	{
		var next = PlayerSettings.player1.controls.ACCEPT;
		var skipWhole = PlayerSettings.player1.controls.BACK;

		if (!dialogueStarted)
		{
			startDialogue();
			dialogueStarted = true;
		}

		if (!isEnding)
		{
			if (skipWhole)
			{
				endDialogue();
			}

			if (!noskippin)
			{
				if (dialogueStarted == true)
				{
					if (next)
					{
						if (dialogueList[1] == null && dialogueList[0] != null)
						{
							endDialogue();
						}
						
						else if (finishType)
						{
							FlxG.sound.play(Paths.sound('clickText'), 0.35);
							dialogueList.remove(dialogueList[0]);
							startDialogue();
						}
						else
						{
							swagDialogue.skip();
						}
					}
				}
			}
		}
		super.update(elapsed);
	}

	function endDialogue()
	{
		isEnding = true;
		FlxG.sound.play(Paths.sound('clickText'), 0.35);
		if (PlayState.SONG.song.toLowerCase() == 'me-and-who')
			FlxTween.tween(bg, {alpha: 0}, 0.6);

		hideAll();
		swagDialogue.visible = false;
		FlxTween.tween(box, {alpha: 0}, 0.6, {
			onComplete: function(twn:FlxTween)
			{
				finishThing();
				kill();
			}
		});
	}

	function startDialogue():Void
	{
		cleanDialog();
		hideAll();
		swagDialogue.resetText(dialogueList[0]);
		swagDialogue.start(0.03, true);
		swagDialogue.completeCallback = function()
		{
			finishType = true;
		};

		finishType = false;

		switch (curPort)
		{
			case 'maie':
				portraitLeft.playPort(curFrame);
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('maie'))];

			case 'bf':
				portraitRight.playPort(curFrame);
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('bfText'))];

			case 'maieBF':
				portraitMid.playPort(curFrame);
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('maie'))];
		}

		if (dialogueList[0] == "Yeeaaah! It's me!" && PlayState.SONG.song.toLowerCase() == 'me-and-who')
		{
			FlxTween.tween(bg, {alpha: 0}, 7, {
				onComplete: function(twn:FlxTween)
				{
					remove(bg);
				}
			});
		}

		// if (dialogueList[0] == "beeep bop bapp skip dop boop bop ba bip bep beep bopbidibip ska bop doo bee baboop beep ba beep bep bip bopbap!"
		// 	&& curPort == 'bf'
		// 	&& PlayState.SONG.song.toLowerCase() == 'dawn')
		// {
		// 	noskippin = true;
		// 	new FlxTimer().start(3.2, function(tmr:FlxTimer)
		// 	{
		// 		dialogueList.remove(dialogueList[0]);
		// 		startDialogue();
		// 		noskippin = false;
		// 	});
		// }

		// if (curPort == 'maieBF'
		// 	&& (curFrame == 'mb6' || curFrame == 'mb8' || curFrame == 'mb9')
		// 	&& PlayState.SONG.song.toLowerCase() == 'dawn')
		// {
		// 	swagDialogue.sounds = [FlxG.sound.load(Paths.sound('bfText'))];
		// }
	}

	function hideAll()
	{
		portraitLeft.hidePort();
		portraitRight.hidePort();
		portraitMid.hidePort();
	}

	function cleanDialog():Void
	{
		var splitName:Array<String> = dialogueList[0].split(":");
		curPort = splitName[1];
		curFrame = splitName[2];
		dialogueList[0] = dialogueList[0].substr(splitName[1].length + splitName[2].length + 3).trim();
	}
}

class Portrait extends FlxSprite
{
	public function new(x:Float, y:Float, char:String)
	{
		super(x, y);

		switch (char)
		{
			case 'maie':
				frames = Paths.getSparrowAtlas('dialogueStuff/maiePort');
				for (i in 0...26)
				{
					animation.addByIndices('m' + i, 'maie dia', [i], "", 0, false);
				}

				flipX = true;

			case 'bf':
				frames = Paths.getSparrowAtlas('dialogueStuff/bfPort');
				for (i in 0...19)
				{
					animation.addByIndices('b' + i, 'BF', [i], "", 0, false);
				}

			case 'maie-bf':
				frames = Paths.getSparrowAtlas('dialogueStuff/maieBfPort');
				for (i in 0...11)
				{
					animation.addByIndices('mb' + i, 'maie and bf', [i], "", 0, false);
				}
		}

		antialiasing = FlxG.save.data.antialiasing;
		scrollFactor.set();
	}

	public function playPort(?_frame:String)
	{
		animation.play(_frame);
		visible = true;
	}

	public function hidePort()
	{
		visible = false;
	}
}
