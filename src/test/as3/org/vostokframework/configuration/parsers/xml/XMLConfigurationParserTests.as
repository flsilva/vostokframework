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
	import mockolate.mock;
	import mockolate.nice;
	import mockolate.runner.MockolateRule;
	import mockolate.verify;

	import org.flexunit.Assert;
	import org.vostokframework.configuration.VostokFrameworkConfiguration;
	import org.vostokframework.domain.loading.ILoadingSettingsFactory;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class XMLConfigurationParserTests
	{
		
		[Rule]
		public var mocks:MockolateRule = new MockolateRule();
		
		public var parser:XMLConfigurationParser;
		
		[Mock(inject="false")]
		public var assetParser:AssetXMLNodeParser;
		
		[Mock(inject="false")]
		public var assetPackageParser:AssetPackageXMLNodeParser;
		
		[Mock(inject="false")]
		public var loadingSettingsFactory:ILoadingSettingsFactory;
		
		[Mock(inject="false")]
		public var settingsParser:LoadingSettingsXMLNodeParser;
		
		public function XMLConfigurationParserTests()
		{
			
		}
		
		/////////////////////////
		// TESTS CONFIGURATION //
		/////////////////////////
		
		[Before]
		public function setUp(): void
		{
			loadingSettingsFactory = nice(ILoadingSettingsFactory);
			settingsParser = nice(LoadingSettingsXMLNodeParser, null, [loadingSettingsFactory]);
			
			assetParser = nice(AssetXMLNodeParser, null, [settingsParser]);
			assetPackageParser = nice(AssetPackageXMLNodeParser, null, [assetParser]);
			
			parser = new XMLConfigurationParser(assetPackageParser, settingsParser, loadingSettingsFactory);
		}
		
		[After]
		public function tearDown(): void
		{
			parser = null;
		}
		
		/////////////////////////////////////
		// XMLConfigurationParser().parse //
		/////////////////////////////////////
		
		// <index><default-settings>
		
		[Test(expects="ArgumentError")]
		public function parse_invalidNullArgument_ThrowsError(): void
		{
			parser.parse(null);
		}
		
		[Test(expects="ArgumentError")]
		public function parse_invalidArgumentDataType_ThrowsError(): void
		{
			parser.parse(new Object());
		}
		
		[Test]
		public function parse_validArgument_ReturnsValidObject(): void
		{
			var xml:XML = <index></index>;
			
			var configuration:VostokFrameworkConfiguration = parser.parse(xml);
			Assert.assertNotNull(configuration);
		}
		
		[Test]
		public function parse_argumentWithDefaultSettings_verifyIfSentDefaultSettingsNodeCorrectlyToStubParser(): void
		{
			var xml:XML = <index><default-settings><kill-external-cache>true</kill-external-cache></default-settings></index>;
			
			mock(settingsParser).method("parse").args(<default-settings><kill-external-cache>true</kill-external-cache></default-settings>).once();
			parser.parse(xml);
			verify(settingsParser);
		}
		
		[Test]
		public function parse_argumentWithPackages_verifyIfSentPackagesNodeCorrectlyToStubParser(): void
		{
			var xml:XML = <index><packages><package id="package-1"><asset id="asset-1" /><asset id="asset-2" /></package></packages></index>;
			
			mock(assetPackageParser).method("parse").args(<packages><package id="package-1"><asset id="asset-1" /><asset id="asset-2" /></package></packages>).once();
			parser.parse(xml);
			verify(assetPackageParser);
		}
		
	}

}