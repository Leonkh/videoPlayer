//
//  ViewController.swift
//  TestTaskVideoPlayer
//
//  Created by Леонид Хабибуллин on 01.12.2020.
//
import AVFoundation
import AVKit
import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet var playButton: UIButton!
    @IBOutlet var stopButton: UIButton!
    
    @IBOutlet var labelCurrentTime: UILabel!
    @IBOutlet var playbackSlider: UISlider!
    @IBOutlet var labelOverallDuration: UILabel!
    
    var myPlayerView: PlayerView!
    var forwardView: UIView!
    var backwardView: UIView!
    
    private let videoPresenter = VideoPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        videoPresenter.playerView = myPlayerView
        videoPresenter.mainView = self
        
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(saveData), name: UIApplication.willResignActiveNotification, object: nil)
        
        videoPresenter.loadData()
    }
    
    @objc func saveData() {
        videoPresenter.saveData()
    }
    
    @objc func addVideo() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.mediaTypes = ["public.movie"]
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let video = info[.mediaURL] as? URL else {
            dismiss(animated: true)
            return
        }
        videoPresenter.videoWasPicked(videoURL: video)
        dismiss(animated: true)
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        videoPresenter.playButtonTapped()
        
    }
    @IBAction func stopButtonTapped(_ sender: UIButton) {
        videoPresenter.stopButtonTapped()
    }
    
    @objc func forwardViewTapped() {
        videoPresenter.forwardViewTapped()
    }
    
    @objc func backwardViewTapped() {
        videoPresenter.backwardViewTapped()
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
    
    func setupSliderAndLabels (duration: String, current: String, maxValue: Float, seconds: Float) {
        
        labelCurrentTime.isHidden = false
        labelOverallDuration.isHidden = false
        playbackSlider.isHidden = false
        
        labelOverallDuration.text = duration
        labelCurrentTime.text = current
        
        playbackSlider.maximumValue = maxValue
        playbackSlider.isContinuous = true
        playbackSlider.value = seconds
        
  
    }
    
    @objc func playbackSliderValueChanged(_ playbackSlider:UISlider) {
        let sliderValue = playbackSlider.value
        videoPresenter.sliderValueChanged(sliderValue: sliderValue)
    }
    
    func changeImagePlayButton(status: Bool) {
        switch status {
        case true:
            playButton.setBackgroundImage(UIImage(named: "pause"), for: .normal)
        default:
            playButton.setBackgroundImage(UIImage(named: "play"), for: .normal)
        }
    }
    
    func alertNoVideo() {
        let ac = UIAlertController(title: "First select the video", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}
