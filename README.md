# SquashMerge
Merge_squash.sh es el script que crea un {{BRANCH}}_for_merge a partir de un {{BRANCH}}. El otro esta pendiente, desestimenlo.

Toma todos los commits de {{BRANCH}}, y los squashea a {{BRANCH}}_for_merge para hacer un pull request y mergear a dev en un solo commit.

¿Como se ejecuta? : ./merge_squash.sh <<branch_a_donde_queremos_mergear>> <commitMessage:parametroOpcional>

Pueden crearle un alias: Ej: alias gitsfm='~/./</shell-scripts/merge_squash.sh'

Lo que hace y verifica:

Se fija si el branch en el que estas parado es de la forma "[A-Z]+-[0-9]+.*" EJ: AISS-123_EJEMPLO
Agrega como prefijo al commitMessage el ID de la forma "[A-Z]+-[0-9]+"
El comentario del commit no puede ser vacio
El branch al que queres mergear (develop) tiene que existir en el repo remoto
El branch a squashear tiene que existir en el repo remoto.
Tenes que tener hub instalado
No tenes que tener cambios locales que no esten en el remoto
No tenes que tener archivos sin trackear (los nuevos)
Pullea el branch a mergear (Ej: develop)
Si hay conflicto termina el script para que se solucione
Pushea al branch a mergear con el commit merge, en caso de que lo existiese.
Proceso de squash
Crea el PR(se imprime por consola el link para verlo)
Pregunta si queres borrar el branch original (Ejemplo: AISS-123_EJEMPLO) del repo Remoto.
Instalacion de Hub: sudo add-apt-repository ppa:cpick/hub sudo apt-get update sudo apt-get install hub

Les va a pedir por unica vez el user de github y el password y el token de 2FA.

