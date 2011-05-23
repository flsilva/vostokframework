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
		private static const ASSET_ID:String = "asset-id";
		private static const ASSET_SRC:String = "asset-path/asset.xml";
		private static const ASSET_TYPE:AssetType = AssetType.XML;
		private static const ASSET_PRIORITY:AssetLoadingPriority = AssetLoadingPriority.HIGH;
		private static const ASSET_SETTINGS:LoadingAssetSettings = new LoadingAssetSettings(new LoadingAssetPolicySettings());
		
		private var _asset:Asset;
		
		public function AssetTests()
		{
			
		}
		
		/////////////////////////
		// TESTS CONFIGURATION //
		/////////////////////////
		
		[Before]
		public function setUp(): void
		{
			_asset = new Asset(ASSET_ID, ASSET_SRC, ASSET_TYPE, ASSET_PRIORITY, ASSET_SETTINGS);
		}
		
		[After]
		public function tearDown(): void
		{
			_asset = null;
		}
		
		///////////////////////
		// CONSTRUCTOR TESTS //
		///////////////////////
		
		[Test(expects="ArgumentError")]
		public function constructor_invalidId_ThrowsError(): void
		{
			new Asset(null, null, null, null);
		}
		
		[Test(expects="ArgumentError")]
		public function constructor_invalidSrc_ThrowsError(): void
		{
			new Asset("asset-id", null, null, null);
		}
		
		[Test(expects="ArgumentError")]
		public function constructor_invalidType_ThrowsError(): void
		{
			new Asset("asset-id", "asset-path/asset.xml", null, null);
		}
		
		[Test(expects="ArgumentError")]
		public function constructor_invalidPriority_ThrowsError(): void
		{
			new Asset("asset-id", "asset-path/asset.xml", AssetType.XML, null);
		}
		
		[Test]
		public function constructor_validInstantiationWithoutSettings_ReturnsValidObject(): void
		{
			var asset:Asset = new Asset("asset-id", "asset-path/asset.xml", AssetType.XML, AssetLoadingPriority.HIGH);
			Assert.assertNotNull(asset);
		}
		
		[Test]
		public function constructor_validInstantiationWithSettings_ReturnsValidObject(): void
		{
			var policy:LoadingAssetPolicySettings = new LoadingAssetPolicySettings();
			var settings:LoadingAssetSettings = new LoadingAssetSettings(policy);
			var asset:Asset = new Asset("asset-id", "asset-path/asset.xml", AssetType.XML, AssetLoadingPriority.HIGH, settings);
			
			Assert.assertNotNull(asset);
		}
		
		////////////////////////////
		// Asset().equals() TESTS //
		////////////////////////////
		
		[Test]
		public function equals_compareTwoEqualAssets_ReturnsTrue(): void
		{
			var otherAsset:Asset = new Asset(_asset.id, _asset.src, _asset.type, _asset.priority);
			Assert.assertTrue(_asset.equals(otherAsset));
		}
		
		[Test]
		public function equals_compareTwoDifferentAssets_ReturnsFalse(): void
		{
			var otherAsset:Asset = new Asset("other-asset-id", "asset-path/asset.xml", AssetType.XML, AssetLoadingPriority.HIGH);
			Assert.assertFalse(_asset.equals(otherAsset));
		}
		
		//////////////////////
		// Asset().id TESTS //
		//////////////////////
		
		[Test]
		public function id_checkIfIdMatches_ReturnsTrue(): void
		{
			Assert.assertEquals(ASSET_ID, _asset.id);
		}
		
		////////////////////////////
		// Asset().priority TESTS //
		///////////////////////////
		
		[Test]
		public function priority_checkIfPriorityMatches_ReturnsTrue(): void
		{
			Assert.assertEquals(ASSET_PRIORITY, _asset.priority);
		}
		
		////////////////////////////
		// Asset().settings TESTS //
		////////////////////////////
		
		[Test]
		public function settings_checkIfSettingsMatches_ReturnsTrue(): void
		{
			Assert.assertEquals(ASSET_SETTINGS, _asset.settings);
		}
		
		///////////////////////
		// Asset().src TESTS //
		///////////////////////
		
		[Test]
		public function src_checkIfSrcMatches_ReturnsTrue(): void
		{
			Assert.assertEquals(ASSET_SRC, _asset.src);
		}
		
		////////////////////////
		// Asset().type TESTS //
		////////////////////////
		
		[Test]
		public function type_checkIfTypeMatches_ReturnsTrue(): void
		{
			Assert.assertEquals(ASSET_TYPE, _asset.type);
		}
		
		/////////////////////////////////
		// Asset().setPriority() TESTS //
		/////////////////////////////////
		
		[Test(expects="ArgumentError")]
		public function setPriority_invalidArgument_ThrowsError(): void
		{
			_asset.setPriority(null);
		}
		
		[Test]
		public function setPriority_validArgument_checkIfPriorityMatches_ReturnsTrue(): void
		{
			var newPriority:AssetLoadingPriority = AssetLoadingPriority.LOW;
			_asset.setPriority(newPriority);
			
			Assert.assertEquals(newPriority, _asset.priority);
			//TODO: teste do evento disparado pela Asset
		}
		
	}

}