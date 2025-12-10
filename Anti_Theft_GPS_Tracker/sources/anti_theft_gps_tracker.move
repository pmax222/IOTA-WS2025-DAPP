/// Module: anti_theft_gps_tracker
/// 
/// A decentralized GPS tracking system for asset protection on IOTA blockchain.
/// This module enables users to:
/// - Create and manage GPS tracking devices
/// - Register physical assets with GPS devices
/// - Update real-time location coordinates
/// - Mark assets as stolen and trigger alerts
/// - Track recovery status of assets
///
/// For Move coding conventions, see
/// https://docs.iota.org/developer/iota-101/move-overview/conventions

module anti_theft_gps_tracker::anti_theft_gps_tracker {
    use iota::object::UID;
    use iota::tx_context::TxContext;
    use iota::transfer;
    use iota::event;
    use std::string::String;

    // ========== Constants ==========

    /// Unauthorized access error code
    const UNAUTHORIZED: u64 = 3;

    /// Invalid device status error code
    const INVALID_DEVICE_STATUS: u64 = 4;

    /// Asset already marked as stolen error code
    const ALREADY_STOLEN: u64 = 5;

    /// Asset not stolen error code
    const NOT_STOLEN: u64 = 6;

    // ========== Structs ==========

    /// Represents a GPS tracking device
    /// 
    /// Fields:
    /// - `id`: Unique object identifier
    /// - `owner`: Address of the device owner
    /// - `name`: Device name/identifier
    /// - `is_active`: Whether the device is actively tracking
    /// - `latitude`: Current latitude coordinate (scaled)
    /// - `longitude`: Current longitude coordinate (scaled)
    /// - `last_update`: Timestamp of last location update
    /// - `alert_threshold`: Distance threshold for triggering alerts (meters)
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

    /// Represents a physical asset being tracked
    /// 
    /// Fields:
    /// - `id`: Unique object identifier
    /// - `owner`: Address of the asset owner
    /// - `name`: Asset name/description
    /// - `description`: Detailed asset description
    /// - `device_id`: Reference to linked GPS device
    /// - `is_stolen`: Current theft status
    /// - `created_at`: Asset registration timestamp
    public struct TrackedAsset has key {
        id: UID,
        owner: address,
        name: String,
        description: String,
        device_id: address,
        is_stolen: bool,
        created_at: u64,
    }

    /// Registry for managing all devices and assets
    /// 
    /// Fields:
    /// - `id`: Unique object identifier
    /// - `total_devices`: Count of all registered devices
    /// - `total_assets`: Count of all tracked assets
    public struct Registry has key {
        id: UID,
        total_devices: u64,
        total_assets: u64,
    }

    // ========== Events ==========

    /// Emitted when a new GPS device is created
    public struct DeviceCreated has copy, drop {
        device_id: address,
        owner: address,
        name: String,
        timestamp: u64,
    }

    /// Emitted when an asset is registered for tracking
    public struct AssetRegistered has copy, drop {
        asset_id: address,
        owner: address,
        name: String,
        device_id: address,
        timestamp: u64,
    }

    /// Emitted when device location is updated
    public struct LocationUpdated has copy, drop {
        device_id: address,
        latitude: u64,
        longitude: u64,
        timestamp: u64,
    }

    /// Emitted when an asset is marked as stolen
    public struct TheftReported has copy, drop {
        asset_id: address,
        device_id: address,
        timestamp: u64,
    }

    /// Emitted when a stolen asset is recovered
    public struct AssetRecovered has copy, drop {
        asset_id: address,
        timestamp: u64,
    }

    /// Emitted when device activation status changes
    public struct DeviceStatusChanged has copy, drop {
        device_id: address,
        is_active: bool,
        timestamp: u64,
    }

    // ========== Functions ==========

    /// Initialize the tracking system
    /// Creates a shared Registry object for managing all devices and assets
    fun init(ctx: &mut TxContext) {
        let registry = Registry {
            id: iota::object::new(ctx),
            total_devices: 0,
            total_assets: 0,
        };
        transfer::share_object(registry);
    }

    /// Create a new GPS tracking device
    ///
    /// Arguments:
    /// - `name`: Device identifier/name
    /// - `alert_threshold`: Distance threshold in meters for alerts
    /// - `registry`: Mutable reference to the registry
    /// - `ctx`: Transaction context
    ///
    /// Returns: A new GPSDevice object
    public fun create_device(
        name: String,
        alert_threshold: u64,
        registry: &mut Registry,
        ctx: &mut TxContext,
    ): GPSDevice {
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

        device
    }

