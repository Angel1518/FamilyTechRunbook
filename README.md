# FamilyTech Runbook

> **«Si algo falla, empieza aquí»**

![Android](https://img.shields.io/badge/Android-Offline--First-2563EB)
![MVP](https://img.shields.io/badge/IA-Sin%20IA%20en%20MVP-informational)
![Zero Telemetry](https://img.shields.io/badge/Telemetr%C3%ADa-0%25-success)

**FamilyTech Runbook** ofrece guías interactivas paso a paso (Sí / No) para ayudar a cualquier persona de la familia a resolver fallos cotidianos (router sin internet, televisión sin señal, impresora) incluso sin conexión.

---

## Características principales

- **Asistente guiado paso a paso**: un único paso claro por pantalla con botones grandes **Sí** / **No** y botón para retroceder al paso anterior.
- **Validación de grafos sin ciclos**: `RunbookValidator` comprueba que ninguna rama cree un bucle infinito.
- **Contactos de ayuda**: agenda rápida con la persona o soporte técnico al que llamar si el problema persiste.
- **Guía imprimible en PDF**: exporta el procedimiento y los contactos para dejarlos impresos junto al router o en la nevera.
- **Sin IA en el MVP**: 100 % determinista y offline.

---

## Instalación y compilación local

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

---

## Documentación adicional

- [DEPENDENCIES.md](DEPENDENCIES.md) · [CONTRIBUTING.md](CONTRIBUTING.md)
