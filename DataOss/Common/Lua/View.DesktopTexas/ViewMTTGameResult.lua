-- Copyright(c) Cragon. All rights reserved.

---------------------------------------
ViewMTTGameResult = ViewBase:new()

---------------------------------------
function ViewMTTGameResult:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.ViewMgr = nil
    o.GoUi = nil
    o.ComUi = nil
    o.Panel = nil
    o.UILayer = nil
    o.InitDepth = nil
    o.ViewKey = nil
    o.Tips = {
        [1] = "MTTResultTip1",
        [2] = "MTTResultTip2"
    }
    return o
end

---------------------------------------
function ViewMTTGameResult:OnCreate()
    local view_matchInfo = self.ViewMgr:GetView("MatchInfo")
    if (view_matchInfo ~= nil) then
        self.ViewMgr:DestroyView(view_matchInfo)
    end
    local com_ui = self.ComUi
    self.ControllerShare = com_ui:GetController("ControllerShare")
    self.ControllerRank = com_ui:GetController("ControllerRank")
    self.TextTips = com_ui:GetChild("TextTips").asTextField
    self.TextRank = com_ui:GetChild("TextRank").asTextField
    self.ListReward = com_ui:GetChild("ListReward").asList

    local p_r = com_ui:GetChild("ParticleRed").asGraph
    local p_r1 = ParticleHelper:GetParticel("fallcolorred.ab")
    local p_r2 = CS.UnityEngine.GameObject.Instantiate(p_r1:LoadAsset("FallColorRed"))
    p_r:SetNativeObject(CS.FairyGUI.GoWrapper(p_r2))

    local p_b = com_ui:GetChild("ParticleBlue").asGraph
    local p_b1 = ParticleHelper:GetParticel("fallcolorblue.ab")
    local p_b2 = CS.UnityEngine.GameObject.Instantiate(p_b1:LoadAsset("FallColorBlue"))
    p_b:SetNativeObject(CS.FairyGUI.GoWrapper(p_b2))

    local p_p = com_ui:GetChild("ParticleP").asGraph
    local p_p1 = ParticleHelper:GetParticel("fallcolorp.ab")
    local p_p2 = CS.UnityEngine.GameObject.Instantiate(p_p1:LoadAsset("FallColorP"))
    p_p:SetNativeObject(CS.FairyGUI.GoWrapper(p_p2))
end

---------------------------------------
function ViewMTTGameResult:OnDestroy()
end

---------------------------------------
function ViewMTTGameResult:OnHandleEv(ev)
end

---------------------------------------
function ViewMTTGameResult:setResult(game_over, cannot_ob)
    local com_ui = self.ComUi
    local group_multi_share = com_ui:GetChild("GroupMultiCanShare").asGroup
    local group_multi_not_share = com_ui:GetChild("GroupMultiCanNotShare").asGroup
    local group_single_share = com_ui:GetChild("GroupSingleCanShare").asGroup
    local group_single_not_share = com_ui:GetChild("GroupSingleCanNotShare").asGroup
    local btn_group = group_multi_share
    local show_tips = false
    local show_list = true
    local select_index = 0
    if cannot_ob then
        if game_over.RewardGold <= 0 and game_over.RewardDiamond <= 0 and game_over.ListRewardItemId == nil then
            select_index = 2
            btn_group = group_single_not_share
            show_tips = true
            show_list = false
            self.TextTips.text = self.ViewMgr.LanMgr:getLanValue(self.Tips[2])
        else
            select_index = 3
            btn_group = group_single_share
            self:createItem(game_over.RewardGold, game_over.RewardDiamond, game_over.ListRewardItemId)
            self.BtnShare = com_ui:GetChildInGroup(group_single_share, "BtnShare").asButton
            self.BtnShare.onClick:Add(
                    function()
                        self:_onClickBtnShare()
                    end)
        end
    else
        if game_over.RewardGold <= 0 and game_over.RewardDiamond <= 0 and game_over.ListRewardItemId == nil then
            select_index = 0
            btn_group = group_multi_not_share
            show_tips = true
            show_list = false
            self.TextTips.text = self.ViewMgr.LanMgr:getLanValue(self.Tips[2])
        else
            select_index = 1
            self:createItem(game_over.RewardGold, game_over.RewardDiamond, game_over.ListRewardItemId)
            self.BtnShare = com_ui:GetChildInGroup(group_multi_share, "BtnShare").asButton
            self.BtnShare.onClick:Add(
                    function()
                        self:_onClickBtnShare()
                    end)
        end
        self.BtnOB = com_ui:GetChildInGroup(btn_group, "BtnOB").asButton
        self.BtnOB.onClick:Add(
                function()
                    self:_onClickBtnOB()
                end)
    end

    self.ControllerShare.selectedIndex = select_index

    local select_rank = 1
    if game_over.Ranking > 0 then
        select_rank = 0
        self.TextRank.text = game_over.Ranking
        self.TextTips.text = self.ViewMgr.LanMgr:getLanValue(self.Tips[1])
    end
    self.ControllerRank.selectedIndex = select_rank

    ViewHelper:SetGObjectVisible(show_tips, self.TextTips)
    ViewHelper:SetGObjectVisible(show_list, self.ListReward)

    self.BtnReturn = com_ui:GetChildInGroup(btn_group, "BtnReturn").asButton
    self.BtnReturn.onClick:Add(
            function()
                self:_onClickBtnLeave()
            end)
