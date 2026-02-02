import SwiftUI
import EventKit
import Combine
import AudioToolbox

// MARK: - 1. ЛОКАЛИЗАЦИЯ И НАСТРОЙКИ

enum Language: String, CaseIterable, Identifiable {
    case en = "English"
    case ru = "Русский"
    case es = "Español"
    var id: String { self.rawValue }
}

class AppSettings: ObservableObject {
    @AppStorage("isDarkMode") var isDarkMode: Bool = true
    @AppStorage("selectedLanguage") var languageString: String = "ru"
    
    var language: Language {
        get { Language(rawValue: languageString) ?? .en }
        set { languageString = newValue.rawValue }
    }
    
    // СЛОВАРЬ ПЕРЕВОДОВ
    let translations: [String: [Language: String]] = [
        // ИНТЕРФЕЙС
        "tab_tasks": [.en: "Tasks", .ru: "Задачи", .es: "Tareas"],
        "tab_goals": [.en: "Goals", .ru: "Цели", .es: "Metas"],
        "tab_tips": [.en: "Tips", .ru: "Советы", .es: "Consejos"],
        "tab_settings": [.en: "Settings", .ru: "Настройки", .es: "Ajustes"],
        "my_templates": [.en: "My Templates", .ru: "Мои Шаблоны", .es: "Mis Plantillas"],
        "new_task": [.en: "New Task", .ru: "Новая Задача", .es: "Nueva Tarea"],
        "edit_task": [.en: "Edit Task", .ru: "Редактировать", .es: "Editar"],
        "task_name": [.en: "Task Name", .ru: "Название задачи", .es: "Nombre de la tarea"],
        "duration": [.en: "Duration", .ru: "Длительность", .es: "Duración"],
        "icon": [.en: "Icon", .ru: "Иконка", .es: "Icono"],
        "cancel": [.en: "Cancel", .ru: "Отмена", .es: "Cancelar"],
        "save": [.en: "Save", .ru: "Сохранить", .es: "Guardar"],
        "schedule": [.en: "Schedule", .ru: "Планирование", .es: "Planificar"],
        "start_time": [.en: "Start Time", .ru: "Время начала", .es: "Hora de inicio"],
        "repeat": [.en: "Repeat", .ru: "Повтор", .es: "Repetir"],
        "add_to_calendar": [.en: "Add to Calendar", .ru: "Добавить в календарь", .es: "Añadir"],
        "success": [.en: "Success!", .ru: "Успешно!", .es: "¡Éxito!"],
        "dark_mode": [.en: "Dark Mode", .ru: "Тёмная тема", .es: "Modo Oscuro"],
        "language": [.en: "Language", .ru: "Язык", .es: "Idioma"],
        "appearance": [.en: "Appearance", .ru: "Внешний вид", .es: "Apariencia"],
        "hours": [.en: "h", .ru: "ч", .es: "h"],
        "minutes": [.en: "m", .ru: "м", .es: "m"],
        
        // ПОВТОРЫ
        "rep_once": [.en: "Once", .ru: "Один раз", .es: "Una vez"],
        "rep_daily": [.en: "Daily", .ru: "Ежедневно", .es: "Diariamente"],
        "rep_weekly": [.en: "Weekly", .ru: "Еженедельно", .es: "Semanalmente"],
        "rep_monthly": [.en: "Monthly", .ru: "Ежемесячно", .es: "Mensualmente"],
        "rep_yearly": [.en: "Yearly", .ru: "Ежегодно", .es: "Anualmente"],

        // КАТЕГОРИИ ЦЕЛЕЙ
        "cat_health": [.en: "Health & Energy", .ru: "Здоровье и энергия", .es: "Salud y Energía"],
        "cat_nutrition": [.en: "Nutrition & Body", .ru: "Питание и тело", .es: "Nutrición y Cuerpo"],
        "cat_work": [.en: "Work & Money", .ru: "Работа и деньги", .es: "Trabajo y Dinero"],
        "cat_self": [.en: "Self-Development", .ru: "Саморазвитие", .es: "Autodesarrollo"],
        "cat_lang": [.en: "Languages", .ru: "Языки", .es: "Idiomas"],
        "cat_hobby": [.en: "Hobbies & Skills", .ru: "Хобби и навыки", .es: "Hobbies y Habilidades"],
        "cat_mind": [.en: "Mind & Order", .ru: "Психика и порядок", .es: "Mente y Orden"],

        // ЗАДАЧИ (ЗДОРОВЬЕ)
        "t_wakeup": [.en: "Wake Up", .ru: "Утренний подъем", .es: "Despertar"],
        "t_water": [.en: "Glass of Water", .ru: "Стакан воды", .es: "Vaso de agua"],
        "t_charge": [.en: "Morning Exercise", .ru: "Утренняя зарядка", .es: "Ejercicio matutino"],
        "t_run_walk": [.en: "Run / Walk", .ru: "Бег / ходьба", .es: "Correr / Caminar"],
        "t_gym_train": [.en: "Gym Workout", .ru: "Тренировка в зале", .es: "Gimnasio"],
        "t_cardio": [.en: "Cardio", .ru: "Кардио", .es: "Cardio"],
        "t_stretch": [.en: "Stretching", .ru: "Растяжка", .es: "Estiramiento"],
        "t_breath": [.en: "Breathing Exercises", .ru: "Дыхательные упражнения", .es: "Respiración"],
        "t_walk": [.en: "Walk", .ru: "Прогулка", .es: "Paseo"],
        "t_sleep_prep": [.en: "Sleep Prep", .ru: "Сон (подготовка)", .es: "Prep. para dormir"],

        // ЗАДАЧИ (ПИТАНИЕ)
        "t_breakfast": [.en: "Breakfast", .ru: "Завтрак", .es: "Desayuno"],
        "t_lunch": [.en: "Lunch", .ru: "Обед", .es: "Almuerzo"],
        "t_dinner": [.en: "Dinner", .ru: "Ужин", .es: "Cena"],
        "t_meal_prep": [.en: "Meal Prep", .ru: "Подготовка еды", .es: "Prep. comida"],
        "t_calories": [.en: "Count Calories", .ru: "Подсчет калорий", .es: "Contar calorías"],
        "t_vitamins": [.en: "Vitamins", .ru: "Прием витаминов", .es: "Vitaminas"],
        "t_weighing": [.en: "Weighing", .ru: "Взвешивание", .es: "Pesaje"],
        "t_water_ctrl": [.en: "Water Control", .ru: "Контроль воды", .es: "Control de agua"],
        "t_protein": [.en: "Protein Intake", .ru: "Протеиновый прием", .es: "Proteína"],
        "t_detox_day": [.en: "Detox Day", .ru: "Разгрузочный день", .es: "Día de detox"],

        // ЗАДАЧИ (РАБОТА)
        "t_work_start": [.en: "Start Work", .ru: "Начало рабочего дня", .es: "Iniciar trabajo"],
        "t_plan_day": [.en: "Daily Planning", .ru: "Планирование дня", .es: "Plan diario"],
        "t_deep_work": [.en: "Deep Work", .ru: "Глубокая работа", .es: "Trabajo profundo"],
        "t_check_mail": [.en: "Check Email", .ru: "Проверка почты", .es: "Revisar correo"],
        "t_call_meet": [.en: "Call / Meeting", .ru: "Созвон / митинг", .es: "Reunión"],
        "t_report": [.en: "Report", .ru: "Отчет по задачам", .es: "Informe"],
        "t_project_work": [.en: "Project Work", .ru: "Работа над проектом", .es: "Proyecto"],
        "t_freelance": [.en: "Freelance Order", .ru: "Фриланс-заказ", .es: "Freelance"],
        "t_check_income": [.en: "Check Income", .ru: "Проверка доходов", .es: "Ingresos"],
        "t_budget_ctrl": [.en: "Budget Control", .ru: "Контроль бюджета", .es: "Presupuesto"],

        // ЗАДАЧИ (САМОРАЗВИТИЕ)
        "t_reading": [.en: "Reading", .ru: "Чтение", .es: "Lectura"],
        "t_study_lesson": [.en: "Study Lesson", .ru: "Обучение (урок)", .es: "Estudio"],
        "t_review_mat": [.en: "Review Material", .ru: "Повтор материала", .es: "Repaso"],
        "t_skill_prac": [.en: "Skill Practice", .ru: "Практика навыка", .es: "Práctica"],
        "t_analysis": [.en: "Error Analysis", .ru: "Анализ ошибок", .es: "Análisis"],
        "t_edu_video": [.en: "Edu Video", .ru: "Обучающее видео", .es: "Video edu"],
        "t_notes": [.en: "Take Notes", .ru: "Конспект", .es: "Notas"],
        "t_study_plan": [.en: "Study Plan", .ru: "План обучения", .es: "Plan de estudio"],
        "t_reflect": [.en: "Self-Reflection", .ru: "Саморефлексия", .es: "Autorreflexión"],
        "t_day_result": [.en: "Day Review", .ru: "Итоги дня", .es: "Resumen del día"],

        // ЗАДАЧИ (ЯЗЫКИ)
        "t_learn_words": [.en: "Learn Words", .ru: "Изучение слов", .es: "Aprender palabras"],
        "t_grammar": [.en: "Grammar", .ru: "Грамматика", .es: "Gramática"],
        "t_listening": [.en: "Listening", .ru: "Аудирование", .es: "Escuchar"],
        "t_speaking": [.en: "Speaking", .ru: "Разговорная практика", .es: "Hablar"],
        "t_rep_words": [.en: "Repeat Words", .ru: "Повтор слов", .es: "Repasar palabras"],
        "t_mini_test": [.en: "Mini Test", .ru: "Мини-тест", .es: "Mini prueba"],
        "t_film_video": [.en: "Film / Video", .ru: "Фильм / видео", .es: "Película"],
        "t_read_lang": [.en: "Reading", .ru: "Чтение", .es: "Leer"],
        "t_translate": [.en: "Translation", .ru: "Перевод текста", .es: "Traducción"],
        "t_pronounce": [.en: "Pronunciation", .ru: "Произношение", .es: "Pronunciación"],

        // ЗАДАЧИ (ХОББИ)
        "t_music_prac": [.en: "Music Practice", .ru: "Музыкальная практика", .es: "Música"],
        "t_drawing": [.en: "Drawing", .ru: "Рисование", .es: "Dibujo"],
        "t_coding": [.en: "Coding", .ru: "Кодинг", .es: "Programación"],
        "t_pet_project": [.en: "Pet Project", .ru: "Пет-проект", .es: "Proyecto personal"],
        "t_writing": [.en: "Creative Writing", .ru: "Креативное письмо", .es: "Escritura"],
        "t_photo_video": [.en: "Photo / Video", .ru: "Фото / видео", .es: "Foto / Video"],
        "t_instrument": [.en: "Instrument", .ru: "Инструмент", .es: "Instrumento"],
        "t_rehearsal": [.en: "Rehearsal", .ru: "Репетиция", .es: "Ensayo"],
        "t_publish": [.en: "Publish Result", .ru: "Публикация результата", .es: "Publicar"],
        "t_prog_analysis": [.en: "Progress Analysis", .ru: "Анализ прогресса", .es: "Progreso"],

        // ЗАДАЧИ (ПСИХИКА)
        "t_meditation": [.en: "Meditation", .ru: "Медитация", .es: "Meditación"],
        "t_journal": [.en: "Journal", .ru: "Дневник", .es: "Diario"],
        "t_week_plan": [.en: "Weekly Plan", .ru: "План недели", .es: "Plan semanal"],
        "t_cleaning": [.en: "Cleaning", .ru: "Уборка", .es: "Limpieza"],
        "t_sort_tasks": [.en: "Sort Tasks", .ru: "Разбор задач", .es: "Organizar tareas"],
        "t_no_screen": [.en: "No Screen Rest", .ru: "Отдых без экрана", .es: "Relax sin pantalla"],
        "t_me_time": [.en: "Me Time", .ru: "Время для себя", .es: "Tiempo para mí"],
        "t_dig_detox": [.en: "Digital Detox", .ru: "Цифровой детокс", .es: "Detox digital"],
        "t_gratitude": [.en: "Gratitude", .ru: "Благодарности", .es: "Gratitud"],
        "t_restore": [.en: "Recovery", .ru: "Восстановление", .es: "Recuperación"],
        
        // ШАБЛОНЫ ПО УМОЛЧАНИЮ
        "tmpl_work": [.en: "Work", .ru: "Работа", .es: "Trabajo"],
        "tmpl_study": [.en: "Study", .ru: "Учеба", .es: "Estudio"],
        "tmpl_part_time": [.en: "Part-time", .ru: "Подработка", .es: "Medio tiempo"],
        "tmpl_workout": [.en: "Workout", .ru: "Тренировка", .es: "Entrenamiento"],
        "tmpl_reading": [.en: "Reading", .ru: "Чтение", .es: "Lectura"],
        "tmpl_movie": [.en: "Movie", .ru: "Просмотр фильмов", .es: "Ver película"],
        
        // --- СОВЕТЫ (ВОССТАНОВЛЕНЫ) ---
        "tip_eisenhower_title": [.en: "Eisenhower Matrix", .ru: "Матрица Эйзенхауэра", .es: "Matriz de Eisenhower"],
        "tip_eisenhower_body": [.en: "Urgent/Important tasks.", .ru: "Делите задачи: Срочно/Важно, Важно/Не срочно.", .es: "Tareas Urgentes/Importantes."],
        
        "tip_pomodoro_title": [.en: "Pomodoro", .ru: "Метод Помодоро", .es: "Pomodoro"],
        "tip_pomodoro_body": [.en: "25 min work, 5 min break.", .ru: "25 мин работы, 5 мин отдыха. 4 цикла.", .es: "25 min trabajo, 5 descanso."],
        
        "tip_frog_title": [.en: "Eat The Frog", .ru: "Съешь лягушку", .es: "Cómete la rana"],
        "tip_frog_body": [.en: "Do hard tasks first.", .ru: "Сложное дело — первым с утра.", .es: "Haz lo difícil primero."],
        
        "tip_135_title": [.en: "1-3-5 Rule", .ru: "Правило 1-3-5", .es: "Regla 1-3-5"],
        "tip_135_body": [.en: "1 Big, 3 Medium, 5 Small tasks.", .ru: "1 Большая, 3 Средних, 5 Мелких задач в день.", .es: "1 Grande, 3 Medianas, 5 Pequeñas."],
        
        "tip_2min_title": [.en: "2-Minute Rule", .ru: "Правило 2 минут", .es: "Regla de 2 min"],
        "tip_2min_body": [.en: "Do short tasks now.", .ru: "Если дело на 2 минуты — делай сразу.", .es: "Haz tareas cortas ya."],
        
        "tip_rest_title": [.en: "Smart Rest", .ru: "Умный отдых", .es: "Descanso"],
        "tip_rest_body": [.en: "Schedule your rest.", .ru: "Планируйте отдых как работу.", .es: "Agenda tu descanso."]
    ]
    
