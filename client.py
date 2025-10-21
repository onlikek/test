import requests

def main():
    text = input("введите сообщение: ")
    payload = {"message": text}

    response = requests.post("http://127.0.0.1:5000/ping", json=payload)

    if response.status_code == 200:
        print("ответ сервера:")
        print(response.json()["reply"])
    else:
        print(f"ошибка: {response.status_code}")

if __name__ == "__main__":
    main()
