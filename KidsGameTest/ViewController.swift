//
//  ViewController.swift
//  KidsGameTest
//
//  Created by Lobanov Viktor on 21.04.2026.
//    playButton.isHidden = false
//   reloadButton.isHidden = false
import AVFoundation
import UIKit

class ViewController: UIViewController {

    @IBOutlet var foodButtons: [UIImageView]! //массив фрктов в корзине
    @IBOutlet var targetViews: [UIImageView]! // массив
    let viewModel = GameViewModel()
    @IBOutlet weak var catImageView: UIImageView!
    
    @IBOutlet weak var reloadButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var levelButton: UIButton!
    
    
    // зхрачки
    @IBOutlet weak var pupilsImageView: UIImageView!
    var pupilsInitialCenter: CGPoint = .zero
    @IBOutlet weak var kittenEyeballsImageView: UIImageView!
    @IBOutlet weak var kittenEyelidsImageView: UIImageView!
    
    // dlya zvykov
    var backgroundPlayer: AVAudioPlayer?
    var effectPlayer: AVAudioPlayer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startBackgroundMusic()
        reloadButton.isHidden = true
        playButton.isHidden = true
        // Do any additional setup after loading the view.
       // view.backgroundColor = .green
        // Подписываемся на обновления от ViewModel
            viewModel.onUpdate = { [weak self] in
                self?.updateUI()
            }
            
            // Первичный запуск
            updateUI()
        // Мы обращаемся к родителю зрачков (кто бы он ни был) и просим положить их под веки
            if let parent = pupilsImageView.superview {
                parent.insertSubview(pupilsImageView, belowSubview: kittenEyelidsImageView)
                // И заодно положим их под блики/глазные яблоки, если нужно
                parent.insertSubview(kittenEyeballsImageView, belowSubview: pupilsImageView)
            }
        
        setupGestures()
        view.insertSubview(pupilsImageView, belowSubview: kittenEyelidsImageView)
        // Добавляем жесты нажатия на силуэты, чтобы проверить их
//        for (index, targetView) in targetViews.enumerated() {
//            targetView.isUserInteractionEnabled = true // Важно!
//            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTargetTap(_:)))
//            targetView.addGestureRecognizer(tap)
//        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
      //  pupilsInitialCenter = pupilsImageView.center
    }
    
    
    
    
    @IBAction func pressReloadButton(_ sender: Any) {
        // 1. Сбрасываем глаза в "ноль" (в те самые -78 из Storyboard)
        self.pupilsImageView.transform = .identity
        
        // 2. Возвращаем видимость
        pupilsImageView.isHidden = false
        kittenEyeballsImageView.isHidden = false
        kittenEyelidsImageView.isHidden = false
        kittenEyelidsImageView.alpha = 0
        
        // 3. Обновляем игру
        viewModel.generateLevel()
        updateUI()
        
        catImageView.image = UIImage(named: "Test_Kitten")
        
        // Управление кнопками
        playButton.isHidden = true
        reloadButton.isHidden = true
        pauseButton.isHidden = false
        levelButton.isHidden = false
        
        foodButtons.forEach { $0.isHidden = false }
        targetViews.forEach { $0.isHidden = false }
        
        UIView.animate(withDuration: 0.3) {
            self.view.backgroundColor = .white
        }
        view.layer.sublayers?.filter { $0 is CAEmitterLayer }.forEach { $0.removeFromSuperlayer() }
    }
    
    @IBAction func pressPlayButton(_ sender: Any) {
        print("press pressPlayButton — тут будет логика следующего уровня")
    }
    
