/*******************************************
 * author	: Redbug
 * e-mail	: l314kimo@gmail.com
 * blog		: http://redbug0314.blogspot.com
 * purpose	:		
 *******************************************/

package idv.redbug.mturk.photoFetcher.agent.flickr.extraInfo
{
    import com.adobe.webapis.flickr.FlickrService;
    import com.adobe.webapis.flickr.Photo;
    import com.adobe.webapis.flickr.PhotoSize;
    import com.adobe.webapis.flickr.PhotoTag;
    import com.adobe.webapis.flickr.events.FlickrResultEvent;
    
    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    
    import idv.redbug.mturk.photo.PhotoModel;
    import idv.redbug.robotbody.commands.SimpleCommand;
    
    import org.osflash.signals.Signal;
    import org.osflash.signals.natives.NativeSignal;
    
    public class GetInfoCmd extends SimpleCommand
    {
        private const TIME_OUT      :int    = 2000; 
        
        private var _flickrService          :FlickrService;
        private var _photo                  :Photo;
        private var _photoModel             :PhotoModel;
        
        private var _sgGetInfoComplete      :NativeSignal;
        private var _sgTimeoutTimer         :NativeSignal;
        private var _timeoutTimer           :Timer;
        
        public function GetInfoCmd( flickrService:FlickrService, photo:Photo, photoModel:PhotoModel, delay:Number=0 )
        {
            super(delay);
            _flickrService = flickrService;
            _photo = photo;
            _photoModel = photoModel;
            
            _timeoutTimer = new Timer( TIME_OUT )
            
            _sgGetInfoComplete = new NativeSignal( _flickrService, FlickrResultEvent.PHOTOS_GET_INFO, FlickrResultEvent );
            _sgTimeoutTimer = new NativeSignal( _timeoutTimer, TimerEvent.TIMER, TimerEvent );
        }
        
        override final public function execute():void
        {
            trace(_photo.id);
            _sgGetInfoComplete.addOnce( onGetInfoComplete );
            _flickrService.photos.getInfo( _photo.id );
            
            _sgTimeoutTimer.addOnce( onTimeOut );
            _timeoutTimer.start();
        }
        
        private function onGetInfoComplete( event:FlickrResultEvent=null ):void
        {
            _timeoutTimer.stop();
            _timeoutTimer = null;
            
            _sgTimeoutTimer.removeAll();
            _sgTimeoutTimer = null;
            
            if (event.success){
                var photoInfo:Photo = event.data.photo;
                
                var tags:String = new String();
                var cnt:int = 1;

                for each( var tag:PhotoTag in photoInfo.tags)
                {
                    tags += tag.raw + "，"
                    
                    if( cnt % 3 == 0 ){
                        tags += "\n";
                    }
                    cnt++;
                }
                
                _photoModel.tags = tags;
                
            } else {
                trace("Photo info were not recieved");
            }

            complete();
        }
        
        private function onTimeOut( event:TimerEvent ):void
        {
            _sgGetInfoComplete.removeAll();
            _sgGetInfoComplete = null;
            
            trace("get photo info timeOut!!");
            complete();
        }
    }
}