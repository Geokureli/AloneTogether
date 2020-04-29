package props;

import flixel.util.FlxArrayUtil;
import flixel.graphics.frames.FlxTileFrames;
import flixel.math.FlxPoint;
import flixel.tile.FlxTilemap;

import zero.flixel.utilities.FlxOgmoUtils;
import zero.utilities.OgmoUtils;

using zero.utilities.OgmoUtils;
using zero.flixel.utilities.FlxOgmoUtils;

@:forward
abstract OgmoTilemap(FlxTilemap) to FlxTilemap
{
	inline public function new
		( ogmo     :OgmoPackage
		, layerName:String
		, path         = 'assets/images/'
		, drawIndex    = 0
		, collideIndex = 1
		, indexOffset  = 0
		)
	{
		this = new FlxTilemap();
		var layer = ogmo.level.get_tile_layer(layerName);
		var tileset = ogmo.project.get_tileset_data(layer.tileset);
		@:privateAccess//get_export_mode
		switch layer.get_export_mode() {
			case CSV    : throw "unsupported CSV export mode";
			case ARRAY  : loadOgmoArrayMap(layer, tileset, path, indexOffset, drawIndex, collideIndex);
			case ARRAY2D: loadOgmo2DArrayMap(layer, tileset, path, indexOffset, drawIndex, collideIndex);
		}
	}
	
	inline public function setTileCollisions(index:Int, allowCollisions:Int)
	{
		@:privateAccess
		this._tileObjects[index].allowCollisions = allowCollisions;
	}
	
	inline public function setTilesCollisions(startIndex:Int, num:Int, allowCollisions:Int)
	{
		for (i in startIndex...startIndex + num)
			setTileCollisions(i, allowCollisions);
	}
	
	inline function loadOgmoArrayMap
		( layer  :TileLayer
		, tileset:ProjectTilesetData
		, path   :String
		, indexOffset  = 0
		, drawIndex    = 0
		, collideIndex = 1
		)
	{
		return this.loadMapFromArray
			( getOffsetIndices(layer.data, indexOffset)
			, layer.gridCellsX
			, layer.gridCellsY
			, getPaddedTileset(tileset, path)
			, tileset.tileWidth
			, tileset.tileHeight
			, OFF
			, 0
			, drawIndex
			, collideIndex
			);
	}
	
	inline function loadOgmo2DArrayMap
		( layer  :TileLayer
		, tileset:ProjectTilesetData
		, path   :String
		, indexOffset  = 0
		, drawIndex    = 0
		, collideIndex = 1
		)
	{
		return this.loadMapFromArray
			( getOffsetIndices(FlxArrayUtil.flatten2DArray(layer.data2D), indexOffset)
			, layer.gridCellsX
			, layer.gridCellsY
			, getPaddedTileset(tileset, path)
			, tileset.tileWidth
			, tileset.tileHeight
			, OFF
			, 0
			, drawIndex
			, collideIndex
			);
	}
	
	inline function getOffsetIndices(data:Array<Int>, offset:Int):Array<Int>
	{
		return offset == 0 ? data : data.map(i->i+offset);
	}
	
	inline function getPaddedTileset(tileset:ProjectTilesetData, path, padding = 2)
	{
		return FlxTileFrames.fromBitmapAddSpacesAndBorders
			( tileset.get_tileset_path(path)
			, FlxPoint.get(tileset.tileWidth, tileset.tileHeight)
			, FlxPoint.get(tileset.tileSeparationX, tileset.tileSeparationY)
			, FlxPoint.get(padding, padding)
			);
	}
}