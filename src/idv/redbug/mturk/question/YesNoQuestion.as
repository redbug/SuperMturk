/*******************************************
 * author	: Redbug
 * e-mail	: l314kimo@gmail.com
 * blog		: http://redbug0314.blogspot.com
 * purpose	:		
 *******************************************/

package idv.redbug.mturk.question
{
    import fl.controls.RadioButton;
    import fl.controls.RadioButtonGroup;
    
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    
    import idv.redbug.robotbody.util.Toolkits;

    public class YesNoQuestion
    {
        public static const QUESTION_YES      :uint = 1;
        public static const QUESTION_NO       :uint = 0;

        private const SPACE :uint = 20;
        private const COLOR :Object = 0xFF3366;
        private const WIDTH :int = 150;
        
        protected var _next_question     :YesNoQuestion;
        protected var _question_txt      :TextField;
        protected var _hint_txt          :TextField;
        
        protected var _rbtn_yes          :RadioButton;
        protected var _rbtn_no           :RadioButton;
        protected var _rbtn_group        :RadioButtonGroup;
        
        private var _answer              :uint;
        private var _container           :Sprite;
        private var _completeHandler     :Function;
        private var _haltHandler         :Function;

        public function YesNoQuestion( question:String, answer:uint, container:Sprite, completeHandler:Function, haltHandler:Function )
        {
            _question_txt = new TextField();
            
            _question_txt.defaultTextFormat = new TextFormat( null, 12, COLOR, true );
            _question_txt.text = question;
            _question_txt.width = WIDTH;
            _question_txt.autoSize = TextFieldAutoSize.LEFT;
            _question_txt.wordWrap = true;            
            
            _hint_txt = new TextField();
            _hint_txt.defaultTextFormat = new TextFormat('Arial', 10, 0x000000, true);
            _hint_txt.text = "Done.";
            _hint_txt.autoSize = TextFieldAutoSize.LEFT;
            _hint_txt.wordWrap = true;
            _hint_txt.visible = false;
            _hint_txt.width = WIDTH;
            
            
            _rbtn_yes = new RadioButton();
            _rbtn_no = new RadioButton();
            _rbtn_group = new RadioButtonGroup( question );
            
            _rbtn_yes.label = "Yes";
            _rbtn_yes.value = YesNoQuestion.QUESTION_YES;
            
            _rbtn_no.label = "No";
            _rbtn_no.value = YesNoQuestion.QUESTION_NO;
            _rbtn_yes.group = _rbtn_no.group = _rbtn_group;
            _rbtn_group.addEventListener( MouseEvent.CLICK, questionHandler );
            
            _answer = answer;
            _container = container;
            _completeHandler = completeHandler;
            _haltHandler = haltHandler;
        }

        public function process():void
        {
            _question_txt.y = SPACE;
            _rbtn_yes.move( 0, _question_txt.y + _question_txt.height );
            _rbtn_no.move( 0, _rbtn_yes.y + SPACE );
            
            _hint_txt.x = 0;
            _hint_txt.y = _rbtn_no.y + SPACE;
            
            _container.addChild( _question_txt );
            _container.addChild( _rbtn_yes );
            _container.addChild( _rbtn_no );
            _container.addChild( _hint_txt );
        }
        
        private function questionHandler( event:Event ):void
        {
            if( event.target.selection.value == _answer )
            {
                Toolkits.removeAllChildren( _container );
                
                if( _next_question ){
                    _next_question.process();
                }
                else{
                    _completeHandler();
                }
            }
            else{
                _haltHandler();
                _hint_txt.visible = true;
            }
        }        
        
        public function get question_txt():TextField
        {
            return _question_txt;
        }

        public function set question_txt(value:TextField):void
        {
            _question_txt = value;
        }

        public function get next_question():YesNoQuestion
        {
            return _next_question;
        }

        public function set next_question(value:YesNoQuestion):void
        {
            _next_question = value;
        }

        public function get answer():uint
        {
            return _answer;
        }

        public function set answer(value:uint):void
        {
            _answer = value;
        }

    }
}