    func t(_ key: String) -> String {
        return translations[key]?[language] ?? key
    }
}

// MARK: - 2. МОДЕЛИ ДАННЫХ

struct TaskTemplate: Identifiable, Codable, Equatable, Hashable {
    var id = UUID(); var title: String; var emoji: String; var durationMinutes: Int
}

struct GoalCategory: Identifiable {
    let id = UUID()
    let titleKey: String
    let icon: String
    let color: Color
    let presets: [TaskTemplate]
}

class GoalsDataManager {
    static func getGoals() -> [GoalCategory] {
        return [
            // 🧠 Здоровье и энергия
            GoalCategory(titleKey: "cat_health", icon: "bolt.heart.fill", color: .red, presets: [
                TaskTemplate(title: "t_wakeup", emoji: "🌅", durationMinutes: 5),
                TaskTemplate(title: "t_water", emoji: "💧", durationMinutes: 1),
                TaskTemplate(title: "t_charge", emoji: "🤸", durationMinutes: 5),
                TaskTemplate(title: "t_run_walk", emoji: "🏃", durationMinutes: 10),
                TaskTemplate(title: "t_gym_train", emoji: "🏋️", durationMinutes: 20),
                TaskTemplate(title: "t_cardio", emoji: "💓", durationMinutes: 10),
                TaskTemplate(title: "t_stretch", emoji: "🧘", durationMinutes: 5),
                TaskTemplate(title: "t_breath", emoji: "😮‍💨", durationMinutes: 3),
                TaskTemplate(title: "t_walk", emoji: "🚶", durationMinutes: 10),
                TaskTemplate(title: "t_sleep_prep", emoji: "😴", durationMinutes: 10)
            ]),
            
            // 🥗 Питание и тело
            GoalCategory(titleKey: "cat_nutrition", icon: "leaf.fill", color: .green, presets: [
                TaskTemplate(title: "t_breakfast", emoji: "🍳", durationMinutes: 10),
                TaskTemplate(title: "t_lunch", emoji: "🍲", durationMinutes: 15),
                TaskTemplate(title: "t_dinner", emoji: "🥗", durationMinutes: 15),
                TaskTemplate(title: "t_meal_prep", emoji: "🔪", durationMinutes: 20),
                TaskTemplate(title: "t_calories", emoji: "📱", durationMinutes: 3),
                TaskTemplate(title: "t_vitamins", emoji: "💊", durationMinutes: 1),
                TaskTemplate(title: "t_weighing", emoji: "⚖️", durationMinutes: 1),
                TaskTemplate(title: "t_water_ctrl", emoji: "🥤", durationMinutes: 1),
                TaskTemplate(title: "t_protein", emoji: "🥩", durationMinutes: 2),
                TaskTemplate(title: "t_detox_day", emoji: "🍏", durationMinutes: 5)
            ]),
            
            // 💼 Работа и деньги
            GoalCategory(titleKey: "cat_work", icon: "briefcase.fill", color: .blue, presets: [
                TaskTemplate(title: "t_work_start", emoji: "🚀", durationMinutes: 5),
                TaskTemplate(title: "t_plan_day", emoji: "📝", durationMinutes: 5),
                TaskTemplate(title: "t_deep_work", emoji: "🧠", durationMinutes: 25),
                TaskTemplate(title: "t_check_mail", emoji: "📧", durationMinutes: 5),
                TaskTemplate(title: "t_call_meet", emoji: "🤝", durationMinutes: 10),
                TaskTemplate(title: "t_report", emoji: "📊", durationMinutes: 5),
                TaskTemplate(title: "t_project_work", emoji: "🏗", durationMinutes: 20),
                TaskTemplate(title: "t_freelance", emoji: "💻", durationMinutes: 15),
                TaskTemplate(title: "t_check_income", emoji: "💰", durationMinutes: 5),
                TaskTemplate(title: "t_budget_ctrl", emoji: "💳", durationMinutes: 10)
            ]),
            
            // 📚 Саморазвитие
            GoalCategory(titleKey: "cat_self", icon: "book.fill", color: .orange, presets: [
                TaskTemplate(title: "t_reading", emoji: "📖", durationMinutes: 10),
                TaskTemplate(title: "t_study_lesson", emoji: "🎓", durationMinutes: 15),
                TaskTemplate(title: "t_review_mat", emoji: "🔄", durationMinutes: 5),
                TaskTemplate(title: "t_skill_prac", emoji: "🛠", durationMinutes: 15),
                TaskTemplate(title: "t_analysis", emoji: "🧐", durationMinutes: 5),
                TaskTemplate(title: "t_edu_video", emoji: "▶️", durationMinutes: 10),
                TaskTemplate(title: "t_notes", emoji: "✍️", durationMinutes: 5),
                TaskTemplate(title: "t_study_plan", emoji: "📅", durationMinutes: 10),
                TaskTemplate(title: "t_reflect", emoji: "🤔", durationMinutes: 5),
                TaskTemplate(title: "t_day_result", emoji: "✅", durationMinutes: 5)
            ]),
            
            // 🌍 Языки
            GoalCategory(titleKey: "cat_lang", icon: "globe", color: .cyan, presets: [
                TaskTemplate(title: "t_learn_words", emoji: "🔤", durationMinutes: 5),
                TaskTemplate(title: "t_grammar", emoji: "📚", durationMinutes: 10),
                TaskTemplate(title: "t_listening", emoji: "🎧", durationMinutes: 5),
                TaskTemplate(title: "t_speaking", emoji: "🗣", durationMinutes: 10),
                TaskTemplate(title: "t_rep_words", emoji: "🔁", durationMinutes: 3),
                TaskTemplate(title: "t_mini_test", emoji: "📝", durationMinutes: 5),
                TaskTemplate(title: "t_film_video", emoji: "🎬", durationMinutes: 15),
                TaskTemplate(title: "t_read_lang", emoji: "📰", durationMinutes: 10),
                TaskTemplate(title: "t_translate", emoji: "🔄", durationMinutes: 5),
                TaskTemplate(title: "t_pronounce", emoji: "🎙", durationMinutes: 5)
            ]),
            
            // 🎵 Хобби и навыки
            GoalCategory(titleKey: "cat_hobby", icon: "paintpalette.fill", color: .purple, presets: [
                TaskTemplate(title: "t_music_prac", emoji: "🎵", durationMinutes: 10),
                TaskTemplate(title: "t_drawing", emoji: "🎨", durationMinutes: 10),
                TaskTemplate(title: "t_coding", emoji: "👨‍💻", durationMinutes: 15),
                TaskTemplate(title: "t_pet_project", emoji: "🚀", durationMinutes: 20),
                TaskTemplate(title: "t_writing", emoji: "✍️", durationMinutes: 10),
                TaskTemplate(title: "t_photo_video", emoji: "📸", durationMinutes: 10),
                TaskTemplate(title: "t_instrument", emoji: "🎸", durationMinutes: 10),
                TaskTemplate(title: "t_rehearsal", emoji: "🎭", durationMinutes: 15),
                TaskTemplate(title: "t_publish", emoji: "📢", durationMinutes: 5),
                TaskTemplate(title: "t_prog_analysis", emoji: "📈", durationMinutes: 5)
            ]),
            
            // 🧘 Психика и порядок
            GoalCategory(titleKey: "cat_mind", icon: "sparkles", color: .indigo, presets: [
                TaskTemplate(title: "t_meditation", emoji: "🧘‍♂️", durationMinutes: 3),
                TaskTemplate(title: "t_journal", emoji: "📔", durationMinutes: 5),
                TaskTemplate(title: "t_week_plan", emoji: "🗓", durationMinutes: 10),
                TaskTemplate(title: "t_cleaning", emoji: "🧹", durationMinutes: 10),
                TaskTemplate(title: "t_sort_tasks", emoji: "🗂", durationMinutes: 5),
                TaskTemplate(title: "t_no_screen", emoji: "🌴", durationMinutes: 10),
                TaskTemplate(title: "t_me_time", emoji: "💆‍♂️", durationMinutes: 10),
                TaskTemplate(title: "t_dig_detox", emoji: "📵", durationMinutes: 5),
                TaskTemplate(title: "t_gratitude", emoji: "🙏", durationMinutes: 3),
                TaskTemplate(title: "t_restore", emoji: "🔋", durationMinutes: 10)
            ])
        ]
    }
}

