# Cyjon
Prosty wielozadaniowy system operacyjny, napisany w języku asemblera dla procesorów z rodziny amd64/x86-64.

#### Działanie:
Aktualnie nic wielkiego nie robi :) Całe środowisko zostało przygotowane, przerwania uruchomione.
- sterownik karty sieciowej odbiera pakiety, ale nie są przetwarzane (porzucam - obsługę udostępnię przy następnych aktualizacjach),
- częściowa obsługa klawiatury (nie wszystkie klawisze zaimplementowane),
- powłoka pobiera od administratora polecenia i przetwarza lub wyświetla komuniat o braku obsługi.

#### Kompilacja:
	nasm.exe -f bin	kernel.asm      -o build\kernel

#### Uruchomienie:
Do uruchomienia systemu, należy skorzystać z programu rozruchowego http://github.com/akasei/Zero.

#### Licencja:
Kod źródłowy systemu operacyjnego jest na licencji **GNU General Public License 3.0**
