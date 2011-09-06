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
package org.vostokframework.assetmanagement.services
{
	import org.as3collections.IList;
	import org.as3utils.StringUtil;
	import org.vostokframework.VostokFramework;
	import org.vostokframework.VostokIdentification;
	import org.vostokframework.assetmanagement.AssetManagementContext;
	import org.vostokframework.assetmanagement.domain.Asset;
	import org.vostokframework.assetmanagement.domain.AssetPackage;
	import org.vostokframework.assetmanagement.domain.AssetType;
	import org.vostokframework.assetmanagement.domain.errors.AssetNotFoundError;
	import org.vostokframework.assetmanagement.domain.errors.DuplicateAssetError;
	import org.vostokframework.assetmanagement.domain.settings.AssetLoadingSettings;
	import org.vostokframework.loadingmanagement.LoadingManagementContext;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class AssetService
	{
		/**
		 * @private
		 */
		private var _context: AssetManagementContext;
		private var _loadingContext: LoadingManagementContext;
		
		/**
		 * description
		 */
		public function AssetService()
		{
			_context = AssetManagementContext.getInstance();
			_loadingContext = LoadingManagementContext.getInstance();
		}
		
		/**
		 * description
		 * 
		 * @param 	id
		 * @param 	locale
		 * @throws 	ArgumentError 	if the <code>assetId</code> argument is <code>null</code> or <code>empty</code>.
		 * @return
		 */
		public function assetExists(assetId:String, locale:String = null): Boolean
		{
			if (StringUtil.isBlank(assetId)) throw new ArgumentError("Argument <assetId> must not be null nor an empty String.");
			
			if (!locale) locale = VostokFramework.CROSS_LOCALE_ID;
			
			var identification:VostokIdentification = new VostokIdentification(assetId, locale);
			return _context.assetRepository.exists(identification);
		}

		/**
		 * description
		 * 
		 * @param src
		 * @param assetPackage
		 * @param configuration
		 * @param id
		 * @param type
		 * @throws 	ArgumentError 	if the <code>src</code> argument is <code>null</code> or <code>empty</code>.
		 * @throws 	ArgumentError 	if the <code>assetPackage</code> argument is <code>null</code>.
		 * @throws 	org.vostokframework.assetmanagement.errors.DuplicateAssetError 	if already exists an <code>Asset</code> object stored with the provided <code>assetId</code> and <code>assetPackage.locale</code>.
		 * @return
		 */
		public function createAsset(src:String, assetPackage:AssetPackage, settings:AssetLoadingSettings = null, assetId:String = null, type:AssetType = null): Asset
		{
			var asset:Asset = _context.assetFactory.create(src, assetPackage, assetId, type);
			
			try
			{
				_context.assetRepository.add(asset);
			}
			catch(error:DuplicateAssetError)
			{
				var $assetPackage:AssetPackage = _context.assetPackageRepository.findAssetPackageByAssetId(error.identification);
				
				var message:String = "There is already an Asset object stored with identification:\n";
				message += "<" + error.identification + ">\n";
				message += "It belongs to the AssetPackage:\n";
				message += "<" + $assetPackage + ">\n";
				message += "Use the method <AssetService().assetExists()> to check if an Asset object already exists.\n";
				message += "In addition, make sure you have provided the correct <assetId>, <src> and <AssetPackage> arguments:\n";
				message += "Provided <assetId>:\n";
				message += "<" + assetId + ">\n";
				message += "Provided <src>:\n";
				message += "<" + src + ">\n";
				message += "Provided <AssetPackage>:\n";
				message += "<" + assetPackage + ">\n";
				message += "Final Asset identification:\n";
				message += "<" + error.identification + ">\n";
				message += "For further information please read the documentation section about the Asset object.";
				
				throw new DuplicateAssetError(error.identification, message);
			}
			
			assetPackage.addAsset(asset);
			
			if (!settings) settings = _loadingContext.loaderFactory.defaultLoadingSettings;
			_loadingContext.assetLoadingSettingsRepository.add(asset, settings);//TODO:create test case for this line
			
			return asset;
		}

		/**
		 * description
		 * 
		 * @return
 		 */
		public function getAllAssets(): IList
		{
			return _context.assetRepository.findAll();
		}

		/**
		 * description
		 * 
		 * @param id
		 * @param locale
		 * @throws 	ArgumentError 	if the <code>assetId</code> argument is <code>null</code> or <code>empty</code>.
		 * @throws 	org.vostokframework.assetmanagement.errors.AssetNotFoundError 	if do not exist an <code>Asset</code> object stored with the provided <code>assetId</code> and <code>locale</code>.
		 * @return
		 */
		public function getAsset(assetId:String, locale:String = null): Asset
		{
			if (StringUtil.isBlank(assetId)) throw new ArgumentError("Argument <assetId> must not be null nor an empty String.");
			
			if (!locale) locale = VostokFramework.CROSS_LOCALE_ID;
			var identification:VostokIdentification = new VostokIdentification(assetId, locale);
			
			if (!assetExists(assetId, locale))
			{
				var message:String = "There is no Asset object stored with identification:\n";
				message += "<" + identification + ">.\n";
				message += "Use the method <AssetService().assetExists()> to check if an Asset object exists.\n";
				message += "In addition, make sure you have provided the correct <assetId> and <locale> arguments:\n";
				message += "Provided <assetId>: " + assetId + "\n";
				message += "Provided <locale>: " + locale + "\n";
				message += "Final Asset identification: " + identification + "\n";
				message += "For further information please read the documentation section about the Asset object.";
				
				throw new AssetNotFoundError(identification, message);
			}
			
			return _context.assetRepository.find(identification);
		}

		/**
		 * description
		 * 
		 * @return
 		 */
		public function removeAllAssets(): void
		{
			_context.assetRepository.clear();
		}

		/**
		 * description
		 * 
		 * @param id
		 * @param locale
		 * @throws 	ArgumentError 	if the <code>assetId</code> argument is <code>null</code> or <code>empty</code>.
		 * @return
		 */
		public function removeAsset(assetId:String, locale:String = null): Boolean
		{
			if (StringUtil.isBlank(assetId)) throw new ArgumentError("Argument <assetId> must not be null nor an empty String.");
			
			if (!locale) locale = VostokFramework.CROSS_LOCALE_ID;
			
			var identification:VostokIdentification = new VostokIdentification(assetId, locale);
			return _context.assetRepository.remove(identification);
		}

	}

}