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

package org.vostokframework.assetmanagement.services
{
	import org.as3collections.IList;
	import org.flexunit.Assert;
	import org.vostokframework.VostokFramework;
	import org.vostokframework.VostokIdentification;
	import org.vostokframework.assetmanagement.AssetManagementContext;
	import org.vostokframework.assetmanagement.domain.Asset;
	import org.vostokframework.assetmanagement.domain.AssetPackage;
	import org.vostokframework.assetmanagement.domain.AssetRepository;
	import org.vostokframework.assetmanagement.domain.AssetType;
	import org.vostokframework.loadingmanagement.domain.LoadPriority;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class AssetServiceTests
	{
		private static const ASSET_ID:String = "asset-id";
		private static const IDENTIFICATION:VostokIdentification = new VostokIdentification(ASSET_ID, VostokFramework.CROSS_LOCALE_ID);

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
			AssetManagementContext.getInstance().setAssetRepository(new AssetRepository());
			
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
		
		private function getAsset():Asset
		{
			return new Asset(IDENTIFICATION, "asset-path/asset.xml", AssetType.XML, LoadPriority.HIGH);
		}
		
		private function getAssetPackage():AssetPackage
		{
			var identification:VostokIdentification = new VostokIdentification("asset-package-1", VostokFramework.CROSS_LOCALE_ID);
			return new AssetPackage(identification);
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
		public function assetExists_addedAsset_callSendingLocale_ReturnsTrue(): void
		{
			AssetManagementContext.getInstance().assetRepository.add(getAsset());
			
			var exists:Boolean = _service.assetExists(ASSET_ID, VostokFramework.CROSS_LOCALE_ID);
			Assert.assertTrue(exists);
		}
		
		[Test]
		public function assetExists_addedAsset_callNotSendingLocale_ReturnsTrue(): void
		{
			AssetManagementContext.getInstance().assetRepository.add(getAsset());
			
			var exists:Boolean = _service.assetExists(ASSET_ID);
			Assert.assertTrue(exists);
		}
		
		////////////////////////////////////////////////
		// AssetService().changeAssetPriority() TESTS //
		////////////////////////////////////////////////
		
		[Test(expects="ArgumentError")]
		public function changeAssetPriority_invalidAssetId_ThrowsError(): void
		{
			_service.changeAssetPriority(null, LoadPriority.HIGH);
		}
		
		[Test(expects="ArgumentError")]
		public function changeAssetPriority_invalidAssetPriority_ThrowsError(): void
		{
			_service.changeAssetPriority("any-not-added-id", null);
		}
		
		[Test(expects="org.vostokframework.assetmanagement.domain.errors.AssetNotFoundError")]
		public function changeAssetPriority_notAddedAsset_ThrowsError(): void
		{
			_service.changeAssetPriority("any-not-added-id", LoadPriority.HIGH);
		}
		
		[Test]
		public function changeAssetPriority_addedAsset_checkIfPriorityMatches_ReturnsTrue(): void
		{
			var asset:Asset = getAsset();
			AssetManagementContext.getInstance().assetRepository.add(asset);
			
			_service.changeAssetPriority(ASSET_ID, LoadPriority.HIGH);
			Assert.assertEquals(LoadPriority.HIGH, asset.priority);
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
			
			var exists:Boolean = AssetManagementContext.getInstance().assetRepository.exists(asset.identification);
			Assert.assertTrue(exists);
		}
		
		[Test(expects="org.vostokframework.assetmanagement.domain.errors.UnsupportedAssetTypeError")]
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
			
			var contains:Boolean = assetPackage.containsAsset(asset.identification);
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
			AssetManagementContext.getInstance().assetRepository.add(getAsset());
			
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
		
		[Test(expects="org.vostokframework.assetmanagement.domain.errors.AssetNotFoundError")]
		public function getAsset_notAddedAsset_ThrowsError(): void
		{
			_service.getAsset("any-not-added-id");
		}
		
		[Test]
		public function getAsset_addedAsset_callSendingLocale_ReturnsAsset(): void
		{
			AssetManagementContext.getInstance().assetRepository.add(getAsset());
			
			var asset:Asset = _service.getAsset(ASSET_ID, VostokFramework.CROSS_LOCALE_ID);
			Assert.assertNotNull(asset);
		}
		
		[Test]
		public function getAsset_addedAsset_callNotSendingLocale_ReturnsAsset(): void
		{
			//testing asset without locale
			
			AssetManagementContext.getInstance().assetRepository.add(getAsset());
			
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
			
			var empty:Boolean = AssetManagementContext.getInstance().assetRepository.isEmpty();
			Assert.assertTrue(empty);
		}
		
		[Test]
		public function removeAllAssets_notEmptyAssetRepository_checkIfAssetRepositoryIsEmpty_ReturnsTrue(): void
		{
			AssetManagementContext.getInstance().assetRepository.add(getAsset());
			_service.removeAllAssets();
			
			var empty:Boolean = AssetManagementContext.getInstance().assetRepository.isEmpty();
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
			AssetManagementContext.getInstance().assetRepository.add(getAsset());
			
			var removed:Boolean = _service.removeAsset(ASSET_ID);
			Assert.assertTrue(removed);
		}
		
	}

}