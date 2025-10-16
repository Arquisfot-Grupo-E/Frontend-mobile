# BookWorm (appprueba)

Pequeño scaffold Flutter basado en tu código. Contiene las pantallas principales, proveedores y servicios GraphQL.

Requisitos
- Flutter SDK instalado
- Un emulador Android o dispositivo físico

Instalación y ejecución

1. Obtener dependencias

```powershell
flutter pub get
```

2. Ejecutar en emulador Android

```powershell
flutter run -d emulator-5554
```

3. Ejecutar en dispositivo físico

- Habilita depuración USB en tu Android y conecta por USB
- Cambia la URL en `lib/services/graphql_service.dart` a tu IP local, por ejemplo:

```dart
static const String _url = 'http://192.168.1.42:4000/graphql';
```

Notas
- El proyecto asume un servidor GraphQL en `http://10.0.2.2:4000/graphql` para emulador Android.
- Si faltan paquetes o versiones, ajusta `pubspec.yaml`.