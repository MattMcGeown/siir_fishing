Config = {}
Config.Locale = 'en'

Config.LegalFishing = {
    -- PolyZone coords
    ZoneOne = {
        pos1 = vec2(1308.5000, 4246.1000),
        pos2 = vec2(1306.3000, 4234.7001),
        pos3 = vec2(1341.9000, 4226.8999),
        pos4 = vec2(1341.2000, 4223.0000),
        pos5 = vec2(1305.0999, 4229.7001),
        pos6 = vec2(1301.8000, 4214.3999),
        pos7 = vec2(1295.8000, 4215.2998),
        pos8 = vec2(1301.0999, 4246.9000),
    },

    CatchItems = {
        -- Bait type
        fish_bait = {
            {catch = 'boot', minWeight = 1000, maxWeight = 2000, model = 'prop_old_boot'},
            {catch = 'perch', minWeight = 380, maxWeight = 1360, model = 'a_c_fish'},
            {catch = 'bass', minWeight = 400, maxWeight = 1400, model = 'a_c_fish'},
            {catch = 'catfish', minWeight = 600, maxWeight = 1600, model = 'a_c_fish'},
            {catch = 'sturgeon', minWeight = 800, maxWeight = 2000, model = 'a_c_fish'},
        },
        -- Bait type
        premium_fish_bait = {
            {catch = 'perch', minWeight = 1814, maxWeight = 2721, model = 'a_c_fish'},
            {catch = 'bass', minWeight = 1850, maxWeight = 3000, model = 'a_c_fish'},
            {catch = 'catfish', minWeight = 2000, maxWeight = 4000, model = 'a_c_fish'},
            {catch = 'sturgeon', minWeight = 2500, maxWeight = 5500, model = 'a_c_fish'},
        }
    }
}

Config.IllegalFishing = {
    ZoneOne = {
        pos1 = vec2(3962.1999, 4637.8999),
        pos2 = vec2(3950.1999, 4601.2998),
        pos3 = vec2(3919.1000, 4620.7001),
        pos4 = vec2(3887.8999, 4677.1000),
        pos5 = vec2(3901.1000, 4696.5000),
        pos6 = vec2(3939.6000, 4677.6000),
    },

    CatchItems = {
        -- Bait type
        fish_guts = {
            {catch = 'dolphin', minWeight = 7000, maxWeight = 9000, model = 'a_c_dolphin'},
            {catch = 'whale', minWeight = 15000, maxWeight = 20000, model = 'a_c_killerwhale'},
            {catch = 'shark', minWeight = 8000, maxWeight = 10000, model = 'a_c_sharkhammer'},
            {catch = 'stingray', minWeight = 4000, maxWeight = 6000, model = 'a_c_stingray'},
        },
    }
}