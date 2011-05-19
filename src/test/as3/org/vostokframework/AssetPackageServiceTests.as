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
	import org.vostokframework.assetmanagement.AssetPackage;
	import org.vostokframework.assetmanagement.AssetPackageFactory;
	import org.vostokframework.assetmanagement.AssetPackageRepository;
	import org.vostokframework.assetmanagement.AssetsContext;
	import org.vostokframework.assetmanagement.utils.LocaleUtil;

	/**
	 * @author Flávio Silva
	 */
	public class AssetPackageServiceTests
	{
		private static const ASSET_PACKAGE_ID:String = "asset-package-1";
		private static const ASSET_PACKAGE_LOCALE:String = "en-US";
		
		public function AssetPackageServiceTests()
		{
			
		}
		
		/////////////////////////
		// TESTS CONFIGURATION //
		/////////////////////////
		
		[Before]
		public function setUp(): void
		{
			AssetsContext.getInstance().setAssetPackageRepository(new AssetPackageRepository());
			
			var assetPackageFactory:AssetPackageFactory = new AssetPackageFactory();
			var assetPackage:AssetPackage = assetPackageFactory.create(ASSET_PACKAGE_ID, ASSET_PACKAGE_LOCALE);
			
			AssetsContext.getInstance().assetPackageRepository.add(assetPackage);
		}
		
		///////////////////////
		// CONSTRUCTOR TESTS //
		///////////////////////
		
		[Test]
		public function constructor_validInstantiation_ReturnsValidObject(): void
		{
			var service:AssetPackageService = new AssetPackageService();
			Assert.assertNotNull(service);
		}
		
		//////////////////////////////////////////////////////
		// AssetPackageService().assetPackageExists() TESTS //
		//////////////////////////////////////////////////////
		
		[Test(expects="ArgumentError")]
		public function assetPackageExists_invalidAssetPackageId_ReturnsFalse(): void
		{
			var service:AssetPackageService = new AssetPackageService();
			service.assetPackageExists(null);
		}
		
		[Test]
		public function assetPackageExists_assetPackageNotExists_ReturnsFalse(): void
		{
			var service:AssetPackageService = new AssetPackageService();
			var exists:Boolean = service.assetPackageExists("any-not-added-id");
			Assert.assertFalse(exists);
		}
		
		[Test]
		public function assetPackageExists_assetPackageWithLocaleExists_ReturnsTrue(): void
		{
			var service:AssetPackageService = new AssetPackageService();
			var exists:Boolean = service.assetPackageExists(ASSET_PACKAGE_ID, ASSET_PACKAGE_LOCALE);
			Assert.assertTrue(exists);
		}
		
		[Test]
		public function assetPackageExists_assetPackageWithoutLocaleExists_ReturnsTrue(): void
		{
			//testing asset package without sending locale
			
			var assetPackageFactory:AssetPackageFactory = new AssetPackageFactory();
			var assetPackage:AssetPackage = assetPackageFactory.create("asset-package-1");
			
			AssetsContext.getInstance().assetPackageRepository.add(assetPackage);
			
			var service:AssetPackageService = new AssetPackageService();
			var exists:Boolean = service.assetPackageExists("asset-package-1");
			Assert.assertTrue(exists);
		}
		
		//////////////////////////////////////////////////////
		// AssetPackageService().createAssetPackage() TESTS //
		//////////////////////////////////////////////////////
		
		[Test]
		public function createAssetPackage_validArguments_ReturnsAssetPackage(): void
		{
			AssetsContext.getInstance().setAssetPackageRepository(new AssetPackageRepository());
			
			var service:AssetPackageService = new AssetPackageService();
			var assetPackage:AssetPackage = service.createAssetPackage("asset-package-1", "en-US");
			Assert.assertNotNull(assetPackage);
		}
		
		[Test]
		public function createAssetPackage_validArgumentsWithLocale_checkIfAssetPackageRepositoryContainsTheObject_ReturnsTrue(): void
		{
			AssetsContext.getInstance().setAssetPackageRepository(new AssetPackageRepository());
			
			var service:AssetPackageService = new AssetPackageService();
			service.createAssetPackage("asset-package-1", "en-US");
			
			var composedId:String = LocaleUtil.composeId("asset-package-1", "en-US");
			Assert.assertTrue(AssetsContext.getInstance().assetPackageRepository.exists(composedId));
		}
		
		[Test]
		public function createAssetPackage_validArgumentsWithoutLocale_checkIfAssetPackageRepositoryContainsTheObject_ReturnsTrue(): void
		{
			AssetsContext.getInstance().setAssetPackageRepository(new AssetPackageRepository());
			
			var service:AssetPackageService = new AssetPackageService();
			service.createAssetPackage("asset-package-1");
			
			var composedId:String = LocaleUtil.composeId("asset-package-1");
			Assert.assertTrue(AssetsContext.getInstance().assetPackageRepository.exists(composedId));
		}
		
		///////////////////////////////////////////////////////
		// AssetPackageService().getAllAssetPackages() TESTS //
		///////////////////////////////////////////////////////
		
		[Test]
		public function getAllAssetPackages_emptyAssetPackageRepository_ReturnsNull(): void
		{
			AssetsContext.getInstance().setAssetPackageRepository(new AssetPackageRepository());
			
			var service:AssetPackageService = new AssetPackageService();
			var list:IList = service.getAllAssetPackages();
			
			Assert.assertNull(list);
		}
		
		[Test]
		public function getAllAssetPackages_notEmptyAssetPackageRepository_ReturnsIList(): void
		{
			var service:AssetPackageService = new AssetPackageService();
			var list:IList = service.getAllAssetPackages();
			
			Assert.assertNotNull(list);
		}
		
		///////////////////////////////////////////////////
		// AssetPackageService().getAssetPackage() TESTS //
		///////////////////////////////////////////////////
		
		[Test(expects="ArgumentError")]
		public function getAssetPackage_invalidAssetPackageId_ThrowsError(): void
		{
			var service:AssetPackageService = new AssetPackageService();
			service.getAssetPackage(null);
		}
		
		[Test(expects="org.vostokframework.assetmanagement.errors.AssetPackageNotFoundError")]
		public function getAssetPackage_notAddedAssetPackage_ThrowsError(): void
		{
			var service:AssetPackageService = new AssetPackageService();
			service.getAssetPackage("any-not-added-id");
		}
		
		[Test]
		public function getAssetPackage_addedAssetPackageWithLocale_ReturnsAssetPackage(): void
		{
			var service:AssetPackageService = new AssetPackageService();
			var assetPackage:AssetPackage = service.getAssetPackage(ASSET_PACKAGE_ID, ASSET_PACKAGE_LOCALE);
			
			Assert.assertNotNull(assetPackage);
		}
		
		[Test]
		public function getAssetPackage_addedAssetPackageWithoutLocale_ReturnsAssetPackage(): void
		{
			//testing asset without locale
			//dupplication of certain code of the setUp() method needed here
			
			AssetsContext.getInstance().setAssetPackageRepository(new AssetPackageRepository());
			
			var assetPackageFactory:AssetPackageFactory = new AssetPackageFactory();
			var assetPackage:AssetPackage = assetPackageFactory.create("asset-package-1");
			
			AssetsContext.getInstance().assetPackageRepository.add(assetPackage);
			
			var service:AssetPackageService = new AssetPackageService();
			assetPackage = service.getAssetPackage("asset-package-1");
			
			Assert.assertNotNull(assetPackage);
		}
		
		//////////////////////////////////////////////////////////
		// AssetPackageService().removeAllAssetPackages() TESTS //
		//////////////////////////////////////////////////////////
		
		[Test]
		public function removeAllAssetPackages_emptyAssetPackageRepository_checkIfAssetPackageRepositoryIsEmpty_ReturnsTrue(): void
		{
			AssetsContext.getInstance().setAssetPackageRepository(new AssetPackageRepository());
			
			var service:AssetPackageService = new AssetPackageService();
			service.removeAllAssetPackages();
			
			Assert.assertTrue(AssetsContext.getInstance().assetPackageRepository.isEmpty());
		}
		
		[Test]
		public function removeAllAssetPackages_notEmptyAssetPackageRepository_checkIfAssetPackageRepositoryIsEmpty_ReturnsTrue(): void
		{
			var service:AssetPackageService = new AssetPackageService();
			service.removeAllAssetPackages();
			
			Assert.assertTrue(AssetsContext.getInstance().assetPackageRepository.isEmpty());
		}
		
		//////////////////////////////////////////////////////
		// AssetPackageService().removeAssetPackage() TESTS //
		//////////////////////////////////////////////////////
		
		[Test(expects="ArgumentError")]
		public function removeAssetPackage_invalidAssetPackageId_ThrowsError(): void
		{
			var service:AssetPackageService = new AssetPackageService();
			service.removeAssetPackage(null);
		}
		
		[Test]
		public function removeAssetPackage_notAddedAssetPackage_ReturnsFalse(): void
		{
			var service:AssetPackageService = new AssetPackageService();
			var removed:Boolean = service.removeAssetPackage("any-not-added-id");
			
			Assert.assertFalse(removed);
		}
		
		[Test]
		public function removeAssetPackage_addedAssetPackage_ReturnsTrue(): void
		{
			var service:AssetPackageService = new AssetPackageService();
			var removed:Boolean = service.removeAssetPackage(ASSET_PACKAGE_ID, ASSET_PACKAGE_LOCALE);
			
			Assert.assertTrue(removed);
		}
		
		[Test]
		public function removeAssetPackage_addedAssetPackage_checkIfAssetPackageRepositoryDoNotContainTheObjectRemoved_ReturnsFalse(): void
		{
			var service:AssetPackageService = new AssetPackageService();
			service.removeAssetPackage(ASSET_PACKAGE_ID, ASSET_PACKAGE_LOCALE);
			
			var composedId:String = LocaleUtil.composeId(ASSET_PACKAGE_ID, ASSET_PACKAGE_LOCALE);
			Assert.assertFalse(AssetsContext.getInstance().assetPackageRepository.exists(composedId));
		}
		
	}

}