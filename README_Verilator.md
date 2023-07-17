
Руководство по симуляции лабораторных заданий средствами [Verialtor](https://www.veripool.org/verilator/)

1. Установка Verilaror. Инструкция подходит для Debian/Ubuntu, [WSL](https://learn.microsoft.com/en-us/windows/wsl/install). Выполните перечисленные ниже шаги

```
# Установите необходимые зависимости и инструменты
# Prerequisites:
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install git help2man perl python3 make autoconf g++ flex bison ccache
sudo apt-get install libgoogle-perftools-dev numactl perl-doc
sudo apt-get install libfl2  # Ubuntu only (ignore if gives error)
sudo apt-get install libfl-dev  # Ubuntu only (ignore if gives error)
sudo apt-get install zlibc zlib1g zlib1g-dev  # Ubuntu only (ignore if gives error)
# Cклонируйте репозиторий Verilator (требуется только в первый раз):
git clone https://github.com/verilator/verilator   # Only first time

# Every time you need to build:
unsetenv VERILATOR_ROOT  # For csh; ignore error if on bash
unset VERILATOR_ROOT  # For bash
cd verilator
git pull         # Make sure git repository is up-to-date
git tag          # See what versions exist
git checkout v5.012  # Switch to specified release version
# To use Verilator as a simulator to compile testbenches written in SV, need version > 5.0
autoconf         # Create ./configure script
./configure      # Configure and create Makefile
make -j `nproc`  # Build Verilator itself (if error, try just 'make')
sudo make install
```

Для проверки корректности установки выполните команду:
```
verilator --version
# Результат должен быть подобным: Verilator 5.012 2023-06-13 rev v5.012
```
Verilator установлен корректно, можно переходить к следуюшему шагу.


2. Для использования в качестве симулятора Veriltor пропишите `define VERILATOR labs/common/config.svh

3. Для примера рассмотрим лабораторную работу labs/02_mux/
Перейдите в папку labs/02_mux/. Кроме bash скриптов для Verilator подготовлен Makefile.
В Makefile содержится 3 сценария: build, sim, clean.
1. build представляет целевой дизайн и testbench в формате C++ модели
2. sim проводит симуляцию целевого дизайна, генерирует dump .vcd. testbench определяется внутри Makefile.
3. clean очищает temp-директорию Verilator'a, удаляет .vcd файл. 

Для того чтобы выполнить симуляцию дизайна выполните команды:
```
make build
make sim
```
После окончания симуляции появится файл tb_verialtor.vcd, котрорый можно октрыть, например, при помощи [gtkwave](https://gtkwave.sourceforge.net/).
При завершении работы можно выполнить команду make clean, чтобы удалить временные файлы.
```
make clean
```

Verilator флаги определяют различные параметры и опции компиляции. Вот расшифровка некоторых флагов, указанных в примере:

    --trace-fst: Включает генерацию трассировочного файла FST.

    --binary: Генерирует исполняемый файл из сгенерированного C++ кода.

    -Wno-style: Отключает предупреждения стиля кодирования, которые могут быть выданы компилятором.

    -Wno-fatal: Предупреждения не приводят к остановке компиляции и генерации модели.

Ознакомиться с описанием всех аргументов можно в специальном разделе документации [Verilator](https://veripool.org/guide/latest/exe_verilator.html)