//    @objc func handleTargetTap(_ gesture: UITapGestureRecognizer) {
//        guard let view = gesture.view else { return }
//        print("👆 НАЖАТИЕ ПО СИЛУЭТУ! Индекс: \(view.tag), Рамка: \(view.frame)")
//        
//        // Подсветим его на секунду, чтобы увидеть визуально
//        let originalColor = view.backgroundColor
//        view.backgroundColor = .white
//        UIView.animate(withDuration: 0.5) {
//            view.backgroundColor = originalColor
//        }
//    }
    

    
    func updateUI() {
        let basketItems = viewModel.basketItems
        let currentTargets = viewModel.targets
        let guessedIds = viewModel.guessedIds
        
        // 1. Обновляем верхние цели (силуэты)
        for (index, view) in targetViews.enumerated() {
            if index < currentTargets.count {
                let item = currentTargets[index]
                let isGuessed = guessedIds.contains(item.id)
                view.image = UIImage(named: isGuessed ? "\(item.name)_guessed" : "\(item.name)_shape")
                view.alpha = 1.0
            }
        }
        
        // 2. СИНХРОНИЗАЦИЯ КОРЗИНЫ
        // Мы перебираем ВСЕ картинки из коллекции foodButtons
        for imageView in foodButtons {
            let tag = imageView.tag
            
            // Проверяем, есть ли в массиве данные для этого тега
            if tag < basketItems.count {
                let item = basketItems[tag]
                
                // Устанавливаем картинку ТУ, которая реально соответствует индексу в массиве
                imageView.image = UIImage(named: item.basketImage)
                
                // Если угадано — скрываем
                //imageView.isHidden = guessedIds.contains(item.id)
                imageView.isUserInteractionEnabled = true
            }
        }
    }
    
    func playSuccessFeedback() {
        catImageView.image = UIImage(named: "Test_Kitten_Happy")
        
        UIView.animate(withDuration: 0.2, animations: {
            self.catImageView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.catImageView.transform = .identity
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            // 👇 ПРОВЕРКА: Если уровень еще НЕ закончен, тогда возвращаем обычного кота
            // Если же уровень закончен, котик должен остаться победным!
            if let self = self, !self.viewModel.isLevelComplete {
                self.catImageView.image = UIImage(named: "Test_Kitten")
            }
        }
        playSoundEffect(name: "success_sound")
    }

    func playFailureFeedback() {
        catImageView.image = UIImage(named: "Test_Kitten_Sad")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            // 👇 То же самое здесь
            if let self = self, !self.viewModel.isLevelComplete {
                self.catImageView.image = UIImage(named: "Test_Kitten")
            }
        }
    }
    
    
    func showVictoryScreen() {
        // 1. Котик становится очень счастливым
        catImageView.image = UIImage(named: "Test_Kitten_Victory")
        
        // 2. Прячем всё лишнее (корзину и силуэты)
        // Скрываем все ягоды в корзине
        foodButtons.forEach { $0.isHidden = true }
        // Скрываем все силуэты целей
        targetViews.forEach { $0.isHidden = true }
        pauseButton.isHidden = true
        levelButton.isHidden = true
        //pryachem glaza
        pupilsImageView.isHidden = true
        kittenEyeballsImageView.isHidden = true
        kittenEyelidsImageView.isHidden = true
        // 3. Показываем кнопки
        playButton.isHidden = false
        reloadButton.isHidden = false
        
        // 4. Опционально: можно плавно затемнить фон, чтобы котик и кнопки "горели"
        UIView.animate(withDuration: 0.5) {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        }
        
        // 5. Запускаем конфетти (код был в прошлом сообщении)
        createConfetti()
        playSoundEffect(name: "victory_fanfare")
    }
    
    // zapusk muziki v fone
    func startBackgroundMusic() {
        guard let url = Bundle.main.url(forResource: "background_music", withExtension: "mp3") else {
            print("❌ Не нашел файл фоновой музыки")
            return
        }
        
        do {
            backgroundPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundPlayer?.numberOfLoops = -1 // Бесконечно
            backgroundPlayer?.volume = 0.2       // Делаем потише, чтобы не мешала
            backgroundPlayer?.play()
            print("🎵 Музыка заиграла!")
        } catch {
            print("❌ Ошибка плеера: \(error)")
        }
    }

    // 3. Универсальная функция для звуков (победа или успех)
    func playSoundEffect(name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else {
            print("❌ Не нашел звук: \(name)")
            return
        }
        
        do {
            effectPlayer = try AVAudioPlayer(contentsOf: url)
            effectPlayer?.play()
        } catch {
            print("❌ Ошибка эффекта: \(error)")
        }
    }
    
  // END Class
}




// MARK: - Drag & Drop Logic

extension ViewController {
    
    func setupGestures() {
        for button in foodButtons {
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
            button.addGestureRecognizer(panGesture)
        }
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let draggedView = gesture.view as? UIImageView else { return }
        let translation = gesture.translation(in: view)
        let location = gesture.location(in: view) // Точка пальца на экране
        
        switch gesture.state {
        case .began:
            // 1. Поднимаем ягоду, чтобы она была над корзиной, но не перекрывала кнопки паузы
            view.bringSubviewToFront(draggedView)
            
            // 2. Легкая вибрация (Haptic Feedback) для тактильности
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
            
        case .changed:
            // 3. Перемещаем ягоду
            draggedView.transform = CGAffineTransform(translationX: translation.x, y: translation.y)
            
            // 4. ГЛАЗА: Заставляем котика следить за перемещением
            // Мы передаем текущую позицию ягоды в функцию обновления зрачков
            updatePupilsPosition(to: location)
            
        case .ended:
            // 5. Проверяем, попали мы в цель или нет
            checkCollision(for: draggedView)
            
            // 6. Возвращаем взгляд в центр, так как ягоду отпустили
            resetPupilsPosition()
            
        case .cancelled, .failed:
            // 7. Если что-то пошло не так — возвращаем ягоду на базу и сбрасываем взгляд
            returnToOriginalPosition(draggedView)
            resetPupilsPosition()
            
        default:
            break
        }
    }