class TemplateManager: ObservableObject {
    @Published var templates: [TaskTemplate] = [] { didSet { save() } }
    
    init() {
        if let data = UserDefaults.standard.data(forKey: "v34_templates"),
           let decoded = try? JSONDecoder().decode([TaskTemplate].self, from: data) {
            templates = decoded
        } else {
            templates = [
                TaskTemplate(title: "tmpl_work", emoji: "💼", durationMinutes: 480),
                TaskTemplate(title: "tmpl_study", emoji: "🎓", durationMinutes: 420),
                TaskTemplate(title: "tmpl_part_time", emoji: "💸", durationMinutes: 120),
                TaskTemplate(title: "tmpl_workout", emoji: "🏋️", durationMinutes: 60),
                TaskTemplate(title: "tmpl_reading", emoji: "📖", durationMinutes: 30),
                TaskTemplate(title: "tmpl_movie", emoji: "🎬", durationMinutes: 120)
            ]
        }
    }
    
    func add(_ template: TaskTemplate) { templates.append(template) }
    
    func update(_ template: TaskTemplate) {
        if let index = templates.firstIndex(where: { $0.id == template.id }) {
            templates[index] = template
        }
    }
    
    func delete(at offsets: IndexSet) { templates.remove(atOffsets: offsets) }
    func save() { if let encoded = try? JSONEncoder().encode(templates) { UserDefaults.standard.set(encoded, forKey: "v34_templates") } }
}

