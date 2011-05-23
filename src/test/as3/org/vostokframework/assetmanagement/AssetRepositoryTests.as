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
	import org.flexunit.Assert;

	/**
	 * @author Flávio Silva
	 */
	[TestCase(order=5)]
	public class AssetRepositoryTests
	{
		private var _repository:AssetRepository;
		
		public function AssetRepositoryTests()
		{
			
		}
		
		/////////////////////////
		// TESTS CONFIGURATION //
		/////////////////////////
		
		[Before]
		public function setUp(): void
		{
			_repository = new AssetRepository();
		}
		
		[After]
		public function tearDown(): void
		{
			_repository = null;
		}
		
		////////////////////
		// HELPER METHODS //
		////////////////////
		
		private function getAsset():Asset
		{
			return new Asset("asset-id", "asset-path/asset.xml", AssetType.XML, AssetLoadingPriority.HIGH);
		}
		
		///////////////////////
		// CONSTRUCTOR TESTS //
		///////////////////////
		
		[Test]
		public function constructor_validInstanciation_ReturnsValidObject(): void
		{
			var repository:AssetRepository = new AssetRepository();
			Assert.assertNotNull(repository);
		}
		
		/////////////////////////////////////
		// AssetRepository().add() TESTS ////
		/////////////////////////////////////
		
		[Test]
		public function add_validArgument_checkIfRepositoryContainsObject_ReturnsTrue(): void
		{
			var asset:Asset = getAsset();
			_repository.add(asset);
			
			var exists:Boolean = _repository.exists(asset.id);
			Assert.assertTrue(exists);
		}
		
		[Test(expects="org.vostokframework.assetmanagement.errors.DuplicateAssetError")]
		public function add_dupplicateAsset_ThrowsError(): void
		{
			_repository.add(getAsset());
			_repository.add(getAsset());
		}
		
		[Test(expects="ArgumentError")]
		public function add_invalidArgument_ThrowsError(): void
		{
			_repository.add(null);
		}
		
		/////////////////////////////////////
		// AssetRepository().clear() TESTS //
		/////////////////////////////////////
		
		[Test]
		public function clear_emptyAssetRepository_checkIfIsEmpty_ReturnsTrue(): void
		{
			_repository.clear();
			
			var empty:Boolean = _repository.isEmpty();
			Assert.assertTrue(empty);
		}
		
		[Test]
		public function clear_notEmptyAssetRepository_checkIfSizeIsZero_ReturnsTrue(): void
		{
			_repository.add(getAsset());
			_repository.clear();
			
			var size:int = _repository.size();
			Assert.assertEquals(0, size);
		}
		
		[Test]
		public function clear_notEmptyAssetRepository_checkIfRepositoryIsEmpty_ReturnsTrue(): void
		{
			_repository.add(getAsset());
			_repository.clear();
			
			var empty:Boolean = _repository.isEmpty();
			Assert.assertTrue(empty);
		}
		
		//////////////////////////////////////
		// AssetRepository().exists() TESTS //
		//////////////////////////////////////
		
		[Test]
		public function exists_addedAsset_ReturnsTrue(): void
		{
			var asset:Asset = getAsset();
			_repository.add(asset);
			
			var exists:Boolean = _repository.exists(asset.id);
			Assert.assertTrue(exists);
		}
		
		[Test]
		public function exists_notAddedAsset_ReturnsFalse(): void
		{
			var exists:Boolean = _repository.exists("any-not-added-id");
			Assert.assertFalse(exists);
		}
		
		////////////////////////////////////
		// AssetRepository().find() TESTS //
		////////////////////////////////////
		
		[Test]
		public function find_addedAsset_checkIfReturnedIdMatches_ReturnsTrue(): void
		{
			var asset:Asset = getAsset();
			_repository.add(asset);
			
			var id:String = asset.id;
			asset = _repository.find(asset.id);
			
			Assert.assertEquals(id, asset.id);
		}
		
		[Test]
		public function find_notAddedAsset_ReturnsNull(): void
		{
			var asset:Asset = _repository.find("any-not-added-id");
			Assert.assertNull(asset);
		}
		
		///////////////////////////////////////
		// AssetRepository().findAll() TESTS //
		///////////////////////////////////////
		
		[Test]
		public function findAll_emptyAssetRepository_ReturnsNull(): void
		{
			var list:IList = _repository.findAll();
			Assert.assertNull(list);
		}
		
		[Test]
		public function findAll_notEmptyAssetRepository_ReturnsIList(): void
		{
			_repository.add(getAsset());
			
			var list:IList = _repository.findAll();
			Assert.assertNotNull(list);
		}
		
		[Test]
		public function findAll_notEmptyAssetRepository_checkIfReturnedListSizeMatches_ReturnsTrue(): void
		{
			_repository.add(getAsset());
			
			var list:IList = _repository.findAll();
			var size:int = list.size();
			Assert.assertEquals(1, size);
		}
		
		///////////////////////////////////////
		// AssetRepository().isEmpty() TESTS //
		///////////////////////////////////////
		
		[Test]
		public function isEmpty_emptyAssetRepository_ReturnsTrue(): void
		{
			var empty:Boolean = _repository.isEmpty();
			Assert.assertTrue(empty);
		}
		
		[Test]
		public function isEmpty_notEmptyAssetRepository_ReturnsFalse(): void
		{
			_repository.add(getAsset());
			
			var empty:Boolean = _repository.isEmpty();
			Assert.assertFalse(empty);
		}
		
		//////////////////////////////////////
		// AssetRepository().remove() TESTS //
		//////////////////////////////////////
		
		[Test]
		public function remove_emptyAssetRepository_ReturnsFalse(): void
		{
			var removed:Boolean = _repository.remove("any-id-not-added");
			Assert.assertFalse(removed);
		}
		
		[Test]
		public function remove_notEmptyAssetRepository_notAddedAsset_ReturnsFalse(): void
		{
			_repository.add(getAsset());
			
			var removed:Boolean = _repository.remove("any-id-not-added");
			Assert.assertFalse(removed);
		}
		
		[Test]
		public function remove_notEmptyAssetRepository_addedAsset_ReturnsTrue(): void
		{
			var asset:Asset = getAsset();
			_repository.add(asset);
			
			var removed:Boolean = _repository.remove(asset.id);
			Assert.assertTrue(removed);
		}
		
		////////////////////////////////////
		// AssetRepository().size() TESTS //
		////////////////////////////////////
		
		[Test]
		public function size_emptyAssetRepository_checkIfSizeIsZero_ReturnsTrue(): void
		{
			var size:int = _repository.size();
			Assert.assertEquals(0, size);
		}
		
		[Test]
		public function size_notEmptyAssetRepository_checkIfSizeMatches_ReturnsTrue(): void
		{
			_repository.add(getAsset());
			
			var size:int = _repository.size();
			Assert.assertEquals(1, size);
		}
		
	}

}