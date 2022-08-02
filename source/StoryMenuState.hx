package;

import flixel.tweens.FlxEase;
import flixel.group.FlxSpriteGroup;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;
import flixel.graphics.FlxGraphic;
import WeekData;

using StringTools;

class StoryMenuState extends MusicBeatState
{
	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();

	var scoreText:FlxText;

	private static var lastDifficultyName:String = '';
	public static var curDifficulty:Int = 1;

	var txtWeekTitle:FlxText;
	var bgSprite:FlxSprite;

	private static var curWeek:Int = 0;

	var txtTracklist:FlxText;

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var difficultySelectors:FlxSpriteGroup;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	var bg:FlxSprite;
	var blackBarThingie:FlxSpriteGroup;
	var blackBarBottom:FlxSprite;
	var theWeek:FlxSprite;
	
	public static var fromMainMenu:Bool = false;

	var loadedWeeks:Array<WeekData> = [];

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		PlayState.isStoryMode = true;
		WeekData.reloadWeekFiles(true);
		if(curWeek >= WeekData.weeksList.length) curWeek = 0;
		persistentUpdate = persistentDraw = true;

		// if (FlxG.sound.music == null || FlxG.sound.music.volume == 0) {
        //     FlxG.sound.playMusic(Paths.music('freakyMenu')); }


		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;


		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		var bgYellow:FlxSprite = new FlxSprite(0, 56).makeGraphic(FlxG.width, 386, 0xFFF9CF51);
		bgSprite = new FlxSprite(0, 56);
		bgSprite.antialiasing = ClientPrefs.globalAntialiasing;

		grpWeekText = new FlxTypedGroup<MenuItem>();
		add(grpWeekText);



		bg = new FlxSprite().loadGraphic(Paths.image('menuBG'));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		blackBarThingie = new FlxSpriteGroup(0, -60);
		add(blackBarThingie);
		scoreText = new FlxText(10, 10, 0, "SCORE: 49324858", 36);
		scoreText.setFormat("VCR OSD Mono", 32);
		// var rankText:FlxText = new FlxText(0, 10);
		// rankText.text = 'RANK: GREAT';
		// rankText.setFormat(Paths.font("vcr.ttf"), 32);
		// rankText.size = scoreText.size;
		// rankText.screenCenter(X);
		var black = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		blackBarThingie.add(black);
		// blackBarThingie.add(rankText);
		blackBarThingie.add(scoreText);

		

		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();

		// grpLocks = new FlxTypedGroup<FlxSprite>();
		// add(grpLocks);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		var num:Int = 0;
		for (i in 0...WeekData.weeksList.length)
		{
			var weekFile:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var isLocked:Bool = weekIsLocked(WeekData.weeksList[i]);
			if(!isLocked || !weekFile.hiddenUntilUnlocked)
			{
				loadedWeeks.push(weekFile);
				WeekData.setDirectoryFromWeek(weekFile);
				// var weekThing:MenuItem = new MenuItem(0, bgSprite.y + 396, WeekData.weeksList[i]);
				// weekThing.y += ((weekThing.height + 20) * num);
				// weekThing.targetY = num;
				// grpWeekText.add(weekThing);

				// weekThing.screenCenter(X);
				// weekThing.antialiasing = ClientPrefs.globalAntialiasing;
				// weekThing.updateHitbox();

				// Needs an offset thingie
				// if (isLocked)
				// {
				// 	var lock:FlxSprite = new FlxSprite(weekThing.width + 10 + weekThing.x);
				// 	lock.frames = ui_tex;
				// 	lock.animation.addByPrefix('lock', 'lock');
				// 	lock.animation.play('lock');
				// 	lock.ID = i;
				// 	lock.antialiasing = ClientPrefs.globalAntialiasing;
				// 	grpLocks.add(lock);
				// }
				num++;
			}
		}

