import UIKit
import WebKit

/*  Les deux ponts que la page attend du natif. Ni l'un ni l'autre n'est
    obligatoire — index.html teste leur présence et retombe sur le navigateur
    quand ils manquent — mais les deux sont ce qui distingue l'app du site.

    Les contrats sont dictés par index.html, pas choisis ici :

      window.SolitaireHaptics(kind)     appelé avec 'win', 'strong', 'light'
                                        ou rien du tout.

      window.storage.get(key)           attendu asynchrone, doit rendre
                                        { value: "<json>" } ou null.
      window.storage.set(key, value)    attendu asynchrone, value est déjà
                                        une chaîne JSON.
      window.storage.delete(key)        attendu asynchrone.

    `get` rend bien un objet et non la chaîne : Store écrit
    `r ? JSON.parse(r.value) : null`, donc une chaîne nue serait parsée deux
    fois et une clé absente doit être falsy.                                  */

// MARK: - Retour haptique

/// Répond à `window.SolitaireHaptics(kind)`.
final class HapticBridge: NSObject, WKScriptMessageHandler {

    static let name = "haptics"

    /* Trois générateurs distincts et gardés : en construire un à chaque coup
       ajoute une latence bien visible sur un tapotement de carte. */
    private let light = UIImpactFeedbackGenerator(style: .light)
    private let firm = UIImpactFeedbackGenerator(style: .medium)
    private let notice = UINotificationFeedbackGenerator()

    /// À appeler avant le premier coup : le moteur haptique met quelques
    /// dizaines de millisecondes à sortir de veille.
    func prepare() {
        light.prepare()
        firm.prepare()
    }

    func userContentController(_ controller: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        /* `haptic()` sans argument veut dire un tapotement discret : c'est le
           cas le plus fréquent, donc le défaut. */
        let kind = message.body as? String ?? "light"

        switch kind {
        case "win":
            /* La version web joue [14,40,14,40,22], une petite fanfare. Le
               retour « succès » du système en est l'équivalent natif, et il
               respecte les réglages d'accessibilité de l'appareil. */
            notice.notificationOccurred(.success)
        case "strong":
            firm.impactOccurred()
            firm.prepare()
        default:
            light.impactOccurred()
            light.prepare()
        }
    }
}

// MARK: - Sauvegarde

/// Répond à `window.storage`. Adossé à `UserDefaults` : huit clés, quelques
/// kilo-octets de JSON chacune, sauvegardées avec l'app et effacées avec elle.
final class StorageBridge: NSObject, WKScriptMessageHandlerWithReply {

    static let name = "storage"

    /* Les clés du jeu s'appellent déjà « sol.<quoi>.v1 ». On les préfixe une
       fois de plus pour qu'elles ne puissent jamais entrer en collision avec
       une préférence native ajoutée plus tard. */
    private let prefix = "web."
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        super.init()
    }

    func userContentController(_ controller: WKUserContentController,
                               didReceive message: WKScriptMessage,
                               replyHandler: @escaping (Any?, String?) -> Void) {
        guard let body = message.body as? [String: Any],
              let op = body["op"] as? String,
              let key = body["key"] as? String,
              !key.isEmpty else {
            replyHandler(nil, "Message de stockage mal formé.")
            return
        }

        let full = prefix + key

        switch op {
        case "get":
            /* Un objet quand la clé existe, null sinon — Store distingue les
               deux et retomberait sur ses valeurs par défaut autrement. */
            if let stored = defaults.string(forKey: full) {
                replyHandler(["value": stored], nil)
            } else {
                replyHandler(nil, nil)
            }

        case "set":
            guard let value = body["value"] as? String else {
                replyHandler(nil, "Écriture sans valeur pour « \(key) ».")
                return
            }
            defaults.set(value, forKey: full)
            replyHandler(nil, nil)

        case "del":
            defaults.removeObject(forKey: full)
            replyHandler(nil, nil)

        default:
            replyHandler(nil, "Opération de stockage inconnue : « \(op) ».")
        }
    }
}
