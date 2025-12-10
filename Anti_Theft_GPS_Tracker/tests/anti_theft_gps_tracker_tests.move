#[test_only]
module anti_theft_gps_tracker::anti_theft_gps_tracker_tests {
    use anti_theft_gps_tracker::anti_theft_gps_tracker;
    use iota::test_scenario;
    use iota::transfer;
    use std::string;

    #[test]
    fun test_create_device() {
        let mut scenario = test_scenario::begin(@0x1);
        let ctx = test_scenario::ctx(&mut scenario);
        
        let mut registry = anti_theft_gps_tracker::Registry {
            id: iota::object::new(ctx),
            total_devices: 0,
            total_assets: 0,
        };

        let device = anti_theft_gps_tracker::create_device(
            string::utf8(b"GPS Device 1"),
            1000,
            &mut registry,
            ctx,
        );

        assert!(anti_theft_gps_tracker::is_device_active(&device), 0);
        assert!(anti_theft_gps_tracker::device_name(&device) == string::utf8(b"GPS Device 1"), 1);

        let sender = iota::tx_context::sender(ctx);
        transfer::transfer(device, sender);
        transfer::transfer(registry, sender);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_register_asset() {
        let mut scenario = test_scenario::begin(@0x1);
        let ctx = test_scenario::ctx(&mut scenario);
        
        let mut registry = anti_theft_gps_tracker::Registry {
            id: iota::object::new(ctx),
            total_devices: 0,
            total_assets: 0,
        };

        let device = anti_theft_gps_tracker::create_device(
            string::utf8(b"GPS Device"),
            1000,
            &mut registry,
            ctx,
        );

        let asset = anti_theft_gps_tracker::register_asset(
            string::utf8(b"My Car"),
            string::utf8(b"Red sedan, license ABC123"),
            &device,
            &mut registry,
            ctx,
        );

        assert!(!anti_theft_gps_tracker::is_asset_stolen(&asset), 0);
        assert!(anti_theft_gps_tracker::asset_name(&asset) == string::utf8(b"My Car"), 1);

        let sender = iota::tx_context::sender(ctx);
        transfer::transfer(device, sender);
        transfer::transfer(asset, sender);
        transfer::transfer(registry, sender);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_update_location() {
        let mut scenario = test_scenario::begin(@0x1);
        let ctx = test_scenario::ctx(&mut scenario);
        
        let mut registry = anti_theft_gps_tracker::Registry {
            id: iota::object::new(ctx),
            total_devices: 0,
            total_assets: 0,
        };

        let mut device = anti_theft_gps_tracker::create_device(
            string::utf8(b"GPS Device"),
            1000,
            &mut registry,
            ctx,
        );

        anti_theft_gps_tracker::update_location(&mut device, 4000, 5000, ctx);

        let (latitude, longitude) = anti_theft_gps_tracker::device_location(&device);
        assert!(latitude == 4000, 0);
        assert!(longitude == 5000, 1);

        let sender = iota::tx_context::sender(ctx);
        transfer::transfer(device, sender);
        transfer::transfer(registry, sender);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_report_theft() {
        let mut scenario = test_scenario::begin(@0x1);
        let ctx = test_scenario::ctx(&mut scenario);
        
        let mut registry = anti_theft_gps_tracker::Registry {
            id: iota::object::new(ctx),
            total_devices: 0,
            total_assets: 0,
        };

        let device = anti_theft_gps_tracker::create_device(
            string::utf8(b"GPS Device"),
            1000,
            &mut registry,
            ctx,
        );

        let mut asset = anti_theft_gps_tracker::register_asset(
            string::utf8(b"My Bike"),
            string::utf8(b"Mountain bike"),
            &device,
            &mut registry,
            ctx,
        );

        assert!(!anti_theft_gps_tracker::is_asset_stolen(&asset), 0);

        anti_theft_gps_tracker::report_theft(&mut asset, &device, ctx);

        assert!(anti_theft_gps_tracker::is_asset_stolen(&asset), 1);

        let sender = iota::tx_context::sender(ctx);
        transfer::transfer(device, sender);
        transfer::transfer(asset, sender);
        transfer::transfer(registry, sender);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_recover_asset() {
        let mut scenario = test_scenario::begin(@0x1);
        let ctx = test_scenario::ctx(&mut scenario);
        
        let mut registry = anti_theft_gps_tracker::Registry {
            id: iota::object::new(ctx),
            total_devices: 0,
            total_assets: 0,
        };

        let device = anti_theft_gps_tracker::create_device(
            string::utf8(b"GPS Device"),
            1000,
            &mut registry,
            ctx,
        );

        let mut asset = anti_theft_gps_tracker::register_asset(
            string::utf8(b"My Laptop"),
            string::utf8(b"MacBook Pro 16"),
            &device,
            &mut registry,
            ctx,
        );

        anti_theft_gps_tracker::report_theft(&mut asset, &device, ctx);
        assert!(anti_theft_gps_tracker::is_asset_stolen(&asset), 0);

        anti_theft_gps_tracker::recover_asset(&mut asset, ctx);
        assert!(!anti_theft_gps_tracker::is_asset_stolen(&asset), 1);

        let sender = iota::tx_context::sender(ctx);
        transfer::transfer(device, sender);
        transfer::transfer(asset, sender);
        transfer::transfer(registry, sender);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_deactivate_and_activate_device() {
        let mut scenario = test_scenario::begin(@0x1);
        let ctx = test_scenario::ctx(&mut scenario);
        
        let mut registry = anti_theft_gps_tracker::Registry {
            id: iota::object::new(ctx),
            total_devices: 0,
            total_assets: 0,
        };

        let mut device = anti_theft_gps_tracker::create_device(
            string::utf8(b"GPS Device"),
            1000,
            &mut registry,
            ctx,
        );

        assert!(anti_theft_gps_tracker::is_device_active(&device), 0);

        anti_theft_gps_tracker::deactivate_device(&mut device, ctx);
        assert!(!anti_theft_gps_tracker::is_device_active(&device), 1);

        anti_theft_gps_tracker::activate_device(&mut device, ctx);
        assert!(anti_theft_gps_tracker::is_device_active(&device), 2);

        let sender = iota::tx_context::sender(ctx);
        transfer::transfer(device, sender);
        transfer::transfer(registry, sender);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = anti_theft_gps_tracker::UNAUTHORIZED)]
    fun test_unauthorized_register_asset() {
        let mut scenario = test_scenario::begin(@0x1);
        let ctx = test_scenario::ctx(&mut scenario);
        
        let mut registry = anti_theft_gps_tracker::Registry {
            id: iota::object::new(ctx),
            total_devices: 0,
            total_assets: 0,
        };

        let device = anti_theft_gps_tracker::create_device(
            string::utf8(b"GPS Device"),
            1000,
            &mut registry,
            ctx,
        );

        test_scenario::next_tx(&mut scenario, @0x2);
        let ctx = test_scenario::ctx(&mut scenario);

        // This should fail because @0x2 is not the device owner
        let _asset = anti_theft_gps_tracker::register_asset(
            string::utf8(b"Someone Else's Car"),
            string::utf8(b"Stolen asset"),
            &device,
            &mut registry,
            ctx,
        );
        let _ = _asset;

        let sender = iota::tx_context::sender(ctx);
        transfer::transfer(device, sender);
        transfer::transfer(registry, sender);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = anti_theft_gps_tracker::ALREADY_STOLEN)]
    fun test_double_theft_report() {
        let mut scenario = test_scenario::begin(@0x1);
        let ctx = test_scenario::ctx(&mut scenario);
        
        let mut registry = anti_theft_gps_tracker::Registry {
            id: iota::object::new(ctx),
            total_devices: 0,
            total_assets: 0,
        };

        let device = anti_theft_gps_tracker::create_device(
            string::utf8(b"GPS Device"),
            1000,
            &mut registry,
            ctx,
        );

        let mut asset = anti_theft_gps_tracker::register_asset(
            string::utf8(b"My Phone"),
            string::utf8(b"iPhone 15"),
            &device,
            &mut registry,
            ctx,
        );

        anti_theft_gps_tracker::report_theft(&mut asset, &device, ctx);
        // This should fail - can't report theft twice
        anti_theft_gps_tracker::report_theft(&mut asset, &device, ctx);

        let sender = iota::tx_context::sender(ctx);
        transfer::transfer(device, sender);
        transfer::transfer(asset, sender);
        transfer::transfer(registry, sender);
        test_scenario::end(scenario);
    }
}
