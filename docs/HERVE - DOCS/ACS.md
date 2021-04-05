# Analyse du cycle de vie de notre application

Notre produit est une solution d'aide à la personne en cas d'alerte, avec visualisation des alertes généré en ligne.
En terme d'impact écologique, deux coûts sont a noter :
- La consommation électrique. Notre dispositif est très peu gourmand en l'état, car toujours endormi et donc avec une consommation minimale de resource, et envoie un simple signal en cas d'appuie. Si la fonctionnalitée de redescente d'alerte (via dispositif sonore par exemple) était présente sur notre application, alors cela dépendrait de la classe de notre board. En classe C, elle à la capacité de se faire reveiller par un signal, et donc de resté minimal en coût energetique. Dans le cas de nos board actuelles, de classe A, il est necessaire de les reveiller periodiquement pour requeter le reseau et verifier la présence d'alerte. Un timer trop long peux être dangereux, mais un timer trop court implique une consommation accrue en énergie.
- Le temps de vie de la board. Cela dépend de la board en question mais en l'état, comme le nombre de paquets envoyé est très faible, elle peut tenir plusieurs années sans problèmes.

