package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.6.2'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String> = [
		'story_mode',
		// 'freeplay',
		// #if MODS_ALLOWED 'mods', #end
		#if ACHIEVEMENTS_ALLOWED 'awards', #end
		'credits',
		'options'
	];

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;

	override function create()
	{
		#if MODS_ALLOWED
		Paths.pushGlobalMods();
		#end
		WeekData.loadTheFirstEnabledMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		// transIn = FlxTransitionableState.defaultTransIn;
		// transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		selectedSomethin = true;

		if (FlxG.sound.music == null) {
            FlxG.sound.playMusic(Paths.music('freakyMenu')); }

		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();


		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.set(0, 0);
		// bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		// camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		// add(camFollowPos);

		magenta = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.set(0, 0);
		// magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		magenta.color = 0xFFfd719b;
		add(magenta);
		
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 0.7;
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/

		for (i in 0...optionShit.length)
		{
			// var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite((i * FlxG.width), 0);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(Y);
			menuItem.y += 270;
			menuItems.add(menuItem);
			menuItem.scrollFactor.set(1, 0);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();
			FlxTween.tween(menuItem, {y: FlxG.height+20}, 0.5, {
				ease: FlxEase.quintOut, 
				type: BACKWARD,
				onComplete: function(t:FlxTween) {
					selectedSomethin = false;
					
			}});
		}
		

		// FlxG.camera.fade(FlxColor.BLACK, 0.4, true, function() {
		// 	for (spr in menuItems) {
		// 		spr.alpha = 1;
		// 		FlxTween.tween(spr, {y: FlxG.height+20}, 0.5, {
		// 			ease: FlxEase.quintOut, 
		// 			type: BACKWARD,
		// 			onComplete: function(t:FlxTween) {
		// 				selectedSomethin = false;
						
		// 		}});
		// 	}
			
		// });

		// FlxG.camera.follow(camFollowPos, null, 1);
		

		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) {
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				ClientPrefs.saveSettings();
			}
		}
		#end

		FlxG.camera.focusOn(camFollow.getPosition());

		super.create();
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement() {
		add(new AchievementObject('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}
	#end

	function switchState() {
		var daChoice:String = optionShit[curSelected];
		switch (daChoice)
		{
			case 'story_mode':
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				StoryMenuState.fromMainMenu = true;
				MusicBeatState.switchState(new StoryMenuState());
		
			// case 'freeplay':
			// 	MusicBeatState.switchState(new FreeplayState());


			// #if MODS_ALLOWED
			// case 'mods':
			// 	MusicBeatState.switchState(new ModsMenuState());
			// #end
			case 'awards':
			MusicBeatState.switchState(new AchievementsMenuState());
			case 'credits':
			MusicBeatState.switchState(new CreditsState());
			case 'options':
			LoadingState.loadAndSwitchState(new options.OptionsState());
		}
	}

	public static var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			if(FreeplayState.vocals != null) FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 16, 0, 1);
		FlxG.camera.follow(camFollow, null, lerpVal);

		
		// var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		// camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			if (controls.UI_LEFT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_RIGHT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					if(ClientPrefs.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false, true);
					

					for (spr in menuItems) {
						if (curSelected == spr.ID) {
							spr.animation.play('selected');
							var offset:Int = 0;
							switch (optionShit[curSelected]) {
								case 'story_mode': offset = 130;
								case 'award': offset = 70;
								default: offset = 120;
							}
							camFollow.setPosition(spr.getGraphicMidpoint().x-offset, spr.getGraphicMidpoint().y-30);
							FlxG.camera.focusOn(camFollow.getPosition());
							FlxTween.tween(spr, {"scale.x": 1.1, "scale.y": 1.1}, 0.4, {
								ease: FlxEase.expoOut, 
								type: FlxTweenType.BACKWARD,
								onComplete: function(tw:FlxTween) {
									FlxTween.tween(spr, {y: FlxG.height+20}, 0.5, {ease: FlxEase.quintIn, onComplete: function(t:FlxTween) {
										switchState();
									}});
								}
							});
							
						}
					}

					// menuItems.forEach(function(spr:FlxSprite)
					// {
					// 	if (curSelected == spr.ID)
					// 	{
					// 		FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
					// 			{
									
					// 			});
					// 	}
					// });
				}
			}
			#if desktop
			else if (FlxG.keys.anyJustPressed(debugKeys))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}

			if (FlxG.keys.justPressed.Z)
			{
				selectedSomethin = true;
				FlxTransitionableState.skipNextTransOut = true;
				if (FanartState.startTheDark == true)
					FanartState.startTheDark = false;
				MusicBeatState.switchState(new FanartState());
				// FlxG.sound.music.volume = 0;
				// MusicBeatState.switchState(new TemporaryEnding());
			}

			if (FlxG.keys.justPressed.X) {
				selectedSomethin = true;
				MusicBeatState.switchState(new TemporaryEnding());
			}
			#end
		}

		super.update(elapsed);

		// menuItems.forEach(function(spr:FlxSprite)
		// {
		// 	spr.screenCenter(Y);
		// });
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				camFollow.setPosition(spr.getGraphicMidpoint().x-100, spr.getGraphicMidpoint().y);
				
				spr.centerOffsets();

				// switch (optionShit[curSelected])
				// {
				// 	case 'awards':
				// 		spr.offset.x = 180;
				// 	case 'options':
				// 		spr.offset.x = 180;
						
				// }
				
			}
		});
	}
}