// MARK: - 3. UI COMPONENTS

struct DurationPickerView: View {
    @Binding var minutes: Int
    
    var body: some View {
        HStack {
            Picker("Hours", selection: Binding(
                get: { minutes / 60 },
                set: { minutes = $0 * 60 + (minutes % 60) }
            )) {
                ForEach(0..<24) { h in Text("\(h) ч").tag(h) }
            }
            .pickerStyle(.wheel)
            .frame(width: 80).clipped()
            
            Picker("Minutes", selection: Binding(
                get: { minutes % 60 },
                set: { minutes = (minutes / 60) * 60 + $0 }
            )) {
                ForEach(stride(from: 0, to: 60, by: 1).map { $0 }, id: \.self) { m in
                    Text("\(m) мин").tag(m)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 80).clipped()
        }
        .frame(height: 120)
    }
}

// MARK: - 4. MAIN VIEWS

struct ContentView: View {
    @State private var showSplash = true
    @StateObject var settings = AppSettings()
    
    var body: some View {
        if showSplash {
            SplashScreen(isActive: $showSplash)
        } else {
            MainAppView(settings: settings)
                .preferredColorScheme(settings.isDarkMode ? .dark : .light)
        }
    }
}

struct SplashScreen: View {
    @Binding var isActive: Bool
    @State private var opacity = 0.0
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground).ignoresSafeArea()
            VStack {
                Image(systemName: "calendar.badge.plus")
                    .resizable().scaledToFit().frame(width: 100)
                    .foregroundColor(.blue)
                Text("calenTask").font(.largeTitle).bold().padding(.top)
            }
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.easeIn(duration: 1.0)) { opacity = 1.0 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation { isActive = false }
            }
        }
    }
}

