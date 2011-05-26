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

package org.vostokframework
{
	import org.as3collections.IList;
	import org.flexunit.Assert;
	import org.vostokframework.assetmanagement.Asset;
	import org.vostokframework.assetmanagement.AssetLoadingPriority;
	import org.vostokframework.assetmanagement.AssetPackage;
	import org.vostokframework.assetmanagement.AssetRepository;
	import org.vostokframework.assetmanagement.AssetType;
	import org.vostokframework.assetmanagement.AssetsContext;
	import org.vostokframework.assetmanagement.utils.LocaleUtil;

	/**
	 * @author Flávio Silva
	 */
	public class AssetServiceTests
	{
		private static const ASSET_ID:String = "asset-id";
		private static const ASSET_LOCALE:String = "en-US";
		
		private var _service:AssetService;
		
		public function AssetServiceTests()
		{
			
		}
		
		/////////////////////////
		// TESTS CONFIGURATION //
		/////////////////////////
		
		[Before]
		public function setUp(): void
		{
			AssetsContext.getInstance().setAssetRepository(new AssetRepository());
			
			_service = new AssetService();
		}
		
		[After]
		public function tearDown(): void
		{
			_service = null;
		}
		
		////////////////////
		// HELPER METHODS //
		////////////////////
		
		private function getAssetWithLocale():Asset
		{
			var composedId:String = LocaleUtil.composeId(ASSET_ID, ASSET_LOCALE);
			return new Asset(composedId, "asset-path/asset.xml", AssetType.XML, AssetLoadingPriority.HIGH);
		}
		
		private function getAssetWithoutLocale():Asset
		{
			var composedId:String = LocaleUtil.composeId(ASSET_ID);
			return new Asset(composedId, "asset-path/asset.xml", AssetType.XML, AssetLoadingPriority.HIGH);
		}
		
		private function getAssetPackage():AssetPackage
		{
			return new AssetPackage("asset-package-1", ASSET_LOCALE);
		}
		
		///////////////////////
		// CONSTRUCTOR TESTS //
		///////////////////////
		
		[Test]
		public function constructor_validInstantiation_ReturnsValidObject(): void
		{
			var service:AssetService = new AssetService();
			Assert.assertNotNull(service);
		}
		
		////////////////////////////////////////
		// AssetService().assetExists() TESTS //
		////////////////////////////////////////
		
		[Test(expects="ArgumentError")]
		public function assetExists_invalidAssetId_ReturnsFalse(): void
		{
			_service.assetExists(null);
		}
		
		[Test]
		public function assetExists_notAddedAsset_ReturnsFalse(): void
		{
			var exists:Boolean = _service.assetExists("any-not-added-id");
			Assert.assertFalse(exists);
		}
		
		[Test]
		public function assetExists_addedAssetWithLocale_ReturnsTrue(): void
		{
			AssetsContext.getInstance().assetRepository.add(getAssetWithLocale());
			
			var exists:Boolean = _service.assetExists(ASSET_ID, ASSET_LOCALE);
			Assert.assertTrue(exists);
		}
		
		[Test]
		public function assetExists_addedAssetWithoutLocale_ReturnsTrue(): void
		{
			AssetsContext.getInstance().assetRepository.add(getAssetWithoutLocale());
			
			var exists:Boolean = _service.assetExists(ASSET_ID);
			Assert.assertTrue(exists);
		}
		
		////////////////////////////////////////////////
		// AssetService().changeAssetPriority() TESTS //
		////////////////////////////////////////////////
		
		[Test(expects="ArgumentError")]
		public function changeAssetPriority_invalidAssetId_ThrowsError(): void
		{
			_service.changeAssetPriority(null, AssetLoadingPriority.HIGH);
		}
		
		[Test(expects="ArgumentError")]
		public function changeAssetPriority_invalidAssetPriority_ThrowsError(): void
		{
			_service.changeAssetPriority("any-not-added-id", null);
		}
		
		[Test(expects="org.vostokframework.assetmanagement.errors.AssetNotFoundError")]
		public function changeAssetPriority_notAddedAsset_ThrowsError(): void
		{
			_service.changeAssetPriority("any-not-added-id", AssetLoadingPriority.HIGH);
		}
		
		[Test]
		public function changeAssetPriority_addedAsset_checkIfPriorityMatches_ReturnsTrue(): void
		{
			var asset:Asset = getAssetWithLocale();
			AssetsContext.getInstance().assetRepository.add(asset);
			
			_service.changeAssetPriority(ASSET_ID, AssetLoadingPriority.HIGH, ASSET_LOCALE);
			Assert.assertEquals(AssetLoadingPriority.HIGH, asset.priority);
		}
		
		////////////////////////////////////////
		// AssetService().createAsset() TESTS //
		////////////////////////////////////////
		
		[Test]
		public function createAsset_srcWithExtension_ReturnsValidObject(): void
		{
			var asset:Asset = _service.createAsset("a.aac", getAssetPackage());
			Assert.assertNotNull(asset);
		}
		
		[Test]
		public function createAsset_srcWithExtension_checkIfAssetRepositoryContainsTheObject_ReturnsTrue(): void
		{
			var asset:Asset = _service.createAsset("http://domain.com/a.aac", getAssetPackage());
			
			var exists:Boolean = AssetsContext.getInstance().assetRepository.exists(asset.id);
			Assert.assertTrue(exists);
		}
		
		[Test(expects="org.vostokframework.assetmanagement.errors.UnsupportedAssetTypeError")]
		public function createAsset_srcWithoutExtensionAndWithoutSendType_ThrowsError(): void
		{
			_service.createAsset("http://domain.com/dynamic-asset", getAssetPackage());
		}
		
		[Test]
		public function createAsset_srcWithoutExtensionAndSendType_ReturnsValidObject(): void
		{
			var asset:Asset = _service.createAsset("http://domain.com/dynamic-asset", getAssetPackage(), null, null, null, AssetType.SWF);
			Assert.assertNotNull(asset);
		}
		
		[Test]
		public function createAsset_checkIfAssetPackageContainsTheObject_ReturnsTrue(): void
		{
			var assetPackage:AssetPackage = getAssetPackage();
			var asset:Asset = _service.createAsset("http://domain.com/a.aac", assetPackage);
			
			var contains:Boolean = assetPackage.containsAsset(asset.id);
			Assert.assertTrue(contains);
		}
		
		/////////////////////////////////////////
		// AssetService().getAllAssets() TESTS //
		/////////////////////////////////////////
		
		[Test]
		public function getAllAssets_emptyAssetRepository_ReturnsNull(): void
		{
			var list:IList = _service.getAllAssets();
			Assert.assertNull(list);
		}
		
		[Test]
		public function getAllAssets_notEmptyAssetRepository_ReturnsIList(): void
		{
			AssetsContext.getInstance().assetRepository.add(getAssetWithLocale());
			
			var list:IList = _service.getAllAssets();
			Assert.assertNotNull(list);
		}
		
		/////////////////////////////////////
		// AssetService().getAsset() TESTS //
		/////////////////////////////////////
		
		[Test(expects="ArgumentError")]
		public function getAsset_invalidAssetId_ThrowsError(): void
		{
			_service.getAsset(null);
		}
		
		[Test(expects="org.vostokframework.assetmanagement.errors.AssetNotFoundError")]
		public function getAsset_notAddedAsset_ThrowsError(): void
		{
			_service.getAsset("any-not-added-id");
		}
		
		[Test]
		public function getAsset_addedAssetWithLocale_ReturnsAsset(): void
		{
			AssetsContext.getInstance().assetRepository.add(getAssetWithLocale());
			
			var asset:Asset = _service.getAsset(ASSET_ID, ASSET_LOCALE);
			Assert.assertNotNull(asset);
		}
		
		[Test]
		public function getAsset_addedAssetWithoutLocale_ReturnsAsset(): void
		{
			//testing asset without locale
			
			AssetsContext.getInstance().assetRepository.add(getAssetWithoutLocale());
			
			var asset:Asset = _service.getAsset(ASSET_ID);
			Assert.assertNotNull(asset);
		}
		
		////////////////////////////////////////////
		// AssetService().removeAllAssets() TESTS //
		////////////////////////////////////////////
		
		[Test]
		public function removeAllAssets_emptyAssetRepository_Void(): void
		{
			_service.removeAllAssets();
			
			var empty:Boolean = AssetsContext.getInstance().assetRepository.isEmpty();
			Assert.assertTrue(empty);
		}
		
		[Test]
		public function removeAllAssets_notEmptyAssetRepository_checkIfAssetRepositoryIsEmpty_ReturnsTrue(): void
		{
			AssetsContext.getInstance().assetRepository.add(getAssetWithoutLocale());
			_service.removeAllAssets();
			
			var empty:Boolean = AssetsContext.getInstance().assetRepository.isEmpty();
			Assert.assertTrue(empty);
		}
		
		////////////////////////////////////////
		// AssetService().removeAsset() TESTS //
		////////////////////////////////////////
		
		[Test(expects="ArgumentError")]
		public function removeAsset_invalidAssetId_ThrowsError(): void
		{
			_service.removeAsset(null);
		}
		
		[Test]
		public function removeAsset_notAddedAsset_ReturnsFalse(): void
		{
			var removed:Boolean = _service.removeAsset("any-not-added-id");
			Assert.assertFalse(removed);
		}
		
		[Test]
		public function removeAsset_addedAsset_ReturnsTrue(): void
		{
			AssetsContext.getInstance().assetRepository.add(getAssetWithLocale());
			
			var removed:Boolean = _service.removeAsset(ASSET_ID, ASSET_LOCALE);
			Assert.assertTrue(removed);
		}
		
	}

}