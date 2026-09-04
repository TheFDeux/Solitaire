import SwiftUI
import WebKit

/// Le jeu, dans une WKWebView plein cadre.
struct GameWebView: UIViewRepresentable {

    /// Exactement `--bg-rgb` du thème Aurore. La vue porte cette couleur pour
    /// qu'aucun blanc n'apparaisse entre le lancement et le premier rendu :
    /// l'écran de démarrage enchaîne alors sur la même teinte que la table.
    static let ground = UIColor(red: 10 / 255, green: 14 / 255, blue: 28 / 255, alpha: 1)

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.setURLSchemeHandler(BundleSchemeHandler(),
                                          forURLScheme: BundleSchemeHandler.scheme)

        let content = configuration.userContentController
        /* Injecté à l'ouverture du document, donc avant le script du jeu : le
           bloc `Store` teste window.storage dès qu'il s'exécute, et le trouver
           absent le condamnerait à la mémoire de session pour toute la
           partie. */
        content.addUserScript(WKUserScript(source: Self.bootstrap,
                                           injectionTime: .atDocumentStart,
                                           forMainFrameOnly: true))
        content.add(context.coordinator.haptics, name: HapticBridge.name)
        /* Le monde `.page` et non `.defaultClient` : le script ci-dessus vit
           dans le monde de la page, et un pont posé ailleurs y serait
           invisible. */
        content.addScriptMessageHandler(context.coordinator.storage,
                                        contentWorld: .page,
                                        name: StorageBridge.name)

        let web = WKWebView(frame: .zero, configuration: configuration)
        web.backgroundColor = Self.ground
        web.scrollView.backgroundColor = Self.ground
        web.isOpaque = true

        /* Le plateau se dimensionne lui-même et tient dans l'écran. Laisser le
           moindre défilement ou rebond ferait vibrer la hauteur de la vue, ce
           que le ResizeObserver de index.html prend pour un changement de
           géométrie : il relance alors la mise en place des 52 cartes. */
        web.scrollView.isScrollEnabled = false
        web.scrollView.bounces = false
        web.scrollView.contentInsetAdjustmentBehavior = .never

        /* Rien à naviguer : une seule page, aucun lien sortant. */
        web.allowsBackForwardNavigationGestures = false
        web.allowsLinkPreview = false

        #if DEBUG
        /* Rend la page visible depuis Safari › Développement, indispensable
           pour lire la console du jeu depuis le Mac. */
        if #available(iOS 16.4, *) { web.isInspectable = true }
        #endif

        context.coordinator.haptics.prepare()
        web.load(URLRequest(url: BundleSchemeHandler.startURL))
        return web
    }

    func updateUIView(_ web: WKWebView, context: Context) {
        /* Rien ne pilote la vue depuis SwiftUI : tout l'état du jeu vit dans
           la page, et le recharger effacerait la partie en cours. */
    }

    /// Les ponts eux-mêmes. WKUserContentController ne retient pas ses
    /// gestionnaires, c'est donc le coordinateur qui les garde en vie.
    final class Coordinator {
        let haptics = HapticBridge()
        let storage = StorageBridge()
    }

    /// Pose `window.storage` et `window.SolitaireHaptics`, et rien d'autre.
    ///
    /// Chaque pont est posé seulement si son gestionnaire répond : ainsi la
    /// page reste jouable même si l'un des deux vient à manquer, exactement
    /// comme dans un navigateur.
    private static let bootstrap = """
    (function () {
      var mh = window.webkit && window.webkit.messageHandlers;
      if (!mh) { return; }

      if (mh.storage) {
        // postMessage rend une promesse ici : le gestionnaire natif est
        // déclaré « with reply », ce qui est exactement ce qu'attend Store.
        window.storage = {
          get:    function (key)        { return mh.storage.postMessage({ op: 'get', key: key }); },
          set:    function (key, value) { return mh.storage.postMessage({ op: 'set', key: key, value: value }); },
          delete: function (key)        { return mh.storage.postMessage({ op: 'del', key: key }); }
        };
      }

      if (mh.haptics) {
        window.SolitaireHaptics = function (kind) {
          mh.haptics.postMessage(kind || 'light');
        };
      }
    })();
    """
}
