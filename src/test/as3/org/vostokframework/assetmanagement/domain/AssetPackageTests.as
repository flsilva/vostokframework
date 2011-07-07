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

package org.vostokframework.assetmanagement.domain
{
	import org.as3collections.IList;
	import org.as3collections.lists.ArrayList;
	import org.flexunit.Assert;
	import org.vostokframework.loadingmanagement.domain.LoadPriority;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class AssetPackageTests
	{
		private static const IDENTIFICATION:AssetPackageIdentification = new AssetPackageIdentification("asset-package-id", "en-US");
		
		private var _assetPackage:AssetPackage;
		
		public function AssetPackageTests()
		{
			
		}
		
		/////////////////////////
		// TESTS CONFIGURATION //
		/////////////////////////
		
		[Before]
		public function setUp(): void
		{
			_assetPackage = new AssetPackage(IDENTIFICATION);
		}
		
		[After]
		public function tearDown(): void
		{
			_assetPackage = null;
		}
		
		////////////////////
		// HELPER METHODS //
		////////////////////
		
		private function getAssetA():Asset
		{
			var identification:AssetIdentification = new AssetIdentification("asset-A", "en-US");
			return new Asset(identification, "asset-path/asset-A.xml", AssetType.XML, LoadPriority.HIGH);
		}
		
		private function getAssetB():Asset
		{
			var identification:AssetIdentification = new AssetIdentification("asset-B", "en-US");
			return new Asset(identification, "asset-path/asset-B.xml", AssetType.XML, LoadPriority.HIGH);
		}
		
		///////////////////////
		// CONSTRUCTOR TESTS //
		///////////////////////
		
		[Test(expects="ArgumentError")]
		public function constructor_invalidIdentification_ThrowsError(): void
		{
			new AssetPackage(null);
		}
		
		[Test]
		public function constructor_validInstantiation_ReturnsValidObject(): void
		{
			var assetPackage:AssetPackage = new AssetPackage(IDENTIFICATION);
			Assert.assertNotNull(assetPackage);
		}
		
		/////////////////////////////////////////
		// AssetPackage().identification TESTS //
		/////////////////////////////////////////
		
		[Test]
		public function identification_checkIfIdMatches_ReturnsTrue(): void
		{
			Assert.assertTrue(_assetPackage.identification.equals(IDENTIFICATION));
		}
		
		/////////////////////////////////////
		// AssetPackage().addAsset() TESTS //
		/////////////////////////////////////
		
		[Test]
		public function addAsset_validArgument_ReturnsTrue(): void
		{
			var added:Boolean = _assetPackage.addAsset(getAssetA());
			Assert.assertTrue(added);
		}
		
		[Test]
		public function addAsset_dupplicatedAsset_ReturnsFalse(): void
		{
			_assetPackage.addAsset(getAssetA());
			var added:Boolean = _assetPackage.addAsset(getAssetA());
			
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
			list.add(getAssetA());
			list.add(getAssetB());
			
			var added:Boolean = _assetPackage.addAssets(list);
			Assert.assertTrue(added);
		}
		
		[Test]
		public function addAssets_dupplicatedAssets_ReturnsFalse(): void
		{
			_assetPackage.addAsset(getAssetA());
			_assetPackage.addAsset(getAssetB());
			
			var list:IList = new ArrayList();
			list.add(getAssetA());
			list.add(getAssetB());
			
			var added:Boolean = _assetPackage.addAssets(list);
			Assert.assertFalse(added);
		}
		
		[Test(expects="ArgumentError")]
		public function addAssets_invalidArgument_ThrowsError(): void
		{
			var list:IList = new ArrayList();
			list.add(getAssetA());
			list.add(getAssetB());
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
			_assetPackage.addAsset(getAssetA());
			_assetPackage.clear();
			
			var size:int = _assetPackage.size();
			Assert.assertEquals(0, size);
		}
		
		[Test]
		public function clear_notEmptyAssetPackage_checkIfIsEmpty_ReturnsTrue(): void
		{
			_assetPackage.addAsset(getAssetA());
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
			var asset:Asset = getAssetA();
			_assetPackage.addAsset(asset);
			
			var contains:Boolean = _assetPackage.containsAsset(asset.identification);
			Assert.assertTrue(contains);
		}
		
		[Test]
		public function containsAsset_notAddedAsset_ReturnsFalse(): void
		{
			var identification:AssetIdentification = new AssetIdentification("any-not-added-id", "en-US");
			var contains:Boolean = _assetPackage.containsAsset(identification);
			Assert.assertFalse(contains);
		}
		
		/////////////////////////////////////
		// AssetPackage().getAsset() TESTS //
		/////////////////////////////////////
		
		[Test]
		public function getAsset_addedAsset_ReturnsValidObject(): void
		{
			var asset:Asset = getAssetA();
			_assetPackage.addAsset(asset);
			
			asset = _assetPackage.getAsset(asset.identification);
			Assert.assertNotNull(asset);
		}
		
		[Test]
		public function getAsset_notAddedAsset_ReturnsNull(): void
		{
			var identification:AssetIdentification = new AssetIdentification("any-not-added-id", "en-US");
			var asset:Asset = _assetPackage.getAsset(identification);
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
			_assetPackage.addAsset(getAssetA());
			
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
			_assetPackage.addAsset(getAssetA());
			
			var empty:Boolean = _assetPackage.isEmpty();
			Assert.assertFalse(empty);
		}
		
		////////////////////////////////////////
		// AssetPackage().removeAsset() TESTS //
		////////////////////////////////////////
		
		[Test]
		public function removeAsset_emptyAssetPackage_ReturnsFalse(): void
		{
			var identification:AssetIdentification = new AssetIdentification("any-not-added-id", "en-US");
			var removed:Boolean = _assetPackage.removeAsset(identification);
			Assert.assertFalse(removed);
		}
		
		[Test]
		public function removeAsset_notEmptyAssetPackage_notAddedAsset_ReturnsFalse(): void
		{
			_assetPackage.addAsset(getAssetA());
			
			var identification:AssetIdentification = new AssetIdentification("any-not-added-id", "en-US");
			var removed:Boolean = _assetPackage.removeAsset(identification);
			Assert.assertFalse(removed);
		}
		
		[Test]
		public function removeAsset_notEmptyAssetPackage_addedAsset_ReturnsTrue(): void
		{
			var asset:Asset = getAssetA();
			_assetPackage.addAsset(asset);
			
			var removed:Boolean = _assetPackage.removeAsset(asset.identification);
			Assert.assertTrue(removed);
		}
		
		/////////////////////////////////////////
		// AssetPackage().removeAssets() TESTS //
		/////////////////////////////////////////
		
		[Test]
		public function removeAssets_emptyAssetPackage_ReturnsFalse(): void
		{
			var list:IList = new ArrayList();
			list.add(getAssetA());
			
			var removed:Boolean = _assetPackage.removeAssets(list);
			Assert.assertFalse(removed);
		}
		
		[Test]
		public function removeAssets_notEmptyAssetPackage_notAddedAssets_ReturnsFalse(): void
		{
			_assetPackage.addAsset(getAssetA());
			
			var list:IList = new ArrayList();
			list.add(getAssetB());
			
			var removed:Boolean = _assetPackage.removeAssets(list);
			Assert.assertFalse(removed);
		}
		
		[Test]
		public function removeAssets_notEmptyAssetPackage_addedAssets_ReturnsTrue(): void
		{
			_assetPackage.addAsset(getAssetA());
			
			var list:IList = new ArrayList();
			list.add(getAssetA());
			list.add(getAssetB());
			
			var removed:Boolean = _assetPackage.removeAssets(list);
			Assert.assertTrue(removed);
		}
		
		[Test]
		public function removeAssets_notEmptyAssetPackage_addedAssets_checkIfIsEmpty_ReturnsTrue(): void
		{
			_assetPackage.addAsset(getAssetA());
			
			var list:IList = new ArrayList();
			list.add(getAssetA());
			list.add(getAssetB());
			
			_assetPackage.removeAssets(list);
			
			var isEmpty:Boolean = _assetPackage.isEmpty();
			Assert.assertTrue(isEmpty);
		}
		
		[Test]
		public function removeAssets_notEmptyAssetPackage_addedAssets_checkIfSizeIsZero_ReturnsTrue(): void
		{
			_assetPackage.addAsset(getAssetA());
			
			var list:IList = new ArrayList();
			list.add(getAssetA());
			list.add(getAssetB());
			
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
			_assetPackage.addAsset(getAssetA());
			
			var size:int = _assetPackage.size();
			Assert.assertEquals(1, size);
		}
		
	}

}