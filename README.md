# El Lenguaje de los Porqués

¿No llegué a documentarlo? ¿Tanta era la rabia? En fin.

## Versión online

Puedes acceder aquí:

  - [https://allnulled.github.io/porque/](https://allnulled.github.io/porque/)


## Ejemplo de uso

```porque
si {tengo porros} entonces {estoy ok}.
si {estoy ok} entonces no {voy al médico}.
si no {voy al médico} entonces {estoy sano}.

si no {tengo porros} entonces no {estoy ok}.
si no {estoy ok} entonces {voy al médico}.
si {estoy ok} entonces no {estoy sano}.

{tengo medicina} porque {tengo porros}.

es cierto que {tengo porros}.

¿{estoy sano}?
```

Cópialo y pégalo. La máquina ya sabe que los porros son medicina, Mr. Minimarley.

[![Minimarley](https://img.youtube.com/vi/9PukqhfMxfc/mqdefault.jpg)](https://www.youtube.com/watch?v=9PukqhfMxfc)

## Código fuente

El front del lenguaje es este:

```pegjs
Lenguaje = s:Sentencia_completa* {return Object.assign({}, new Memoria().procesar(s));}
Sentencia_completa = s:Sentencia EOS {return s}
Sentencia = s:( sentencia_es_cierto_que / sentencia_pregunta_por_que / sentencia_pregunta / sentencia_porque ) {return {...s, todosLosSucesos: listarSucesosDeSentencia(s), texto: text(), localizacion: location()}}
sentencia_pregunta_por_que = op:( "¿por qué" _ ) suceso:suceso_no_agrupado "?" {return {tipo:"pregunta",suceso, operador: op[0].trim() + "?"}}
sentencia_pregunta = op:( "¿" _? ) suceso:suceso _? "?" {return {tipo:"pregunta",suceso, operador: op[0] + "?"}}
sentencia_es_cierto_que = subtipo:( "es cierto que " / "es falso que " ) suceso:suceso_grupal "."  {return {tipo:"afirmación",subtipo:subtipo.trim(),suceso}}
sentencia_porque = sentencia_porque_nucleo
sentencia_porque_nucleo = sentencia_porque_1 / sentencia_porque_2 / sentencia_porque_3
sentencia_porque_1 = consecuencia:suceso_grupal ( _ ("porque" / "en tanto que") _ ) causa:suceso "."  {return {tipo:"causalidad",causa,consecuencia}}
sentencia_porque_2 = "si" _ causa:suceso ( _ "entonces" _ ) consecuencia:suceso_grupal "."  {return {tipo:"causalidad",causa,consecuencia}}
sentencia_porque_3 = "si" _ consecuencia:suceso_grupal ( _ "es porque" _ ) causa:suceso "."  {return {tipo:"causalidad",causa,consecuencia}}
suceso = s:(suceso_concatenado / suceso_grupal) {return s}
suceso_concatenado = suceso:suceso_grupal concatenaciones:suceso_concatenaciones {return {tipo:"suceso concatenado",concatenaciones: [suceso].concat(concatenaciones), texto: text(), localizacion: location()}}
suceso_concatenaciones = suceso_concatenacion+
suceso_concatenacion = op:( _ ("y" / "o") _ ) suceso:suceso {return {operador:op[1], ...suceso}}
suceso_grupal = suceso_agrupado / suceso_no_agrupado
suceso_agrupado = n:negacion* "(" _? s:suceso _? ")" {return {...s,negacion:n?n.length:0}}
suceso_no_agrupado = suceso_negado
suceso_negado = n:negacion* s:suceso_puro {return {...s,negacion:n?n.length:0}}
negacion = "no" _
_ = [\t\r\n ]+
suceso_puro = "{" [^\}]+ "}" {return {tipo:"suceso puro",texto:text().substr(1, text().length-2).trim()}}
EOL = "\n" / "\r\n"
EOS = (EOL* / !.)
```

La ventaja del lenguaje es que deja como unas "escuchas" entre los valores que se relacionan mediante las sentencias lógicas del lenguaje. Es decir, las relaciones no pueden mutar. Tiene limitaciones, pero ilumina un poco el nexo entre lenguaje y lógica con lo del `porque`. Es útil. Ya, joder, no es ChatGPT. Obvio que no. Ni va por ahí, pero vaya, que me preocupa la cabeza de la gente, el ordenador ya sé que sabe multiplicar.

-----

## Generativa simple o `{ x }`

La generativa es una afirmación lógica atómica o que no necesita de relación con otras para tener sentido completo.

## Generativa compuesta

La composición de generativas permite:

  - Negar una generativa: `no { x }`
  - Conjuntivar generativas: `{ x } y { y } y { z }`
  - Disyuntivar generativas: `{ x } o { y } o { z }`
  - Agrupar generativas: `({ x } y { y }) o ({ z } y { w })`

## Sentencia `es cierto que { x }` y `es falso que { x }`

Esta sentencia va a cambiar el valor de verdad de `{ x }`. Hasta entonces, `{ x }` era indeterminado.

## Sentencia `¿por qué { x }?`

Esta sentencia va a hacer al PC mostrar las razones en cadena que justifican el valor de verdad de `{ x }`, o que afirme que dicho valor es indeterminado por el momento.

## Sentencia `¿{ x }?`

Esta sentencia va a hacer al PC mostrar el valor de verdad de `{ x }`.

## Sentencia `{ x } porque { y }`

Esta sentencia va a hacer que el valor de `{ x }` sea dependiente de `{ y }` bajo relación de condicional.

## Sentencia `si { x } entonces { y }`

Esta sentencia va a hacer que el valor de `{ y }` sea dependiente de `{ x }` bajo relación de condicional.


