/*
 * Licensed under the MIT License
 * 
 * Copyright 2011 (c) Flávio Silva, flsilva.com
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
package org.vostokframework.domain.assets
{
	import org.as3utils.StringUtil;
	import org.vostokframework.VostokIdentification;
	import org.vostokframework.domain.assets.errors.UnsupportedAssetTypeError;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class AssetFactory
	{
		/**
		 * @private
		 */
		private var _urlAssetParser:UrlAssetParser;

		public function AssetFactory()
		{
			_urlAssetParser = createUrlAssetParser();
		}

		/**
		 * description
		 * 
		 * @param src
		 * @param assetPackage
		 * @param priority
		 * @param settings
		 * @param id
		 * @param type
		 * @throws 	ArgumentError 	if the <code>src</code> argument is <code>null</code> or <code>empty</code>.
		 * @throws 	ArgumentError 	if the <code>assetPackage</code> argument is <code>null</code>.
		 * @throws 	org.vostokframework.domain.assets.errors.UnsupportedAssetType 	if the <code>type</code> argument is <code>null</code> and the framework cannot get the Asset Type over its <code>src</code> argument or the file extension in the <code>src</code> argument is not supported.
		 * @return
		 */
		public function create(src:String, assetPackage:AssetPackage, id:String = null, type:AssetType = null): Asset
		{
			if (StringUtil.isBlank(src)) throw new ArgumentError("Argument <src> must not be null nor an empty String.");
			if (!assetPackage) throw new ArgumentError("Argument <assetPackage> must not be null.");
			
			var identification:VostokIdentification = createIdentification(src, assetPackage, id);
			if (!type) type = getType(src);
			
			if (!type)
			{
				var message:String = "It was not possible to get the correct asset type over the provided <src> argument OR the provided <src> argument contains an extension that is not supported.\n";
				message += "Provided src: <" + src + ">\n";
				message += "Provided id: <" + id + ">\n";
				message += "Final identification: <" + identification + ">\n";
				message += "For further information please read the documentation section about the supported Asset types.";
				
				throw new UnsupportedAssetTypeError(identification, message);
			}
			
			return instanciate(identification, src, type);
		}
		
		/**
		 * description
		 * 
		 * @param settings
		 * @throws 	ArgumentError 	if the <code>settings</code> argument is <code>null</code>.
		 */
		public function setUrlAssetParser(parser:UrlAssetParser): void
		{
			if (!parser) throw new ArgumentError("Argument <parser> must not be null.");
			_urlAssetParser = parser;
		}
		
		/**
		 * @private
		 */
		protected function instanciate(id:VostokIdentification, src:String, type:AssetType): Asset
		{
			return new Asset(id, src, type);
		}
		
		/**
		 * @private
		 */
		protected function createIdentification(src:String, assetPackage:AssetPackage, id:String = null): VostokIdentification
		{
			if (StringUtil.isBlank(id)) id = src;
			var identification:VostokIdentification = new VostokIdentification(id, assetPackage.identification.locale);
			
			return identification;
		}
		
		/**
		 * @private
		 */
		protected function getType(src:String): AssetType
		{
			return _urlAssetParser.getAssetType(src);
		}
		
		private function createUrlAssetParser():UrlAssetParser
		{
			return new UrlAssetParser();
		}

	}

}