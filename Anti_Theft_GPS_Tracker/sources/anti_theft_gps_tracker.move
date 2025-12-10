/// Module: anti_theft_gps_tracker
#[allow(duplicate_alias)]
module anti_theft_gps_tracker::anti_theft_gps_tracker {
    use iota::object::UID;
    use iota::tx_context::TxContext;
    use iota::transfer;
    use iota::event;
    use std::string::String;

    // ========== Constants ==========
    const UNAUTHORIZED: u64 = 3;
    const INVALID_DEVICE_STATUS: u64 = 4;
    const ALREADY_STOLEN: u64 = 5;
    const NOT_STOLEN: u64 = 6;

    // ========== Structs ==========
    public struct GPSDevice has key {
        id: UID,
        owner: address,
        name: String,
        is_active: bool,
        latitude: u64,
        longitude: u64,
        last_update: u64,
        alert_threshold: u64,
    }

    public struct TrackedAsset has key {
        id: UID,
        owner: address,
        name: String,
        description: String,
        device_id: address,
        is_stolen: bool,
        created_at: u64,
    }

    public struct Registry has key {
        id: UID,
        total_devices: u64,
        total_assets: u64,
    }

    // ========== Events ==========
    public struct DeviceCreated has copy, drop {
        device_id: address,
        owner: address,
        name: String,
        timestamp: u64,
    }

    public struct AssetRegistered has copy, drop {
        asset_id: address,
        owner: address,
        name: String,
        device_id: address,
        timestamp: u64,
    }

    public struct LocationUpdated has copy, drop {
        device_id: address,
        latitude: u64,
        longitude: u64,
        timestamp: u64,
    }

    public struct TheftReported has copy, drop {
        asset_id: address,
        device_id: address,
        timestamp: u64,
    }

    public struct AssetRecovered has copy, drop {
        asset_id: address,
        timestamp: u64,
    }

    public struct DeviceStatusChanged has copy, drop {
        device_id: address,
        is_active: bool,
        timestamp: u64,
    }

    // ========== Functions ==========

    fun init(ctx: &mut TxContext) {
        let registry = Registry {
            id: iota::object::new(ctx),
            total_devices: 0,
            total_assets: 0,
        };
        transfer::share_object(registry);
    }

    // --- Hàm hỗ trợ Test ---
    #[test_only]
    public fun init_for_testing(ctx: &mut TxContext) {
        init(ctx);
    }
    // -----------------------

    /// Create a new GPS tracking device and transfer to sender
    public fun create_device(
        name: String,
        alert_threshold: u64,
        registry: &mut Registry,
        ctx: &mut TxContext,
    ) { // Không còn trả về GPSDevice, hàm sẽ tự transfer
        let device = GPSDevice {
            id: iota::object::new(ctx),
            owner: iota::tx_context::sender(ctx),
            name,
            is_active: true,
            latitude: 0,
            longitude: 0,
            last_update: iota::tx_context::epoch(ctx),
            alert_threshold,
        };
        registry.total_devices = registry.total_devices + 1;

        let device_id = iota::object::uid_to_address(&device.id);
        event::emit(DeviceCreated {
            device_id,
            owner: iota::tx_context::sender(ctx),
            name,
            timestamp: iota::tx_context::epoch(ctx),
        });
        
        // Transfer trực tiếp cho người gọi
        transfer::transfer(device, iota::tx_context::sender(ctx));
    }

    /// Register an asset and transfer to sender
    public fun register_asset(
        name: String,
        description: String,
        device: &GPSDevice,
        registry: &mut Registry,
        ctx: &mut TxContext,
    ) { // Không còn trả về TrackedAsset
        assert!(device.owner == iota::tx_context::sender(ctx), UNAUTHORIZED);
        assert!(device.is_active, INVALID_DEVICE_STATUS);

        let asset = TrackedAsset {
            id: iota::object::new(ctx),
            owner: iota::tx_context::sender(ctx),
            name,
            description,
            device_id: iota::object::uid_to_address(&device.id),
            is_stolen: false,
            created_at: iota::tx_context::epoch(ctx),
        };

        registry.total_assets = registry.total_assets + 1;

        let asset_id = iota::object::uid_to_address(&asset.id);
        event::emit(AssetRegistered {
            asset_id,
            owner: iota::tx_context::sender(ctx),
            name,
            device_id: iota::object::uid_to_address(&device.id),
            timestamp: iota::tx_context::epoch(ctx),
        });

        // Transfer trực tiếp cho người gọi
        transfer::transfer(asset, iota::tx_context::sender(ctx));
    }

