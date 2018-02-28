//
//  OMCChatVC.swift
//  ChatBots
//
//  Created by Jay Vachhani on 11/11/16.
//  Copyright © 2016 Oracle. All rights reserved.
//

import UIKit
import Speech
import CoreLocation

struct UserCurrLocation {
    static var currLoc:CLLocationCoordinate2D = CLLocationCoordinate2D.init()
}
open class OMCChatVC: UIViewController, UITextFieldDelegate, SFSpeechRecognizerDelegate {
    
    @IBOutlet weak var txtChat: UITextView!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var btnVoice: UIButton!
    @IBOutlet weak var chatScrollView: UIScrollView!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var floorConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewRecord: UIView!
    @IBOutlet weak var btnRecordHold: UIButton!
    
    var typingImgView:UIImageView?
    
    var selectedImage : UIImage?
    var lastChatBubbleY: CGFloat = 9.9
    var internalPadding: CGFloat = 9.9
    var lastMessageType: OMCChatBubbleType?
    var sendTapped:Bool = false
    
    var originalSize:CGSize?
    
    let audioUrl:String = "https://raw.githubusercontent.com/fbsamples/messenger-platform-samples/master/node/public/assets/sample.mp3"
    // {"from":{"type":"bot","id":"8519E87B-FE8E-44C0-92C0-D716E962750B"},"body":{"messagePayload":{"attachment":{"type":"audio","url":"https://raw.githubusercontent.com/fbsamples/messenger-platform-samples/master/node/public/assets/sample.mp3"},"type":"attachment"},"userId":"IBCSoVyV"}}

    let videoUrl:String = "https://raw.githubusercontent.com/fbsamples/messenger-platform-samples/master/node/public/assets/allofus480.mov"
    // {"from":{"type":"bot","id":"8519E87B-FE8E-44C0-92C0-D716E962750B"},"body":{"messagePayload":{"attachment":{"type":"video","url":"https://raw.githubusercontent.com/fbsamples/messenger-platform-samples/master/node/public/assets/allofus480.mov"},"type":"attachment"},"userId":"IBCSoVyV"}}
    
    
    var locationManager = CLLocationManager()

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    //private var CBManager.sharedInstance.recognitionRequest: SFSpeechAudioBufferCBManager.sharedInstance.recognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = OMCBotManager.sharedInstance.audioEngine;
    
    //MARK:-
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.navigationItem.title = UserDefaults.standard.object(forKey: kBotName) as? String;

        //   txtChat.delegate = self;
        self.txtChat.layer.borderWidth = 0.9
        self.txtChat.layer.borderColor = UIColor.lightGray.cgColor;
        self.txtChat.layer.cornerRadius = 10.0
        
        originalSize = self.chatScrollView.contentSize

        NotificationCenter.default.addObserver(self, selector: #selector(OMCChatVC.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(OMCChatVC.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
       // self.txtChat.becomeFirstResponder();
        self.viewRecord.isHidden = true
        //        self.btnRecordHold.setBackgroundImage(UIImage.init(named: "micEnabled.png") , for: UIControlState.highlighted)
        self.btnRecordHold.setImage(UIImage.init(named: "micEnabled.png") , for: UIControlState.highlighted)
        self.btnRecordHold.setImage(UIImage.init(named: "mic.png") , for: UIControlState.normal)
        self.btnRecordHold.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        
        NotificationCenter.default.addObserver(self, selector: #selector(OMCChatVC.handleNewMessege(_:)), name: NSNotification.Name(rawValue: kNewMessegeReceived), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(OMCChatVC.sendAndAddMyChat(_:)), name: NSNotification.Name(rawValue: kchoiceSelectedOrChatEntered), object: nil)
        
        moveScrollView(constant: 5.0)
    }
    
    func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        lockOrientation(.all)
    }
    
