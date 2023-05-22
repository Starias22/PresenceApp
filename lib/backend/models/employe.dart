enum TypeSexe{
  masculin,
  feminin;
}

enum EtatPresence{
  present,
  retard,
  absent,
  sortie;
}

enum TypeService{
  comptabilite,
  direction,
  sa,
  sc,
  ss
}

class Employe{
  String id;
  String empreinte;
  String nom;
  String prenom;
  TypeSexe sexe;
  String email;
  TypeService service;
  int heureArrivee;
  int heureSortie;
  EtatPresence etat;
  String image;

  Employe(
      {
        required this.id, this.empreinte = "", required this.nom, required this.prenom,
        required this.sexe, required this.email, required this.service, required this.heureArrivee,
        required this.heureSortie, this.etat = EtatPresence.absent, this.image = ""
      });

  String SexeString()
  {
    if(sexe == TypeSexe.masculin)
      return "M";

    else
      return "F";
  }

  String EtatString()
  {
    if(etat == EtatPresence.present)
      return 'Présent';

    else if(etat == EtatPresence.retard)
      return 'En retard';

    else if(etat == EtatPresence.sortie)
      return 'Sortie';

    else
    return 'Absent';
  }

  String ServiceString()
  {
    if(service == TypeService.comptabilite)
      return 'Comptabilité';

    else if(service == TypeService.direction)
      return 'Direction';

    else if(service == TypeService.sa)
      return 'Secrétarit administratif';

    else if(service == TypeService.sc)
      return 'Service de coorpération';

    else
      return 'Service de scolarité';
  }

  Map<String, dynamic> toMap()
  {
    return
      {
        "nom" : nom, "prenom": prenom, "image": image, "sexe": sexe.index,
        "service": service.index, "etat": etat.index, "heureDepart": heureSortie,
        'heureArrivee': heureArrivee, "email": email, "empreinte": empreinte
      };
  }

  static Employe fromMap(Map<String, dynamic> map)
  {
    return Employe(id: map["id"], image: map["image"], nom: map["nom"],
        prenom: map["prenom"], email: map["email"], empreinte: map["empreinte"],
        etat: EtatPresence.values[int.parse(map['etat'].toString())],
        heureArrivee: (map["heureArrivee"]), heureSortie: (map["heureDepart"]),
        sexe: TypeSexe.values[int.parse(map["sexe"].toString())],
        service: TypeService.values[int.parse(map['service'].toString())]);
  }
}

  List<Employe> employes = [
    Employe(id: "1", nom: "ADEDE", prenom: "Ezéchièl", sexe: TypeSexe.masculin,
        email: "adede@gmail.com", service: TypeService.direction,
        heureArrivee: 9, heureSortie: 17),
    Employe(id: "2", nom: "JOHN", prenom: "Wesley", sexe: TypeSexe.masculin,
        email: "john@gmail.com", service: TypeService.comptabilite,
        heureArrivee: 9, heureSortie: 17, etat: EtatPresence.present),
    Employe(id: "3", nom: "LMD", prenom: "Géo", sexe: TypeSexe.masculin,
        email: "lmd@gmail.com", service: TypeService.sc,
        heureArrivee: 10, heureSortie: 16, etat: EtatPresence.sortie),
    Employe(id: "4", nom: "Gelond", prenom: "Winner", sexe: TypeSexe.masculin,
        email: "gelond@gmail.com", service: TypeService.ss,
        heureArrivee: 10, heureSortie: 16, etat: EtatPresence.present,),
    Employe(id: "5", nom: "Fleur", prenom: "Hubert", sexe: TypeSexe.masculin,
      email: "fleur@gmail.com", service: TypeService.sa,
      heureArrivee: 10, heureSortie: 16, etat: EtatPresence.retard,),
    Employe(id: "6", nom: "Le TIGRE", prenom: "Nairobi", sexe: TypeSexe.feminin,
      email: "nairobi@gmail.com", service: TypeService.sa,
      heureArrivee: 10, heureSortie: 16, etat: EtatPresence.sortie,)
  ];
