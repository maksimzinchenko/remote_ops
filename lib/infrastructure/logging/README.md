# logging

Отладочный лог в консоль разработчика. Секретные поля отбрасываются.

`main` выбирает реализацию по режиму сборки: `DebugAppLogger` только при `kDebugMode`. Profile и release получают `NoOpAppLogger`.

