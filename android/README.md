# android

Оболочка Flutter для Android. Бизнес-логика и SSH здесь не реализуются.

В манифесте нужно разрешение INTERNET: приложение само открывает SSH на время блока команд.

В `app/src/main/res` нет README: Gradle считает каждый файл ресурсом и принимает только `.xml` и `.png`. Там лежат иконки (`mipmap-*`), картинка запуска (`drawable`, `drawable-v21`) и стили окна (`values`, `values-night`).

