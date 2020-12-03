//
//  ViewController.swift
//  TestTaskVideoPlayer
//
//  Created by Леонид Хабибуллин on 01.12.2020.
//
import AVFoundation
import AVKit
import UIKit

protocol ViewControllerDelegate {
    func forwardRewind()
    func backwardRewind()
}

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ViewControllerDelegate {
    
    @IBOutlet var playButton: UIButton!
    @IBOutlet var stopButton: UIButton!
    
    @IBOutlet var labelCurrentTime: UILabel!
    @IBOutlet var playbackSlider: UISlider!
    @IBOutlet var labelOverallDuration: UILabel!
    
    let myPlayerView = PlayerView()
    let rewindView = RewindView()
    
    private let videoPresenter = VideoPresenter()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rewindView.delegate = self
        
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
    
    func setUpMyPlayerView() {
        myPlayerView.backgroundColor = .secondarySystemBackground
        view.addSubview(myPlayerView)
        makeConstraint(view: myPlayerView)
    }
    
    func setUpRewindView() {
        view.addSubview(rewindView)
        makeConstraint(view: rewindView)
        rewindView.setUpAll()
    }
    
    func makeConstraint(view: UIView) {
        view.alpha = 1
        guard let myView = self.view else {return}
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leadingAnchor.constraint(equalTo: myView.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: myView.trailingAnchor).isActive = true
        view.heightAnchor.constraint(equalTo: myView.heightAnchor, multiplier: 0.3).isActive = true
        view.widthAnchor.constraint(equalTo: myView.widthAnchor).isActive = true
        view.centerYAnchor.constraint(equalTo: myView.centerYAnchor).isActive = true
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
    
    func forwardRewind() {
        videoPresenter.forwardViewTapped()
    }
    func backwardRewind() {
        videoPresenter.backwardViewTapped()
    }
}
