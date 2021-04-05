

# Rapport technique

## Matériel mis à disposition
Notre matériel était le kit P-nucleo LRWAN  contenant une gateway permettant de réceptionner les données des objets connectés et de les transmettre à un serveur via son port ethernet et une carte de type end point la LRWAN  ayant différent capteur sur elle dont température et humidité. La carte end point va nous permettre d’envoyer des données à la gateway notamment celle de ces capteurs.

## Objectif

ici l'objectif et de permettre à un utilisateur d'envoyé une alerte via la carte en  appuyant sur le bouton du endpoint  grace à du code en c et de permettre de le visionné sur un dashboard de grafana  .Concrètement,  La gateway va  capté et transmettre le paquet au serveur campusiot qui va être utilisé par node red pour les stockées dans une base de donnée influxDb qui va être exploité par grafana afin de mettre en forme les données envoyés par la carte sous un dashboard .

## Explication brève de l'implémentation 

### code de la carte

Pour arriver à implémenter cela , nous avons activées les interruptions sur la carte donc pour cela nous avons appelées la fonction HAL_GPIO_Init avec les bon pins de notre bouton utilisateur.  Ensuite une fois l'interruption généré nous avons du créer un handler : pour cela nous avons dans notre handler appelées une fonction du lora.c qui va set la variable bouton à vraie. 
Cela va servir ensuite dans le timer de la lorawan ou lors du réveille nous allons regarder si la variable bouton est vrai et si la valeur est vraie alors nous allons envoyé un paquet de données . et remettre la variable bouton à faux afin que l'interruption ne soit pas trigger plusieurs fois .

### code nodeRed et grafana
nous avons simplement mis un switch dans le nodeRed afin de trié nos données d'alerte de l'utilisateur et celles envoyé périodiquement. Puis nous les avons mis en forme dans grafana avec la liste des dernières alertes et un graphique sur les alertes au cours du temps . 
 



