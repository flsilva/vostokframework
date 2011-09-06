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
	import org.as3collections.lists.ArrayList;
	import org.as3collections.lists.ReadOnlyArrayList;
	import org.as3collections.utils.ListUtil;
	import org.as3coreaddendum.system.IDisposable;
	import org.as3coreaddendum.system.IEquatable;
	import org.as3utils.ReflectionUtil;
	import org.vostokframework.VostokIdentification;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class AssetPackage implements IEquatable, IDisposable
	{
		private var _assets:IList;
		private var _identification:VostokIdentification;
		
		/**
		 * description
		 */
		public function get identification(): VostokIdentification { return _identification; }

		/**
		 * description
		 * 
		 * @param id
		 * @param locale
		 * @throws 	ArgumentError 	if the <code>id</code> argument is <code>null</code> or <code>empty</code>.
		 * @throws 	ArgumentError 	if the <code>locale</code> argument is <code>null</code> or <code>empty</code>.
		 */
		public function AssetPackage(identification:VostokIdentification)
		{
			if (!identification) throw new ArgumentError("Argument <identification> must not be null.");
			
			_identification = identification;
			_assets = ListUtil.getUniqueTypedList(new ArrayList(), Asset);
		}
		
		/**
		 * description
		 * 
		 * @param asset
		 * @throws 	ArgumentError 	if the <code>asset</code> argument is <code>null</code>.
		 * @return
		 */
		public function addAsset(asset:Asset): Boolean
		{
			if (!asset) throw new ArgumentError("Argument <asset> must not be null.");
			if (identification.locale != asset.identification.locale)
			{
				var errorMessage:String = "The <locale> property of Asset and AssetPackage objects must match.\n";
				errorMessage += "AssetPackage: <" + AssetPackage + ">\n";
				errorMessage += "Asset: <" + Asset + ">\n";
				errorMessage += "For further information please read the documentation section about the AssetPackage object.";
				throw new ArgumentError(errorMessage);
			}
			
			return _assets.add(asset);
		}

		/**
		 * description
		 * 
		 * @param assets
		 * @throws 	ArgumentError 	if the <code>assets</code> argument is <code>null</code>.
		 * @throws 	ArgumentError 	if the <code>assets</code> argument contains any <code>null</code> element.
		 * @return
		 */
		public function addAssets(assets:IList): Boolean
		{
			if (!assets) throw new ArgumentError("Argument <assets> must not be null.");
			
			var it:IIterator = assets.iterator();
			while (it.hasNext())
			{
				if (!it.next()) throw new ArgumentError("Argument <assets> must not contain any null element. A null element was found at index <" + it.pointer() + ">");
			}
			
			return _assets.addAll(assets);
		}
		
		/**
		 * description
		 * 
		 * @return
 		 */
		public function clear(): void
		{
			_assets.clear();
		}

		/**
		 * description
		 * 
		 * @param assetId
		 * @throws 	ArgumentError 	if the <code>assetId</code> argument is <code>null</code> or <code>empty</code>.
		 * @return
		 */
		public function containsAsset(identification:VostokIdentification): Boolean
		{
			if (!identification) throw new ArgumentError("Argument <identification> must not be null.");
			
			if (isEmpty()) return false;
			
			var asset:Asset = getAsset(identification);
			return _assets.contains(asset);
		}
		
		public function dispose():void
		{
			clear();
			_assets = null;
		}
		
		public function equals(other : *): Boolean
		{
			if (this == other) return true;
			if (!(other is AssetPackage)) return false;
			
			var otherAssetPackage:AssetPackage = other as AssetPackage;
			return identification.equals(otherAssetPackage.identification);
		}

		/**
		 * description
		 * 
		 * @param id
		 * @throws 	ArgumentError 	if the <code>assetId</code> argument is <code>null</code> or <code>empty</code>.
		 * @return
		 */
		public function getAsset(identification:VostokIdentification): Asset
		{
			if (!identification) throw new ArgumentError("Argument <identification> must not be null.");
			
			if (isEmpty()) return null;
			
			var asset:Asset;
			var it:IIterator = _assets.iterator();
			
			while (it.hasNext())
			{
				asset = it.next();
				if (asset.identification.equals(identification)) return asset;
			}
			
			return null;
		}
		
		/**
		 * description
		 * 
		 * @return
 		 */
		public function getAssets(): ReadOnlyArrayList
		{
			if (isEmpty()) return null;
			return new ReadOnlyArrayList(_assets.toArray());
		}
		
		/**
		 * description
		 * 
		 * @return
		 */
		public function isEmpty(): Boolean
		{
			return _assets.isEmpty();
		}

		/**
		 * description
		 * 
		 * @param id
		 * @throws 	ArgumentError 	if the <code>assetId</code> argument is <code>null</code> or <code>empty</code>.
		 * @return
		 */
		public function removeAsset(identification:VostokIdentification): Boolean
		{
			if (!identification) throw new ArgumentError("Argument <identification> must not be null.");
			
			if (isEmpty()) return false;
			
			var asset:Asset = getAsset(identification);
			return _assets.remove(asset);
		}

		/**
		 * description
		 * 
		 * @param assets
		 * @throws 	ArgumentError 	if the <code>assets</code> argument is <code>null</code>.
		 * @return
		 */
		public function removeAssets(assets:IList): Boolean
		{
			if (!assets) throw new ArgumentError("Argument <assets> must not be null.");
			
			if (isEmpty()) return false;
			return _assets.removeAll(assets);
		}
		
		/**
		 * description
		 * 
		 * @return
		 */
		public function size(): int
		{
			return _assets.size();
		}
		
		/**
		 * description
		 * 
		 * @return
		 */
		public function toString(): String
		{
			return "[" + ReflectionUtil.getClassName(this) + " identification <" + identification + ">]";
		}

	}

}