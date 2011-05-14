/*******************************************
 * author	: Redbug
 * e-mail	: l314kimo@gmail.com
 * blog		: http://redbug0314.blogspot.com
 * purpose	:		
 *******************************************/

package
{
    import flash.display.Sprite;
    import flash.events.IOErrorEvent;
    import flash.net.URLRequest;
    
    import mx.core.BitmapAsset;
    
    import org.bytearray.gif.events.GIFPlayerEvent;
    import org.bytearray.gif.player.GIFPlayer;
    
    //This Class is deprecated due to the bad performance of the gif player 
    public class Preloader extends Sprite
    {
        private var _request :URLRequest;
        private var _player  :GIFPlayer;
        
        public function Preloader()
        {
            super();
        
            _request = new URLRequest("/media/gif/loading.gif");
            _player = new GIFPlayer();
            
            addChild(_player);
            _player.load(_request);
            
            _player.addEventListener ( IOErrorEvent.IO_ERROR, onIOError, false, 0, true );
            _player.addEventListener ( GIFPlayerEvent.COMPLETE, onCompleteGIFLoad, false, 0, true );
        }
        
        public function destroy():void
        {
            _player.stop();
            _player.removeEventListener( GIFPlayerEvent.COMPLETE, onCompleteGIFLoad );
            _player.removeEventListener( IOErrorEvent.IO_ERROR, onIOError );
            _player = null;
        }
        
        private function onIOError( event:IOErrorEvent ):void
        {
            trace( "IOError:", event.text );        
        }
        
        private function onCompleteGIFLoad( event:GIFPlayerEvent ):void
        {
            _player.play();
        }
        
    }
}