    @IBAction func resetTapped(_ sender: Any) {
   
        OMCBotManager.sharedInstance.synth?.stopSpeaking(at: .immediate);
        OMCBotManager.sharedInstance.synth = nil;

        print("Resetting chat view")
        
        if audioEngine.isRunning {
            audioEngine.stop()
            OMCBotManager.sharedInstance.recognitionRequest?.endAudio()
            btnVoice.isEnabled = true
            btnVoice.setBackgroundImage(UIImage.init(named: "mic.png"), for: UIControlState.normal)
            if( audioEngine.inputNode != nil ){
                audioEngine.inputNode?.removeTap(onBus: 0)
            }
        }
        
        self.txtChat.text = ""
        
        for aView:UIView in self.chatScrollView.subviews {
            aView.removeFromSuperview()
        }
        
        self.chatScrollView.contentSize = originalSize!
        
        moveToLastMessage()
        
        let defaults = UserDefaults.standard
        let rStr = OMCBotManager.sharedInstance.randomString(length: 4);
        defaults.set(rStr, forKey: kUsername)
        defaults.synchronize()
        
        OMCBotManager.sharedInstance.disconnectWS()
        
        let appDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate;
        appDel.establishWSConnection();
        
        txtChat.resignFirstResponder()
    }
   
    //MARK:- Handle New Chat
    func handleMessageWithChoices(responseBody: NSDictionary? ) {
        
        let arrChoices:NSArray? = responseBody?.object(forKey: "choices") as! NSArray?;
        // v1.0
        addBotChatBubble(txt: responseBody?.object(forKey: "text") as! String,
                         choices: arrChoices, actions: nil);
    }
    
    func handleBotsResponseBody( responseBody: NSDictionary? ) {
        
        if( responseBody?.object(forKey: "choices") != nil ){
            // Old format v1.0
            handleMessageWithChoices(responseBody: responseBody)
        }
        else{
            // New format v1.1
            let messagePayload:NSDictionary? = responseBody?.object(forKey: "messagePayload") as? NSDictionary
            if( messagePayload != nil ){
                // V 1.1

                let aMessage:OMCBotMessagePayload = OMCBotMessagePayload.init(aMessage: messagePayload)
                
                addBotChatBubble(aBotMsg: aMessage)
            }
            else{
                
                // Something went wrong, could not find messagePayload, in bot's reply.
            }
        }
    }
    
    func handleSystemResponseBody( responseBody: NSDictionary? ) {
        
    }
    
    func handleNewMessege(_ notification: Notification) {
        
        let chatMessege = notification.object as! NSDictionary
        
        let err:NSDictionary? = chatMessege.object(forKey: "error") as? NSDictionary;
        if( err != nil ){
            addBotChatBubble(txt: err?.object(forKey: "message") as! String,
                             choices: nil, actions: nil);
            
            return; // EXIT 1
        }
        else{
            
            var body:NSDictionary? = chatMessege.object(forKey: "body") as? NSDictionary;
            if( body == nil ){
                body = chatMessege;
                addBotChatBubble(txt: "Something went wrong, could not found response body for messagePayload. Please try again.",
                                 choices: nil, actions: nil);
                
                return; // EXIT 2
            }
            else{
                
                if let from:NSDictionary = chatMessege.object(forKey: "from") as? NSDictionary {
                    if let type:String = from.object(forKey: "type") as? String{
                        if( type == "bot" ){
                            handleBotsResponseBody(responseBody: body);
                        }
                        else if( type == "system" ){
                            handleSystemResponseBody(responseBody: body);
                        }
                    }
                }
            }
        }
    }
    
    func sendAndAddMyChat(_ notification: Notification) -> Void {
        
        if notification.object is NSString {
            
            let chat = notification.object as! NSString
            sendChatToBot(channelID: UserDefaults.standard.object(forKey: kWebhookChannelID) as! String, chat: chat as String);
            addMineChatBubble(txt: chat as String);
        }
        else if( notification.object is CLLocationCoordinate2D ){
            
            let centerLoc = notification.object as! CLLocationCoordinate2D
            // {"messagePayload":{"location":{"latitude":37.2900055,"longitude":-121.906558},"type":"location"}

            let strChat:String = "{\"to\":{\"type\": \"bot\",\"id\": \"\(UserDefaults.standard.object(forKey: kWebhookChannelID) as! String)\"}, \"messagePayload\":{\"location\":{\"latitude\":\(centerLoc.latitude),\"longitude\":\(centerLoc.longitude)},\"type\":\"location\"}}";
            
            print(strChat)

            OMCBotManager.sharedInstance.sendChat(chatMessege: strChat);
        }
        else{
            
            let anAction:OMCBotAction? = notification.object as? OMCBotAction;
            
            if( anAction?.type == "postback" ){
                sendPostbackActionToBot(channelID: UserDefaults.standard.object(forKey: kWebhookChannelID) as! String, postbackAction: anAction?.postback);
                addMineChatBubble(txt: (anAction?.lbl)! );
            }
            else if( anAction?.type == "location" ){
                addCurrentLocationMap();
            }
            else if( anAction?.type == "call" ){
                _ = phoneTo(number: (anAction?.phoneNumber)!)
            }
            else if( anAction?.type == "url" ){
                gotoWebView(url: anAction?.url)
            }
        }
    }
    
