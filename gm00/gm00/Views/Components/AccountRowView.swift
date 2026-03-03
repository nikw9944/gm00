import SwiftUI

struct AccountRowView: View {
    let account: ResolvedAccount

    var body: some View {
        switch account {
        case .location(_, let loc):
            locationRow(loc)
        case .exchange(_, let ex):
            exchangeRow(ex)
        case .device(_, let dev):
            deviceRow(dev)
        case .link(_, let link):
            linkRow(link)
        case .user(_, let user):
            userRow(user)
        case .multicastGroup(_, let mg):
            multicastGroupRow(mg)
        case .contributor(_, let contrib):
            contributorRow(contrib)
        case .tenant(_, let tenant):
            tenantRow(tenant)
        case .accessPass(_, let ap):
            accessPassRow(ap)
        case .reservation(_, let res):
            reservationRow(res)
        }
    }

    private func locationRow(_ loc: LocationAccount) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(loc.code)
                    .font(.headline)
                Text("\(loc.name) • \(loc.country)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            StatusBadgeView(loc.status.displayName)
        }
    }

    private func exchangeRow(_ ex: ExchangeAccount) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(ex.code)
                    .font(.headline)
                Text(ex.name)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            StatusBadgeView(ex.status.displayName)
        }
    }

    private func deviceRow(_ dev: DeviceAccount) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(dev.code)
                    .font(.headline)
                HStack(spacing: 4) {
                    Text(dev.deviceType.displayName)
                    Text("•")
                    Text(dev.publicIp)
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                StatusBadgeView(dev.status.displayName)
                StatusBadgeView(dev.deviceHealth.displayName)
            }
        }
    }

    private func linkRow(_ link: LinkAccount) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(link.code)
                    .font(.headline)
                Text("\(link.linkType.displayName) • \(link.bandwidth.formattedBandwidth)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                StatusBadgeView(link.status.displayName)
                StatusBadgeView(link.linkHealth.displayName)
            }
        }
    }

    private func userRow(_ user: DZUser) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(user.displayCode ?? user.pubkey.truncatedPubkey)
                    .font(.headline)
                Text(user.userType.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            StatusBadgeView(user.status.displayName)
        }
    }

    private func multicastGroupRow(_ mg: MulticastGroupAccount) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(mg.code)
                    .font(.headline)
                Text(mg.multicastIp)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            StatusBadgeView(mg.status.displayName)
        }
    }

    private func contributorRow(_ contrib: ContributorAccount) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(contrib.code)
                    .font(.headline)
                Text("Refs: \(contrib.referenceCount)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            StatusBadgeView(contrib.status.displayName)
        }
    }

    private func tenantRow(_ tenant: TenantAccount) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(tenant.code)
                    .font(.headline)
                Text("VRF: \(tenant.vrfId)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            StatusBadgeView(tenant.paymentStatus.displayName)
        }
    }

    private func accessPassRow(_ ap: AccessPassAccount) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(ap.clientIp)
                    .font(.headline)
                Text(ap.accessPassType.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            StatusBadgeView(ap.status.displayName)
        }
    }

    private func reservationRow(_ res: ReservationAccount) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(res.clientIp)
                    .font(.headline)
                Text("Device: \(res.devicePk.truncatedPubkey)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
    }
}
