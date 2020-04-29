package input;

import flixel.FlxG;
import flixel.system.replay.CodeValuePair;
import flixel.util.FlxArrayUtil;
import flixel.system.replay.FrameRecord;
import flixel.input.keyboard.FlxKey;
import flixel.input.FlxInput;
import flixel.input.keyboard.FlxKeyboard;
import flixel.system.replay.FlxReplay;

class Controls
{
    static var nullKeys:FlxKeyboard;
    
    public var pressed(default, null):KeyList;
    public var released(default, null):KeyList;
    public var justPressed(default, null):KeyList;
    public var justReleased(default, null):KeyList;
    
    var keyboard:FlxKeyboard;
    var recorder:KeyboardReplay;
    
    public function new (type:ControlsType)
    {
        keyboard = switch type
        {
            case Input:
                FlxG.keys;
            case Replay(data):
                new ReplayKeyboard(data);
            case None: 
                if (nullKeys == null)
                    nullKeys = new FlxKeyboard();
                nullKeys;
        }
        pressed      = new KeyList(keyboard, PRESSED);
        released     = new KeyList(keyboard, RELEASED);
        justPressed  = new KeyList(keyboard, JUST_PRESSED);
        justReleased = new KeyList(keyboard, JUST_RELEASED);
    }
    
    public function update(elapsed:Float):Void
    {
        if (Std.is(keyboard, ReplayKeyboard))
            @:privateAccess
            keyboard.update();
    }
    
    public function startRecording():Void
    {
        if (keyboard != FlxG.keys)
            throw "Can only record player controlled characters";
        
        recorder = new KeyboardReplay(keyboard);
        recorder.create(FlxG.random.currentSeed);
    }
    
    public function finishRecording():String
    {
        if (keyboard != FlxG.keys)
            throw "Can only record player controlled characters";
        if (recorder == null)
            throw "No recorder to finish, call startRecording first";
        
        return recorder.save();
    }
}

class KeyList
{
    var keyboard:FlxKeyboard;
    var status:FlxInputState;
    
    public function new(keyboard:FlxKeyboard, status:FlxInputState)
    {
        this.keyboard = keyboard;
        this.status = status;
    }
    
    inline function check(key:FlxKey)
    {
        return keyboard.checkStatus(key, status);
    }
    
    public var LEFT (get, never):Bool; inline function get_LEFT ():Bool return check(FlxKey.LEFT );
    public var RIGHT(get, never):Bool; inline function get_RIGHT():Bool return check(FlxKey.RIGHT);
    public var DOWN (get, never):Bool; inline function get_DOWN ():Bool return check(FlxKey.DOWN );
    public var JUMP (get, never):Bool; inline function get_JUMP ():Bool return check(FlxKey.Z) || check(FlxKey.UP);
    public var PLAT (get, never):Bool; inline function get_PLAT ():Bool return check(FlxKey.X    );
    public var SWAP (get, never):Bool; inline function get_SWAP ():Bool return check(FlxKey.SPACE);
}

class ReplayKeyboard extends FlxKeyboard
{
    var replay:KeyboardReplay;
    public function new (data:String)
    {
        super();
        replay = new KeyboardReplay(this);
    }
    
    override function update()
    {
        super.update();
        replay.playNextFrame();
    }
}

class KeyboardReplay extends FlxReplay {
    
    public var keys (default, null):FlxKeyboard;
    
    public function new (keys:FlxKeyboard) {
        super();
        
        this.keys = keys != null ? keys : FlxG.keys;
    }
    
    override function recordFrame():Void
    {
        var continueFrame = true;
        
        var keysRecord:Array<CodeValuePair> = keys.record();
        if (keysRecord != null)
            continueFrame = false;
        
        if (continueFrame)
        {
            frame++;
            return;
        }
        
        var frameRecorded = new FrameRecord().create(frame++);
        frameRecorded.keys = keysRecord;
        
        _frames[frameCount++] = frameRecorded;
        
        if (frameCount >= _capacity)
        {
            _capacity *= 2;
            FlxArrayUtil.setLength(_frames, _capacity);
        }
    }
    
    override function playNextFrame():Void
    {
        if (_marker >= frameCount)
        {
            finished = true;
            return;
        }
        
        if (_frames[_marker].frame != frame++)
            return;
        
        var fr:FrameRecord = _frames[_marker++];
        
        if (fr.keys != null)
            keys.playback(fr.keys);
    }
}

enum ControlsType
{
    Replay(data:String);
    Input;
    None;
}