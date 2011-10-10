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

package org.vostokframework.configuration.parsers.xml
{
	import mockolate.nice;
	import mockolate.runner.MockolateRule;

	import org.as3collections.ICollection;
	import org.as3collections.IList;
	import org.flexunit.Assert;
	import org.vostokframework.configuration.AssetPackageConfiguration;
	import org.vostokframework.domain.loading.ILoadingSettingsFactory;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class AssetPackageXMLNodeParserTests
	{
		
		[Rule]
		public var mocks:MockolateRule = new MockolateRule();
		
		public var parser:AssetPackageXMLNodeParser;
		
		[Mock(inject="false")]
		public var assetXMLNodeParser:AssetXMLNodeParser;
		
		[Mock(inject="false")]
		public var loadingSettingsFactory:ILoadingSettingsFactory;
		
		[Mock(inject="false")]
		public var loadingSettingsXMLNodeParser:LoadingSettingsXMLNodeParser;
		
		public function AssetPackageXMLNodeParserTests()
		{
			
		}
		
		/////////////////////////
		// TESTS CONFIGURATION //
		/////////////////////////
		
		[Before]
		public function setUp(): void
		{
			loadingSettingsFactory = nice(ILoadingSettingsFactory);
			
			loadingSettingsXMLNodeParser = nice(LoadingSettingsXMLNodeParser, null, [loadingSettingsFactory]);
			
			assetXMLNodeParser = nice(AssetXMLNodeParser, null, [loadingSettingsXMLNodeParser]);
			
			parser = new AssetPackageXMLNodeParser(assetXMLNodeParser);
		}
		
		[After]
		public function tearDown(): void
		{
			parser = null;
		}
		
		///////////////////////////////////////
		// AssetPackageXMLNodeParser().parse //
		///////////////////////////////////////
		
		// <index><packages><package>
		
		[Test(expects="org.vostokframework.configuration.parsers.xml.errors.XMLConfigurationParserError")]
		public function parse_argumentWithPackageWithoutId_ThrowsError(): void
		{
			var xml:XML = <index><packages><package></package></packages></index>;
			
			var packagesNode:XMLList = xml.children().(name().localName == "packages");
			parser.parse(packagesNode);
		}
		
		[Test]
		public function parse_argumentWithTwoValidPackages_checkCollectionSize_ReturnsTwo(): void
		{
			var xml:XML = <index><packages><package id="package-id-1" /><package id="package-id-2" /></packages></index>;
			
			var packagesNode:XMLList = xml.children().(name().localName == "packages");
			var packages:ICollection = parser.parse(packagesNode);
			
			var size:int = packages.size();
			Assert.assertEquals(2, size);
		}
		
		[Test]
		public function parse_argumentWithPackage_verifyPackageId(): void
		{
			var xml:XML = <index><packages><package id="package-id" /></packages></index>;
			
			var packagesNode:XMLList = xml.children().(name().localName == "packages");
			var packages:IList = parser.parse(packagesNode);
			
			var packageConfiguration:AssetPackageConfiguration = packages.getAt(0);
			Assert.assertEquals("package-id", packageConfiguration.id);
		}
		
		[Test]
		public function parse_argumentWithPackage_verifyPackageLocale(): void
		{
			var xml:XML = <index><packages><package id="package-id" locale="en-us" /></packages></index>;
			
			var packagesNode:XMLList = xml.children().(name().localName == "packages");
			var packages:IList = parser.parse(packagesNode);
			
			var packageConfiguration:AssetPackageConfiguration = packages.getAt(0);
			Assert.assertEquals("en-us", packageConfiguration.locale);
		}
		
	}

}