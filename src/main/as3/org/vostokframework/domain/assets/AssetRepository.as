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
	import org.as3collections.IList;
	import org.as3collections.IMap;
	import org.as3collections.lists.ReadOnlyArrayList;
	import org.as3collections.maps.HashMap;
	import org.as3collections.maps.TypedMap;
	import org.as3utils.ReflectionUtil;
	import org.vostokframework.VostokIdentification;
	import org.vostokframework.domain.assets.errors.DuplicateAssetError;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class AssetRepository
	{
		private var _assetMap:IMap;//key = String (Asset().identification().toString()) | value = Asset 

		/**
		 * description
		 */
		public function AssetRepository()
		{
			_assetMap = new TypedMap(new HashMap(), String, Asset);
		}
		
		/**
		 * description
		 * 
		 * @param asset
		 * @throws 	ArgumentError 	if the <code>asset</code> argument is <code>null</code>.
		 * @throws 	org.vostokframework.domain.assets.errors.DuplicateAssetError 	if already exists an <code>Asset</code> object stored with the same <code>id</code> of the provided <code>asset</code> argument.
		 * @return
		 */
		public function add(asset:Asset): void
		{
			if (!asset) throw new ArgumentError("Argument <asset> must not be null.");
			
			if (_assetMap.containsKey(asset.identification.toString()))
			{
				var message:String = "There is already an Asset object stored with identification:\n";
				message += "<" + asset.identification + ">\n";
				message += "Use the method <AssetRepository().exists()> to check if an Asset object already exists.\n";
				message += "For further information please read the documentation section about the Asset object.";
				
				throw new DuplicateAssetError(asset.identification, message);
			}
			
			_assetMap.put(asset.identification.toString(), asset);
		}
		
		/**
		 * description
		 * 
		 * @return
 		 */
		public function clear(): void
		{
			_assetMap.clear();
		}

		/**
		 * description
		 * 
		 * @param assetId    idPackageAsset
		 * @throws 	ArgumentError 	if the <code>assetId</code> argument is <code>null</code> or <code>empty</code>.
		 * @return
		 */
		public function exists(identification:VostokIdentification): Boolean
		{
			if (!identification) throw new ArgumentError("Argument <identification> must not be null.");
			
			return _assetMap.containsKey(identification.toString());
		}

		/**
		 * description
		 * 
		 * @param assetId    idPackageAsset
		 * @param localeId
		 * @throws 	ArgumentError 	if the <code>assetId</code> argument is <code>null</code> or <code>empty</code>.
		 * @return
		 */
		public function find(identification:VostokIdentification): Asset
		{
			if (!identification) throw new ArgumentError("Argument <identification> must not be null.");
			
			return _assetMap.getValue(identification.toString());
		}

		/**
		 * description
		 * 
		 * @return
 		 */
		public function findAll(): IList
		{
			if (isEmpty()) return null;
			var l:IList = new ReadOnlyArrayList(_assetMap.getValues().toArray());
			
			return l;
		}
		
		/**
		 * description
		 * 
		 * @return
		 */
		public function isEmpty(): Boolean
		{
			return _assetMap.isEmpty();
		}

		/**
		 * description
		 * 
		 * @param assetId    idAssetPackage
		 * @param localeId
		 * @throws 	ArgumentError 	if the <code>assetId</code> argument is <code>null</code> or <code>empty</code>.
		 * @return
		 */
		public function remove(identification:VostokIdentification): Boolean
		{
			if (!identification) throw new ArgumentError("Argument <identification> must not be null.");
			
			return _assetMap.remove(identification.toString()) != null;
		}
		
		/**
		 * description
		 * 
		 * @return
		 */
		public function size(): int
		{
			return _assetMap.size();
		}
		
		/**
		 * description
		 * 
		 * @return
		 */
		public function toString(): String
		{
			return "[" + ReflectionUtil.getClassName(this) + "] <" + _assetMap.getValues() + ">";
		}

	}

}