struct MainAppView: View {
    @ObservedObject var settings: AppSettings
    @StateObject var templates = TemplateManager()
    
    var body: some View {
        TabView {
            HomeView(templates: templates, settings: settings)
                .tabItem { Label(settings.t("tab_tasks"), systemImage: "checklist") }
            GoalsView(settings: settings, templates: templates)
                .tabItem { Label(settings.t("tab_goals"), systemImage: "target") }
            TipsView(settings: settings)
                .tabItem { Label(settings.t("tab_tips"), systemImage: "lightbulb.fill") }
            SettingsView(settings: settings)
                .tabItem { Label(settings.t("tab_settings"), systemImage: "gear") }
        }
        .accentColor(.blue)
    }
}

// MARK: - 5. HOME VIEW (TASKS)

struct HomeView: View {
    @ObservedObject var templates: TemplateManager
    @ObservedObject var settings: AppSettings
    @State private var selectedTemplate: TaskTemplate?
    @State private var templateToEdit: TaskTemplate?
    @State private var isCreatingNew = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                List {
                    Section(header: Text(settings.t("my_templates"))) {
                        ForEach(templates.templates) { template in
                            HStack {
                                Button(action: { selectedTemplate = template }) {
                                    HStack(spacing: 12) {
                                        Text(template.emoji).font(.system(size: 42))
                                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                                        VStack(alignment: .leading, spacing: 0) {
                                            Text(settings.t(template.title)).font(.headline).foregroundColor(.primary)
                                            Text(formatDuration(template.durationMinutes)).font(.subheadline).foregroundColor(.secondary)
                                        }
                                    }
                                }
                                Spacer()
                                Button(action: { templateToEdit = template }) {
                                    Image(systemName: "pencil.circle").font(.title2).foregroundColor(.blue.opacity(0.7)).padding(.leading, 10)
                                }.buttonStyle(.borderless)
                            }
                            .padding(.vertical, 4)
                        }
                        .onDelete { templates.delete(at: $0) }
                    }
                }
                .listStyle(.insetGrouped)
                
