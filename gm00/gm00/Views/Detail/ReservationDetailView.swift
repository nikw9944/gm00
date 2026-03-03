import SwiftUI

struct ReservationDetailView: View {
    let pubkey: String
    let reservation: ReservationAccount
    @Binding var navigationPath: NavigationPath

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            DetailSection(title: "Identity") {
                IPAddressView(label: "Client IP", ip: reservation.clientIp)
                DetailRow(label: "Pubkey", value: pubkey, monospaced: true)
            }

            DetailSection(title: "Related Accounts") {
                PubkeyLinkView(label: "Device", pubkey: reservation.devicePk, navigationPath: $navigationPath)
            }
        }
    }
}
