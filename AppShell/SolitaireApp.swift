import SwiftUI

/// Le point d'entrée. L'app n'est qu'un cadre : tout le jeu vit dans
/// index.html, et rien ici ne doit lui disputer la mise en page.
@main
struct SolitaireApp: App {
    var body: some Scene {
        WindowGroup {
            GameWebView()
                /* La page gère elle-même les zones sûres : son <meta viewport>
                   porte `viewport-fit=cover`, et sa feuille de style compte en
                   env(safe-area-inset-*) pour écarter le bandeau du haut et la
                   barre d'accueil. Laisser SwiftUI insérer ses propres marges
                   les compterait deux fois. */
                .ignoresSafeArea()
                /* Sous la vue, la couleur des bords du fond. Elle ne se voit
                   qu'au tout premier rendu et pendant une rotation, mais du
                   blanc à cet instant se remarque tout de suite. */
                .background(Color(uiColor: GameWebView.ground))
                /* Le jeu n'a pas de version claire : ses cartes sont blanches
                   sur une table sombre. Cela accorde aussi le clavier et les
                   menus système au reste. */
                .preferredColorScheme(.dark)
        }
    }
}
