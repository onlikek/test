#!/bin/bash
set -e

REPO_URL=$1
BRANCH=$2
FRAMEWORK=$3
PORT=$4

APP_DIR="./app_deploy"
PYTHON="py"

echo "=========================="
echo "Репозиторий: $REPO_URL"
echo "Ветка: $BRANCH"
echo "Фреймворк: $FRAMEWORK"
echo "Порт: $PORT"
echo "Папка: $APP_DIR"
echo "Python: $PYTHON"
echo "=========================="

# Клонируем или обновляем репозиторий
if [ ! -d "$APP_DIR/.git" ]; then
  echo "Клонирую репозиторий..."
  git clone -b "$BRANCH" "$REPO_URL" "$APP_DIR"
else
  echo "Папка $APP_DIR уже содержит git. Обновляю ветку $BRANCH..."
  cd "$APP_DIR"
  git fetch origin "$BRANCH"
  git checkout "$BRANCH"
  git pull origin "$BRANCH"
  cd ..
fi

# Создаём виртуальное окружение
echo "Создаю виртуальное окружение..."
$PYTHON -m venv "$APP_DIR/.venv"

# Активируем окружение
source "$APP_DIR/.venv/Scripts/activate"

# Устанавливаем зависимости
if [ -f "$APP_DIR/requirements.txt" ]; then
  echo "Устанавливаю зависимости..."
  pip install -r "$APP_DIR/requirements.txt"
else
  echo "⚠️ requirements.txt не найден — устанавливаю flask/django вручную..."
  if [ "$FRAMEWORK" == "flask" ]; then
    pip install flask
  elif [ "$FRAMEWORK" == "django" ]; then
    pip install django
  else
    echo "Неизвестный фреймворк: $FRAMEWORK"
    exit 1
  fi
fi

# Запуск приложения
cd "$APP_DIR"
echo "Запускаю сервер на $FRAMEWORK..."
if [ "$FRAMEWORK" == "flask" ]; then
  export FLASK_APP=app.py
  flask run --host=0.0.0.0 --port="$PORT"
elif [ "$FRAMEWORK" == "django" ]; then
  python manage.py runserver 0.0.0.0:"$PORT"
else
  echo "Неизвестный фреймворк: $FRAMEWORK"
  exit 1
fi