    // Вспомогательная функция для плавного возврата зрачков в центр
    func resetPupilsPosition() {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut, .allowUserInteraction]) {
            self.pupilsImageView.transform = .identity
        }
    }
    
   
    func checkCollision(for draggedView: UIImageView) {
        let viewTag = draggedView.tag
        guard viewTag < viewModel.basketItems.count else { return }
        let foodItem = viewModel.basketItems[viewTag]
        
        var hasHandledFeedback = false
        
        let actualX = draggedView.center.x + draggedView.transform.tx
        let actualY = draggedView.center.y + draggedView.transform.ty
        let fruitCenterInMainView = draggedView.superview?.convert(CGPoint(x: actualX, y: actualY), to: self.view) ?? CGPoint(x: actualX, y: actualY)

        for (index, targetView) in targetViews.enumerated() {
            let targetCenter = targetView.superview?.convert(targetView.center, to: self.view) ?? targetView.center
            let distance = sqrt(pow(targetCenter.x - fruitCenterInMainView.x, 2) + pow(targetCenter.y - fruitCenterInMainView.y, 2))
            
            if distance < 90 {
                let wasAlreadyGuessed = viewModel.guessedIds.contains(foodItem.id)
                
                if viewModel.checkMatch(foodId: foodItem.id, targetIndex: index) {
                    if !wasAlreadyGuessed {
                        print("✅ Новое совпадение!")
                        showSuccessEmotion()
                        
                        playSuccessFeedback()
                        updateUI()
                        
                        // ПРОВЕРКА НА ФИНАЛ УРОВНЯ
                        if viewModel.isLevelComplete {
                            print("🏆 УРОВЕНЬ ЗАВЕРШЕН!")
                            // Даем 0.5 сек, чтобы ребенок увидел результат, потом показываем экран победы
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                self.showVictoryScreen()
                            }
                        }
                    } else {
                        print("ℹ️ Фрукт уже на месте")
                    }
                } else {
                    print("❌ Котику грустно: принесли не в ту лунку")
                    playFailureFeedback()
                }
                hasHandledFeedback = true
                break
            }
        }
        
        returnToOriginalPosition(draggedView)
    }
    
    // функция для отрабатывания сборки глаз при счасстливом котике нашедшим совпадение
    func showSuccessEmotion() {
        // 1. Скрываем динамические глаза, чтобы они не двоились
        pupilsImageView.isHidden = true
        kittenEyelidsImageView.isHidden = true
        kittenEyeballsImageView.isHidden = true
        
        // 2. Меняем котика на радостного (у которого глаза уже встроены)
        catImageView.image = UIImage(named: "Test_Kitten_Success") // Замени на имя своего ассета
        
        // 3. Через 0.8 секунд возвращаем всё как было
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            // Проверяем, не закончился ли уровень за это время (чтобы не перебить экран победы)
            if !self.viewModel.isLevelComplete {
                self.catImageView.image = UIImage(named: "Test_Kitten") // Обычный безглазый котик
                self.pupilsImageView.isHidden = false
                self.kittenEyelidsImageView.isHidden = false
                self.kittenEyeballsImageView.isHidden = false
                
                // Сбрасываем трансформацию, чтобы зрачки не "прыгали"
                self.pupilsImageView.transform = .identity
            }
        }
    }
    
    func returnToOriginalPosition(_ view: UIImageView) {
        // Убираем взаимодействие, чтобы пользователь не схватил летящую ягоду
        view.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.6,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.5,
                       options: [.curveEaseOut, .beginFromCurrentState],
                       animations: {
            
            // 1. Сбрасываем трансформацию в ноль
            view.transform = .identity
            
        }, completion: { _ in
            // 2. Возвращаем возможность трогать ягоду
            view.isUserInteractionEnabled = true
            print("🏠 Ягода вернулась на базу")
        })
    }
    
    // конфеты
    func createConfetti() {
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: view.center.x, y: -10)
        emitter.emitterShape = .line
        emitter.emitterSize = CGSize(width: view.frame.size.width, height: 2)
        
        let colors: [UIColor] = [.systemRed, .systemBlue, .systemYellow, .systemGreen, .systemPink, .systemOrange]
        
        let cells: [CAEmitterCell] = colors.map { color in
            let cell = CAEmitterCell()
            cell.birthRate = 4.0
            cell.lifetime = 10.0
            cell.velocity = CGFloat.random(in: 100...200)
            cell.velocityRange = 50
            cell.emissionLongitude = .pi
            cell.emissionRange = .pi / 4
            cell.spin = 2
            cell.spinRange = 3
            cell.scale = 0.5
            cell.scaleRange = 0.4
            
            // Создаем маленькую белую картинку для частицы конфетти
            cell.contents = createConfettiImage(with: color)?.cgImage
            return cell
        }
        
        emitter.emitterCells = cells
        view.layer.addSublayer(emitter)
    }

    
    // Вспомогательная функция для рисования частицы
        func createConfettiImage(with color: UIColor) -> UIImage? {
            // 👇 Увеличиваем размер холста
            let rect = CGRect(x: 0, y: 0, width: 25, height: 25)
            
            UIGraphicsBeginImageContext(rect.size)
            if let context = UIGraphicsGetCurrentContext() {
                context.setFillColor(color.cgColor)
                context.fill(rect)
            }
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
    // для переходв с Нового Экрана
    @IBAction func unwindToGame(segue: UIStoryboardSegue) {
        print("Вернулись! Наводим порядок на игровом поле...")
        
        // 1. Убираем конфетти (удаляем слой анимации)
        view.layer.sublayers?.filter { $0 is CAEmitterLayer }.forEach { $0.removeFromSuperlayer() }
        
        // 2. Возвращаем фон к обычному состоянию (убираем затемнение)
        UIView.animate(withDuration: 0.3) {
            self.view.backgroundColor = .white // или твой цвет фона
        }
        // 👇 ВОЗВРАЩАЕМ ГЛАЗА ИЗ НЕБЫТИЯ
            pupilsImageView.isHidden = false
            kittenEyeballsImageView.isHidden = false
            
            // Веки тоже делаем не скрытыми, но прозрачными (чтобы работало моргание)
            kittenEyelidsImageView.isHidden = false
            kittenEyelidsImageView.alpha = 0.0
        // Сбрасываем положение зрачков в центр
            pupilsImageView.transform = .identity
        
        prepareCatForNewGame()
        
        // 3. УПРАВЛЯЕМ КНОПКАМИ:
        // Показываем игровые кнопки
        pauseButton.isHidden = false
        levelButton.isHidden = false
        
        // Прячем кнопки победы
        playButton.isHidden = true
        reloadButton.isHidden = true
        
        // 4. Возвращаем игровые элементы
        foodButtons.forEach { $0.isHidden = false }
        targetViews.forEach { $0.isHidden = false }
        
        // 5. Сбрасываем котика и обновляем уровень
        catImageView.image = UIImage(named: "Test_Kitten")
        viewModel.generateLevel()
        updateUI()
    }
    
    
    // движение глаз
    func updatePupilsPosition(to targetPoint: CGPoint) {
        // 1. ПЕРЕВОДИМ координату пальца из системы экрана в систему координат РОДИТЕЛЯ зрачков
        // Это уберет прыжки, если зрачки вложены в другую картинку
        guard let parent = pupilsImageView.superview else { return }
        let targetInParentCoords = parent.convert(targetPoint, from: self.view)

        // 2. Считаем вектор от центра (где зрачок должен быть по дефолту) до пальца
        let dx = targetInParentCoords.x - pupilsImageView.center.x
        let dy = targetInParentCoords.y - pupilsImageView.center.y
        
        let distance = sqrt(dx * dx + dy * dy)
        if distance == 0 { return }

        // 3. ОГРАНИЧЕНИЯ (чтобы зрачок не вывалился из глаза)
        let maxDistance: CGFloat = 8.0 // Максимальный сдвиг в пикселях
        let movement = min(maxDistance, distance / 10.0)
        let ratio = movement / distance
        
        let finalX = dx * ratio
        let finalY = dy * ratio
        
        // 4. Двигаем через transform (это не меняет реальный .center)
        self.pupilsImageView.transform = CGAffineTransform(translationX: finalX, y: finalY)
    }
    
    func prepareCatForNewGame() {
        // 1. Мгновенно убираем смещение
        self.pupilsImageView.transform = .identity
        
        // 2. Возвращаем кота и видимость
        self.catImageView.image = UIImage(named: "Test_Kitten")
        self.pupilsImageView.isHidden = false
        self.kittenEyeballsImageView.isHidden = false
        self.kittenEyelidsImageView.isHidden = false
        self.kittenEyelidsImageView.alpha = 0.0
        
        // 3. Принудительно обновляем геометрию
        self.view.layoutIfNeeded()
        
        // 4. Перезахватываем центр на всякий случай
       // self.pupilsInitialCenter = self.pupilsImageView.center
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Захватываем центр ТОЛЬКО один раз, когда констрейнты (-78) уже применились
        if pupilsInitialCenter == .zero {
            pupilsInitialCenter = pupilsImageView.center
            print("✅ Центр зрачков зафиксирован: \(pupilsInitialCenter)")
        }
    }
    
    
}
