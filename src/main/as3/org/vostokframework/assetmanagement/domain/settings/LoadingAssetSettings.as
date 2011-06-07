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
package org.vostokframework.assetmanagement.domain.settings
{

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class LoadingAssetSettings
	{
		/**
		 * description
		 */
		private var _cache:LoadingAssetCacheSettings;
		private var _extra:LoadingAssetExtraSettings;
		private var _media:LoadingAssetMediaSettings;
		private var _policy:LoadingAssetPolicySettings;
		private var _security:LoadingAssetSecuritySettings;

		public function get cache(): LoadingAssetCacheSettings { return _cache; }

		/**
		 * description
		 */
		public function get extra(): LoadingAssetExtraSettings { return _extra; }

		/**
		 * description
		 */
		public function get media(): LoadingAssetMediaSettings { return _media; }

		/**
		 * description
		 */
		public function get policy(): LoadingAssetPolicySettings { return _policy; }

		/**
		 * description
		 */
		public function get security(): LoadingAssetSecuritySettings { return _security; }
		
		/**
		 * description
		 * 
		 * @param policy
		 * @param cache
		 * @param security
		 * @param media
		 * @param extra
		 */
		public function LoadingAssetSettings(policy:LoadingAssetPolicySettings, cache:LoadingAssetCacheSettings = null, security:LoadingAssetSecuritySettings = null, media:LoadingAssetMediaSettings = null, extra:LoadingAssetExtraSettings = null)
		{
			if (!policy) throw new ArgumentError("Argument <policy> must not be null.");
			
			_policy = policy;
			_cache = cache;
			_security = security;
			_media = media;
			_extra = extra;
		}

	}

}