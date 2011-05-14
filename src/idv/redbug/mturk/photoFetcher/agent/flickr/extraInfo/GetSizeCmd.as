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
    import com.adobe.webapis.flickr.events.FlickrResultEvent;
    
    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    
    import idv.redbug.mturk.photo.PhotoModel;
    import idv.redbug.robotbody.commands.SimpleCommand;
    
    import org.osflash.signals.Signal;
    import org.osflash.signals.natives.NativeSignal;
    
    public class GetSizeCmd extends SimpleCommand
    {
        private const SQUARE        :String = "Square";
        private const THUMBNAIL     :String = "Thumbnail";
        private const SMALL         :String = "Small";
        private const MEDIUM        :String = "Medium";
        private const MEDIUM_640    :String = "Medium 640";
        private const LARGE         :String = "Large";
        private const ORIGINAL      :String = "Original";
        
        private const TIME_OUT      :int    = 2000; 
        
        private var _flickrService          :FlickrService;
        private var _photo                  :Photo;
        private var _photoModel             :PhotoModel;
        
        private var _sgGetSizeComplete      :NativeSignal;
        private var _sgTimeoutTimer         :NativeSignal;
        private var _timeoutTimer           :Timer;
        
        public function GetSizeCmd( flickrService:FlickrService, photo:Photo, photoModel:PhotoModel, delay:Number=0 )
        {
            super(delay);
            _flickrService = flickrService;
            _photo = photo;
            _photoModel = photoModel;
         
            _timeoutTimer = new Timer( TIME_OUT )
                
            _sgGetSizeComplete = new NativeSignal( _flickrService, FlickrResultEvent.PHOTOS_GET_SIZES, FlickrResultEvent );
            _sgTimeoutTimer = new NativeSignal( _timeoutTimer, TimerEvent.TIMER, TimerEvent );
        }
        
        override final public function execute():void
        {
            trace(_photo.id);
            _sgGetSizeComplete.addOnce( onGetSizeComplete );
            _flickrService.photos.getSizes( _photo.id );
            
            _sgTimeoutTimer.addOnce( onTimeOut );
            _timeoutTimer.start();
        }
        
        private function onGetSizeComplete( event:FlickrResultEvent=null ):void
        {
            _timeoutTimer.stop();
            _timeoutTimer = null;
            
            _sgTimeoutTimer.removeAll();
            _sgTimeoutTimer = null;
            
            if ( event.success ){
                var sizeArr     :Array = event.data.photoSizes;
                var sizeObject  :PhotoSize;
                var len         :uint = sizeArr.length;
                
                for (var i:int = 0; i < sizeArr.length; ++i) 
                {
                    sizeObject = sizeArr[i];
                    
                    _photoModel.width = sizeObject.width;
                    _photoModel.height = sizeObject.height;
                    
                    //the max size of thumb nail is SMALL which is one level higher than THUMBNAIL
                    if( sizeObject.label == SMALL )
                    {
                        _photoModel.urlThumb = sizeObject.source;
                    }
                    
                    _photoModel.urlSource = sizeObject.source;
                    
                    //the max size of source pic is MEDIUM_640.
                    if( sizeObject.label == MEDIUM_640 ){
                        break;
                    }
                }
                
            } else {
                trace("Photo sizes were not recieved");
            }
            complete();
        }
        
        private function onTimeOut( event:TimerEvent ):void
        {
            _sgGetSizeComplete.removeAll();
            _sgGetSizeComplete = null;
            
            trace("get photo size timeOut!!");
            complete();
        }
    }
}