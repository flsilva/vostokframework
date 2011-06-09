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
	import org.vostokframework.assetmanagement.domain.Asset;
	import org.vostokframework.assetmanagement.domain.AssetManagementContext;
	import org.vostokframework.assetmanagement.domain.AssetPackage;
	import org.vostokframework.assetmanagement.domain.AssetType;
	import org.vostokframework.assetmanagement.domain.errors.AssetNotFoundError;
	import org.vostokframework.assetmanagement.domain.errors.DuplicateAssetError;
	import org.vostokframework.assetmanagement.domain.settings.AssetLoadingSettings;
	import org.vostokframework.assetmanagement.domain.utils.LocaleUtil;
	import org.vostokframework.loadingmanagement.domain.LoadPriority;

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
		
		/**
		 * description
		 */
		public function AssetService()
		{
			_context = AssetManagementContext.getInstance();
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
			
			var composedId:String = LocaleUtil.composeId(assetId, locale);
			return _context.assetRepository.exists(composedId);
		}

		/**
		 * description
		 * 
		 * @param assetId
		 * @param priority
		 * @throws 	ArgumentError 	if the <code>assetId</code> argument is <code>null</code> or <code>empty</code>.
		 * @throws 	ArgumentError 	if the <code>priority</code> argument is <code>null</code>.
		 * @throws 	org.vostokframework.assetmanagement.errors.AssetNotFoundError 	if do not exist an <code>Asset</code> object stored with the provided <code>assetId</code> and <code>locale</code>.
		 */
		public function changeAssetPriority(assetId:String, priority:LoadPriority, locale:String = null): void
		{
			if (StringUtil.isBlank(assetId)) throw new ArgumentError("Argument <assetId> must not be null nor an empty String.");
			if (!priority) throw new ArgumentError("Argument <priority> must not be null.");
			
			var asset:Asset = getAsset(assetId, locale);
			asset.setPriority(priority);
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
		public function createAsset(src:String, assetPackage:AssetPackage, priority:LoadPriority = null, settings:AssetLoadingSettings = null, assetId:String = null, type:AssetType = null): Asset
		{
			var asset:Asset = _context.assetFactory.create(src, assetPackage, priority, settings, assetId, type);
			
			try
			{
				_context.assetRepository.add(asset);
			}
			catch(error:DuplicateAssetError)
			{
				var $assetPackage:AssetPackage = _context.assetPackageRepository.findAssetPackageByAssetId(error.assetId);
				
				var message:String = "There is already an Asset object stored with id:\n";
				message += "<" + error.assetId + ">\n";
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
				message += "Final composed Asset id:\n";
				message += "<" + error.assetId + ">\n";
				message += "For further information please read the documentation section about the Asset object.";
				
				throw new DuplicateAssetError(error.assetId, message);
			}
			
			//TODO:try-catch here as above
			assetPackage.addAsset(asset);
			
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
			locale = LocaleUtil.validateLocale(locale);
			
			if (!assetExists(assetId, locale))
			{
				var message:String = "There is no Asset object stored with id:\n";
				message += "<" + LocaleUtil.composeId(assetId, locale) + ">.\n";
				message += "Use the method <AssetService().assetExists()> to check if an Asset object exists.\n";
				message += "In addition, make sure you have provided the correct <assetId> and <locale> arguments:\n";
				message += "Provided <assetId>: " + assetId + "\n";
				message += "Provided <locale>: " + locale + "\n";
				message += "Final composed Asset id: " + LocaleUtil.composeId(assetId, locale) + "\n";
				message += "For further information please read the documentation section about the Asset object.";
				
				throw new AssetNotFoundError(LocaleUtil.composeId(assetId, locale), message);
			}
			
			var composedId:String = LocaleUtil.composeId(assetId, locale);
			
			return _context.assetRepository.find(composedId);
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
			
			locale = LocaleUtil.validateLocale(locale);
			var composedId:String = LocaleUtil.composeId(assetId, locale);
			
			return _context.assetRepository.remove(composedId);
		}

	}

}