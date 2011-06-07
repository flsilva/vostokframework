/*
 * Licensed under the MIT License
 * 
 * Copyright 2011 (c) Flávio Silva, flsilva.com
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 * 
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.vostokframework.assetmanagement
{
	import org.as3collections.IIterator;
	import org.as3collections.IMap;
	import org.as3collections.maps.HashMap;
	import org.as3utils.StringUtil;

	import flash.errors.IllegalOperationError;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class UrlAssetParser
	{
		private static var _instance:UrlAssetParser = new UrlAssetParser();
		
		private var _typeRegexpMap:IMap;
		
		/**
		 * @private
		 */
		private static var _created :Boolean = false;
		
		{
			_created = true;
		}
		
		public function UrlAssetParser()
		{
			if (_created) throw new IllegalOperationError("<UrlAssetParser> is a singleton class and should be accessed only by its <getInstance> method.");
			
			_typeRegexpMap = new HashMap();
			
			var aacExt:Array = getAACExtensions();
			var xmlExt:Array = getXMLExtensions();
			
			_typeRegexpMap.put(AssetType.AAC, getRegexp(aacExt));
			_typeRegexpMap.put(AssetType.XML, getRegexp(xmlExt));
		}
		
		public static function getInstance():UrlAssetParser
		{
			return _instance;
		}
		
		public function getAssetType(src:String):AssetType
		{
			if (StringUtil.isBlank(src)) throw new ArgumentError("Argument <src> must not be null nor an empty String.");
			
			var type:AssetType;
			var regexp:RegExp;
			var it:IIterator = _typeRegexpMap.iterator();
			
			while (it.hasNext())
			{
				regexp = it.next();
				type = it.pointer();
				
				if (src.search(regexp) != -1) return type;
			}
			
			return null;
		}
		
		private function getAACExtensions(): Array
		{
			var ext:Array = [];
			ext.push("aac");
			ext.push("m4a");
			ext.push("m4b");
			ext.push("m4p");
			ext.push("m4v");
			ext.push("m4r");
			
			return ext;
		}
		
		private function getXMLExtensions(): Array
		{
			var ext:Array = [];
			ext.push("xml");
			
			return ext;
		}
		
		private function getRegexp(ext:Array): RegExp
		{
			var l:int = ext.length;
			var r:String = "^.+\.(";
			
			for (var i:int = 0; i < l; i++)
			{
				r += "(" + ext[i] + ")";
				if (i + 1 < l) r += "|";
			}
			
			r += ")";
			
			var regexp:RegExp = new RegExp(r, "i");
			
			return regexp;
		}
		
	}

}