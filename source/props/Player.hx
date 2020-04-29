package props;

import input.Controls;

import flixel.system.replay.FlxReplay;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxColor;

class Hero extends FlxSprite
{
    static inline var TILE_SIZE = 16;
    
    public static inline var JUMP_TIME = 0.35;
    public static inline var JUMP_HEIGHT  = TILE_SIZE * 2.9;
    
    static inline var GRAVITY = 2 * JUMP_HEIGHT / JUMP_TIME / JUMP_TIME;
    static inline var JUMP_SPEED = -2 * JUMP_HEIGHT / JUMP_TIME;
    
    public inline static var JUMP_DISTANCE = TILE_SIZE * 3;
    public inline static var SLOW_DOWN_TIME = 0.1;
    public inline static var SPEED_UP_TIME  = 0.1;

    inline static var MAXSPEED = JUMP_DISTANCE / JUMP_TIME / 2;
    inline static var ACCEL = MAXSPEED / SPEED_UP_TIME;
    inline static var DRAG = MAXSPEED / SLOW_DOWN_TIME;
    
    inline static var WIDTH = 14;
    inline static var HEIGHT = 30;
    
    public var enabled = true;
    public var platform:FlxSprite;
    
    var controls:Controls;
    var jumpTimer = 0.0;
    
    public function new (x, y, color, controls)
    {
        super(x, y + 16 - HEIGHT);
        makeGraphic(WIDTH, HEIGHT, color);
        this.controls = new Controls(controls);
        
        acceleration.y = GRAVITY;
        maxVelocity.set(MAXSPEED, -JUMP_SPEED);
        drag.set(DRAG, DRAG);
        
        platform = new FlxSprite(0, 0);
        platform.immovable = true;
        // platform.moves = false;
        platform.allowCollisions = FlxObject.UP;
        platform.makeGraphic(32, 8, color);
        platform.kill();
    }
    
    override function update(elapsed:Float)
    {
        alpha = enabled ? 1 : 0.75;
        
        controls.update(elapsed);
        if (enabled)
            move(elapsed);
        
        super.update(elapsed);
        platform.velocity.copyFrom(velocity);
        platform.last.x = platform.x;
        platform.last.y = platform.y;
        platform.x = x + (width - platform.width) / 2;
        platform.y = y - platform.height;
    }
    
    function move(elapsed:Float)
    {
        if (isTouching(FlxObject.FLOOR) && controls.justPressed.JUMP)
            velocity.y = JUMP_SPEED;
        
        if (controls.justPressed.PLAT)
        {
            // toggle platform
            if (platform.alive)
                platform.kill();
            else
                platform.revive();
        }
        
        acceleration.x = ACCEL * ((controls.pressed.RIGHT ? 1 : 0) - (controls.pressed.LEFT ? 1 : 0));
    }
}

class Player extends Hero
{
    public function new(x, y, color) { super(x, y, color, Input); }
}

class SwappablePlayer extends Player
{
    public var isSwapping(get, never):Bool;
    public function new (x, y, color) { super(x, y, color); }
    
    inline function get_isSwapping():Bool
    {
        return enabled && controls.justPressed.SWAP;
    }
}

@:forward
abstract Npc(Hero) to Hero
{
    inline public function new(x, y, replay) { this = new Hero(x, y, FlxColor.BLUE, Replay(replay)); }
}