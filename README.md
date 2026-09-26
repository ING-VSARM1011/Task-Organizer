# Task Organizer

Aplicación Rails con SQLite, Devise, Haml y JavaScript mediante import maps.

## Entorno

- Ruby 3.4.11 y Bundler 2.6.9.
- Rails 8.1.4 (resuelto en `Gemfile.lock`).
- Node.js 22 y Yarn 1.22.22.
- En Windows: RubyInstaller con MSYS2/Devkit para compilar gemas nativas.

```sh
gem install bundler -v 2.6.9
bundle install
npx --yes yarn@1.22.22 install --frozen-lockfile
bundle exec rails db:prepare
bundle exec rails server
```

El archivo SQLite de desarrollo sigue siendo `task-organizer`.
Pruebas usa `storage/test.sqlite3`; producción, `storage/production.sqlite3`.
Conserva una copia de la base de datos antes de actualizar un despliegue.
Ruby debe actualizarse también en el servidor; el Dockerfile ya usa 3.4.11.

## Comprobaciones

```sh
node script/audit-dependencies.mjs
bundle exec rails zeitwerk:check
bundle exec rails runner -e test script/smoke_test.rb
```

La auditoría consulta OSV para las versiones de ambos archivos de bloqueo y
falla si encuentra avisos o no puede consultar el servicio. No requiere instalar
las dependencias y necesita acceso a internet. El resultado refleja los avisos
conocidos al ejecutar la consulta; no sustituye una revisión del código.

La prueba de compatibilidad usa una base SQLite en memoria y comprueba creación
de usuarios/categorías/tareas, contraseñas, inicio de sesión y una página
autenticada. No prueba JavaScript en un navegador ni todos los formularios.

El workflow `Dependencies` ejecuta estas comprobaciones y la compilación de
assets en Linux. Dependabot revisa Bundler, npm y GitHub Actions semanalmente.

## Actualización de dependencias

Se actualizaron Ruby, Rails, Devise, SQLite y las dependencias transitivas.
Se conserva `config.load_defaults 7.1` para incorporar cambios de configuración
de forma separada, siguiendo la
[guía de actualización de Rails](https://guides.rubyonrails.org/upgrading_ruby_on_rails.html).

- `annotate` se sustituyó por `annotaterb` porque limitaba Active Record a versiones anteriores a 8.
  Para actualizar anotaciones: `bundle exec annotaterb models`.
- Bootstrap y webpack se actualizaron; Popper 1 se sustituyó por `@popperjs/core`,
  la dependencia requerida por Bootstrap 5.
- `node_modules` deja de versionarse; se restaura con Yarn.
- No mezclar gestores: mantener `yarn.lock` y evitar crear `package-lock.json`.

Para futuras actualizaciones, ejecutar `bundle update` o
`npx --yes yarn@1.22.22 upgrade`, revisar los cambios y repetir las comprobaciones.

## Validación de esta actualización

- OSV: 168 versiones consultadas, sin avisos conocidos al realizar la revisión.
- Instalación de Bundler y Yarn con el bloqueo actualizado: correctas.
- Carga completa con Zeitwerk, prueba de compatibilidad y compilación de assets:
  correctas en Windows con Ruby 3.4.11.
- Sprockets usa caché intermedio en memoria en Windows para evitar errores al
  reemplazar archivos abiertos. Linux conserva el caché de archivos.
- No se ejecutó Docker ni el workflow remoto; GitHub los comprobará al subir los
  cambios. Las pruebas locales no cubren la interacción JavaScript en navegador.
- El formulario de participantes y la integración JavaScript de Cocoon ya
  presentaban inconsistencias: el paquete npm `cocoon` es una biblioteca distinta
  de la gema y el import map no define ese módulo. Queda pendiente esa revisión
  funcional; esta actualización no la da por resuelta.
