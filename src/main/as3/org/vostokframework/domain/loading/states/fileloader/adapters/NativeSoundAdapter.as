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
package org.vostokframework.domain.loading.states.fileloader.adapters
{
	import flash.events.IEventDispatcher;
	import flash.media.Sound;
	import flash.media.SoundLoaderContext;
	import flash.net.URLRequest;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class NativeSoundAdapter extends DataLoaderAdapter
	{
		/**
		 * @private
 		 */
		private var _context:SoundLoaderContext;
		private var _request:URLRequest;
		private var _sound:Sound;
		
		/**
		 * description
		 * 
		 * @param loader
		 * @param request
		 * @param context
		 */
		public function NativeSoundAdapter(sound:Sound, request:URLRequest, context:SoundLoaderContext = null)
		{
			if (!sound) throw new ArgumentError("Argument <sound> must not be null.");
			if (!request) throw new ArgumentError("Argument <request> must not be null.");
			
			_sound = sound;
			_request = request;
			_context = context;
		}
		
		/**
		 * description
		 */
		override protected function doCancel(): void
		{
			close();
		}
		
		override protected function doDispose():void
		{
			close();
			
			_sound = null;
			_request = null;
			_context = null;
		}
		
		override protected function doGetData():*
		{
			return _sound;
		}
		
		/**
		 * description
		 */
		override protected function doLoad(): void
		{
			_sound.load(_request, _context);
		}
		
		/**
		 * description
		 */
		override protected function doStop():void
		{
			close();
		}
		
		override protected function getLoadingDispatcher():IEventDispatcher
		{
			return _sound;
		}
		
		private function close():void
		{
			try
			{
				_sound.close();
			}
			catch (error:Error)
			{
				//do nothing
			}
		}

	}

}