                Button(action: { isCreatingNew = true }) {
                    Image(systemName: "plus").font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white).frame(width: 60, height: 60)
                        .background(Color.blue).clipShape(Circle())
                        .shadow(radius: 4)
                }
                .padding()
            }
            .navigationTitle("calenTask")
            .sheet(item: $selectedTemplate) { template in ScheduleTaskSheet(template: template, settings: settings) }
            .sheet(isPresented: $isCreatingNew) { CreateTaskView(manager: templates, settings: settings) }
            .sheet(item: $templateToEdit) { template in CreateTaskView(manager: templates, settings: settings, taskToEdit: template) }
        }
    }
    
    func formatDuration(_ m: Int) -> String {
        let h = m / 60; let min = m % 60
        if h > 0 && min > 0 { return "\(h)\(settings.t("hours")) \(min)\(settings.t("minutes"))" }
        if h > 0 { return "\(h)\(settings.t("hours"))" }
        return "\(min)\(settings.t("minutes"))"
    }
}

// MARK: - 6. GOALS VIEW (NEW LOGIC)

struct GoalsView: View {
    @ObservedObject var settings: AppSettings
    @ObservedObject var templates: TemplateManager
    @State private var selectedGoalTask: TaskTemplate?
    let goals = GoalsDataManager.getGoals()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(goals) { goal in
                    Section(header: Label(settings.t(goal.titleKey), systemImage: goal.icon).foregroundColor(goal.color)) {
                        ForEach(goal.presets) { task in
                            Button(action: {
                                selectedGoalTask = TaskTemplate(title: settings.t(task.title), emoji: task.emoji, durationMinutes: task.durationMinutes)
                            }) {
                                HStack {
                                    Text(task.emoji).font(.title)
                                    VStack(alignment: .leading) {
                                        Text(settings.t(task.title)).font(.body)
                                        Text("\(task.durationMinutes) \(settings.t("minutes"))").font(.caption).foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Image(systemName: "plus.circle").foregroundColor(.blue.opacity(0.6))
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(settings.t("tab_goals"))
            .sheet(item: $selectedGoalTask) { task in
                CreateTaskView(manager: templates, settings: settings, prefilledTask: task)
            }
        }
    }
}

// MARK: - 7. CREATE / EDIT TASK

struct CreateTaskView: View {
    @ObservedObject var manager: TemplateManager
    @ObservedObject var settings: AppSettings
    var prefilledTask: TaskTemplate? = nil
    var taskToEdit: TaskTemplate? = nil
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var emoji = "📝"
    @State private var duration = 30
    
    let quickEmojis = ["💼", "🏋️", "🎓", "🛒", "💊", "✈️", "🧹", "🎮", "🎬", "📖", "🕌", "🙏"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(settings.t("task_name"))) { TextField("...", text: $title) }
                Section(header: Text(settings.t("duration"))) {
                    DurationPickerView(minutes: $duration)
                }
                Section(header: Text(settings.t("icon"))) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(quickEmojis, id: \.self) { e in
                                Button(action: { emoji = e }) {
                                    Text(e).font(.largeTitle).padding(5).background(emoji == e ? Color.blue.opacity(0.2) : Color.clear).cornerRadius(8)
                                }.buttonStyle(.plain)
                            }
                        }
                    }
                    TextField("Emoji", text: $emoji).onChange(of: emoji) { val in if val.count > 1 { emoji = String(val.last!) } }
                }
            }
            .navigationTitle(taskToEdit != nil ? settings.t("edit_task") : settings.t("new_task"))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(settings.t("save")) {
                        if let existing = taskToEdit {
                            var updated = existing; updated.title = title; updated.emoji = emoji; updated.durationMinutes = duration; manager.update(updated)
                        } else {
                            manager.add(TaskTemplate(title: title.isEmpty ? "Task" : title, emoji: emoji, durationMinutes: duration))
                        }
                        let gen = UINotificationFeedbackGenerator(); gen.notificationOccurred(.success); dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) { Button(settings.t("cancel")) { dismiss() } }
            }
            .onAppear {
                if let t = taskToEdit ?? prefilledTask {
                    title = settings.t(t.title)
                    emoji = t.emoji
                    duration = t.durationMinutes
                }
            }
        }
    }
}

