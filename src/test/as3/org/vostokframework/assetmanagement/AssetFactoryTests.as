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
	[TestCase(order=3)]
	public class AssetFactoryTests
	{
		
		public function AssetFactoryTests()
		{
			
		}
		
		////////////////////
		// HELPER METHODS //
		////////////////////
		
		private function getFactory():AssetFactory
		{
			return new AssetFactory();
		}
		
		private function getAssetPackage():AssetPackage
		{
			return new AssetPackage("package-id", "en-US");
		}
		
		///////////////////////
		// CONSTRUCTOR TESTS //
		///////////////////////
		
		[Test]
		public function constructor_validInstantiation_ReturnsValidObject(): void
		{
			var factory:AssetFactory = new AssetFactory();
			Assert.assertNotNull(factory);
		}
		
		//////////////////////////////////////////
		// AssetFactory().defaultSettings TESTS //
		//////////////////////////////////////////
		
		[Test]
		public function defaultSettings_instanciateWithoutArgument_ReturnsValidObject(): void
		{
			var factory:AssetFactory = new AssetFactory();
			Assert.assertNotNull(factory.defaultSettings);
		}
		
		[Test]
		public function defaultSettings_instanciateWithSettings_checkIfObjectsMatch_ReturnsTrue(): void
		{
			var policy:LoadingAssetPolicySettings = new LoadingAssetPolicySettings();
			var settings:LoadingAssetSettings = new LoadingAssetSettings(policy);
			var factory:AssetFactory = new AssetFactory(settings);
			
			Assert.assertEquals(settings, factory.defaultSettings);
		}
		
		//////////////////////////////////////////
		// AssetFactory().defaultPriority TESTS //
		//////////////////////////////////////////
		
		[Test]
		public function defaultPriority_instanciateWithoutPriority_ReturnsValidObject(): void
		{
			var factory:AssetFactory = new AssetFactory();
			Assert.assertNotNull(factory.defaultPriority);
		}
		
		[Test]
		public function defaultPriority_instanciateWithPriority_checkIfObjectsMatch_ReturnsTrue(): void
		{
			var priority:AssetLoadingPriority = AssetLoadingPriority.LOW;
			var factory:AssetFactory = new AssetFactory(null, priority);
			Assert.assertEquals(priority, factory.defaultPriority);
		}
		
		///////////////////////////////////////////////
		// AssetFactory().setDefaultPriority() TESTS //
		///////////////////////////////////////////////
		
		[Test]
		public function setDefaultPriority_validArgument_checkIfObjectsMatch_ReturnTrue(): void
		{
			var priority:AssetLoadingPriority = AssetLoadingPriority.LOW;
			var factory:AssetFactory = new AssetFactory(null, priority);
			
			var priority2:AssetLoadingPriority = AssetLoadingPriority.HIGH;
			factory.setDefaultPriority(priority2);
			
			Assert.assertEquals(priority2, factory.defaultPriority);
		}
		
		///////////////////////////////////////////////
		// AssetFactory().setDefaultSettings() TESTS //
		///////////////////////////////////////////////
		
		[Test]
		public function setDefaultSettings_validArgument_checkIfObjectsMatch_ReturnsTrue(): void
		{
			var settings:LoadingAssetSettings = new LoadingAssetSettings(new LoadingAssetPolicySettings());
			var factory:AssetFactory = new AssetFactory(settings);
			
			var policy:LoadingAssetPolicySettings = new LoadingAssetPolicySettings();
			var settings2:LoadingAssetSettings = new LoadingAssetSettings(policy);
			factory.setDefaultSettings(settings2);
			
			Assert.assertEquals(settings2, factory.defaultSettings);
		}
		
		///////////////////////////////////
		// AssetFactory().create() TESTS //
		///////////////////////////////////
		
		[Test(expects="org.vostokframework.assetmanagement.errors.UnsupportedAssetTypeError")]
		public function create_unsupportedAssetType_ThrowsError(): void
		{
			var factory:AssetFactory = getFactory();
			factory.create("a.xyz", getAssetPackage());
		}
		
		[Test(expects="ArgumentError")]
		public function create_invalidAssetPackageArgument_ThrowsError(): void
		{
			var factory:AssetFactory = getFactory();
			factory.create("a.aac", null);
		}
		
		[Test]
		public function create_validArguments_ReturnsValidObject(): void
		{
			var factory:AssetFactory = getFactory();
			var asset:Asset = factory.create("a.aac", getAssetPackage());
			Assert.assertNotNull(asset);
		}
		
		[Test]
		public function create_validArgumentsWithoutAssetId_checkIfAssetIdMatches_ReturnsTrue(): void
		{
			var factory:AssetFactory = getFactory();
			var asset:Asset = factory.create("a.aac", getAssetPackage());
			Assert.assertEquals("a.aac-en-US", asset.id);
		}
		
		[Test]
		public function create_validArgumentsWithAssetId_checkIfAssetIdMatches_ReturnsTrue(): void
		{
			var factory:AssetFactory = getFactory();
			var asset:Asset = factory.create("a.aac", getAssetPackage(), null, null, "asset-id");
			Assert.assertEquals("asset-id-en-US", asset.id);
		}
		
	}

}