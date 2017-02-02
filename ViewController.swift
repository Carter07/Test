//
//  ViewController.swift
//  HitMan
//
//  Created by Davide Feliciello on 28/10/2016.
//  Copyright © 2016 Davide Feliciello. All rights reserved.
//



// Known bugs:
// Sound effects works only on xcode simulator..can't listen nothing in iphone 6s
// In newer iterations works slower on simulator but it's fine on the real iphone 6s


import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    
    var player: AVAudioPlayer!
    let url1 = Bundle.main.url(forResource: "metal", withExtension: "mp3")!
    let url2 = Bundle.main.url(forResource: "glass", withExtension: "mp3")!
    let url3 = Bundle.main.url(forResource: "banana", withExtension: "mp3")!
    
    var size_w_P1: Int = 60    //width of P1 frame
    var size_h_P1: Int = 60    //height of P1 frame
    var center_X_P1: UInt32 = 157  //x of center P1 frame
    var center_Y_P1: UInt32 = 242  //y of center P1 frame
    
    var size_w_P2: Int = 60    //width of P1 frame
    var size_h_P2: Int = 60    //height of P1 frame
    var center_X_P2: UInt32 = 264  //x of center P1 frame
    var center_Y_P2: UInt32 = 426  //y of center P1 frame
    
    var life_left: Int = 3
    var size_multiplier: Double = 2
    var time_multiplier: Double = 2
    var highscore: Int = 0
    var msg_window: String = ""
    
    var timer = Timer()
    var timeout: Double = 1    //time before buttons change position
    
    
    
    @IBOutlet weak var score: UILabel!
    @IBOutlet weak var debug: UILabel!
    @IBOutlet weak var life: UILabel!

    @IBOutlet weak var step_outlet: UIStepper!
    
    @IBAction func step_action(_ sender: UIStepper) {
        if Int(sender.value)>0{
            size_w_P1 = 60+(Int(sender.value)*20)
            size_h_P1 = 60+(Int(sender.value)*20)
            size_w_P2 = 60+(Int(sender.value)*20)
            size_h_P2 = 60+(Int(sender.value)*20)
        }
        
        P1_outlet.frame = CGRect(x: Int(center_X_P1), y: Int(center_X_P1), width: size_w_P1, height: size_h_P1)
        P2_outlet.frame = CGRect(x: Int(center_X_P2), y: Int(center_X_P2), width: size_w_P2, height: size_h_P2)
        //debug.text = ("\(sender.value)")
        //debug.text = ("\(size_w_P1)")
    
    }
    
    @IBOutlet var tap_out_outlet: UITapGestureRecognizer!
    @IBAction func tap_out_action(_ sender: UITapGestureRecognizer) {
        playSound(url: url3)
        msg_window = "Whoops" + ("\n") + "Score: " + score.text!
        Game_Over(msg: msg_window)
    }
    
    
    
    @IBOutlet weak var game_area: UIView!
    @IBOutlet weak var P1_outlet: UIButton!
    
    @IBAction func P1_action(_ sender: UIButton) {
        playSound(url: url1)
        Calcolate_p1_position()
        Update_Score()
        timeout = 1
        P2_enters()
    }
    
    @IBOutlet weak var P2_outlet: UIButton!
    
    @IBAction func P2_action(_ sender: UIButton) {
        playSound(url: url2)
        msg_window = "Hey, you can't hit someone with glasses!!" + ("\n") + "Score: " + score.text!
        Game_Over(msg: msg_window)
    }
    
    @IBOutlet weak var info: UILabel!
    @IBOutlet weak var time: UILabel!
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        New_Game()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    
    
    func New_Game(){
        score.text = "0"
        time.text = "0"
        info.text = "High Score: \(highscore)"
        P1_outlet.center.x = 157
        P1_outlet.center.y = 242
        P2_outlet.isHidden = true
        debug.isHidden = true
        timeout = 2
        life_left = 3
        life.text = ("Left: \(life_left)")
        step_outlet.maximumValue = 5
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(Update_Time), userInfo: nil,repeats: true)
    }
    

    func Calcolate_p1_position(){
        repeat {
            center_X_P1 = arc4random_uniform(UInt32(game_area.bounds.maxX))
            center_Y_P1 = arc4random_uniform(UInt32(game_area.bounds.maxY))
        } while (UInt32(game_area.bounds.maxX) - center_X_P1)<(UInt32(size_w_P1/2)) || center_X_P1<(UInt32(size_w_P1/2)) || (UInt32(game_area.bounds.maxY) - center_Y_P1)<(UInt32(size_h_P1/2)) || center_Y_P1<(UInt32(size_h_P1/2))
        
        P1_outlet.center.x = CGFloat(center_X_P1)
        P1_outlet.center.y = CGFloat(center_Y_P1)
    }
    
    func Calcolate_p2_position(){
        repeat {
            center_X_P2 = arc4random_uniform(UInt32(game_area.bounds.maxX))
            center_Y_P2 = arc4random_uniform(UInt32(game_area.bounds.maxY))
        } while (UInt32(game_area.bounds.maxX) - center_X_P2)<(UInt32(size_w_P2/2)) || center_X_P2<(UInt32(size_w_P2/2)) || (UInt32(game_area.bounds.maxY) - center_Y_P2)<(UInt32(size_h_P2/2)) || center_Y_P2<(UInt32(size_h_P2/2))
        
        P2_outlet.center.x = CGFloat(center_X_P2)
        P2_outlet.center.y = CGFloat(center_Y_P2)
    }
    
    
    func playSound(url: URL) {
        do {
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            
            player.prepareToPlay()
            player.play()
        } catch let error as Error {
            //print(debug.description)
        }
    }

    
    
    func Update_Time(){
        time.text = String((Double(time.text!)!+0.1))
        timeout -= 0.1
        //debug.text = ("\(timeout)")
        if timeout<=0{
            life_left -= 1
            if life_left==0{
                msg_window = "0 life left" + ("\n") + "Score: " + score.text!
                Game_Over(msg: msg_window)
            }
            life.text = ("Left: \(life_left)")
            Calcolate_p1_position()
            P2_enters()
            timeout = 1
        }
    
    
    }
    
    func Update_Score(){
        size_multiplier = 160.0/Double(size_w_P1)   //from x1 to x2
        time_multiplier = 10*timeout        //from x1 to x20
        score.text = String((Int(score.text!)! + Int(time_multiplier*size_multiplier)))   //gained score is higher when tapping faster or size of buttons is lower
        //debug.text = String(Int(time_multiplier*size_multiplier))
        //debug.text = String(size_multiplier)
        //debug.text = String(time_multiplier)
    }
    
    
    func P2_enters(){
        let xxx = arc4random_uniform(UInt32(2))
        if xxx==1{
            P2_outlet.isHidden = false
            Calcolate_p2_position()
        }else{
            P2_outlet.isHidden = true
        }

    }
    
    func Game_Over(msg: String){
        timer.invalidate()
        if Int(score.text!)!>highscore{
           highscore = Int(score.text!)!
        }
       let alertController = UIAlertController(title: "Game Over", message: msg, preferredStyle: UIAlertControllerStyle.alert)
    
       let ExitAction = UIAlertAction(title: "Restart", style: UIAlertActionStyle.destructive) {
          (result : UIAlertAction) -> Void in
          self.New_Game()
        }
       let okAction = UIAlertAction(title: "Exit", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
        UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
       }
       alertController.addAction(ExitAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
}



