// MARK: - 8. SCHEDULE SHEET

struct ScheduleTaskSheet: View {
    var template: TaskTemplate
    @ObservedObject var settings: AppSettings
    @Environment(\.dismiss) var dismiss
    @State private var date = Date()
    @State private var duration: Int = 60
    @State private var repeatOption = 0
    let eventStore = EKEventStore()
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Text(template.emoji).font(.largeTitle)
                        Text(settings.t(template.title)).font(.headline)
                    }
                }
                Section(header: Text(settings.t("start_time"))) { DatePicker("", selection: $date).labelsHidden() }
                
                Section(header: Text(settings.t("duration"))) {
                    DurationPickerView(minutes: $duration)
                }
                
                Section(header: Text(settings.t("repeat"))) {
                    Picker("", selection: $repeatOption) {
                        Text(settings.t("rep_once")).tag(0); Text(settings.t("rep_daily")).tag(1); Text(settings.t("rep_weekly")).tag(2); Text(settings.t("rep_monthly")).tag(3); Text(settings.t("rep_yearly")).tag(4)
                    }
                }
                Section {
                    Button(settings.t("add_to_calendar")) { scheduleEvent() }.frame(maxWidth: .infinity).foregroundColor(.blue)
                }
            }
            .navigationTitle(settings.t("schedule"))
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button(settings.t("cancel")) { dismiss() } } }
            .onAppear { duration = template.durationMinutes }
        }
    }
    
    func scheduleEvent() {
        eventStore.requestAccess(to: .event) { granted, _ in
            if granted {
                let event = EKEvent(eventStore: eventStore)
                event.title = settings.t(template.title)
                event.startDate = date
                event.endDate = date.addingTimeInterval(Double(duration * 60))
                event.calendar = eventStore.defaultCalendarForNewEvents
                
                switch repeatOption {
                case 1: event.addRecurrenceRule(EKRecurrenceRule(recurrenceWith: .daily, interval: 1, end: nil))
                case 2: event.addRecurrenceRule(EKRecurrenceRule(recurrenceWith: .weekly, interval: 1, end: nil))
                case 3: event.addRecurrenceRule(EKRecurrenceRule(recurrenceWith: .monthly, interval: 1, end: nil))
                case 4: event.addRecurrenceRule(EKRecurrenceRule(recurrenceWith: .yearly, interval: 1, end: nil))
                default: break
                }
                try? eventStore.save(event, span: .thisEvent)
                DispatchQueue.main.async { let gen = UINotificationFeedbackGenerator(); gen.notificationOccurred(.success); dismiss() }
            }
        }
    }
}

