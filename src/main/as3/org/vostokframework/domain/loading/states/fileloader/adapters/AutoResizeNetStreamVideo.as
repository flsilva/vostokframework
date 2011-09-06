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
package org.vostokframework.loadingmanagement.domain.states.fileloader.adapters
{
	import org.vostokframework.loadingmanagement.domain.states.fileloader.FileLoadingAlgorithmMediaEvent;
	import org.vostokframework.loadingmanagement.domain.states.fileloader.IDataLoader;

	import flash.media.Video;
	import flash.net.NetStream;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class AutoResizeNetStreamVideo extends DataLoaderBehavior
	{
		
		/**
		 * description
		 * 
		 * @param loader
		 * @param request
		 * @param context
		 */
		public function AutoResizeNetStreamVideo(wrappedDataLoader:IDataLoader, netStream:NetStream)
		{
			super(wrappedDataLoader);
			
			if (!netStream) throw new ArgumentError("Argument <netStream> must not be null.");
			
			addDataLoaderListener();
		}
		
		override protected function doDispose():void
		{
			removeDataLoaderListener();
		}
		
		private function addDataLoaderListener():void
		{
			wrappedDataLoader.addEventListener(FileLoadingAlgorithmMediaEvent.META_DATA, metadataHandler, false, int.MAX_VALUE, true);
		}
		
		private function metadataHandler(event:FileLoadingAlgorithmMediaEvent):void
		{
			var width:Number = event.metadata["width"];
			var height:Number = event.metadata["height"];
			
			if (width > 0 && height > 0)
			{
				var video:Video = getData();
				
				video.width = width;
				video.height = height;
			}
			
			removeDataLoaderListener();
		}
		
		private function removeDataLoaderListener():void
		{
			wrappedDataLoader.removeEventListener(FileLoadingAlgorithmMediaEvent.META_DATA, metadataHandler, false);
		}
		
	}

}