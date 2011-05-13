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
package org.vostokframework.assetmanagement
{
	import org.as3coreaddendum.system.IEquatable;
	import org.as3utils.ReflectionUtil;
	import org.as3utils.StringUtil;
	import org.vostokframework.assetmanagement.settings.LoadingAssetSettings;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class Asset implements IEquatable
	{
		/**
		 * @private
		 */
		private var _id:String;
		private var _priority:AssetLoadingPriority;
		private var _settings:LoadingAssetSettings;
		private var _src:String;
		private var _type:AssetType;

		/**
		 * description
		 */
		public function get id(): String { return _id; }

		/**
		 * description
		 */
		public function get priority(): AssetLoadingPriority { return _priority; }

		/**
		 * description
		 */
		public function get settings(): LoadingAssetSettings { return _settings; }

		/**
		 * description
		 */
		public function get src(): String { return _src; }

		/**
		 * description
		 */
		public function get type(): AssetType { return _type; }

		/**
		 * description
		 * 
		 * @param id
		 * @param src
		 * @param type    type
		 * @param configuration
		 * @param priority
		 * @throws 	ArgumentError 	if the <code>id</code> argument is <code>null</code> or <code>empty</code>.
		 * @throws 	ArgumentError 	if the <code>src</code> argument is <code>null</code> or <code>empty</code>.
		 * @throws 	ArgumentError 	if the <code>type</code> argument is <code>null</code>.
		 * @throws 	ArgumentError 	if the <code>src</code> argument is <code>null</code>.
		 */
		public function Asset(id:String, src:String, type:AssetType, priority:AssetLoadingPriority, settings:LoadingAssetSettings = null)
		{
			if (StringUtil.isBlank(id)) throw new ArgumentError("Argument <id> must not be null nor an empty String.");
			if (StringUtil.isBlank(src)) throw new ArgumentError("Argument <src> must not be null nor an empty String.");
			if (!type) throw new ArgumentError("Argument <type> must not be null.");
			if (!priority) throw new ArgumentError("Argument <priority> must not be null.");
			
			_id = id;
			_src = src;
			_type = type;
			_priority = priority;
			_settings = settings;
		}
		
		public function equals(other : *): Boolean
		{
			if (this == other) return true;
			if (!(other is Asset)) return false;
			
			var otherAsset:Asset = other as Asset;
			return id == otherAsset.id;
		}

		/**
		 * description
		 * 
		 * @param priority
		 * @throws 	ArgumentError 	if the <code>priority</code> argument is <code>null</code>.
		 */
		public function setPriority(priority:AssetLoadingPriority): void
		{
			if (!priority) throw new ArgumentError("Argument <priority> must not be null.");
			_priority = priority;
			//TODO: disparar evento
		}
		
		/**
		 * description
		 * 
		 * @return
		 */
		public function toString(): String
		{
			return "[" + ReflectionUtil.getClassName(this) + " id<" + id + ">]";
		}

	}

}