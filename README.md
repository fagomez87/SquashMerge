# SquashMerge
Ahi los invite a un repo privado(https://github.com/GabrielDyck/shell-scripts).
El que se llama merge_squash.sh es el script que crea un {{BRANCH}}_for_merge a partir de un {{BRANCH}}.
Al otro no le den bola. Esta pendienteA grandes rasgos toma todos los commits de {{BRANCH}}, y los squashea a  {{BRANCH}}_for_merge para hacer un pull request y mergear a dev en un solo commit.

¿Como se ejecuta? : ./merge_squash.sh "<<mensaje del commit>>" <<branch_a_donde_queremos_mergear>>
Pueden crearle un alias: Ej: alias gitsfm='~/./<<ruta desde la home hasta el repo>/shell-scripts/merge_squash.sh'
Cuento un poco que hace asi no tienen que leerlo tan en detalle:
1. Se fija si el branch en el que estas parado es de la forma "[A-Z]+-[0-9]+.*" EJ: AISS-123_EJEMPLO
2. el comentario del commit no puede ser vacio
3. el branch al que queres mergear(develop) tiene que existir en el repo remoto
4. el branch a squashear tiene que existir en el repo remoto.
5. tenes que tener hub instalado
6. no tenes que tener cambios locales que no esten en el remoto
7. no tenes que tener archivos sin trackear( los nuevos)
8. pullea el branch a mergear(Ej: develop)
9. si hay conflicto termina el script para que se solucione
10. pushea al branch a mergear con el commit merge, en caso de que lo existiese.
11. Proceso de squash
12. Crea el PR(se imprime por consola el link para verlo)
13. Pregunta si queres borrar el branch original (Ejemplo: AISS-123_EJEMPLO) del repo Remoto.

Instalacion de Hub:
sudo add-apt-repository ppa:cpick/hub
sudo apt-get update
sudo apt-get install hub

Les va a pedir por unica vez el user de github y el password y el token de 2FA.
Si encuentran algo que les llame la atencion, o les impida la correr bien el script avisenme.
