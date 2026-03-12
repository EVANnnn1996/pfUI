pfUI:RegisterModule("target", "vanilla:tbc", function ()
  -- do not go further on disabled UFs
  if C.unitframes.disable == "1" then return end

  -- Hide Blizzard target frame and unregister all events to prevent it from popping up again
  TargetFrame:Hide()
  TargetFrame:UnregisterAllEvents()

  pfUI.uf.target = pfUI.uf:CreateUnitFrame("Target", nil, C.unitframes.target)
  local targetFrame = pfUI.uf.target
  if not targetFrame.infoTopCenterText then
    targetFrame.infoTopCenterText = targetFrame.texts:CreateFontString(nil, "OVERLAY")
    targetFrame.infoTopCenterText:SetFontObject(GameFontWhite)
    local cfg = targetFrame.config
    local fontname, fontsize, fontstyle
    if cfg.customfont == "1" then
      fontname = pfUI.media[cfg.customfont_name]
      fontsize = tonumber(cfg.customfont_size)
      fontstyle = cfg.customfont_style
    else
      fontname = pfUI.font_unit
      fontsize = tonumber(C.global.font_unit_size)
      fontstyle = C.global.font_unit_style
    end
    targetFrame.infoTopCenterText:SetFont(fontname, fontsize, fontstyle)
    targetFrame.infoTopCenterText:SetJustifyH("CENTER")
    targetFrame.infoTopCenterText:SetPoint("TOPLEFT", targetFrame.hp.bar, "TOPLEFT", 0, 0)
    targetFrame.infoTopCenterText:SetPoint("TOPRIGHT", targetFrame.hp.bar, "TOPRIGHT", 0, 0)
    targetFrame.infoTopCenterText:SetHeight(14)
  end

  local S = { target = "target" }

  local function UpdateArmorText()
    local cfg = targetFrame.config
    if not cfg or cfg.display_armor ~= "1" then
      targetFrame.infoTopCenterText:SetText("")
      return
    end

    if not UnitExists(S.target) or not UnitIsEnemy("player", S.target) then
      targetFrame.infoTopCenterText:SetText("")
      return
    end

    local armor = UnitResistance(S.target, 0)
    if not armor then
      targetFrame.infoTopCenterText:SetText("")
      return
    end

    targetFrame.infoTopCenterText:SetText(string.format("|cffFFFFFF%d|r", armor))
  end

  local hookUpdateConfig = targetFrame.UpdateConfig
  function targetFrame:UpdateConfig()
    if hookUpdateConfig then
      hookUpdateConfig(self)
    end
    UpdateArmorText()
  end

  if targetFrame:GetScript("OnUpdate") then
    local originalOnUpdate = targetFrame:GetScript("OnUpdate")
    targetFrame:SetScript("OnUpdate", function()
      if (this.throttleTick or 0) > GetTime() then
        return
      end
      this.throttleTick = GetTime() + 0.05
      originalOnUpdate()
      if (this.armorTextTick or 0) <= GetTime() then
        this.armorTextTick = GetTime() + 0.25
        UpdateArmorText()
      end
    end)
  end

  UpdateArmorText()

  pfUI.uf.target:UpdateFrameSize()
  pfUI.uf.target:SetPoint("BOTTOMLEFT", UIParent, "BOTTOM", 75, 125)
  UpdateMovable(pfUI.uf.target)
end)
