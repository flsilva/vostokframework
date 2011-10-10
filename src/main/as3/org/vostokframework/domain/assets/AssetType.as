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
package org.vostokframework.domain.assets
{
	import org.as3collections.IIterator;
	import org.as3collections.lists.ArrayList;
	import org.as3collections.utils.ListUtil;
	import org.as3collections.IList;
	import org.as3coreaddendum.system.Enum;
	import org.as3utils.StringUtil;

	import flash.errors.IllegalOperationError;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class AssetType extends Enum
	{
		public static const AAC:AssetType = new AssetType("AAC", 0);
		public static const CSS:AssetType = new AssetType("CSS", 1);
		public static const IMAGE:AssetType = new AssetType("IMAGE", 2);
		public static const JSON:AssetType = new AssetType("JSON", 3);
		public static const MP3:AssetType = new AssetType("MP3", 4);
		public static const SWF:AssetType = new AssetType("SWF", 5);
		public static const TXT:AssetType = new AssetType("TXT", 6);
		public static const VIDEO:AssetType = new AssetType("VIDEO", 7);
		public static const XML:AssetType = new AssetType("XML", 8);
		
		/**
		 * @private
		 */
		private static var _created :Boolean = false;
		
		{
			_created = true;
		}
		
		public function AssetType(name:String, ordinal:int)
		{
			super(name, ordinal);
			if (_created) throw new IllegalOperationError("The set of acceptable values by this Enumerated Type has already been created internally.");
		}
		
		public static function getByName(name:String):AssetType
		{
			if (StringUtil.isBlank(name)) throw new ArgumentError("Argument <name> must not be null nor an empty String.");
			
			var it:IIterator = getTypes().iterator();
			var type:AssetType;
			
			while (it.hasNext())
			{
				type = it.next();
				if (type.name == name.toUpperCase()) return type;
			}
			
			throw new ArgumentError("There is no AssetType object with <name>: " + name);
		}
		
		public static function getTypes():IList
		{
			var types:IList = ListUtil.getUniqueTypedList(new ArrayList(), AssetType);
			types.add(AAC);
			types.add(CSS);
			types.add(IMAGE);
			types.add(JSON);
			types.add(MP3);
			types.add(SWF);
			types.add(TXT);
			types.add(VIDEO);
			types.add(XML);
			
			return types;
		}

	}

}