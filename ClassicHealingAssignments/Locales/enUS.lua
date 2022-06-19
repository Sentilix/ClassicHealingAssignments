local L = DigamAddonLib:createLocale("enUS")

--	Main Frame (assignment setup)
L["Add target"] = "Ajouter cible"
L["Add template"] = "Ajouter modèle"
L["Classic Healing Assignments"] = "Contrôle de Guérison Classique"
L["Clean up"] = "Nettoie"
L["Reset all"] = "Effacer tout"
L["CTRL+Leftclick: announcement to Party/Raid"] = "CTRL+Clic gauche : annonce à Party/Raid"
L["CTRL+Rightclick: test announcement locally"] = "CTRL+Clic droit : tester l'annonce en local"
L["Healers: %s/%s"] = "Guérisseurs: %s/%s"
L["Tanks"] = "Chars"
L["Healers"] = "Guérisseurs"
L["Texts"] = "Textes"
--	Text frame (text management)
L["Announce in"] = "Annoncer dans"
L["Close"] = "Ferme"
L["Classic Healing Announcements"] = "Annonces de guérison classiques"
L["Headline"] = "Gros titre"
L["Assignments"] = "Contrôle"
L["Use {TARGET} for the target / tank."] = "Utilisez {TARGET} pour la cible / le char."
L["Use {ASSIGNMENTS} for assigned players."] = "Utilisez {ASSIGNMENTS} pour les joueurs assignés."
L["Raid line"] = "Ligne de raid"
--	Resource frame (resource filtering)
L["Resource Configuration"] = "Configuration des Ressources"
L["Class Filter:"] = "Des classes:"
L["Include Raid icons"] = "Icônes Raid"
L["Include Directions"] = "Directions"
L["Include Groups"] = "Groupes"
L["Include Custom labels"] = "Étiquettes privées"
--	Resources:
L["(Unassigned)"] = "(Non attribué)"
L["Skull"] = "Crâne"
L["Cross"] = "Croix"
L["Star"] = "Étoile"
L["Square"] = "Carrée"
L["Diamond"] = "Diamant"
L["Triangle"] = "Triangle"
L["Moon"] = "Lune"
L["Circle"] = "Cercle"
L["<== Left"] = "<== Gauche"
L["Right ==>"] = "Droit ==>"
L["North"] = "Nord"
L["East"] = "Est"
L["South"] = "Sud"
L["West"] = "Ouest"
L["(Custom 1)"] = "(Private 1)"
L["(Custom 2)"] = "(Private 2)"
L["(Custom 3)"] = "(Private 3)"
L["(Custom 4)"] = "(Private 4)"
L["Group 1"] = "Groupe 1"
L["Group 2"] = "Groupe 2"
L["Group 3"] = "Groupe 3"
L["Group 4"] = "Groupe 4"
L["Group 5"] = "Groupe 5"
L["Group 6"] = "Groupe 6"
L["Group 7"] = "Groupe 7"
L["Group 8"] = "Groupe 8"
--	Generel:
L["OK"] = "OK"
L["Cancel"] = "Annuler"
--	Popups:
L["Name of template:"] = "Nom du modèle"
L["Please enter new name:"] = "Veuillez entrer un nouveau nom:"
L["Really delete the template [%s]?"] = "Supprimer vraiment le modèle [%s] ?"
L["Really unassign the tank [%s]?"] = "Vraiment désaffecter le tank [%s] ?"
L["Really remove the target [%s]?"] = "Supprimer vraiment la cible [%s] ?"
L["Do you want to kick all disconnected characters and characters not in the raid?"] = "Voulez-vous kicker tous les personnages déconnectés et ceux qui ne sont pas dans le raid ?"
L["Do you want to reset (delete) all targets and healers for this template?"] = "Voulez-vous réinitialiser (supprimer) toutes les cibles et soigneurs pour ce modèle ?"
L["A template with that name already exists."] = "Un modèle portant ce nom existe déjà."
L["The template '%s' was not found."] = "Le modèle '%s' est introuvable."
--	Options
L["Move up"] = "Déplacer vers le haut"
L["Move down"] = "Déplacez-le vers le bas"
L["Copy template"] = "Copier le modèle"
L["Rename template"] = "Renommer le modèle"
L["Delete template"] = "Supprimer le modèle"
L["Rename tank"] = "Renommer le char"
L["Unassign tank"] = "Désaffecter le char"
L["Remove tank"] = "Retirer le char"
L["Rename healer"] = "Renommer le guérisseur"
L["Unassign healer"] = "Désassigner le guérisseur"
L["Remove healer"] = "Supprimer le guérisseur"
--	Wow
L["Raid"] = "Raid"
L["Raid warning"] = "Avert de raid"
L["Party"] = "Fête"
L["(Custom)"] = "(Private)"
--	Misc:
L["Type %s/cha%s to configure the addon, or click the [+] button."] = "Tapez %s/cha%s pour configurer l'addon, ou cliquez sur le bouton [+]."
L["Unknown command: %s"] = "Commande inconnue: %s"
L["%s is using ClassicHealingAssignments version %s"] = "%s utilise ClassicHealingAssignments version %s"
L["NOTE: A newer version of %s! is available (version %s)!"] = "REMARQUE: une version plus récente de %s! est disponible (version %s) !"
L["You can download latest version from %s or %s."] = "Vous pouvez télécharger la dernière version depuis %s ou %s."
--	Assignments:
L["HEALER Assignments :"] = "Missions de Guérisseur :"
L["All other healers: Heal the raid."] = "Tous les autres guérisseurs : soignez le raid."
L["Whisper \"%s\" for your assignment or \"%s\" for a full repost."] = "Chuchotez \"%s\" pour votre devoir ou \"%s\" pour un repost complet."
L["There are currently no assignments defined."] = "Il n'y a actuellement aucune affectation définie."
L["You are assigned as Healer on [%s]."] = "Vous êtes affecté en tant que Guérisseur sur [%s]."
L["You have no assigned target here."] = "Vous n'avez pas de cible assignée ici."
--	Help:
L["ClassicHealingAssignments version %s options:"] = "Options de la version %s du ClassicHealingAssignments:"
L["Syntax:"] = "Syntaxe:"
L["    /cha [command]"] = "    /cha [commande]"
L["Where commands can be:"] = "Où les commandes peuvent être:"
L["    Config       (default) Open the configuration dialogue."] = "    Config       (par défaut) Ouvre la boîte de dialogue de configuration."
L["    Version      Request version info from all clients."] = "    Version      Demander des informations sur la version de tous les clients."
L["    Help         This help."] = "    Help         Afficher cette aide."