    /// Register an asset for tracking with a GPS device
    ///
    /// Arguments:
    /// - `name`: Asset name/description
    /// - `description`: Detailed asset description
    /// - `device`: Reference to the GPS device
    /// - `registry`: Mutable reference to the registry
    /// - `ctx`: Transaction context
    ///
    /// Returns: A new TrackedAsset object
    ///
    /// Aborts with:
    /// - `UNAUTHORIZED`: If caller is not the device owner
    /// - `INVALID_DEVICE_STATUS`: If device is not active
    public fun register_asset(
        name: String,
        description: String,
        device: &GPSDevice,
        registry: &mut Registry,
        ctx: &mut TxContext,
    ): TrackedAsset {
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

        asset
    }

    /// Update the current GPS location of a device
    ///
    /// Arguments:
    /// - `device`: Mutable reference to the GPS device
    /// - `latitude`: New latitude coordinate
    /// - `longitude`: New longitude coordinate
    /// - `ctx`: Transaction context
    ///
    /// Aborts with:
    /// - `INVALID_DEVICE_STATUS`: If device is not active
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

    /// Mark an asset as stolen and report the theft
    ///
    /// Arguments:
    /// - `asset`: Mutable reference to the asset
    /// - `device`: Reference to the linked GPS device
    /// - `ctx`: Transaction context
    ///
    /// Aborts with:
    /// - `UNAUTHORIZED`: If caller is not the asset owner
    /// - `ALREADY_STOLEN`: If asset is already marked as stolen
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

    /// Mark a stolen asset as recovered
    ///
    /// Arguments:
    /// - `asset`: Mutable reference to the asset
    /// - `ctx`: Transaction context
    ///
    /// Aborts with:
    /// - `UNAUTHORIZED`: If caller is not the asset owner
    /// - `NOT_STOLEN`: If asset is not marked as stolen
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

    /// Activate a GPS device
    ///
    /// Arguments:
    /// - `device`: Mutable reference to the device
    /// - `ctx`: Transaction context
    ///
    /// Aborts with:
    /// - `UNAUTHORIZED`: If caller is not the device owner
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

    /// Deactivate a GPS device
    ///
    /// Arguments:
    /// - `device`: Mutable reference to the device
    /// - `ctx`: Transaction context
    ///
    /// Aborts with:
    /// - `UNAUTHORIZED`: If caller is not the device owner
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

    // ========== Read-only Functions (Accessors) ==========

    /// Get the owner address of a device
    public fun device_owner(device: &GPSDevice): address {
        device.owner
    }

    /// Get the name of a device
    public fun device_name(device: &GPSDevice): String {
        device.name
    }

    /// Check if a device is currently active
    public fun is_device_active(device: &GPSDevice): bool {
        device.is_active
    }

    /// Get the current coordinates of a device
    public fun device_location(device: &GPSDevice): (u64, u64) {
        (device.latitude, device.longitude)
    }

    /// Get the last location update timestamp
    public fun device_last_update(device: &GPSDevice): u64 {
        device.last_update
    }

    /// Get the alert threshold distance
    public fun device_alert_threshold(device: &GPSDevice): u64 {
        device.alert_threshold
    }

    /// Get the owner of an asset
    public fun asset_owner(asset: &TrackedAsset): address {
        asset.owner
    }

    /// Get the name of an asset
    public fun asset_name(asset: &TrackedAsset): String {
        asset.name
    }

    /// Get the description of an asset
    public fun asset_description(asset: &TrackedAsset): String {
        asset.description
    }

    /// Check if an asset is marked as stolen
    public fun is_asset_stolen(asset: &TrackedAsset): bool {
        asset.is_stolen
    }

    /// Get the linked device ID of an asset
    public fun asset_device_id(asset: &TrackedAsset): address {
        asset.device_id
    }

    /// Get the creation timestamp of an asset
    public fun asset_created_at(asset: &TrackedAsset): u64 {
        asset.created_at
    }

    /// Get the total number of registered devices
    public fun registry_total_devices(registry: &Registry): u64 {
        registry.total_devices
    }

    /// Get the total number of tracked assets
    public fun registry_total_assets(registry: &Registry): u64 {
        registry.total_assets
    }
}


