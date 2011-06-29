/*******************************************
 * author	: Redbug
 * e-mail	: l314kimo@gmail.com
 * blog		: http://redbug0314.blogspot.com
 * purpose	:		
 *******************************************/

package idv.redbug.mturk.photo
{
    import fl.controls.RadioButton;
    import fl.controls.RadioButtonGroup;
    import fl.motion.Color;
    
    import flash.display.Bitmap;
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.text.StyleSheet;
    import flash.text.TextColorType;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    
    import idv.redbug.mturk.question.YesNoQuestion;
    import idv.redbug.robotbody.util.Toolkits;
    
    import org.osflash.signals.Signal;
    
    public class PhotoSprite extends Sprite
    {
        private const MAX_DESCRIPTION   :uint = 150;

        private const SPACE             :uint = 20;
        
        private var _model              :PhotoModel;
        private var _bitmap             :DisplayObject;
        private var _title_txt          :TextField;
        private var _tags_txt           :TextField;
        private var _description_txt    :TextField;
        private var _reference_txt      :TextField;
        private var _hint_txt           :TextField;
        
        private var _ct_restaurant_rb   :RadioButton;
        private var _ct_dish_rb         :RadioButton; 
        private var _ct_logo_rb         :RadioButton;
        private var _ct_none_rb         :RadioButton;
        private var _ct_rb_group        :RadioButtonGroup;
        
        private var _q_is_related       :YesNoQuestion;
        private var _q_has_any_person   :YesNoQuestion;
        
        private var _box                :Sprite; 
        private var _index              :int;
        
        private var _sgSelected         :Signal;
        
        public function PhotoSprite( bitmap:DisplayObject, model:PhotoModel, index:int)
        {
            _model = model;
            _bitmap = bitmap;
            _index = index;
            _sgSelected = new Signal( int );
            
            makeUI();
            this.addEventListener( Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true );	//removed in onAddedToStage()
        }
        
        private function makeURL( url:String, value:String):String
        {
            if(url != ""){
                return "<u><a href='" + url + "' target='_blank'>" + value + "</a></u>";
            }
            else{
                return "This url doesn't exist!!"; 
            }
        }
        
        private function onAddedToStage( event:Event ):void
        {
            this.removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );	
        }
        
        private function makeUI():void
        {
            var width   :int = 150;
            var x       :int = 0;
            var y       :int = 0;
            
            var center:TextFormat = new TextFormat();
            center.align="center";
            
            var color = 0xFF3366;
            
            //--  title --//
            _title_txt = new TextField();
            _title_txt.htmlText = "Photo Title:"
            _title_txt.setTextFormat( new TextFormat(null, null, color, true) );
            _title_txt.htmlText += "\n" + _model.title;
            _title_txt.setTextFormat(center);
            _title_txt.width = width;
            _title_txt.x = x;
            _title_txt.y = y;
            _title_txt.autoSize = TextFieldAutoSize.CENTER
            _title_txt.wordWrap = true;
            
            //-- Hint text --//
            _hint_txt = new TextField();
            _hint_txt.defaultTextFormat = new TextFormat('Arial', 10, 0x000000, true);
            _hint_txt.text = "Done.";
            _hint_txt.autoSize = TextFieldAutoSize.LEFT;
            _hint_txt.wordWrap = true;
            _hint_txt.visible = false;
            _hint_txt.width = width;
            
            //--  restaurant photo --//
            _bitmap.x = ( width - _bitmap.width ) >> 1;
            _bitmap.y = _title_txt.height;
            
            
            //-- reference url --//
            var css:StyleSheet = new StyleSheet();
            
            var linkStyle:Object = { 
                color:"#0000FF",
                textAlign:"center"
            };
            css.setStyle("a", linkStyle);
            
            var reference_wraper:Sprite = new Sprite();
            reference_wraper.buttonMode = true;
            reference_wraper.useHandCursor = true;
            
            _reference_txt = new TextField();
            _reference_txt.styleSheet = css;
            _reference_txt.text = makeURL( _model.urlOwner, "view source page");
            _reference_txt.width = width;
            _reference_txt.x = x;
            _reference_txt.y = _bitmap.y + _bitmap.height;
            _reference_txt.autoSize = TextFieldAutoSize.CENTER;
            _reference_txt.wordWrap = true;
            reference_wraper.addChild(_reference_txt );
            
            
            //-- radio buttons - content type --//
            _ct_restaurant_rb = new RadioButton();
            _ct_dish_rb = new RadioButton();
            _ct_logo_rb = new RadioButton();
            _ct_none_rb = new RadioButton();
            _ct_rb_group = new RadioButtonGroup("ct_group");
            
            _ct_restaurant_rb.label = "Restaurant"; 
            _ct_restaurant_rb.value = PhotoModel.CT_RESTAURANT;
            
            _ct_dish_rb.label = "Dish"; 
            _ct_dish_rb.value = PhotoModel.CT_DISH;
            
            _ct_logo_rb.label = "Logo"; 
            _ct_logo_rb.value = PhotoModel.CT_LOGO;
            
            _ct_none_rb.label = "None of the above";
            _ct_none_rb.value = PhotoModel.CT_NONE;
            _ct_none_rb.width = 130;
            
            _ct_restaurant_rb.group = _ct_dish_rb.group = _ct_logo_rb.group = _ct_none_rb.group = _ct_rb_group;

            
            y = _bitmap.y + _bitmap.height;
            
            //-----  Box ------//
            _box = new Sprite();
            _box.x = x;
            _box.y = y + SPACE;
            
            var contentType:int = _model.contentType; 


            /******************************
             * Question: is_related
             ******************************/
            question = "Is there any person in this photo?";
            _q_has_any_person = new YesNoQuestion( question, YesNoQuestion.QUESTION_NO, _box, addCTRadioButtons, haltHandlerForYesNoQuestion );            

            /******************************
             * Question: is_related
             ******************************/
            var question:String = "Is this photo related to the designated restaurant?"
            _q_is_related = new YesNoQuestion(question, YesNoQuestion.QUESTION_YES, _box, addCTRadioButtons, haltHandlerForYesNoQuestion);
            
            _q_has_any_person.next_question = _q_is_related; 
            
            
            //-- tags --//
            _tags_txt = new TextField();
            _tags_txt.text = "Tags: \n";
            _tags_txt.setTextFormat( new TextFormat(null, null, color, true) );
            
            var tags:String = _model.tags;
            tags = (tags == "")? "None.":tags;
                
            _tags_txt.appendText( tags );
            _tags_txt.width = width;
            _tags_txt.autoSize = TextFieldAutoSize.CENTER
            _tags_txt.wordWrap = true;
            
            
            //-- description --//
            _description_txt = new TextField();
            _description_txt.text = "Description: \n";
            _description_txt.setTextFormat( new TextFormat(null, null, color, true) );
            
            var description:String;
            if( model.from == "F" ){
                description = _model.description.substr(0, MAX_DESCRIPTION); 
                description = ( description == "" )? "None.":description + "...";
            } else{
                description = _model.description;
                description = ( description == "" )? "None.":description;
            }
            
            _description_txt.appendText( description );
            _description_txt.width = width;
            _description_txt.autoSize = TextFieldAutoSize.CENTER
            _description_txt.wordWrap = true;

            
            //review mode
            if( contentType != -1 )
            {
                switch( contentType ){
                    case PhotoModel.CT_NONE:
                        _ct_none_rb.selected = true;
                        break;
                    case PhotoModel.CT_RESTAURANT:
                        _ct_restaurant_rb.selected = true;
                        break;
                    case PhotoModel.CT_DISH:
                        _ct_dish_rb.selected = true;
                        break;
                    case PhotoModel.CT_LOGO:
                        _ct_logo_rb.selected = true;
                        break;
                }
                addCTRadioButtons();
            }
            //normal mode
            else{
                addPreQuestion();
            }
            
            this.addChild( _title_txt );
            this.addChild( _bitmap );
            this.addChild( _box ); 
            this.addChild( _hint_txt );
            this.addChild( _tags_txt );
            this.addChild( _description_txt );
            this.addChild( reference_wraper );
        }
        
        private function haltHandlerForYesNoQuestion():void
        {
            _ct_none_rb.selected = true;
            _model.contentType = PhotoModel.CT_NONE;
            _sgSelected.dispatch( _index );
        }
        
        
        private function addCTRadioButtons( ):void
        {
            _ct_restaurant_rb.move(0, 0); 
            _ct_dish_rb.move(0, _ct_restaurant_rb.y + SPACE); 
            _ct_logo_rb.move(0, _ct_dish_rb.y + SPACE); 
            _ct_none_rb.move(0, _ct_logo_rb.y + SPACE);
            
            _box.addChild( _ct_restaurant_rb );
            _box.addChild( _ct_dish_rb );
            _box.addChild( _ct_logo_rb );
            _box.addChild( _ct_none_rb );
            
            _hint_txt.x = _box.x;
            _hint_txt.y = _box.y + (_box.height >> 1);
            
            _tags_txt.x = _box.x;
            _tags_txt.y = _hint_txt.y + SPACE;

            _description_txt.x = _box.x;
            _description_txt.y = _tags_txt.y + _tags_txt.height + SPACE;
            
            _ct_rb_group.addEventListener( MouseEvent.CLICK, onClickRadioButton );
        }
        
        private function addPreQuestion():void
        {
            _q_has_any_person.process();
            
            _tags_txt.x = _box.x;
            _tags_txt.y = _box.y + (_box.height >> 1) + SPACE * 2;
            _description_txt.x = _box.x;
            _description_txt.y = _tags_txt.y + _tags_txt.height + SPACE;
        }
        
        private function onClickRadioButton(event:Event):void
        {
            _model.contentType = event.target.selection.value;
            _sgSelected.dispatch( _index );
            
            _hint_txt.visible = true;
        }
        
        public function get bitmap():DisplayObject
        {
            return _bitmap;
        }
        
        public function set bitmap( value:DisplayObject ):void
        {
            _bitmap = value;
        }

        public function get model():PhotoModel
        {
            return _model;
        }

        public function set model(value:PhotoModel):void
        {
            _model = value;
        }

        public function get sgSelected():Signal
        {
            return _sgSelected;
        }

        public function set sgSelected(value:Signal):void
        {
            _sgSelected = value;
        }

        public function get index():int
        {
            return _index;
        }

        public function set index(value:int):void
        {
            _index = value;
        }

    }
}