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
package org.vostokframework.domain.loading
{
	import org.as3collections.IList;
	import org.as3collections.IMap;
	import org.as3collections.lists.ArrayList;
	import org.as3collections.maps.HashMap;
	import org.as3collections.maps.TypedMap;
	import org.as3collections.utils.ListUtil;
	import org.as3utils.ReflectionUtil;
	import org.vostokframework.domain.assets.AssetType;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class DataParserRepository
	{
		private var _parserMap:IMap;//<AssetType,IList> - where IList<IDataParser> 

		/**
		 * description
		 */
		public function DataParserRepository()
		{
			_parserMap = new TypedMap(new HashMap(), AssetType, IList);
		}
		
		/**
		 * description
		 * 
		 * @param 	loader
		 * @throws 	ArgumentError 	if the <code>loader</code> argument is <code>null</code>.
		 * @throws 	org.vostokframework.loadermanagement.errors.DuplicateLoaderError 	if already exists an <code>ILoader</code> object stored with the same <code>id</code> of the provided <code>loader</code> argument.
		 * @return
		 */
		public function add(type:AssetType, parser:IDataParser): void
		{
			if (!type) throw new ArgumentError("Argument <type> must not be null.");
			if (!parser) throw new ArgumentError("Argument <parser> must not be null.");
			
			var parserList:IList;
			
			if (!_parserMap.containsKey(type))
			{
				parserList = ListUtil.getUniqueTypedList(new ArrayList(), IDataParser);
				_parserMap.put(type, parserList);
			}
			
			parserList = _parserMap.getValue(type);
			parserList.add(parser);
		}
		
		/**
		 * description
		 * 
		 * @return
 		 */
		public function clear(): void
		{
			_parserMap.clear();
		}

		/**
		 * description
		 * 
		 * @param 	loaderId    
		 * @throws 	ArgumentError 	if the <code>loaderId</code> argument is <code>null</code> or <code>empty</code>.
		 * @return
		 */
		public function exists(type:AssetType, parser:IDataParser): Boolean
		{
			if (!type) throw new ArgumentError("Argument <type> must not be null.");
			if (!parser) throw new ArgumentError("Argument <parser> must not be null.");
			
			if (!_parserMap.containsKey(type)) return false;
			
			var parserList:IList = _parserMap.getValue(type);
			return parserList.contains(parser);
		}

		/**
		 * description
		 * 
		 * @param 	loaderId    
		 * @throws 	ArgumentError 	if the <code>loaderId</code> argument is <code>null</code> or <code>empty</code>.
		 * @return
		 */
		public function find(type:AssetType): IList
		{
			if (!type) throw new ArgumentError("Argument <type> must not be null.");
			
			return _parserMap.getValue(type);
		}
		
		/**
		 * description
		 * 
		 * @return
		 */
		public function isEmpty(): Boolean
		{
			return _parserMap.isEmpty();
		}

		/**
		 * description
		 * 
		 * @param 	loaderId    
		 * @throws 	ArgumentError 	if the <code>loaderId</code> argument is <code>null</code> or <code>empty</code>.
		 * @return
		 */
		public function remove(type:AssetType, parser:IDataParser): Boolean
		{
			if (!type) throw new ArgumentError("Argument <type> must not be null.");
			if (!parser) throw new ArgumentError("Argument <parser> must not be null.");
			
			if (!exists(type, parser)) return false;
			
			var parserList:IList = _parserMap.getValue(type);
			return parserList.remove(parser);
		}
		
		/**
		 * description
		 * 
		 * @return
		 */
		public function size(): int
		{
			return _parserMap.size();
		}
		
		/**
		 * description
		 * 
		 * @return
		 */
		public function toString(): String
		{
			return "[" + ReflectionUtil.getClassName(this) + "] <" + _parserMap.getValues() + ">";
		}
		
	}

}