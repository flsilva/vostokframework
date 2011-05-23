/*
 * Licensed under the MIT License
 * 
 * Copyright 2010 (c) Flávio Silva, http://flsilva.com
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
	import org.as3collections.IList;
	import org.as3collections.lists.ArrayList;
	import org.flexunit.Assert;

	/**
	 * @author Flávio Silva
	 */
	[TestCase(order=2)]
	public class AssetPackageTests
	{
		private var _assetPackage:AssetPackage;
		private var _asset1:Asset;
		private var _asset2:Asset;
		
		public function AssetPackageTests()
		{
			
		}
		
		/////////////////////////
		// TESTS CONFIGURATION //
		/////////////////////////
		
		[Before]
		public function setUp(): void
		{
			_assetPackage = new AssetPackage("asset-package-1", "en-US");
			
			_asset1 = new Asset("asset-1", "asset-path/asset.xml", AssetType.XML, AssetLoadingPriority.HIGH);
			_asset2 = new Asset("asset-2", "asset-path/asset.xml", AssetType.XML, AssetLoadingPriority.HIGH);
		}
		
		[After]
		public function tearDown(): void
		{
			_assetPackage = null;
			_asset1 = null;
			_asset2 = null;
		}
		
		///////////////////////
		// CONSTRUCTOR TESTS //
		///////////////////////
		
		[Test(expects="ArgumentError")]
		public function constructor_invalidId_ThrowsError(): void
		{
			var assetPackage:AssetPackage = new AssetPackage(null, null);
			assetPackage = null;
		}
		
		[Test(expects="ArgumentError")]
		public function constructor_invalidLocale_ThrowsError(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", null);
			assetPackage = null;
		}
		
		[Test]
		public function constructor_validInstantiation_ReturnsValidObject(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			Assert.assertNotNull(assetPackage);
		}
		
		/////////////////////////////
		// AssetPackage().id TESTS //
		/////////////////////////////
		
		[Test]
		public function id_instanciationWithId_checkIfIdMatches_ReturnsTrue(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			Assert.assertEquals("asset-package-1", assetPackage.id);
		}
		
		/////////////////////////////////
		// AssetPackage().locale TESTS //
		/////////////////////////////////
		
		[Test]
		public function locale_instanciationWithLocale_checkIfLocaleMatches_ReturnsTrue(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			Assert.assertEquals("en-US", assetPackage.locale);
		}
		
		/////////////////////////////////////
		// AssetPackage().addAsset() TESTS //
		/////////////////////////////////////
		
		[Test]
		public function addAsset_validArgument_ReturnsTrue(): void
		{
			var added:Boolean = _assetPackage.addAsset(_asset1);
			Assert.assertTrue(added);
		}
		
		[Test]
		public function addAsset_dupplicatedAsset_ReturnsFalse(): void
		{
			_assetPackage.addAsset(_asset1);
			var added:Boolean = _assetPackage.addAsset(_asset1);
			
			Assert.assertFalse(added);
		}
		
		[Test(expects="ArgumentError")]
		public function addAsset_nullAsset_ThrowsError(): void
		{
			_assetPackage.addAsset(null);
		}
		
		//////////////////////////////////////
		// AssetPackage().addAssets() TESTS //
		//////////////////////////////////////
		
		[Test]
		public function addAssets_validArgument_ReturnsTrue(): void
		{
			var list:IList = new ArrayList();
			list.add(_asset1);
			list.add(_asset2);
			
			var added:Boolean = _assetPackage.addAssets(list);
			
			Assert.assertTrue(added);
		}
		
		[Test]
		public function addAssets_dupplicatedAssets_ReturnsFalse(): void
		{
			_assetPackage.addAsset(_asset1);
			_assetPackage.addAsset(_asset2);
			
			var list:IList = new ArrayList();
			list.add(_asset1);
			list.add(_asset2);
			
			var added:Boolean = _assetPackage.addAssets(list);
			
			Assert.assertFalse(added);
		}
		
		[Test(expects="ArgumentError")]
		public function addAssets_invalidArgument_ThrowsError(): void
		{
			var list:IList = new ArrayList();
			list.add(_asset1);
			list.add(_asset2);
			list.add(null);
			
			_assetPackage.addAssets(list);
		}
		
		//////////////////////////////////
		// AssetPackage().clear() TESTS //
		//////////////////////////////////
		
		[Test]
		public function clear_emptyAssetPackage_checkIfIsEmpty_ReturnsTrue(): void
		{
			_assetPackage.clear();
			
			Assert.assertTrue(_assetPackage.isEmpty());
		}
		
		[Test]
		public function clear_notEmptyAssetPackage_checkIfSizeIsZero_ReturnsTrue(): void
		{
			_assetPackage.addAsset(_asset1);
			_assetPackage.clear();
			
			var size:int = _assetPackage.size();
			Assert.assertEquals(0, size);
		}
		
		[Test]
		public function clear_notEmptyAssetPackage_checkIfIsEmpty_ReturnsTrue(): void
		{
			_assetPackage.addAsset(_asset1);
			_assetPackage.clear();
			
			var empty:Boolean = _assetPackage.isEmpty();
			Assert.assertTrue(empty);
		}
		
		//////////////////////////////////////////
		// AssetPackage().containsAsset() TESTS //
		//////////////////////////////////////////
		
		[Test]
		public function containsAsset_addedAsset_ReturnsTrue(): void
		{
			_assetPackage.addAsset(_asset1);
			
			var contains:Boolean = _assetPackage.containsAsset(_asset1.id);
			Assert.assertTrue(contains);
		}
		
		[Test]
		public function containsAsset_notAddedAsset_ReturnsFalse(): void
		{
			var contains:Boolean = _assetPackage.containsAsset(_asset1.id);
			Assert.assertFalse(contains);
		}
		
		/////////////////////////////////////
		// AssetPackage().getAsset() TESTS //
		/////////////////////////////////////
		
		[Test]
		public function getAsset_addedAsset_ReturnsValidObject(): void
		{
			_assetPackage.addAsset(_asset1);
			var asset:Asset = _assetPackage.getAsset(_asset1.id);
			
			Assert.assertNotNull(asset);
		}
		
		[Test]
		public function getAsset_notAddedAsset_ReturnsNull(): void
		{
			var asset:Asset = _assetPackage.getAsset("any-id-not-added");
			Assert.assertNull(asset);
		}
		
		//////////////////////////////////////
		// AssetPackage().getAssets() TESTS //
		//////////////////////////////////////
		
		[Test]
		public function getAssets_emptyAssetPackage_ReturnsNull(): void
		{
			var list:IList = _assetPackage.getAssets();
			Assert.assertNull(list);
		}
		
		[Test]
		public function getAssets_notEmptyAssetPackage_ReturnsIList(): void
		{
			_assetPackage.addAsset(_asset1);
			
			var list:IList = _assetPackage.getAssets();
			Assert.assertNotNull(list);
		}
		
		////////////////////////////////////
		// AssetPackage().isEmpty() TESTS //
		////////////////////////////////////
		
		[Test]
		public function isEmpty_emptyAssetPackage_ReturnsTrue(): void
		{
			var empty:Boolean = _assetPackage.isEmpty();
			Assert.assertTrue(empty);
		}
		
		[Test]
		public function isEmpty_notEmptyAssetPackage_ReturnsFalse(): void
		{
			_assetPackage.addAsset(_asset1);
			
			var empty:Boolean = _assetPackage.isEmpty();
			Assert.assertFalse(empty);
		}
		
		////////////////////////////////////////
		// AssetPackage().removeAsset() TESTS //
		////////////////////////////////////////
		
		[Test]
		public function removeAsset_emptyAssetPackage_ReturnsFalse(): void
		{
			var removed:Boolean = _assetPackage.removeAsset("any-id-not-added");
			Assert.assertFalse(removed);
		}
		
		[Test]
		public function removeAsset_notEmptyAssetPackage_notAddedAsset_ReturnsFalse(): void
		{
			_assetPackage.addAsset(_asset1);
			
			var removed:Boolean = _assetPackage.removeAsset("any-id-not-added");
			Assert.assertFalse(removed);
		}
		
		[Test]
		public function removeAsset_notEmptyAssetPackage_addedAsset_ReturnsTrue(): void
		{
			_assetPackage.addAsset(_asset1);
			
			var removed:Boolean = _assetPackage.removeAsset(_asset1.id);
			Assert.assertTrue(removed);
		}
		
		/////////////////////////////////////////
		// AssetPackage().removeAssets() TESTS //
		/////////////////////////////////////////
		
		[Test]
		public function removeAssets_emptyAssetPackage_ReturnsFalse(): void
		{
			var list:IList = new ArrayList();
			list.add(_asset1);
			
			var removed:Boolean = _assetPackage.removeAssets(list);
			Assert.assertFalse(removed);
		}
		
		[Test]
		public function removeAssets_notEmptyAssetPackage_notAddedAssets_ReturnsFalse(): void
		{
			_assetPackage.addAsset(_asset1);
			
			var list:IList = new ArrayList();
			list.add(_asset2);
			
			var removed:Boolean = _assetPackage.removeAssets(list);
			Assert.assertFalse(removed);
		}
		
		[Test]
		public function removeAssets_notEmptyAssetPackage_addedAssets_ReturnsTrue(): void
		{
			_assetPackage.addAsset(_asset1);
			
			var list:IList = new ArrayList();
			list.add(_asset1);
			list.add(_asset2);
			
			var removed:Boolean = _assetPackage.removeAssets(list);
			Assert.assertTrue(removed);
		}
		
		[Test]
		public function removeAssets_notEmptyAssetPackage_addedAssets_checkIfIsEmpty_ReturnsTrue(): void
		{
			_assetPackage.addAsset(_asset1);
			
			var list:IList = new ArrayList();
			list.add(_asset1);
			list.add(_asset2);
			
			_assetPackage.removeAssets(list);
			
			var isEmpty:Boolean = _assetPackage.isEmpty();
			Assert.assertTrue(isEmpty);
		}
		
		[Test]
		public function removeAssets_notEmptyAssetPackage_addedAssets_checkIfSizeIsZero_ReturnsTrue(): void
		{
			_assetPackage.addAsset(_asset1);
			
			var list:IList = new ArrayList();
			list.add(_asset1);
			list.add(_asset2);
			
			_assetPackage.removeAssets(list);
			
			var size:int = _assetPackage.size();
			Assert.assertEquals(0, size);
		}
		
		/////////////////////////////////
		// AssetPackage().size() TESTS //
		/////////////////////////////////
		
		[Test]
		public function size_emptyAssetPackage_checkIfSizeIsZero_ReturnsTrue(): void
		{
			var size:int = _assetPackage.size();
			Assert.assertEquals(0, size);
		}
		
		[Test]
		public function size_oneAssetAdded_checkIfSizeIsOne_ReturnsTrue(): void
		{
			_assetPackage.addAsset(_asset1);
			
			var size:int = _assetPackage.size();
			Assert.assertEquals(1, size);
		}
		
	}

}