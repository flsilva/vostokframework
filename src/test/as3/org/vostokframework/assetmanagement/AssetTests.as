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
	import org.flexunit.Assert;
	import org.vostokframework.assetmanagement.settings.LoadingAssetPolicySettings;
	import org.vostokframework.assetmanagement.settings.LoadingAssetSettings;

	/**
	 * @author Flávio Silva
	 */
	[TestCase(order=1)]
	public class AssetTests
	{
		
		public function AssetTests()
		{
			
		}
		
		///////////////////////
		// CONSTRUCTOR TESTS //
		///////////////////////
		
		[Test(expects="ArgumentError")]
		public function constructor_invalidId_ThrowsError(): void
		{
			var asset:Asset = new Asset(null, null, null, null);
			asset = null;
		}
		
		[Test(expects="ArgumentError")]
		public function constructor_invalidSrc_ThrowsError(): void
		{
			var asset:Asset = new Asset("asset-1", null, null, null);
			asset = null;
		}
		
		[Test(expects="ArgumentError")]
		public function constructor_invalidType_ThrowsError(): void
		{
			var asset:Asset = new Asset("asset-1", "asset-path/asset.xml", null, null);
			asset = null;
		}
		
		[Test(expects="ArgumentError")]
		public function constructor_invalidPriority_ThrowsError(): void
		{
			var asset:Asset = new Asset("asset-1", "asset-path/asset.xml", AssetType.XML, null);
			asset = null;
		}
		
		[Test]
		public function constructor_validInstantiation_ReturnsValidObject(): void
		{
			var asset:Asset = new Asset("asset-1", "asset-path/asset.xml", AssetType.XML, AssetLoadingPriority.HIGH);
			Assert.assertNotNull(asset);
		}
		
		////////////////////////////
		// Asset().equals() TESTS //
		////////////////////////////
		
		[Test]
		public function equals_compareTwoEqualAssets_ReturnsTrue(): void
		{
			var asset1:Asset = new Asset("asset-1", "asset-path/asset.xml", AssetType.XML, AssetLoadingPriority.HIGH);
			var asset2:Asset = new Asset("asset-1", "asset-path/asset.xml", AssetType.XML, AssetLoadingPriority.HIGH);
			Assert.assertTrue(asset1.equals(asset2));
		}
		
		[Test]
		public function equals_compareTwoDifferentAssets_ReturnsFalse(): void
		{
			var asset1:Asset = new Asset("asset-1", "asset-path/asset.xml", AssetType.XML, AssetLoadingPriority.HIGH);
			var asset2:Asset = new Asset("asset-2", "asset-path/asset.xml", AssetType.XML, AssetLoadingPriority.HIGH);
			Assert.assertFalse(asset1.equals(asset2));
		}
		
		//////////////////////
		// Asset().id TESTS //
		//////////////////////
		
		[Test]
		public function id_instanciationWithId_checkIfIdMatches_ReturnsTrue(): void
		{
			var asset:Asset = new Asset("asset-1", "asset-path/asset.xml", AssetType.XML, AssetLoadingPriority.HIGH);
			Assert.assertEquals("asset-1", asset.id);
		}
		
		////////////////////////////
		// Asset().priority TESTS //
		///////////////////////////
		
		[Test]
		public function priority_instanciationWithPriority_checkIfPriorityMatches_ReturnsTrue(): void
		{
			var asset:Asset = new Asset("asset-1", "asset-path/asset.xml", AssetType.XML, AssetLoadingPriority.HIGH);
			Assert.assertEquals(AssetLoadingPriority.HIGH, asset.priority);
		}
		
		////////////////////////////
		// Asset().settings TESTS //
		////////////////////////////
		
		[Test]
		public function settings_instanciationWithSettings_checkIfSettingsMatches_ReturnsTrue(): void
		{
			var policy:LoadingAssetPolicySettings = new LoadingAssetPolicySettings(5);
			var settings:LoadingAssetSettings = new LoadingAssetSettings(policy);
			
			var asset:Asset = new Asset("asset-1", "asset-path/asset.xml", AssetType.XML, AssetLoadingPriority.HIGH, settings);
			Assert.assertEquals(settings, asset.settings);
		}
		
		///////////////////////
		// Asset().src TESTS //
		///////////////////////
		
		[Test]
		public function src_instanciationWithSrc_checkIfSrcMatches_ReturnsTrue(): void
		{
			var asset:Asset = new Asset("asset-1", "asset-path/asset.xml", AssetType.XML, AssetLoadingPriority.HIGH);
			Assert.assertEquals("asset-path/asset.xml", asset.src);
		}
		
		////////////////////////
		// Asset().type TESTS //
		////////////////////////
		
		[Test]
		public function type_instanciationWithType_checkIfTypeMatches_ReturnsTrue(): void
		{
			var asset:Asset = new Asset("asset-1", "asset-path/asset.xml", AssetType.XML, AssetLoadingPriority.HIGH);
			Assert.assertEquals(AssetType.XML, asset.type);
		}
		
		/////////////////////////////////
		// Asset().setPriority() TESTS //
		/////////////////////////////////
		
		[Test(expects="ArgumentError")]
		public function setPriority_invalidArgument_ThrowsError(): void
		{
			var asset:Asset = new Asset("asset-1", "asset-path/asset.xml", AssetType.XML, AssetLoadingPriority.HIGH);
			asset.setPriority(null);
		}
		
		[Test]
		public function setPriority_validArgument_checkIfPriorityMatches_ReturnsTrue(): void
		{
			var asset:Asset = new Asset("asset-1", "asset-path/asset.xml", AssetType.XML, AssetLoadingPriority.HIGH);
			asset.setPriority(AssetLoadingPriority.LOW);
			
			Assert.assertEquals(AssetLoadingPriority.LOW, asset.priority);
			//TODO: teste do evento disparado pela Asset
		}
		
	}

}