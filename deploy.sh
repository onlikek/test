#!/usr/bin/env bash
set -e

# === Функция для выбора Python ===
get_python_cmd() {
    if command -v py &>/dev/null; then
        echo "py"
    elif command -v python3 &>/dev/null; then
        echo "python3"
    else
        echo "python"
    fi
}

# === Ввод пользователя ===
read -p "Введите URL репозитория: " REPO_URL
read -p "Введите ветку: " BRANCH
read -p "Введите папку для деплоя (по умолчанию ./app_deploy): " TARGET_DIR
TARGET_DIR=${TARGET_DIR:-./app_deploy}

PYTHON_CMD=$(get_python_cmd)

echo
echo "Repo: $REPO_URL"
echo "Branch: $BRANCH"
echo "Dir: $TARGET_DIR"
echo "Python: $PYTHON_CMD"
echo

# === Клонирование / обновление репозитория ===
if [ -d "$TARGET_DIR/.git" ]; then
    echo "Обновляю ветку $BRANCH..."
    cd "$TARGET_DIR"
    git fetch origin "$BRANCH"
    git checkout "$BRANCH"
    git pull origin "$BRANCH"
    cd ..
else
    echo "Клонирую $REPO_URL ($BRANCH)..."
    git clone --branch "$BRANCH" "$REPO_URL" "$TARGET_DIR"
fi

# === Виртуальное окружение ===
echo "Создаю виртуальное окружение..."
$PYTHON_CMD -m venv "$TARGET_DIR/.venv"
source "$TARGET_DIR/.venv/Scripts/activate" 2>/dev/null || source "$TARGET_DIR/.venv/bin/activate"

# === Установка зависимостей ===
if [ -f "$TARGET_DIR/requirements.txt" ]; then
    echo "Устанавливаю зависимости из requirements.txt..."
    python -m pip install --upgrade pip
    pip install -r "$TARGET_DIR/requirements.txt"
else
    echo "⚠️ requirements.txt не найден. Пропускаю установку зависимостей."
fi

# === Выбор скрипта для запуска ===
echo
echo "Файлы в папке $TARGET_DIR:"
ls "$TARGET_DIR"
echo
read -p "Введите имя скрипта для запуска (например app.py): " SCRIPT_NAME

SCRIPT_PATH="$TARGET_DIR/$SCRIPT_NAME"
if [ ! -f "$SCRIPT_PATH" ]; then
    echo "❌ Файл $SCRIPT_NAME не найден!"
    exit 1
fi

# === Запуск выбранного скрипта ===
echo "Запускаю $SCRIPT_NAME..."
$PYTHON_CMD "$SCRIPT_PATH"