// MARK: - 9. TIPS VIEW (RESTORED)

struct TipsView: View {
    @ObservedObject var settings: AppSettings
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Совет 1: Эйзенхауэр
                    TipCard(icon: "square.grid.2x2.fill", title: settings.t("tip_eisenhower_title"), bodyText: settings.t("tip_eisenhower_body"), color: .purple)
                    
                    // Совет 2: Помодоро
                    TipCard(icon: "timer", title: settings.t("tip_pomodoro_title"), bodyText: settings.t("tip_pomodoro_body"), color: .red)
                    
                    // Совет 3: Лягушка
                    TipCard(icon: "hare.fill", title: settings.t("tip_frog_title"), bodyText: settings.t("tip_frog_body"), color: .green)
                    
                    // Совет 4: 1-3-5
                    TipCard(icon: "list.number", title: settings.t("tip_135_title"), bodyText: settings.t("tip_135_body"), color: .blue)
                    
                    // Совет 5: 2 минуты
                    TipCard(icon: "hourglass", title: settings.t("tip_2min_title"), bodyText: settings.t("tip_2min_body"), color: .orange)
                    
                    // Совет 6: Отдых
                    TipCard(icon: "moon.zzz.fill", title: settings.t("tip_rest_title"), bodyText: settings.t("tip_rest_body"), color: .indigo)
                }
                .padding()
            }
            .navigationTitle(settings.t("tab_tips"))
        }
    }
}

struct TipCard: View {
    var icon: String; var title: String; var bodyText: String; var color: Color
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon).font(.largeTitle).foregroundColor(color).frame(width: 40)
            VStack(alignment: .leading, spacing: 5) {
                Text(title).font(.headline)
                Text(bodyText).font(.subheadline).foregroundColor(.secondary).fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - 10. SETTINGS

struct SettingsView: View {
    @ObservedObject var settings: AppSettings
    var body: some View {
        NavigationView {
            List {
                Section(header: Text(settings.t("appearance"))) {
                    Toggle(settings.t("dark_mode"), isOn: $settings.isDarkMode)
                    Picker(settings.t("language"), selection: $settings.languageString) {
                        ForEach(Language.allCases) { lang in Text(lang.rawValue).tag(lang.rawValue) }
                    }
                }
                Section { Text("calenTask v34.0").foregroundColor(.gray) }
            }
            .navigationTitle(settings.t("tab_settings"))
        }
    }
}

#Preview { ContentView() }