end

---------------------------------------
function ViewMTTGameResult:createItem(reward_gold, reward_diamond, list_reward)
    if (reward_gold > 0)
    then
        local com = CS.FairyGUI.UIPackage.CreateObject("Common", "ComItemReward").asCom
        self.ListReward:AddChild(com)
        ItemMttRewardItem:new(nil, com, 0, reward_gold, 0, self.ViewMgr)
    end
    if (reward_diamond > 0)
    then
        local com = CS.FairyGUI.UIPackage.CreateObject("Common", "ComItemReward").asCom
        self.ListReward:AddChild(com)
        ItemMttRewardItem:new(nil, com, 0, 0, reward_diamond, self.ViewMgr)
    end
    if (list_reward ~= nil)
    then
        for i, v in pairs(list_reward) do
            local com = CS.FairyGUI.UIPackage.CreateObject("Common", "ComItemReward").asCom
            self.ListReward:AddChild(com)
            ItemMttRewardItem:new(nil, com, v, 0, 0, self.ViewMgr)
        end
    end
end

---------------------------------------
function ViewMTTGameResult:_onClickBtnLeave()
    local ev = self.ViewMgr:GetEv("EvUiClickExitDesk")
    if (ev == nil)
    then
        ev = EvUiClickExitDesk:new(nil)
    end
    self.ViewMgr:SendEv(ev)
    self:_onClickClose()
end

---------------------------------------
function ViewMTTGameResult:_onClickBtnShare()
    local pic_name = "Share.png"
    local pic_path = CS.Casinos.CasinosContext.Instance.PathMgr:CombinePersistentDataPath(pic_name)
    PicCapture.Instance:CapturePic(pic_name, function()
        Native.Instance:ShareContent(CS.cn.sharesdk.unity3d.PlatformType.WeChat, self.ViewMgr.LanMgr:getLanValue("PlayGameNow"), pic_path, self.ViewMgr.LanMgr:getLanValue("CragonPoker"),
                Native.Instance.ShareUrl, CS.cn.sharesdk.unity3d.ContentType.Image)--Webpage
    end)
end

---------------------------------------
function ViewMTTGameResult:_onClickBtnOB()
    local ev = self.ViewMgr:GetEv("EvUiClickOB")
    if (ev == nil)
    then
        ev = EvUiClickOB:new(nil)
    end
    self.ViewMgr:SendEv(ev)
    self:_onClickClose()
end

---------------------------------------
function ViewMTTGameResult:_onClickClose()
    self.ViewMgr:DestroyView(self)
end

---------------------------------------
ViewMTTGameResultFactory = ViewFactory:new()

---------------------------------------
function ViewMTTGameResultFactory:new(o, ui_package_name, ui_component_name,
                                      ui_layer, is_single, fit_screen)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.PackageName = ui_package_name
    self.ComponentName = ui_component_name
    self.UILayer = ui_layer
    self.IsSingle = is_single
    self.FitScreen = fit_screen
    return o
end

---------------------------------------
function ViewMTTGameResultFactory:CreateView()
    local view = ViewMTTGameResult:new(nil)
    return view
end