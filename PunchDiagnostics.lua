-- PunchDiagnostics.lua
-- Diagnostic helper for a Roblox experience you own or are authorized to edit.
-- This module does NOT discover hidden functions, inspect executor memory,
-- or invoke another game's remotes.
--
-- Usage:
--   local PunchDiagnostics = require(path.To.PunchDiagnostics)
--   local diagnostics = PunchDiagnostics.new(function(status, detail)
--       print("Punch status:", status, detail or "")
--       -- Update your own UI label here.
--   end)
--
-- Call ReportVerified only after your OWN server-side game logic confirms
-- that a punch action was accepted. Do not use a local hand animation as proof.

local PunchDiagnostics = {}
PunchDiagnostics.__index = PunchDiagnostics

function PunchDiagnostics.new(onChanged)
    assert(onChanged == nil or type(onChanged) == "function",
        "onChanged must be a function or nil")

    local self = setmetatable({}, PunchDiagnostics)
    self._onChanged = onChanged
    self._status = "BELUM DIVERIFIKASI"
    self._detail = "Belum ada konfirmasi dari logika server."
    self:_notify()
    return self
end

function PunchDiagnostics:_notify()
    if self._onChanged then
        local ok, err = pcall(self._onChanged, self._status, self._detail)
        if not ok then
            warn("[PunchDiagnostics] onChanged error:", err)
        end
    end
end

-- Call this when your own server-side handler confirms the punch was accepted.
function PunchDiagnostics:ReportVerified(detail)
    self._status = "BERFUNGSI"
    self._detail = detail or "Aksi pukul dikonfirmasi oleh server."
    self:_notify()
end

-- Use when the game has no authoritative confirmation available.
-- This avoids incorrectly showing TIDAK merely because a detector found nothing.
function PunchDiagnostics:ReportUnverified(detail)
    self._status = "BELUM DIVERIFIKASI"
    self._detail = detail or "Belum ada konfirmasi server; animasi lokal bukan bukti."
    self:_notify()
end

-- Use when your own server explicitly rejects or disables the punch action.
function PunchDiagnostics:ReportUnavailable(detail)
    self._status = "TIDAK TERSEDIA"
    self._detail = detail or "Logika server menyatakan aksi pukul tidak tersedia."
    self:_notify()
end

function PunchDiagnostics:GetStatus()
    return self._status, self._detail
end

return PunchDiagnostics
