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
package org.vostokframework.assetmanagement.domain
{
	import org.as3collections.IIterator;
	import org.as3collections.IList;
	import org.as3collections.IMap;
	import org.as3collections.lists.ReadOnlyArrayList;
	import org.as3collections.maps.HashMap;
	import org.as3collections.maps.TypedMap;
	import org.as3utils.ReflectionUtil;
	import org.vostokframework.assetmanagement.domain.errors.DuplicateAssetPackageError;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class AssetPackageRepository
	{
		private var _assetPackageMap:IMap;//key = AssetPackageIdentification | value = AssetPackage 

		/**
		 * description
		 */
		public function AssetPackageRepository(): void
		{
			_assetPackageMap = new TypedMap(new HashMap(), AssetPackageIdentification, AssetPackage);
		}
		
		/**
		 * description
		 * 
		 * @param asset    assetPackage
		 * @throws 	ArgumentError 	if the <code>assetPackage</code> argument is <code>null</code>.
		 * @throws 	org.vostokframework.assetmanagement.domain.errors.DuplicateAssetPackageError 	if already exists an <code>AssetPackage</code> object stored with the same <code>id</code> of the provided <code>assetPackage</code> argument.
		 * @return
		 */
		public function add(assetPackage:AssetPackage): void
		{
			if (!assetPackage) throw new ArgumentError("Argument <assetPackage> must not be null.");
			
			if (_assetPackageMap.containsKey(assetPackage.identification))
			{
				var message:String = "There is already an AssetPackage object stored with identification: ";
				message += "<" + assetPackage.identification + ">\n";
				message += "Use the method <AssetPackageRepository().exists()> to check if an AssetPackage object already exists.\n";
				message += "For further information please read the documentation section about the AssetPackage object.";
				
				throw new DuplicateAssetPackageError(assetPackage.identification, message);
			}
			
			_assetPackageMap.put(assetPackage.identification, assetPackage);
		}
		
		/**
		 * description
		 * 
		 * @return
 		 */
		public function clear(): void
		{
			_assetPackageMap.clear();
		}

		/**
		 * description
		 * 
		 * @param assetId    idPackageAsset
		 * @throws 	ArgumentError 	if the <code>assetPackageId</code> argument is <code>null</code> or <code>empty</code>.
		 * @return
		 */
		public function exists(identification:AssetPackageIdentification): Boolean
		{
			if (!identification) throw new ArgumentError("Argument <identification> must not be null.");
			
			return _assetPackageMap.containsKey(identification);
		}

		/**
		 * description
		 * 
		 * @param assetPackageId    idPackageAsset
		 * @param localeId
		 * @throws 	ArgumentError 	if the <code>assetPackageId</code> argument is <code>null</code> or <code>empty</code>.
		 * @return
		 */
		public function find(identification:AssetPackageIdentification): AssetPackage
		{
			if (!identification) throw new ArgumentError("Argument <identification> must not be null.");
			
			return _assetPackageMap.getValue(identification);
		}

		/**
		 * description
		 * 
		 * @return
 		 */
		public function findAll(): IList
		{
			if (isEmpty()) return null;
			var l:IList = new ReadOnlyArrayList(_assetPackageMap.getValues().toArray());
			
			return l;
		}
		
		/**
		 * description
		 * 
		 * @param assetId    idPackageAsset
		 * @throws 	ArgumentError 	if the <code>assetId</code> argument is <code>null</code> or <code>empty</code>.
		 * @return
		 */
		public function findAssetPackageByAssetId(identification:AssetIdentification): AssetPackage
		{
			if (!identification) throw new ArgumentError("Argument <identification> must not be null.");
			
			if (isEmpty()) return null;
			
			var itAssetPackages:IIterator = _assetPackageMap.getValues().iterator();
			var itAssets:IIterator;
			var assetPackage:AssetPackage;
			var asset:Asset;
			
			while (itAssetPackages.hasNext())
			{
				assetPackage = itAssetPackages.next();
				if (assetPackage.isEmpty()) continue;
				
				itAssets = assetPackage.getAssets().iterator();
				while (itAssets.hasNext())
				{
					asset = itAssets.next();
					if (asset.identification.equals(identification)) return assetPackage;
				}
			}
			
			return null;
		}
		
		/**
		 * description
		 * 
		 * @return
		 */
		public function isEmpty(): Boolean
		{
			return _assetPackageMap.isEmpty();
		}

		/**
		 * description
		 * 
		 * @param assetPackageId
		 * @param localeId
		 * @throws 	ArgumentError 	if the <code>assetPackageId</code> argument is <code>null</code> or <code>empty</code>.
		 * @return
		 */
		public function remove(identification:AssetPackageIdentification): Boolean
		{
			if (!identification) throw new ArgumentError("Argument <identification> must not be null.");
			
			return _assetPackageMap.remove(identification) != null;
		}
		
		/**
		 * description
		 * 
		 * @return
		 */
		public function size(): int
		{
			return _assetPackageMap.size();
		}
		
		/**
		 * description
		 * 
		 * @return
		 */
		public function toString(): String
		{
			return "[" + ReflectionUtil.getClassName(this) + "] <" + _assetPackageMap.getValues() + ">";
		}

	}

}