    public fun update_location(
        device: &mut GPSDevice,
        latitude: u64,
        longitude: u64,
        ctx: &mut TxContext,
    ) {
        assert!(device.is_active, INVALID_DEVICE_STATUS);
        device.latitude = latitude;
        device.longitude = longitude;
        device.last_update = iota::tx_context::epoch(ctx);

        let device_id = iota::object::uid_to_address(&device.id);
        event::emit(LocationUpdated {
            device_id,
            latitude,
            longitude,
            timestamp: iota::tx_context::epoch(ctx),
        });
    }

    public fun report_theft(
        asset: &mut TrackedAsset,
        device: &GPSDevice,
        ctx: &mut TxContext,
    ) {
        assert!(asset.owner == iota::tx_context::sender(ctx), UNAUTHORIZED);
        assert!(!asset.is_stolen, ALREADY_STOLEN);

        asset.is_stolen = true;

        let asset_id = iota::object::uid_to_address(&asset.id);
        event::emit(TheftReported {
            asset_id,
            device_id: iota::object::uid_to_address(&device.id),
            timestamp: iota::tx_context::epoch(ctx),
        });
    }

    public fun recover_asset(
        asset: &mut TrackedAsset,
        ctx: &mut TxContext,
    ) {
        assert!(asset.owner == iota::tx_context::sender(ctx), UNAUTHORIZED);
        assert!(asset.is_stolen, NOT_STOLEN);
        asset.is_stolen = false;

        let asset_id = iota::object::uid_to_address(&asset.id);
        event::emit(AssetRecovered {
            asset_id,
            timestamp: iota::tx_context::epoch(ctx),
        });
    }

    public fun activate_device(
        device: &mut GPSDevice,
        ctx: &mut TxContext,
    ) {
        assert!(device.owner == iota::tx_context::sender(ctx), UNAUTHORIZED);
        device.is_active = true;
        let device_id = iota::object::uid_to_address(&device.id);
        event::emit(DeviceStatusChanged {
            device_id,
            is_active: true,
            timestamp: iota::tx_context::epoch(ctx),
        });
    }

    public fun deactivate_device(
        device: &mut GPSDevice,
        ctx: &mut TxContext,
    ) {
        assert!(device.owner == iota::tx_context::sender(ctx), UNAUTHORIZED);
        device.is_active = false;
        let device_id = iota::object::uid_to_address(&device.id);
        event::emit(DeviceStatusChanged {
            device_id,
            is_active: false,
            timestamp: iota::tx_context::epoch(ctx),
        });
    }

    // ========== Read-only Functions ==========
    public fun device_owner(device: &GPSDevice): address { device.owner }
    public fun device_name(device: &GPSDevice): String { device.name }
    public fun is_device_active(device: &GPSDevice): bool { device.is_active }
    public fun device_location(device: &GPSDevice): (u64, u64) { (device.latitude, device.longitude) }
    public fun device_last_update(device: &GPSDevice): u64 { device.last_update }
    public fun device_alert_threshold(device: &GPSDevice): u64 { device.alert_threshold }
    public fun asset_owner(asset: &TrackedAsset): address { asset.owner }
    public fun asset_name(asset: &TrackedAsset): String { asset.name }
    public fun asset_description(asset: &TrackedAsset): String { asset.description }
    public fun is_asset_stolen(asset: &TrackedAsset): bool { asset.is_stolen }
    public fun asset_device_id(asset: &TrackedAsset): address { asset.device_id }
    public fun asset_created_at(asset: &TrackedAsset): u64 { asset.created_at }
    public fun registry_total_devices(registry: &Registry): u64 { registry.total_devices }
    public fun registry_total_assets(registry: &Registry): u64 { registry.total_assets }
}
