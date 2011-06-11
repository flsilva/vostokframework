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
package org.vostokframework.loadingmanagement.report
{
	import org.as3utils.StringUtil;
	import org.vostokframework.assetmanagement.domain.AssetIdentification;
	import org.vostokframework.assetmanagement.domain.AssetType;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class LoadedAssetReport
	{
		/**
		 * @private
		 */
		private var _bytesTotal:int;
		private var _data:*;
		private var _identification:AssetIdentification;
		private var _latency:int;
		private var _queueId:String;
		private var _src:String;
		private var _totalTime:int;
		private var _type:AssetType;
		
		public function get bytesTotal():int { return _bytesTotal; }
		
		public function set bytesTotal(value:int):void
		{
			if (value < 1) throw new ArgumentError("Value must be greater than zero. Received: <" + value + ">");
			_bytesTotal = value;
		}
		
		public function get data():* { return _data; }
		
		public function get identification():AssetIdentification { return _identification; }
		
		public function get latency():int { return _latency; }
		
		public function set latency(value:int):void
		{
			if (value < 1) throw new ArgumentError("Value must be greater than zero. Received: <" + value + ">");
			_latency = value;
		}
		
		public function get queueId():String { return _queueId; }
		
		public function get src():String { return _src; }
		
		public function get totalTime():int { return _totalTime; }
		
		public function set totalTime(value:int):void
		{
			if (value < 1) throw new ArgumentError("Value must be greater than zero. Received: <" + value + ">");
			_totalTime = value;
		}
		
		public function get type():AssetType { return _type; }
		
		/**
		 * description
		 * 
		 * @param name
		 * @param ordinal
		 */
		public function LoadedAssetReport(identification:AssetIdentification, queueId:String, data:*, type:AssetType, src:String)
		{
			if (!identification) throw new ArgumentError("Argument <identification> must not be null.");
			if (StringUtil.isBlank(queueId)) throw new ArgumentError("Argument <queueId> must not be null nor an empty String.");
			if (!data) throw new ArgumentError("Argument <data> must not be null.");
			if (!type) throw new ArgumentError("Argument <type> must not be null.");
			if (StringUtil.isBlank(src)) throw new ArgumentError("Argument <src> must not be null nor an empty String.");
			
			_identification = identification;
			_queueId = queueId;
			_data = data;
			_type = type;
			_src = src;
		}

	}

}