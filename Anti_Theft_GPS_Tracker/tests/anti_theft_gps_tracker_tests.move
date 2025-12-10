#[test_only]
module anti_theft_gps_tracker::anti_theft_gps_tracker_tests {
    use anti_theft_gps_tracker::anti_theft_gps_tracker::{Self, GPSDevice, TrackedAsset, Registry};
    use iota::test_scenario;
    use std::string;

    #[test]
    fun test_create_device() {
        let user = @0x1;
        let mut scenario = test_scenario::begin(user);
        
        // 1. Khởi tạo hệ thống
        {
            let ctx = test_scenario::ctx(&mut scenario);
            anti_theft_gps_tracker::init_for_testing(ctx);
        };

        // 2. Tạo thiết bị (user gọi hàm)
        test_scenario::next_tx(&mut scenario, user);
        {
            let mut registry = test_scenario::take_shared<Registry>(&scenario);
            let ctx = test_scenario::ctx(&mut scenario);
            
            anti_theft_gps_tracker::create_device(
                string::utf8(b"GPS Device 1"),
                1000,
                &mut registry,
                ctx
            );
            test_scenario::return_shared(registry);
        };

        // 3. Kiểm tra thiết bị đã được chuyển về cho user chưa
        test_scenario::next_tx(&mut scenario, user);
        {
            let device = test_scenario::take_from_sender<GPSDevice>(&scenario);
            assert!(anti_theft_gps_tracker::is_device_active(&device), 0);
            assert!(anti_theft_gps_tracker::device_name(&device) == string::utf8(b"GPS Device 1"), 1);
            test_scenario::return_to_sender(&scenario, device);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_register_asset() {
        let user = @0x1;
        let mut scenario = test_scenario::begin(user);
        
        // Init
        {
            let ctx = test_scenario::ctx(&mut scenario);
            anti_theft_gps_tracker::init_for_testing(ctx);
        };

        // Create Device
        test_scenario::next_tx(&mut scenario, user);
        {
            let mut registry = test_scenario::take_shared<Registry>(&scenario);
            let ctx = test_scenario::ctx(&mut scenario);
            anti_theft_gps_tracker::create_device(
                string::utf8(b"GPS Device"), 1000, &mut registry, ctx
            );
            test_scenario::return_shared(registry);
        };

        // Register Asset
        test_scenario::next_tx(&mut scenario, user);
        {
            let device = test_scenario::take_from_sender<GPSDevice>(&scenario);
            let mut registry = test_scenario::take_shared<Registry>(&scenario);
            let ctx = test_scenario::ctx(&mut scenario);

            anti_theft_gps_tracker::register_asset(
                string::utf8(b"My Car"),
                string::utf8(b"Red sedan"),
                &device,
                &mut registry,
                ctx
            );
            
            test_scenario::return_shared(registry);
            test_scenario::return_to_sender(&scenario, device);
        };

        // Verify Asset
        test_scenario::next_tx(&mut scenario, user);
        {
            let asset = test_scenario::take_from_sender<TrackedAsset>(&scenario);
            assert!(!anti_theft_gps_tracker::is_asset_stolen(&asset), 0);
            assert!(anti_theft_gps_tracker::asset_name(&asset) == string::utf8(b"My Car"), 1);
            test_scenario::return_to_sender(&scenario, asset);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_update_location() {
        let user = @0x1;
        let mut scenario = test_scenario::begin(user);
        
        {
            let ctx = test_scenario::ctx(&mut scenario);
            anti_theft_gps_tracker::init_for_testing(ctx);
        };

        test_scenario::next_tx(&mut scenario, user);
        {
            let mut registry = test_scenario::take_shared<Registry>(&scenario);
            let ctx = test_scenario::ctx(&mut scenario);
            anti_theft_gps_tracker::create_device(string::utf8(b"GPS"), 1000, &mut registry, ctx);
            test_scenario::return_shared(registry);
        };

        test_scenario::next_tx(&mut scenario, user);
        {
            let mut device = test_scenario::take_from_sender<GPSDevice>(&scenario);
            let ctx = test_scenario::ctx(&mut scenario);
            
            anti_theft_gps_tracker::update_location(&mut device, 4000, 5000, ctx);
            
            let (lat, long) = anti_theft_gps_tracker::device_location(&device);
            assert!(lat == 4000, 0);
            assert!(long == 5000, 1);
            
            test_scenario::return_to_sender(&scenario, device);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_report_theft() {
        let user = @0x1;
        let mut scenario = test_scenario::begin(user);
        
        {
            let ctx = test_scenario::ctx(&mut scenario);
            anti_theft_gps_tracker::init_for_testing(ctx);
        };

        // Create Device & Asset
        test_scenario::next_tx(&mut scenario, user);
        {
            let mut registry = test_scenario::take_shared<Registry>(&scenario);
            let ctx = test_scenario::ctx(&mut scenario);
            anti_theft_gps_tracker::create_device(string::utf8(b"GPS"), 1000, &mut registry, ctx);
            test_scenario::return_shared(registry);
        };

        test_scenario::next_tx(&mut scenario, user);
        {
            let device = test_scenario::take_from_sender<GPSDevice>(&scenario);
            let mut registry = test_scenario::take_shared<Registry>(&scenario);
            let ctx = test_scenario::ctx(&mut scenario);
            anti_theft_gps_tracker::register_asset(
                string::utf8(b"Bike"), string::utf8(b"Desc"), &device, &mut registry, ctx
            );
            test_scenario::return_shared(registry);
            test_scenario::return_to_sender(&scenario, device);
        };

        // Report Theft
        test_scenario::next_tx(&mut scenario, user);
        {
            let device = test_scenario::take_from_sender<GPSDevice>(&scenario);
            let mut asset = test_scenario::take_from_sender<TrackedAsset>(&scenario);
            let ctx = test_scenario::ctx(&mut scenario);

            anti_theft_gps_tracker::report_theft(&mut asset, &device, ctx);
            assert!(anti_theft_gps_tracker::is_asset_stolen(&asset), 1);

            test_scenario::return_to_sender(&scenario, device);
            test_scenario::return_to_sender(&scenario, asset);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_recover_asset() {
        let user = @0x1;
        let mut scenario = test_scenario::begin(user);
        
        {
            let ctx = test_scenario::ctx(&mut scenario);
            anti_theft_gps_tracker::init_for_testing(ctx);
        };

        test_scenario::next_tx(&mut scenario, user);
        {
            let mut registry = test_scenario::take_shared<Registry>(&scenario);
            let ctx = test_scenario::ctx(&mut scenario);
            anti_theft_gps_tracker::create_device(string::utf8(b"GPS"), 1000, &mut registry, ctx);
            test_scenario::return_shared(registry);
        };

        test_scenario::next_tx(&mut scenario, user);
        {
            let device = test_scenario::take_from_sender<GPSDevice>(&scenario);
            let mut registry = test_scenario::take_shared<Registry>(&scenario);
            let ctx = test_scenario::ctx(&mut scenario);
            anti_theft_gps_tracker::register_asset(
                string::utf8(b"Laptop"), string::utf8(b"Mac"), &device, &mut registry, ctx
            );
            test_scenario::return_shared(registry);
            test_scenario::return_to_sender(&scenario, device);
        };

        test_scenario::next_tx(&mut scenario, user);
        {
            let device = test_scenario::take_from_sender<GPSDevice>(&scenario);
            let mut asset = test_scenario::take_from_sender<TrackedAsset>(&scenario);
            let ctx = test_scenario::ctx(&mut scenario);

            anti_theft_gps_tracker::report_theft(&mut asset, &device, ctx);
            anti_theft_gps_tracker::recover_asset(&mut asset, ctx);
            assert!(!anti_theft_gps_tracker::is_asset_stolen(&asset), 1);

            test_scenario::return_to_sender(&scenario, device);
            test_scenario::return_to_sender(&scenario, asset);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_deactivate_and_activate_device() {
        let user = @0x1;
        let mut scenario = test_scenario::begin(user);
        
        {
            let ctx = test_scenario::ctx(&mut scenario);
            anti_theft_gps_tracker::init_for_testing(ctx);
        };

        test_scenario::next_tx(&mut scenario, user);
        {
            let mut registry = test_scenario::take_shared<Registry>(&scenario);
            let ctx = test_scenario::ctx(&mut scenario);
            anti_theft_gps_tracker::create_device(string::utf8(b"GPS"), 1000, &mut registry, ctx);
            test_scenario::return_shared(registry);
        };

        test_scenario::next_tx(&mut scenario, user);
        {
            let mut device = test_scenario::take_from_sender<GPSDevice>(&scenario);
            let ctx = test_scenario::ctx(&mut scenario);

            anti_theft_gps_tracker::deactivate_device(&mut device, ctx);
            assert!(!anti_theft_gps_tracker::is_device_active(&device), 1);

            anti_theft_gps_tracker::activate_device(&mut device, ctx);
            assert!(anti_theft_gps_tracker::is_device_active(&device), 2);

            test_scenario::return_to_sender(&scenario, device);
        };

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = anti_theft_gps_tracker::UNAUTHORIZED)]
    fun test_unauthorized_register_asset() {
        let user = @0x1;
        let attacker = @0x2;
        let mut scenario = test_scenario::begin(user);
        
        // 1. Khởi tạo
        {
            let ctx = test_scenario::ctx(&mut scenario);
            anti_theft_gps_tracker::init_for_testing(ctx);
        };

        // 2. User tạo thiết bị
        test_scenario::next_tx(&mut scenario, user);
        {
            let mut registry = test_scenario::take_shared<Registry>(&scenario);
            let ctx = test_scenario::ctx(&mut scenario);
            anti_theft_gps_tracker::create_device(string::utf8(b"GPS"), 1000, &mut registry, ctx);
            test_scenario::return_shared(registry);
        };

        // 3. Attacker cố gắng đăng ký tài sản vào thiết bị của User
        test_scenario::next_tx(&mut scenario, attacker); 
        {
             // Lấy thiết bị từ kho chứa của User để làm tham số test (không cần transfer)
             let device = test_scenario::take_from_address<GPSDevice>(&scenario, user);
             let mut registry = test_scenario::take_shared<Registry>(&scenario);
             let ctx = test_scenario::ctx(&mut scenario);

             // Hàm này sẽ thất bại (ABORT) tại đây vì:
             // sender (attacker) != device.owner (user)
             anti_theft_gps_tracker::register_asset(
                string::utf8(b"Stolen Asset"),
                string::utf8(b"Desc"),
                &device,
                &mut registry,
                ctx
             );

             // Các dòng dưới này sẽ không chạy được do hàm trên đã abort, 
             // nhưng cần thiết để trình biên dịch không báo lỗi unused variables
             test_scenario::return_shared(registry);
             test_scenario::return_to_address(user, device);
        };

        test_scenario::end(scenario);
    }
}
