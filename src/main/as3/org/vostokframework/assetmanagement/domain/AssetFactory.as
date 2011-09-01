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
package org.vostokframework.assetmanagement.domain
{
	import org.as3utils.StringUtil;
	import org.vostokframework.VostokIdentification;
	import org.vostokframework.assetmanagement.domain.errors.UnsupportedAssetTypeError;
	import org.vostokframework.assetmanagement.domain.settings.AssetLoadingCacheSettings;
	import org.vostokframework.assetmanagement.domain.settings.AssetLoadingExtraSettings;
	import org.vostokframework.assetmanagement.domain.settings.AssetLoadingMediaSettings;
	import org.vostokframework.assetmanagement.domain.settings.AssetLoadingPolicySettings;
	import org.vostokframework.assetmanagement.domain.settings.AssetLoadingSecuritySettings;
	import org.vostokframework.assetmanagement.domain.settings.AssetLoadingSettings;
	import org.vostokframework.loadingmanagement.domain.LoadPriority;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class AssetFactory
	{
		/**
		 * description
		 */
		private var _defaultPriority:LoadPriority;
		
		/**
		 * description
		 */
		private var _defaultSettings:AssetLoadingSettings;
		
		/**
		 * description
		 */
		private var _urlAssetParser:UrlAssetParser;

		/**
		 * description
		 */
		public function get defaultPriority(): LoadPriority { return _defaultPriority; }
		
		/**
		 * description
		 */
		public function get defaultSettings(): AssetLoadingSettings { return _defaultSettings; }

		public function AssetFactory(defaultSettings:AssetLoadingSettings = null, defaultPriority:LoadPriority = null)
		{
			if (!defaultSettings) defaultSettings = createDefaultSettings();
			setDefaultSettings(defaultSettings);
			
			if (!defaultPriority) defaultPriority = createDefaultPriority();
			setDefaultPriority(defaultPriority);
			
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
		 * @throws 	org.vostokframework.assetmanagement.domain.errors.UnsupportedAssetType 	if the <code>type</code> argument is <code>null</code> and the framework cannot get the Asset Type over its <code>src</code> argument or the file extension in the <code>src</code> argument is not supported.
		 * @return
		 */
		public function create(src:String, assetPackage:AssetPackage, priority:LoadPriority = null, settings:AssetLoadingSettings = null, id:String = null, type:AssetType = null): Asset
		{
			if (StringUtil.isBlank(src)) throw new ArgumentError("Argument <src> must not be null nor an empty String.");
			if (!assetPackage) throw new ArgumentError("Argument <assetPackage> must not be null.");
			
			if (!priority) priority = _defaultPriority;
			if (!settings) settings = _defaultSettings;
			
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
			
			return instanciate(identification, src, type, priority, settings);
		}

		/**
		 * description
		 * 
		 * @param settings
		 * @throws 	ArgumentError 	if the <code>priority</code> argument is <code>null</code>.
		 */
		public function setDefaultPriority(priority:LoadPriority): void
		{
			if (!priority) throw new ArgumentError("Argument <priority> must not be null.");
			_defaultPriority = priority;
		}

		/**
		 * description
		 * 
		 * @param settings
		 * @throws 	ArgumentError 	if the <code>settings</code> argument is <code>null</code>.
		 */
		public function setDefaultSettings(settings:AssetLoadingSettings): void
		{
			if (!settings) throw new ArgumentError("Argument <settings> must not be null.");
			_defaultSettings = settings;
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
		protected function instanciate(id:VostokIdentification, src:String, type:AssetType, priority:LoadPriority, settings:AssetLoadingSettings): Asset
		{
			return new Asset(id, src, type, priority, settings);
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
		
		/**
		 * @private
		 */
		private function createDefaultPriority(): LoadPriority
		{
			return LoadPriority.MEDIUM;
		}
		
		/**
		 * @private
		 */
		private function createDefaultSettings(): AssetLoadingSettings
		{
			var cache:AssetLoadingCacheSettings = new AssetLoadingCacheSettings();
			var extra:AssetLoadingExtraSettings = new AssetLoadingExtraSettings();
			var media:AssetLoadingMediaSettings = new AssetLoadingMediaSettings();
			var policy:AssetLoadingPolicySettings = new AssetLoadingPolicySettings();
			var security:AssetLoadingSecuritySettings = new AssetLoadingSecuritySettings();
			
			cache.allowInternalCache = true;
			cache.killExternalCache = false;
			
			media.autoCreateVideo = false;
			media.autoResizeVideo = false;
			media.autoStopStream = false;
			
			policy.latencyTimeout = 12000;
			policy.maxAttempts = 2;
			
			var settings:AssetLoadingSettings = new AssetLoadingSettings();
			settings.cache = cache;
			settings.extra = extra;
			settings.media = media;
			settings.policy = policy;
			settings.security = security;
			
			return settings;
		}
		
		private function createUrlAssetParser():UrlAssetParser
		{
			return new UrlAssetParser();
		}

	}

}