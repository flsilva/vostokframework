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

package org.vostokframework.application.services
{
	import org.as3collections.IList;
	import org.flexunit.Assert;
	import org.vostokframework.VostokIdentification;
	import org.vostokframework.assetmanagement.AssetManagementContext;
	import org.vostokframework.domain.assets.AssetPackage;
	import org.vostokframework.domain.assets.AssetPackageFactory;
	import org.vostokframework.domain.assets.AssetPackageRepository;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class AssetPackageServiceTests
	{
		private static const ASSET_PACKAGE_ID:String = "asset-package-id";
		private static const ASSET_PACKAGE_LOCALE:String = "en-US";
		private static const IDENTIFICATION:VostokIdentification = new VostokIdentification(ASSET_PACKAGE_ID, ASSET_PACKAGE_LOCALE);
		
		private var _service:AssetPackageService;
		
		public function AssetPackageServiceTests()
		{
			
		}
		
		/////////////////////////
		// TESTS CONFIGURATION //
		/////////////////////////
		
		[Before]
		public function setUp(): void
		{
			AssetManagementContext.getInstance().setAssetPackageRepository(new AssetPackageRepository());
			
			_service = new AssetPackageService();
		}
		
		[After]
		public function tearDown(): void
		{
			_service = null;
		}
		
		////////////////////
		// HELPER METHODS //
		////////////////////
		
		private function getAssetPackage():AssetPackage
		{
			var factory:AssetPackageFactory = new AssetPackageFactory();
			return factory.create(IDENTIFICATION);
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
			_service.assetPackageExists(null);
		}
		
		[Test]
		public function assetPackageExists_notAddedAssetPackage_ReturnsFalse(): void
		{
			var exists:Boolean = _service.assetPackageExists("any-not-added-id");
			Assert.assertFalse(exists);
		}
		
		[Test]
		public function assetPackageExists_addedAssetPackage_ReturnsTrue(): void
		{
			AssetManagementContext.getInstance().assetPackageRepository.add(getAssetPackage());
			
			var exists:Boolean = _service.assetPackageExists(ASSET_PACKAGE_ID, ASSET_PACKAGE_LOCALE);
			Assert.assertTrue(exists);
		}
		
		//////////////////////////////////////////////////////
		// AssetPackageService().createAssetPackage() TESTS //
		//////////////////////////////////////////////////////
		
		[Test]
		public function createAssetPackage_validArguments_ReturnsValidObject(): void
		{
			var assetPackage:AssetPackage = _service.createAssetPackage(ASSET_PACKAGE_ID, ASSET_PACKAGE_LOCALE);
			Assert.assertNotNull(assetPackage);
		}
		
		[Test]
		public function createAssetPackage_checkIfAssetPackageRepositoryContainsTheObject_ReturnsTrue(): void
		{
			_service.createAssetPackage(ASSET_PACKAGE_ID, ASSET_PACKAGE_LOCALE);
			
			var identification:VostokIdentification = new VostokIdentification(ASSET_PACKAGE_ID, ASSET_PACKAGE_LOCALE);
			Assert.assertTrue(AssetManagementContext.getInstance().assetPackageRepository.exists(identification));
		}
		
		///////////////////////////////////////////////////////
		// AssetPackageService().getAllAssetPackages() TESTS //
		///////////////////////////////////////////////////////
		
		[Test]
		public function getAllAssetPackages_emptyAssetPackageRepository_ReturnsNull(): void
		{
			var list:IList = _service.getAllAssetPackages();
			Assert.assertNull(list);
		}
		
		[Test]
		public function getAllAssetPackages_notEmptyAssetPackageRepository_ReturnsIList(): void
		{
			AssetManagementContext.getInstance().assetPackageRepository.add(getAssetPackage());
			
			var list:IList = _service.getAllAssetPackages();
			Assert.assertNotNull(list);
		}
		
		///////////////////////////////////////////////////
		// AssetPackageService().getAssetPackage() TESTS //
		///////////////////////////////////////////////////
		
		[Test(expects="ArgumentError")]
		public function getAssetPackage_invalidAssetPackageId_ThrowsError(): void
		{
			_service.getAssetPackage(null);
		}
		
		[Test(expects="org.vostokframework.domain.assets.errors.AssetPackageNotFoundError")]
		public function getAssetPackage_notAddedAssetPackage_ThrowsError(): void
		{
			_service.getAssetPackage("any-not-added-id");
		}
		
		[Test]
		public function getAssetPackage_addedAssetPackage_ReturnsValidObject(): void
		{
			AssetManagementContext.getInstance().assetPackageRepository.add(getAssetPackage());
			
			var assetPackage:AssetPackage = _service.getAssetPackage(ASSET_PACKAGE_ID, ASSET_PACKAGE_LOCALE);
			Assert.assertNotNull(assetPackage);
		}
		
		//////////////////////////////////////////////////////////
		// AssetPackageService().removeAllAssetPackages() TESTS //
		//////////////////////////////////////////////////////////
		
		[Test]
		public function removeAllAssetPackages_emptyAssetPackageRepository_checkIfAssetPackageRepositoryIsEmpty_ReturnsTrue(): void
		{
			_service.removeAllAssetPackages();
			
			var empty:Boolean = AssetManagementContext.getInstance().assetPackageRepository.isEmpty();
			Assert.assertTrue(empty);
		}
		
		[Test]
		public function removeAllAssetPackages_notEmptyAssetPackageRepository_checkIfAssetPackageRepositoryIsEmpty_ReturnsTrue(): void
		{
			AssetManagementContext.getInstance().assetPackageRepository.add(getAssetPackage());
			_service.removeAllAssetPackages();
			
			var empty:Boolean = AssetManagementContext.getInstance().assetPackageRepository.isEmpty();
			Assert.assertTrue(empty);
		}
		
		//////////////////////////////////////////////////////
		// AssetPackageService().removeAssetPackage() TESTS //
		//////////////////////////////////////////////////////
		
		[Test(expects="ArgumentError")]
		public function removeAssetPackage_invalidAssetPackageId_ThrowsError(): void
		{
			_service.removeAssetPackage(null);
		}
		
		[Test]
		public function removeAssetPackage_notAddedAssetPackage_ReturnsFalse(): void
		{
			var removed:Boolean = _service.removeAssetPackage("any-not-added-id");
			Assert.assertFalse(removed);
		}
		
		[Test]
		public function removeAssetPackage_addedAssetPackage_ReturnsTrue(): void
		{
			AssetManagementContext.getInstance().assetPackageRepository.add(getAssetPackage());
			
			var removed:Boolean = _service.removeAssetPackage(ASSET_PACKAGE_ID, ASSET_PACKAGE_LOCALE);
			Assert.assertTrue(removed);
		}
		
		[Test]
		public function removeAssetPackage_addedAssetPackage_checkIfAssetPackageRepositoryDoNotContainTheObjectRemoved_ReturnsFalse(): void
		{
			AssetManagementContext.getInstance().assetPackageRepository.add(getAssetPackage());
			
			_service.removeAssetPackage(ASSET_PACKAGE_ID, ASSET_PACKAGE_LOCALE);
			
			var identification:VostokIdentification = new VostokIdentification(ASSET_PACKAGE_ID, ASSET_PACKAGE_LOCALE);
			var exists:Boolean = AssetManagementContext.getInstance().assetPackageRepository.exists(identification);
			Assert.assertFalse(exists);
		}
		
	}

}