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
package org.vostokframework.configuration
{
	import org.vostokframework.domain.assets.AssetType;
	import org.vostokframework.domain.loading.settings.LoadingSettings;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class AssetConfiguration
	{
		private var _id:String;
		private var _src:String;
		private var _settings:LoadingSettings;
		private var _type:AssetType;
		
		/**
		 * description
		 */
		public function get id(): String { return _id; }
		
		/**
		 * description
		 */
		public function get src(): String { return _src; }
		
		/**
		 * description
		 */
		public function get settings(): LoadingSettings { return _settings; }
		
		/**
		 * description
		 */
		public function get type(): AssetType { return _type; }

		/**
		 * description
		 * 
		 * @param id
		 * @param locale
		 * @throws 	ArgumentError 	if the <code>id</code> argument is <code>null</code> or <code>empty</code>.
		 * @throws 	ArgumentError 	if the <code>locale</code> argument is <code>null</code> or <code>empty</code>.
		 */
		public function AssetConfiguration(src:String, type:AssetType = null, settings:LoadingSettings = null, id:String = null)
		{
			_src = src;
			_type = type;
			_settings = settings;
			_id = id;
		}

	}

}