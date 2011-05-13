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
	import org.vostokframework.assetmanagement.AssetFactory;
	import org.vostokframework.assetmanagement.AssetLoadingPriority;
	import org.vostokframework.assetmanagement.AssetPackage;
	import org.vostokframework.assetmanagement.AssetPackageFactory;
	import org.vostokframework.assetmanagement.AssetRepository;
	import org.vostokframework.assetmanagement.AssetsContext;
	import org.vostokframework.assetmanagement.utils.LocaleUtil;

	/**
	 * @author Flávio Silva
	 */
	public class AssetServiceTests
	{
		private static const ASSET_ID:String = "a.aac";
		private static const ASSET_LOCALE:String = "en-US";
		private static const ASSET_PRIORITY:AssetLoadingPriority = AssetLoadingPriority.LOW;
		
		public function AssetServiceTests()
		{
			
		}
		
		/////////////////////////
		// TESTS CONFIGURATION //
		/////////////////////////
		
		[Before]
		public function startup(): void
		{
			AssetsContext.getInstance().setAssetRepository(new AssetRepository());
			
			var assetPackageFactory:AssetPackageFactory = new AssetPackageFactory();
			var assetPackage:AssetPackage = assetPackageFactory.create("asset-package-1", ASSET_LOCALE);
			
			var assetFactory:AssetFactory = new AssetFactory();
			var asset:Asset = assetFactory.create(ASSET_ID, assetPackage, ASSET_PRIORITY);
			
			AssetsContext.getInstance().assetRepository.add(asset);
		}
		
		///////////////////////
		// CONSTRUCTOR TESTS //
		///////////////////////
		
		[Test]
		public function constructor_validInstantiation_Void(): void
		{
			var service:AssetService = new AssetService();
			Assert.assertNotNull(service);
		}
		
		////////////////////////////////////////
		// AssetService().assetExists() TESTS //
		////////////////////////////////////////
		
		[Test(expects="ArgumentError")]
		public function assetExists_invalidAssetId_False(): void
		{
			var service:AssetService = new AssetService();
			service.assetExists(null);
		}
		
		[Test]
		public function assetExists_notAddedAsset_False(): void
		{
			var service:AssetService = new AssetService();
			var exists:Boolean = service.assetExists("any-not-added-id");
			Assert.assertFalse(exists);
		}
		
		[Test]
		public function assetExists_addedAssetWithLocale_True(): void
		{
			var service:AssetService = new AssetService();
			var exists:Boolean = service.assetExists(ASSET_ID, ASSET_LOCALE);
			Assert.assertTrue(exists);
		}
		
		[Test]
		public function assetExists_addedAssetWithoutLocale_True(): void
		{
			//testing asset without sending locale
			
			var assetPackageFactory:AssetPackageFactory = new AssetPackageFactory();
			var assetPackage:AssetPackage = assetPackageFactory.create("asset-package-1");
			
			var assetFactory:AssetFactory = new AssetFactory();
			var asset:Asset = assetFactory.create("a.aac", assetPackage);
			
			AssetsContext.getInstance().assetRepository.add(asset);
			
			var service:AssetService = new AssetService();
			var exists:Boolean = service.assetExists("a.aac");
			Assert.assertTrue(exists);
		}
		
		////////////////////////////////////////////////
		// AssetService().changeAssetPriority() TESTS //
		////////////////////////////////////////////////
		
		[Test(expects="ArgumentError")]
		public function changeAssetPriority_invalidAssetId_ThrowsError(): void
		{
			var service:AssetService = new AssetService();
			service.changeAssetPriority(null, AssetLoadingPriority.HIGH);
		}
		
		[Test(expects="ArgumentError")]
		public function changeAssetPriority_invalidAssetPriority_ThrowsError(): void
		{
			var service:AssetService = new AssetService();
			service.changeAssetPriority("any-not-added-id", null);
		}
		
		[Test(expects="org.vostokframework.assetmanagement.errors.AssetNotFoundError")]
		public function changeAssetPriority_notAddedAsset_ThrowsError(): void
		{
			var service:AssetService = new AssetService();
			service.changeAssetPriority("any-not-added-id", AssetLoadingPriority.HIGH);
		}
		
		[Test]
		public function changeAssetPriority_addedAsset_Void(): void
		{
			var service:AssetService = new AssetService();
			service.changeAssetPriority(ASSET_ID, AssetLoadingPriority.HIGH, ASSET_LOCALE);
			
			var asset:Asset = AssetsContext.getInstance().assetRepository.find(LocaleUtil.composeId(ASSET_ID, ASSET_LOCALE));
			
			Assert.assertEquals(AssetLoadingPriority.HIGH, asset.priority);
		}
		
		////////////////////////////////////////
		// AssetService().createAsset() TESTS //
		////////////////////////////////////////
		
		[Test]
		public function createAsset_validArguments_Asset(): void
		{
			AssetsContext.getInstance().setAssetRepository(new AssetRepository());
			
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			
			var service:AssetService = new AssetService();
			var asset:Asset = service.createAsset("a.aac", assetPackage);
			Assert.assertNotNull(asset);
		}
		
		[Test]
		public function createAsset_validArgumentsCheckAssetRepository_True(): void
		{
			AssetsContext.getInstance().setAssetRepository(new AssetRepository());
			
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			
			var service:AssetService = new AssetService();
			service.createAsset("a.aac", assetPackage);
			
			Assert.assertTrue(AssetsContext.getInstance().assetRepository.exists(LocaleUtil.composeId("a.aac", "en-US")));
		}
		
		/////////////////////////////////////////
		// AssetService().getAllAssets() TESTS //
		/////////////////////////////////////////
		
		[Test]
		public function getAllAssets_emptyAssetRepository_Null(): void
		{
			AssetsContext.getInstance().setAssetRepository(new AssetRepository());
			
			var service:AssetService = new AssetService();
			var list:IList = service.getAllAssets();
			
			Assert.assertNull(list);
		}
		
		[Test]
		public function getAllAssets_notEmptyAssetRepository_IList(): void
		{
			var service:AssetService = new AssetService();
			var list:IList = service.getAllAssets();
			
			Assert.assertNotNull(list);
		}
		
		/////////////////////////////////////
		// AssetService().getAsset() TESTS //
		/////////////////////////////////////
		
		[Test(expects="ArgumentError")]
		public function getAsset_invalidAssetId_ThrowsError(): void
		{
			var service:AssetService = new AssetService();
			service.getAsset(null);
		}
		
		[Test(expects="org.vostokframework.assetmanagement.errors.AssetNotFoundError")]
		public function getAsset_notAddedAsset_ThrowsError(): void
		{
			var service:AssetService = new AssetService();
			service.getAsset("any-not-added-id");
		}
		
		[Test]
		public function getAsset_addedAssetWithLocale_Asset(): void
		{
			var service:AssetService = new AssetService();
			var asset:Asset = service.getAsset(ASSET_ID, ASSET_LOCALE);
			
			Assert.assertNotNull(asset);
		}
		
		[Test]
		public function getAsset_addedAssetWithoutLocale_Asset(): void
		{
			//testing asset without locale
			
			AssetsContext.getInstance().setAssetRepository(new AssetRepository());
			
			var assetPackageFactory:AssetPackageFactory = new AssetPackageFactory();
			var assetPackage:AssetPackage = assetPackageFactory.create("asset-package-1");
			
			var assetFactory:AssetFactory = new AssetFactory();
			var asset:Asset = assetFactory.create("a.aac", assetPackage);
			
			AssetsContext.getInstance().assetRepository.add(asset);
			
			var service:AssetService = new AssetService();
			asset = service.getAsset("a.aac");
			
			Assert.assertNotNull(asset);
		}
		
		////////////////////////////////////////////
		// AssetService().removeAllAssets() TESTS //
		////////////////////////////////////////////
		
		[Test]
		public function removeAllAssets_emptyAssetRepository_Void(): void
		{
			AssetsContext.getInstance().setAssetRepository(new AssetRepository());
			
			var service:AssetService = new AssetService();
			service.removeAllAssets();
			
			Assert.assertTrue(AssetsContext.getInstance().assetRepository.isEmpty());
		}
		
		[Test]
		public function removeAllAssets_notEmptyAssetRepository_Void(): void
		{
			var service:AssetService = new AssetService();
			service.removeAllAssets();
			
			Assert.assertTrue(AssetsContext.getInstance().assetRepository.isEmpty());
		}
		
		////////////////////////////////////////
		// AssetService().removeAsset() TESTS //
		////////////////////////////////////////
		
		[Test(expects="ArgumentError")]
		public function removeAsset_invalidAssetId_ThrowsError(): void
		{
			var service:AssetService = new AssetService();
			service.removeAsset(null);
		}
		
		[Test]
		public function removeAsset_notAddedAsset_False(): void
		{
			var service:AssetService = new AssetService();
			var removed:Boolean = service.removeAsset("any-not-added-id");
			
			Assert.assertFalse(removed);
		}
		
		[Test]
		public function removeAsset_addedAsset_True(): void
		{
			var service:AssetService = new AssetService();
			var removed:Boolean = service.removeAsset(ASSET_ID, ASSET_LOCALE);
			
			Assert.assertTrue(removed);
		}
		
	}

}