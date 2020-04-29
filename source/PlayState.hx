package;

import props.OgmoTilemap;
import props.Player;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;

using zero.utilities.OgmoUtils;
using zero.flixel.utilities.FlxOgmoUtils;

class PlayState extends flixel.FlxState
{
	var purpleMap:OgmoTilemap;
	var blueMap:OgmoTilemap;
	var redMap:OgmoTilemap;
	var goal:FlxSprite;
	
	var blueBro:Hero;
	var redBro:Hero;
	var bros = new FlxTypedGroup<Hero>();
	var platforms = new FlxTypedGroup<FlxSprite>();
	
	var mode:PlayMode = Alone;
	
	override public function create():Void
	{
		super.create();
		
		initOgmo();
	}
	
	function initOgmo()
	{
		var ogmo = FlxOgmoUtils.get_ogmo_package("assets/data/levels.ogmo", "assets/data/test.json");
		add(purpleMap = new OgmoTilemap(ogmo, 'Purple', 0, 1));
		add(blueMap = new OgmoTilemap(ogmo, 'Blue', 0, 1));
		add(redMap = new OgmoTilemap(ogmo, 'Red', 0, 1));
		ogmo.level.get_entity_layer('Props').load_entities(createEntity);
		add(platforms);
		add(bros);
		
		if (mode == Alone)
			redBro.enabled = false;
	}
	
	function createEntity(data:EntityData)
	{
		switch(data.name)
		{
			case "Start1": 
				blueBro = switch mode
				{
					case Alone: new SwappablePlayer(data.x, data.y, FlxColor.BLUE);
					case Together(true, _): new Player(data.x, data.y, FlxColor.BLUE);
					case Together(_, replay): new Npc(data.x, data.y, replay);
				}
				bros.add(blueBro);
				platforms.add(blueBro.platform);
				
			case "Start2": 
				redBro = switch mode
				{
					case Alone: new SwappablePlayer(data.x, data.y, FlxColor.RED);
					case Together(false, _): new Player(data.x, data.y, FlxColor.RED);
					case Together(_, replay): new Npc(data.x, data.y, replay);
				}
				bros.add(redBro);
				platforms.add(redBro.platform);
			case "Goal":
				add(goal = new FlxSprite(data.x, data.y));
				goal.makeGraphic(16, 16, FlxColor.RED);
			case unhandled:
				throw 'Unhandled token:$unhandled';
		}
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		FlxG.collide(bros, purpleMap);
		FlxG.collide(blueBro, blueMap);
		FlxG.collide(redBro, redMap);
		FlxG.collide(blueBro, redBro.platform);
		FlxG.collide(redBro, blueBro.platform);
		
		if (mode == Alone)
		{
			if (blueBro.enabled == redBro.enabled)
				throw "Invalid state, there can only be one!";
			
			var bro:SwappablePlayer = cast (blueBro.enabled ? blueBro : redBro);
			if (bro.isSwapping)
			{
				blueBro.enabled = !blueBro.enabled;
				redBro.enabled = !redBro.enabled;
			}
		}
	}
}

enum PlayMode
{
	Alone;
	Together(isBlue:Bool, replay:String);
}