--	Frames:
--L["Add target"] = true
--L["Add template"] = true
--L["Classic Healing Assignments"] = true
--L["Clean up"] = true
--L["Reset all"] = true
--L["CTRL+Leftclick: announcement to Party/Raid"] = true
--L["CTRL+Rightclick: test announcement locally"] = true
--L["Healers: %s/%s"] = true
--L["Tanks"] = true
--L["Healers"] = true
--L["Texts"] = true
--L["Announce in"] = true
--L["Close"] = true
--L["Classic Healing Announcements"] = true
--L["Headline"] = true
--L["Assignments"] = true
--L["Use {TARGET} for the target / tank."] = true
--L["Use {ASSIGNMENTS} for assigned players."] = true
--L["Raid line"] = true
--	Resource frame:
--L["Resource Configuration"] = true
--L["Class Filter:"] = true
--L["Include Raid icons"] = true
--L["Include Directions"] = true
--L["Include Groups"] = true
--L["Include Custom labels"] = true
--	Resources:
--L["(Unassigned)" = true
--L["Skull"] = true
--L["Cross"] = true
--L["Star"] = true
--L["Square"] = true
--L["Diamond"] = true
--L["Triangle"] = true
--L["Moon"] = true
--L["Circle"] = true
--L["<== Left"] = true
--L["Right ==>"] = true
--L["North"] = true
--L["East"] = true
--L["South"] = true
--L["West"] = true
--L["(Custom 1)" = true
--L["(Custom 2)" = true
--L["(Custom 3)" = true
--L["(Custom 4)" = true
--L["Group 1" = true
--L["Group 2" = true
--L["Group 3" = true
--L["Group 4" = true
--L["Group 5" = true
--L["Group 6" = true
--L["Group 7" = true
--L["Group 8" = true
--	Generel
--L["OK"] = true
--L["Cancel"] = true
--	Popups
--L["Name of template:"] = true
--L["Please enter new name:"] = true
--L["Really delete the template [%s]?"] = true
--L["Really unassign the tank [%s]?"] = true
--L["Really remove the target [%s]?"] = true
--L["Do you want to kick all disconnected characters and characters not in the raid?"] = true
--L["Do you want to reset (delete) all targets and healers for this template?"] = true
--L["A template with that name already exists."] = true
--L["The template '%s' was not found."] = true
--	Options
--L["Move up"] = true
--L["Move down"] = true
--L["Copy template"] = true
--L["Rename template"] = true
--L["Delete template"] = true
--L["Rename tank"] = true
--L["Unassign tank"] = true
--L["Remove tank"] = true
--L["Rename healer"] = true
--L["Unassign healer"] = true
--L["Remove healer"] = true
--	Wow
--L["Raid"] = true
--L["Raid warning"] = true
--L["Party"] = true
--L["(Custom)"] = true
--	Misc:
--L["Type %s/cha%s to configure the addon, or click the [+] button."] = true
--L["Unknown command: %s"] = true
--L["%s is using ClassicHealingAssignments version %s"] = true
--L["NOTE: A newer version of %s! is available (version %s)!"] = true
--L["You can download latest version from %s or %s."] = true
--	Assignments:
--L["HEALER Assignments :"] = true
--L["All other healers: Heal the raid."] = true
--L["Whisper \"%s\" for your assignment or \"%s\" for a full repost."] = true
--L["There are currently no assignments defined."] = true
--L["You are assigned as Healer on [%s]."] = true
--L["You have no assigned target here."] = true
--	Help:
--L["ClassicHealingAssignments version %s options:"] = true
--L["Syntax:"] = true
--L["    /cha [command]"] = true
--L["Where commands can be:"] = true
--L["    Config       (default) Open the configuration dialogue."] = true
--L["    Version      Request version info from all clients."] = true
--L["    Help         This help."] = true
