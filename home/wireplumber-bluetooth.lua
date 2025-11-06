-- WirePlumber Bluetooth Configuration
-- Prefer A2DP (high-quality audio) profile over HFP/HSP (calling) profile
-- Optimized for Nothing Ear devices

bluez_monitor.properties = {
  -- Enable high-quality SBC codec
  ["bluez5.enable-sbc-xq"] = true,

  -- Enable mSBC for better call quality when in HFP/HSP mode
  ["bluez5.enable-msbc"] = true,

  -- Enable hardware volume control
  ["bluez5.enable-hw-volume"] = true,

  -- Supported headset roles
  ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]",

  -- Supported codecs (SBC, SBC-XQ, AAC)
  ["bluez5.codecs"] = "[ sbc sbc_xq aac ]",

  -- Auto-connect profiles (prefer A2DP sink)
  ["bluez5.auto-connect"] = "[ hfp_hf hsp_hs a2dp_sink ]",

  -- Default profile: A2DP sink (high-quality audio)
  ["bluez5.profile"] = "a2dp-sink",
}

-- Set A2DP as default profile for all Bluetooth audio devices
bluez_monitor.rules = {
  {
    matches = {
      {
        -- Match all Bluetooth audio devices
        { "device.name", "matches", "bluez_card.*" },
      },
    },
    apply_properties = {
      -- Always prefer A2DP profile on connection
      ["device.profile"] = "a2dp-sink",
    },
  },
}
