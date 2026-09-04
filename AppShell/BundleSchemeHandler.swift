import Foundation
import WebKit

/// Sert le jeu depuis le bundle sous un schéma d'URL maison.
///
/// Pourquoi pas `file://` : une page chargée en `file://` reçoit une origine
/// opaque. `localStorage` y est refusé, et le worker du solveur — construit
/// depuis un Blob — se retrouve dans une origine qui n'en est pas une. Un
/// schéma maison donne au contraire une origine stable, `solitaire://game`,
/// donc une page équivalente à une page servie, sans serveur ni réseau.
///
/// Le service worker, lui, ne s'enregistrera pas : WKWebView ne l'accepte que
/// sur des domaines déclarés, pas sur un schéma maison. Ce n'est pas une
/// perte — `sw.js` n'existe que pour mettre le jeu en cache, et dans l'app il
/// est déjà dans le bundle. index.html teste `'serviceWorker' in navigator`
/// avant d'appeler, donc l'absence passe sans erreur.
final class BundleSchemeHandler: NSObject, WKURLSchemeHandler {

    static let scheme = "solitaire"
    static let host = "game"
    static let startURL = URL(string: "\(scheme)://\(host)/index.html")!

    /// Racine des ressources. Rien en dehors de ce dossier n'est servi.
    private let root: URL

    init(root: URL = Bundle.main.resourceURL ?? Bundle.main.bundleURL) {
        self.root = root.standardizedFileURL
        super.init()
    }

    // MARK: - WKURLSchemeHandler

    /// Tout est servi de façon synchrone, avant de rendre la main.
    ///
    /// Ce n'est pas de la paresse : appeler `didReceive` ou `didFinish` sur une
    /// tâche déjà arrêtée lève une exception Objective-C qui termine le
    /// processus. En restant synchrone, `stop(_:)` ne peut pas s'interposer, et
    /// il n'y a aucun état partagé à protéger. Les fichiers sont locaux et le
    /// plus gros fait moins de 200 ko.
    func webView(_ webView: WKWebView, start task: WKURLSchemeTask) {
        guard let url = task.request.url else {
            task.didFailWithError(Self.failure(.badURL, "Requête sans URL."))
            return
        }
        guard let file = resolve(url) else {
            task.didFailWithError(Self.failure(.unsupportedURL,
                "Chemin refusé, hors du bundle : \(url.path)"))
            return
        }
        guard let data = try? Data(contentsOf: file) else {
            task.didFailWithError(Self.failure(.fileDoesNotExist,
                "Ressource absente du bundle : \(url.path)"))
            return
        }
        let response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: [
                "Content-Type": Self.mimeType(forExtension: file.pathExtension),
                "Content-Length": String(data.count),
                /* Le bundle est figé pour une version donnée de l'app : rien à
                   revalider, et rien à garder non plus puisque la lecture est
                   locale. */
                "Cache-Control": "no-cache",
                /* Aucune requête ne sort d'ici, mais autant que la page ne
                   puisse pas être encadrée par autre chose qu'elle-même. */
                "X-Content-Type-Options": "nosniff"
            ])!

        task.didReceive(response)
        task.didReceive(data)
        task.didFinish()
    }

    func webView(_ webView: WKWebView, stop task: WKURLSchemeTask) {
        /* Rien à annuler : `start` a déjà tout servi avant de rendre la main. */
    }

    // MARK: - Résolution des chemins

    /// Traduit une URL du schéma en fichier du bundle, ou `nil` si le chemin
    /// sort de la racine ou ne désigne pas un fichier.
    private func resolve(_ url: URL) -> URL? {
        var path = url.path
        if path.isEmpty || path == "/" { path = "/index.html" }

        /* Les noms du bundle ne sont pas encodés ; ceux de l'URL peuvent
           l'être. On décode avant de comparer. */
        let decoded = path.removingPercentEncoding ?? path
        let relative = String(decoded.dropFirst())          // sans le "/" initial
        guard !relative.isEmpty else { return nil }

        let candidate = root.appendingPathComponent(relative).standardizedFileURL

        /* Confinement. `standardizedFileURL` a déjà résolu les "..", il suffit
           donc de vérifier que ce qui reste est bien sous la racine. Le "/"
           ajouté au préfixe évite qu'un dossier voisin nommé "Resources-bis"
           passe pour un enfant de "Resources". */
        guard candidate.path == root.path
            || candidate.path.hasPrefix(root.path + "/") else { return nil }

        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: candidate.path,
                                            isDirectory: &isDirectory),
              !isDirectory.boolValue else { return nil }

        return candidate
    }

    // MARK: - Types

    /// WKWebView ne devine pas le type d'un schéma maison : sans en-tête
    /// correct, le HTML s'affiche en texte brut et les scripts sont ignorés.
    private static func mimeType(forExtension ext: String) -> String {
        switch ext.lowercased() {
        case "html", "htm":   return "text/html; charset=utf-8"
        case "js", "mjs":     return "text/javascript; charset=utf-8"
        case "css":           return "text/css; charset=utf-8"
        case "json":          return "application/json; charset=utf-8"
        case "webmanifest":   return "application/manifest+json; charset=utf-8"
        case "png":           return "image/png"
        case "jpg", "jpeg":   return "image/jpeg"
        case "svg":           return "image/svg+xml"
        case "ico":           return "image/x-icon"
        case "woff2":         return "font/woff2"
        case "woff":          return "font/woff"
        case "txt", "md":     return "text/plain; charset=utf-8"
        default:              return "application/octet-stream"
        }
    }

    private static func failure(_ code: URLError.Code, _ reason: String) -> NSError {
        NSError(domain: NSURLErrorDomain,
                code: code.rawValue,
                userInfo: [NSLocalizedDescriptionKey: reason])
    }
}
