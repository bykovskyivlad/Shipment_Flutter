 Shipments System

Aplikacja do zarządzania przesyłkami, zrealizowana w technologii **ASP.NET Core Web API** oraz **Flutter**.
System obsługuje różne role użytkowników i pełny cykl życia przesyłki.

Opis projektu

Celem projektu jest stworzenie systemu umożliwiającego zarządzanie przesyłkami pomiędzy klientami, kurierami oraz administratorem.

Aplikacja została podzielona na trzy główne części:

- **Shipments.Api** – REST API odpowiedzialne za logikę biznesową, autoryzację i dostęp do bazy danych
- **Shipments.Flutter** – aplikacja kliencka pełniąca rolę interfejsu użytkownika
- **Shipments.Shared** – warstwa współdzielona zawierająca kontrakty, role, encje domenowe i reguły biznesowe

Komunikacja pomiędzy frontendem a backendem odbywa się za pomocą **HTTP**, **JSON** oraz klienta **Dio**.

---

Architektura

Projekt wykorzystuje architekturę warstwową:

- warstwa prezentacji (**Flutter UI**)
- warstwa aplikacyjna (**API Controllers + Services**)
- warstwa domenowa (**Entities, Enums, Rules**)
- warstwa danych (**Entity Framework Core + SQLite**)

W projekcie zastosowano:

- REST API
- DTO / Contracts
- Dependency Injection
- Middleware do obsługi wyjątków
- JWT Authentication
- Role użytkowników
- separację logiki od widoku przez warstwę `service` po stronie Fluttera

---

Role użytkowników

Client
- rejestracja i logowanie
- tworzenie przesyłek
- przegląd własnych przesyłek
- podgląd szczegółów przesyłki
- anulowanie przesyłki

Courier
- dostęp tylko do przypisanych przesyłek
- podgląd szczegółów przesyłki
- zmiana statusów przesyłki zgodnie z regułami biznesowymi
- brak możliwości wykonania niedozwolonych przejść statusów

Admin
- dostęp do wszystkich przesyłek
- podgląd szczegółów przesyłek
- przypisywanie i zmiana kuriera
- wymuszona zmiana hasła przy pierwszym logowaniu administratora seedowanego z konfiguracji

---

Statusy przesyłek

Dostępne statusy:

- `Created`
- `PickedUp`
- `OutForDelivery`
- `Delivered`
- `DeliveryFailed`
- `Canceled`

Przejścia pomiędzy statusami są kontrolowane centralnie w logice biznesowej i nie mogą być omijane z poziomu interfejsu użytkownika.

---

Baza danych i ORM

Projekt wykorzystuje:

- **SQLite**
- **Entity Framework Core**

Mapowanie relacyjne obejmuje m.in.:

- `Shipment -> ShipmentEvents` (1:N)
- `Shipment -> Client` (N:1)
- `Shipment -> Courier` (N:1)

Projekt wykorzystuje ORM do:

- operacji CRUD
- filtrowania i pobierania danych
- obsługi relacji pomiędzy encjami
- mapowania modeli domenowych do bazy danych

---

Bezpieczeństwo

W projekcie zastosowano:

- **ASP.NET Identity**
- **JWT** po stronie API
- autoryzację opartą o role
- ochronę dostępu do danych użytkowników
- przechowywanie tokenu po stronie klienta
- wymuszenie zmiany hasła administratora przy pierwszym logowaniu

---

Frontend

Aplikacja kliencka została wykonana w technologii **Flutter**.

Frontend odpowiada za:

- formularze logowania i rejestracji
- wyświetlanie ekranów zależnie od roli użytkownika
- komunikację z backendem przez `Dio`
- przechowywanie tokenu JWT
- obsługę list, szczegółów i akcji na przesyłkach

W projekcie zastosowano m.in.:

- `api_client.dart` – konfiguracja klienta HTTP
- `auth_interceptor.dart` – automatyczne dodawanie tokenu JWT do zapytań
- `secure_storage_service.dart` – zapis i odczyt tokenu
- `jwt_service.dart` – odczyt roli z tokenu
- `app_snackbar.dart` – wspólny mechanizm komunikatów w UI

---

Backend

Backend został wykonany w technologii **ASP.NET Core Web API**.

Najważniejsze elementy backendu:

- `AuthController` – rejestracja, logowanie, zmiana hasła
- `ShipmentsController` – operacje klienta na przesyłkach
- `AdminShipmentsController` – operacje administratora
- `CourierShipmentsController` – operacje kuriera
- `ShipmentService` – główna logika biznesowa systemu
- `IdentitySeed` – seed ról i konta administratora

---

Seed administratora

Administrator tworzony jest automatycznie przy starcie API.  
Dane logowania nie są zapisane bezpośrednio w kodzie źródłowym, lecz w **User Secrets**.

Przykład konfiguracji:

```bash
dotnet user-secrets init
dotnet user-secrets set "AdminSeed:Email" "admin@test.com"
dotnet user-secrets set "AdminSeed:Password" "TestAdmin123!"