		WeekData.setDirectoryFromWeek(loadedWeeks[0]);
		// var charArray:Array<String> = loadedWeeks[0].weekCharacters;
		// for (char in 0...3)
		// {
		// 	var weekCharacterThing:MenuCharacter = new MenuCharacter((FlxG.width * 0.25) * (1 + char) - 150, charArray[char]);
		// 	weekCharacterThing.y += 70;
		// 	grpWeekCharacters.add(weekCharacterThing);
		// }

		difficultySelectors = new FlxSpriteGroup(0, FlxG.height+10);
		add(difficultySelectors);

		blackBarBottom = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		difficultySelectors.add(blackBarBottom);

		theWeek = new FlxSprite(0, 30).loadGraphic(Paths.image('storymenu/weekcloud'));
		theWeek.screenCenter(X);
		difficultySelectors.add(theWeek);

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		if(lastDifficultyName == '')
		{
			lastDifficultyName = CoolUtil.defaultDifficulty;
		}
		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(lastDifficultyName)));
		
		sprDifficulty = new FlxSprite(0, theWeek.y+theWeek.height+15);
		sprDifficulty.screenCenter(X);
		sprDifficulty.antialiasing = ClientPrefs.globalAntialiasing;
		difficultySelectors.add(sprDifficulty);

		var fuck = 95;

		leftArrow = new FlxSprite(0, theWeek.y+theWeek.height+15);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		leftArrow.screenCenter(X);
		leftArrow.x -= ((FlxG.width/4)-120) + 48 - fuck;
		leftArrow.antialiasing = ClientPrefs.globalAntialiasing;
		difficultySelectors.add(leftArrow);

		rightArrow = new FlxSprite(0, theWeek.y+theWeek.height+15);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right");
		rightArrow.animation.play('idle');
		rightArrow.screenCenter(X);
		rightArrow.x += ((FlxG.width/4)-120) + fuck;
		rightArrow.antialiasing = ClientPrefs.globalAntialiasing;
		difficultySelectors.add(rightArrow);

		var tracksSprite:FlxSprite = new FlxSprite(FlxG.width * 0.07, bgSprite.y + 425).loadGraphic(Paths.image('Menu_Tracks'));
		tracksSprite.antialiasing = ClientPrefs.globalAntialiasing;
		

		// txtTracklist = new FlxText(FlxG.width * 0.05, tracksSprite.y + 60, 0, "", 32);
		// txtTracklist.alignment = CENTER;
		// txtTracklist.font = rankText.font;
		// txtTracklist.color = 0xFFe55777;
		// add(bgYellow);
		// add(bgSprite);
		// add(grpWeekCharacters);		
		// add(tracksSprite);

		// add(txtTracklist);
		// add(txtWeekTitle);

		movedBack = selectedWeek = true;

		if (fromMainMenu) {
			FlxTween.tween(blackBarThingie, {y: 0}, 0.5, {ease: FlxEase.quartOut});
			FlxTween.tween(difficultySelectors, {y: 386+56}, 0.5, {ease: FlxEase.quartOut});
			FlxTween.tween(bg, {y: -150}, 0.5, {ease: FlxEase.quartOut, onComplete: function(t:FlxTween) {
				movedBack = selectedWeek = false;
				fromMainMenu = false;
			}});
		} else {
			blackBarThingie.y = 0;
			difficultySelectors.y = 386+56;
			bg.y = -50;
			movedBack = selectedWeek = false;
		}
		
		changeWeek();
		changeDifficulty();

		super.create();
	}

	override function closeSubState() {
		persistentUpdate = true;
		changeWeek();
		super.closeSubState();
	}

	override function update(elapsed:Float)
	{
		// scoreText.setFormat('VCR OSD Mono', 32);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 30, 0, 1)));
		if(Math.abs(intendedScore - lerpScore) < 10) lerpScore = intendedScore;

		scoreText.text = "Score:" + lerpScore;

		if (isFlashing)
			flashingInt += 1;

		if (flashingInt % fakeFramerate >= Math.floor(fakeFramerate / 2))
			theWeek.color = 0xFF33ffff;
		else 
			theWeek.color = FlxColor.WHITE;

		// FlxG.watch.addQuick('font', scoreText.font);

		if (!movedBack && !selectedWeek)
		{
			// var upP = controls.UI_UP_P;
			// var downP = controls.UI_DOWN_P;
			// if (upP)
			// {
			// 	changeWeek(-1);
			// 	FlxG.sound.play(Paths.sound('scrollMenu'));
			// }

			// if (downP)
			// {
			// 	changeWeek(1);
			// 	FlxG.sound.play(Paths.sound('scrollMenu'));
			// }

			// if(FlxG.mouse.wheel != 0)
			// {
			// 	FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
			// 	changeWeek(-FlxG.mouse.wheel);
			// 	changeDifficulty();
			// }

			if (controls.UI_RIGHT)
				rightArrow.animation.play('press')
			else
				rightArrow.animation.play('idle');

			if (controls.UI_LEFT)
				leftArrow.animation.play('press');
			else
				leftArrow.animation.play('idle');

			if (controls.UI_RIGHT_P)
				changeDifficulty(1);
			else if (controls.UI_LEFT_P)
				changeDifficulty(-1);

			if(FlxG.keys.justPressed.CONTROL)
			{
				persistentUpdate = false;
				openSubState(new GameplayChangersSubstate());
			}
			else if(controls.RESET)
			{
				persistentUpdate = false;
				openSubState(new ResetScoreSubState('', curDifficulty, '', curWeek));
				//FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			else if (controls.ACCEPT)
			{
				selectWeek();
			}
		}

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxTween.tween(blackBarThingie, {y: -60}, 0.5, {ease: FlxEase.quartIn});
			FlxTween.tween(difficultySelectors, {y: FlxG.height+10}, 0.5, {ease: FlxEase.quartIn});
			FlxTween.tween(bg, {y: 0}, 0.5, {ease: FlxEase.quartIn, onComplete: function(t:FlxTween) {
				movedBack = true;
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				MusicBeatState.switchState(new MainMenuState());
			}});
			
		}

		super.update(elapsed);

		// grpLocks.forEach(function(lock:FlxSprite)
		// {
		// 	lock.y = grpWeekText.members[lock.ID].y;
		// 	lock.visible = (lock.y > FlxG.height / 2);
		// });
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	var isFlashing:Bool = false;

	var flashingInt:Int = 0;
	var fakeFramerate:Int = Math.round((1 / FlxG.elapsed) / 10);



	function selectWeek()
	{
		if (!weekIsLocked(loadedWeeks[curWeek].fileName))
		{
			if (stopspamming == false)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));
				isFlashing = true;
				FlxTween.tween(bg, {'scale.x': 1.1, 'scale.y': 1.1},0.6, {ease: FlxEase.quadOut, type: BACKWARD});
				stopspamming = true;
			}

			// We can't use Dynamic Array .copy() because that crashes HTML5, here's a workaround.
			var songArray:Array<String> = [];
			var leWeek:Array<Dynamic> = loadedWeeks[curWeek].songs;
			for (i in 0...leWeek.length) {
				songArray.push(leWeek[i][0]);
			}

			// Nevermind that's stupid lmao
			PlayState.storyPlaylist = songArray;
			PlayState.isStoryMode = true;
			selectedWeek = true;

			var diffic = CoolUtil.getDifficultyFilePath(curDifficulty);
			if(diffic == null) diffic = '';

			PlayState.storyDifficulty = curDifficulty;

			PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
			PlayState.campaignScore = 0;
			PlayState.campaignMisses = 0;
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				LoadingState.loadAndSwitchState(new PlayState(), true);
				FreeplayState.destroyFreeplayVocals();
			});
		} else {
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}
	}

	var tweenDifficulty:FlxTween;
	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficulties.length-1;
		if (curDifficulty >= CoolUtil.difficulties.length)
			curDifficulty = 0;

		WeekData.setDirectoryFromWeek(loadedWeeks[curWeek]);

		var diff:String = CoolUtil.difficulties[curDifficulty];
		var newImage:FlxGraphic = Paths.image('menudifficulties/' + Paths.formatToSongPath(diff));
		//trace(Paths.currentModDirectory + ', menudifficulties/' + Paths.formatToSongPath(diff));

		if(sprDifficulty.graphic != newImage)
		{
			sprDifficulty.loadGraphic(newImage);
			sprDifficulty.screenCenter(X);
			sprDifficulty.y = leftArrow.y = rightArrow.y = theWeek.y+theWeek.height+15;

			if(tweenDifficulty != null) tweenDifficulty.cancel();
			tweenDifficulty = FlxTween.tween(sprDifficulty, {'scale.x': 1.1, 'scale.y': 1.1}, 0.07, {type:BACKWARD ,onComplete: function(twn:FlxTween)
			{
				tweenDifficulty = null;
			}});
		}
		lastDifficultyName = diff;
		

		#if !switch
		intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty);
		#end
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;

		if (curWeek >= loadedWeeks.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = loadedWeeks.length - 1;

		var leWeek:WeekData = loadedWeeks[curWeek];
		WeekData.setDirectoryFromWeek(leWeek);

		var leName:String = leWeek.storyName;
		txtWeekTitle.text = leName.toUpperCase();
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		var bullShit:Int = 0;

		var unlocked:Bool = !weekIsLocked(leWeek.fileName);
		// for (item in grpWeekText.members)
		// {
		// 	item.targetY = bullShit - curWeek;
		// 	if (item.targetY == Std.int(0) && unlocked)
		// 		item.alpha = 1;
		// 	else
		// 		item.alpha = 0.6;
		// 	bullShit++;
		// }

		bgSprite.visible = true;
		var assetName:String = leWeek.weekBackground;
		if(assetName == null || assetName.length < 1) {
			bgSprite.visible = false;
		} else {
			bgSprite.loadGraphic(Paths.image('menubackgrounds/menu_' + assetName));
		}
		PlayState.storyWeek = curWeek;

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		var diffStr:String = WeekData.getCurrentWeek().difficulties;
		if(diffStr != null) diffStr = diffStr.trim(); //Fuck you HTML5
		// difficultySelectors.visible = unlocked;

		if(diffStr != null && diffStr.length > 0)
		{
			var diffs:Array<String> = diffStr.split(',');
			var i:Int = diffs.length - 1;
			while (i > 0)
			{
				if(diffs[i] != null)
				{
					diffs[i] = diffs[i].trim();
					if(diffs[i].length < 1) diffs.remove(diffs[i]);
				}
				--i;
			}

			if(diffs.length > 0 && diffs[0].length > 0)
			{
				CoolUtil.difficulties = diffs;
			}
		}
		
		if(CoolUtil.difficulties.contains(CoolUtil.defaultDifficulty))
		{
			curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(CoolUtil.defaultDifficulty)));
		}
		else
		{
			curDifficulty = 0;
		}

		var newPos:Int = CoolUtil.difficulties.indexOf(lastDifficultyName);
		//trace('Pos of ' + lastDifficultyName + ' is ' + newPos);
		if(newPos > -1)
		{
			curDifficulty = newPos;
		}
		updateText();
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!weekCompleted.exists(leWeek.weekBefore) || !weekCompleted.get(leWeek.weekBefore)));
	}

	function updateText()
	{
	// 	var weekArray:Array<String> = loadedWeeks[curWeek].weekCharacters;
	// 	for (i in 0...grpWeekCharacters.length) {
	// 		grpWeekCharacters.members[i].changeCharacter(weekArray[i]);
	// 	}

	// 	var leWeek:WeekData = loadedWeeks[curWeek];
	// 	var stringThing:Array<String> = [];
	// 	for (i in 0...leWeek.songs.length) {
	// 		stringThing.push(leWeek.songs[i][0]);
	// 	}

	// 	txtTracklist.text = '';
	// 	for (i in 0...stringThing.length)
	// 	{
	// 		txtTracklist.text += stringThing[i] + '\n';
	// 	}

	// 	txtTracklist.text = txtTracklist.text.toUpperCase();

	// 	txtTracklist.screenCenter(X);
	// 	txtTracklist.x -= FlxG.width * 0.35;

		#if !switch
		intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty);
		#end
	}
}
