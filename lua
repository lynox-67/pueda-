-- ======================================
-- LYNOX AUTO JOIN 40M+
-- Ejecuta automáticamente en cada server
-- ======================================

-- ===== SERVICIOS =====
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

-- ===== CONFIG =====
local MIN_BRAINROT = 40_000_000 -- 40M
local LOAD_DELAY = 3 -- segundos para que cargue el mapa

-- ===== PROTECCIÓN DOBLE EJECUCIÓN =====
if getgenv().LYNOX_AUTOJOIN_RUNNING then
    return
end
getgenv().LYNOX_AUTOJOIN_RUNNING = true

-- ===== FUNCIÓN ESCANEO =====
local function FindBrainrot40M()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("NumberValue") then
            if obj.Value >= MIN_BRAINROT then
                return true, obj.Value
            end
        end
    end
    return false, nil
end

-- ===== MAIN =====
task.spawn(function()
    task.wait(LOAD_DELAY)

    local found, value = FindBrainrot40M()

    if found then
        warn("✅ [LYNOX] Brainrot encontrado:", value)
        -- SE QUEDA EN ESTE SERVER
    else
        warn("❌ [LYNOX] No hay 40M+, cambiando server...")
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
end)