    func sendPostbackActionToBot ( channelID:String, postbackAction:NSDictionary? ){
        
        if let theJSONData = try?  JSONSerialization.data(
            withJSONObject: postbackAction as Any,
            options: .prettyPrinted
            ),
            let jsonPostback = String(data: theJSONData,
                                     encoding: String.Encoding.ascii) {

            let strChat:String = "{\"to\":{\"type\": \"bot\",\"id\": \"\(channelID)\"}, \"messagePayload\":{\"postback\":\(jsonPostback), \"type\":\"postback\"}}";

            print(strChat)
            
            OMCBotManager.sharedInstance.sendChat(chatMessege: strChat);
        }
    }
    
    func sendChatToBot( channelID:String, chat:String ) -> Void {
        
        let strChat:String = "{\"to\":{\"type\": \"bot\",\"id\": \"\(channelID)\"}, \"messagePayload\":{\"text\":\"\(chat)\", \"type\":\"text\"}}";

        print(strChat)
        
        OMCBotManager.sharedInstance.sendChat(chatMessege: strChat);
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    @IBAction func btnSendClicked(_ sender: AnyObject) {
        
        txtChat.resignFirstResponder()
        
        if( self.viewRecord.isHidden == false ){
            self.viewRecord.isHidden = true
            moveScrollView(constant: 5.0)
        }

        if audioEngine.isRunning {

            sendTapped = true

            audioEngine.stop()
            OMCBotManager.sharedInstance.recognitionRequest?.endAudio()
            btnVoice.isEnabled = true
            btnVoice.setBackgroundImage(UIImage.init(named: "mic.png"), for: UIControlState.normal)
            if( audioEngine.inputNode != nil ){
                audioEngine.inputNode?.removeTap(onBus: 0)
            }
        }

        if ( txtChat.text.characters.count > 0 ){
            let strChat:String = txtChat.text;
            txtChat.text = "";
            sendChatToBot(channelID: UserDefaults.standard.object(forKey: kWebhookChannelID) as! String, chat: strChat);
            self.addMineChatBubble(txt: strChat)
        }
    }
    
    //MARK:- Keyboard adjust
    func keyboardWillShow(_ notification: Notification) {
        
        if( self.viewRecord.isHidden == false ){
            self.viewRecord.isHidden = true
        }
        
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        moveScrollView(constant: keyboardFrame.size.height - 44)
    }
    
    func keyboardWillHide(_ notification: Notification) {
        moveScrollView(constant: 5.0)
    }
    
    //MARK:- Add Chat Bubble
    func addTypingIcon() -> Void {
        
        // If already added, remove it first.
        typingImgView?.removeFromSuperview()

        let startY = self.lastChatBubbleY + 10

        var aFrame:CGRect = OMCChatBubbleView.framePrimary(OMCChatBubbleType.opponentBubble , startY: startY)
        aFrame.size.height = 40
        aFrame.size.width = 66
        typingImgView = UIImageView.init(frame: aFrame)

        var images: [UIImage] = []
        for i in 1...3 {
            images.append(UIImage(named: "typing_indicators_\(i)")!)
        }
        typingImgView?.animationImages = images
        typingImgView?.animationDuration = 1.0
        typingImgView?.startAnimating()
        self.chatScrollView.addSubview(typingImgView!)
    }
    
    func addMineChatBubble( txt:String ) {
        
        let bubbleData = OMCChatMessage( text: txt )
        addChatBubble(bubbleData, choices: nil )
    }
    
    func addCurrentLocationMap ( ) {
        
        checkLocationAuthorizationStatus();

        let bubbleData = OMCChatMessage( map: true )
        addChatBubble(bubbleData, choices: nil )
    }
    
    // V1.0
    func addBotChatBubble( txt:String, choices:NSArray?, actions:NSArray? ) {
        
        let bubbleData = OMCChatMessage(text: txt, type: OMCChatBubbleType.opponentBubble )
        
        addChatBubble(bubbleData, choices: choices )
    }
    
    // V1.1
    func addBotChatBubble( aBotMsg:OMCBotMessagePayload? ) {
        
        if( aBotMsg?.cards != nil ){
            self.lastChatBubbleY = self.lastChatBubbleY+(internalPadding*2);
        }
        
        let bubbleData = OMCChatMessage( botMsg: aBotMsg );
        addChatBubble(bubbleData, choices: nil )
    }
    
    func gotoFullImageView(url:String?) -> Void {
        if let vc:OMCImageVC = OMCImageVC(nibName: "OMCImageVC", bundle: nil) {
            vc.url = url
            self.present(vc, animated:true, completion:nil)
        }
    }
    
    func gotoWebView(url:String?) -> Void {
        if let vc:OMCWebVC = OMCWebVC(nibName: "OMCWebVC", bundle: nil) {
            vc.urlString = url
            self.present(vc, animated:true, completion:nil)
        }
    }
    
    func addChatBubble(_ data: OMCChatMessage, choices:NSArray? ) {
        
        var padding:CGFloat = lastMessageType == data.type ? internalPadding/3.0 :  internalPadding
        padding = internalPadding;
        
        let chatBubble = OMCChatBubbleView(data: data, startY:self.lastChatBubbleY + padding + 1, choices: choices, chatVC:self)
        //chatBubble.chatVC = self
        
        self.chatScrollView.addSubview(chatBubble)
        
        self.lastChatBubbleY = chatBubble.frame.maxY
        
        self.chatScrollView.contentSize = CGSize(width: self.chatScrollView.frame.width, height: self.lastChatBubbleY + self.internalPadding)
        self.moveToLastMessage()
        self.lastMessageType = data.type
        self.txtChat.text = ""
        
        self.btnVoice.isEnabled = true
        
        if( data.type == OMCChatBubbleType.mineBubble ){
            // Add typing icon
            self.addTypingIcon()
        }
        else{
            // Remove typing icon
            self.typingImgView?.removeFromSuperview()
            self.typingImgView = nil
        }
    }
    
    //MARK:- Scroll adjust
    func moveScrollView( constant:CGFloat ){
        
        UIView.animate(withDuration: 1.0, animations: { () -> Void in
            self.floorConstraint.constant = constant;
            
        }, completion: { (completed: Bool) -> Void in
            self.moveToLastMessage()
        })
    }
    
    func moveToLastMessage() {
        
        if chatScrollView.contentSize.height > chatScrollView.frame.height {
            let contentOffSet = CGPoint(x: 0.0, y: chatScrollView.contentSize.height - chatScrollView.frame.height)
            self.chatScrollView.setContentOffset(contentOffSet, animated: true)
        }
    }
    
    // MARK: - delegate methods
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Send button clicked
        textField.resignFirstResponder()
        return true
    }
    
    
    // MARK:- Speech
    override open func viewDidAppear(_ animated: Bool) {
        lockOrientation(.portrait)
        
        speechRecognizer.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            /*
             The callback may not be called on the main thread. Add an
             operation to the main queue to update the record button's state.
             */
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.btnVoice.isEnabled = true
                    
                case .denied:
                    self.btnVoice.isEnabled = false
                   // self.btnVoice.setTitle("User denied access to speech recognition", for: .disabled)
                    
                case .restricted:
                    self.btnVoice.isEnabled = false
                   // self.btnVoice.setTitle("Speech recognition restricted on this device", for: .disabled)
                    
                case .notDetermined:
                    self.btnVoice.isEnabled = false
                   // self.btnVoice.setTitle("Speech recognition not yet authorized", for: .disabled)
                }
            }
        }
    }
    
    private func startRecording() throws {
        
        // Cancel the previous task if it's running.
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        try audioSession.setMode(AVAudioSessionModeMeasurement)
        try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        
        OMCBotManager.sharedInstance.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        btnVoice.setBackgroundImage(UIImage.init(named: "micEnabled.png"), for: UIControlState.normal)
        
        guard let inputNode = audioEngine.inputNode else { fatalError("Audio engine has no input node") }
        guard let recognitionRequest = OMCBotManager.sharedInstance.recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        
        // Configure request so that results are returned before audio recording is finished
        OMCBotManager.sharedInstance.recognitionRequest?.shouldReportPartialResults = true
        
        // A recognition task represents a speech recognition session.
        // We keep a reference to the task so that it can be cancelled.
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            DispatchQueue.main.async {
                
                if let result = result {
                    
                    if ( self.sendTapped == false ){
                        self.txtChat.text = result.transcriptions.first?.formattedString
                    }
                    // self.txtChat.placeholder = "type here.."
                    isFinal = result.isFinal
                    if isFinal == true {
                        self.sendTapped = false;
                    }
                }
                
                if error != nil || isFinal {
                    
                    if self.audioEngine.isRunning {
                        self.audioEngine.stop()
                    }
                    
                    inputNode.removeTap(onBus: 0)
                    
                    OMCBotManager.sharedInstance.recognitionRequest = nil
                    self.recognitionTask = nil
                    
                    self.btnVoice.isEnabled = true
                    self.btnVoice.setBackgroundImage(UIImage.init(named: "mic.png"), for: UIControlState.normal)
                }
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            OMCBotManager.sharedInstance.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        try audioEngine.start()
        
        txtChat.text = "";
    }
    
    // MARK: SFSpeechRecognizerDelegate
    
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            btnVoice.isEnabled = true
           // btnVoice.setTitle("Start Recording", for: [])
        } else {
            btnVoice.isEnabled = false
          // btnVoice.setTitle("Recognition not available", for: .disabled)
        }
    }
    
    
    @IBAction func btnRecordDown(_ sender: Any) {
        
        OMCBotManager.sharedInstance.synth?.stopSpeaking(at: .immediate);
        OMCBotManager.sharedInstance.synth = nil;
        
        try! startRecording()
    }
    
    @IBAction func btnRecordUp(_ sender: Any) {
        
        if audioEngine.isRunning {
            
            self.txtChat.resignFirstResponder()
            
            audioEngine.stop()
            OMCBotManager.sharedInstance.recognitionRequest?.endAudio()
            if( audioEngine.inputNode != nil ){
                audioEngine.inputNode?.removeTap(onBus: 0)
            }
        }
    }
    
    
    @IBAction func recordButtonTapped() {
        
        txtChat.resignFirstResponder()
        
        if( ScreenSize.SCREEN_WIDTH == 320
            ||  ScreenSize.SCREEN_HEIGHT == 320 ) {
            
            if audioEngine.isRunning {
                self.btnVoice.setImage(UIImage.init(named: "mic.png"), for: UIControlState.normal)
                btnRecordUp(btnVoice);

            }
            else{
                
                self.btnVoice.setImage(UIImage.init(named: "micEnabled.png"), for: UIControlState.normal)
                btnRecordDown(btnVoice);
            }
        }
        else{
            
            if( self.viewRecord.isHidden == false ){
                
                self.viewRecord.isHidden = true
                moveScrollView(constant: 5.0)
            }
            else{
                
                self.viewRecord.isHidden = false
                
                moveScrollView(constant: self.viewRecord.frame.height + 5 )
            }
        }
        /*
         if audioEngine.isRunning {
         
            self.txtChat.resignFirstResponder()

            audioEngine.stop()
            CBManager.sharedInstance.recognitionRequest?.endAudio()
            if( audioEngine.inputNode != nil ){
                audioEngine.inputNode?.removeTap(onBus: 0)
            }

        } else {
            try! startRecording()
           // btnVoice.setTitle("Stop recording", for: [])
        }
         */
    }

    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
