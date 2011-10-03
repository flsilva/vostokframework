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
package org.vostokframework.application.cache
{
	import org.as3collections.IList;
	import org.as3collections.IMap;
	import org.as3collections.lists.ReadOnlyArrayList;
	import org.as3collections.maps.HashMap;
	import org.as3collections.maps.TypedMap;
	import org.as3utils.ReflectionUtil;
	import org.vostokframework.VostokIdentification;
	import org.vostokframework.application.cache.errors.AssetDataAlreadyCachedError;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class CachedAssetDataRepository
	{
		private var _reportMap:IMap;//key = VostokIdentification | value = LoadedAssetReport 

		/**
		 * description
		 */
		public function CachedAssetDataRepository()
		{
			_reportMap = new TypedMap(new HashMap(), VostokIdentification, CachedAssetData);
		}
		
		/**
		 * description
		 * 
		 * @throws 	ArgumentError 	if the <code>report</code> argument is <code>null</code>.
		 * @return
		 */
		public function add(report:CachedAssetData): void
		{
			if (!report) throw new ArgumentError("Argument <report> must not be null.");
			
			if (_reportMap.containsKey(report.identification))
			{
				var message:String = "There is already a LoadedAssetReport object stored with VostokIdentification:\n";
				message += "<" + report.identification + ">\n";
				message += "Use the method <LoadedAssetRepository().exists()> to check if a LoadedAssetReport object already exists.\n";
				
				throw new AssetDataAlreadyCachedError(report.identification, message);
			}
			
			_reportMap.put(report.identification, report);
		}
		
		/**
		 * description
		 * 
		 * @return
 		 */
		public function clear(): void
		{
			_reportMap.clear();
		}

		/**
		 * description
		 * 
		 * @param 	assetId    
		 * @throws 	ArgumentError 	if the <code>identification</code> argument is <code>null</code>.
		 * @return
		 */
		public function exists(identification:VostokIdentification): Boolean
		{
			if (!identification) throw new ArgumentError("Argument <identification> must not be null.");
			
			return _reportMap.containsKey(identification);
		}

		/**
		 * description
		 * 
		 * @param 	identification    
		 * @throws 	ArgumentError 	if the <code>identification</code> argument is <code>null</code>.
		 * @return
		 */
		public function find(identification:VostokIdentification): CachedAssetData
		{
			if (!identification) throw new ArgumentError("Argument <identification> must not be null.");
			
			return _reportMap.getValue(identification);
		}

		/**
		 * description
		 * 
		 * @return
 		 */
		public function findAll(): IList
		{
			if (isEmpty()) return null;
			var l:IList = new ReadOnlyArrayList(_reportMap.getValues().toArray());
			
			return l;
		}
		
		/**
		 * description
		 * 
		 * @return
		 */
		public function isEmpty(): Boolean
		{
			return _reportMap.isEmpty();
		}

		/**
		 * description
		 * 
		 * @param 	assetId    
		 * @throws 	ArgumentError 	if the <code>assetId</code> argument is <code>null</code> or <code>empty</code>.
		 * @return
		 */
		public function remove(identification:VostokIdentification): Boolean
		{
			if (!identification) throw new ArgumentError("Argument <identification> must not be null.");
			
			return _reportMap.remove(identification) != null;
		}
		
		/**
		 * description
		 * 
		 * @return
		 */
		public function size(): int
		{
			return _reportMap.size();
		}
		
		/**
		 * description
		 * 
		 * @return
		 */
		public function toString(): String
		{
			return "[" + ReflectionUtil.getClassName(this) + "] <" + _reportMap.getValues() + ">";
		}

	}

}