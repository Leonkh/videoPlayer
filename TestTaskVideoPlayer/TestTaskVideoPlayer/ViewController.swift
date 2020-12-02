//
//  ViewController.swift
//  TestTaskVideoPlayer
//
//  Created by Леонид Хабибуллин on 01.12.2020.
//
import AVFoundation
import AVKit
import CoreData
import UIKit

private var lastVideo: [NSManagedObject] = []

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var playButton: UIButton!
    @IBOutlet var stopButton: UIButton!
    
    @IBOutlet var labelCurrentTime: UILabel!
    @IBOutlet var playbackSlider: UISlider!
    @IBOutlet var labelOverallDuration: UILabel!
    
    var videoURL: URL!
    
    var myPlayerView: PlayerView!
    var forwardView: UIView!
    var backwardView: UIView!
    
    var statusPlay = false
    var statusVideoHere = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Video")
        
        do {
            lastVideo = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addVideo))
        
        playButton.contentMode = .scaleAspectFill
        playButton.setBackgroundImage(UIImage(named: "play"), for: .normal)
        playButton.setTitle(nil, for: .normal)
        
        stopButton.contentMode = .scaleAspectFill
        stopButton.setBackgroundImage(UIImage(named: "stop"), for: .normal)
        stopButton.setTitle(nil, for: .normal)
        
        labelCurrentTime.isHidden = true
        labelOverallDuration.isHidden = true
        playbackSlider.isHidden = true
        playbackSlider.minimumValue = 0
        playbackSlider.value = 0
        playbackSlider.addTarget(self, action: #selector(playbackSliderValueChanged(_:)), for: .valueChanged)
        
        // горизонтальный режим временно недоступен
        setUpMyPlayerView()
        setUpMyForwardView()
        setUpMyBackwardView()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(saveChanges), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    @objc func addVideo() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.mediaTypes = ["public.movie"]
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let video = info[.mediaURL] as? URL else {return}
        videoURL = video
        myPlayerView.createController(videoURL: videoURL)
        saveChanges()
        statusVideoHere = true
        setupSliderAndLabels()
        dismiss(animated: true)
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        
        if statusVideoHere == false {
            let ac = UIAlertController(title: "First select the video", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
            return
        }
        statusPlay = !statusPlay
        if statusPlay {
            playButton.setBackgroundImage(UIImage(named: "pause"), for: .normal)
            myPlayerView.play()
        } else {
            playButton.setBackgroundImage(UIImage(named: "play"), for: .normal)
            myPlayerView.pause()
        }
    }
    @IBAction func stopButtonTapped(_ sender: UIButton) {
        if statusVideoHere == false {
            let ac = UIAlertController(title: "First select the video", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
            return
        }
        statusPlay = false
        playButton.setBackgroundImage(UIImage(named: "play"), for: .normal)
        myPlayerView.stop()
    }
    
    @objc func forwardViewTapped() {
        myPlayerView.forwardByDoubleTouch()
    }
    
    @objc func backwardViewTapped() {
        myPlayerView.backwardByDoubleTouch()
    }
    
    func setUpMyPlayerView() {
        myPlayerView = PlayerView()
        myPlayerView.backgroundColor = .secondarySystemBackground
        view.addSubview(myPlayerView)
        myPlayerView.alpha = 1
        myPlayerView.translatesAutoresizingMaskIntoConstraints = false
        myPlayerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        myPlayerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        myPlayerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3).isActive = true
        myPlayerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        myPlayerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    func setUpMyForwardView() {
        forwardView = UIView()
        forwardView.backgroundColor = nil
        view.addSubview(forwardView)
        forwardView.alpha = 1
        forwardView.translatesAutoresizingMaskIntoConstraints = false
        forwardView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        forwardView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3).isActive = true
        forwardView.widthAnchor.constraint(equalToConstant: view.frame.width / 2).isActive = true
        forwardView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(forwardViewTapped))
        doubleTap.numberOfTapsRequired = 2
        forwardView.addGestureRecognizer(doubleTap)
        
        let tripleTap = UITapGestureRecognizer(target: self, action: #selector(forwardViewTapped))
        tripleTap.numberOfTapsRequired = 3
        forwardView.addGestureRecognizer(tripleTap)
    }
    
    func setUpMyBackwardView() {
        backwardView = UIView()
        backwardView.backgroundColor = nil
        view.addSubview(backwardView)
        backwardView.alpha = 1
        backwardView.translatesAutoresizingMaskIntoConstraints = false
        backwardView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        backwardView.trailingAnchor.constraint(equalTo: forwardView.leadingAnchor).isActive = true
        backwardView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3).isActive = true
        backwardView.widthAnchor.constraint(equalToConstant: view.frame.width / 2).isActive = true
        backwardView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(backwardViewTapped))
        doubleTap.numberOfTapsRequired = 2
        backwardView.addGestureRecognizer(doubleTap)
        
        let tripleTap = UITapGestureRecognizer(target: self, action: #selector(backwardViewTapped))
        tripleTap.numberOfTapsRequired = 3
        backwardView.addGestureRecognizer(tripleTap)
    }
    
    func setupSliderAndLabels () {
        
        labelCurrentTime.isHidden = false
        labelOverallDuration.isHidden = false
        playbackSlider.isHidden = false
        
        labelOverallDuration.text = stringFromTimeInterval(interval: myPlayerView.seconds!)
        labelCurrentTime.text = stringFromTimeInterval(interval: myPlayerView.currentSeconds!)
        
        playbackSlider.maximumValue = Float(myPlayerView.seconds!)
        playbackSlider.isContinuous = true
        
        myPlayerView.player!.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { (CMTime) -> Void in
            if self.myPlayerView.player!.currentItem?.status == .readyToPlay {
                self.myPlayerView.time = CMTimeGetSeconds(self.myPlayerView.player!.currentTime())
                self.playbackSlider.value = Float ( self.myPlayerView.time! )
                self.labelCurrentTime.text = self.stringFromTimeInterval(interval: self.myPlayerView.time!)
            }
        }
    }
    
    @objc func playbackSliderValueChanged(_ playbackSlider:UISlider) {
        let seconds : Int64 = Int64(playbackSlider.value)
        let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
        myPlayerView.player!.seek(to: targetTime)
    }
    
    func stringFromTimeInterval(interval: TimeInterval) -> String {
        let interval = Int(interval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let video = lastVideo.first else {return}
        guard let urlV = video.value(forKeyPath: "videoURL") as? URL else {return}
        myPlayerView.createController(videoURL: urlV)
        myPlayerView.player.seek(to: CMTime(seconds: Double(video.value(forKey: "currentTime") as! Float), preferredTimescale: 1))
        statusVideoHere = true
        setupSliderAndLabels()
    }
    
    @objc func saveChanges() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        guard let entity = NSEntityDescription.entity(forEntityName: "Video", in: managedContext) else {return}
        if let object = lastVideo.first {
            do {
                managedContext.delete(object)
                lastVideo.removeAll()
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
        
        let video = NSManagedObject(entity: entity, insertInto: managedContext)
        video.setValue(videoURL, forKeyPath: "videoURL")
        video.setValue(playbackSlider.value, forKeyPath: "currentTime")
        do {
            lastVideo.append(video)
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}
