#include "script_component.hpp"
/*
 * Author: Grey
 * Loads Magazine into static weapon using a timer.
 *
 * Arguments:
 * 0: Static <OBJECT>
 * 1: Unit <OBJECT>
 * 2: Magazine Class <STRING> (default: "")
 *
 * Return Value:
 * None
 *
 * Example:
 * [_target,_player,"ACE_1Rnd_82mm_Mo_HE"] call ace_mk6mortar_fnc_loadMagazineTimer
 *
 * Public: Yes
 */

params ["_static","_unit",["_magazineClassOptional","",[""]]];

_static setVariable [QGVAR(inUse), true, true];

// Move player into animation if player is standing
if ((_unit call CBA_fnc_getUnitAnim) select 0 == "stand") then {
    [_unit, "AmovPercMstpSrasWrflDnon_diary", 1] call EFUNC(common,doAnimation);
};

private _timeToLoad = 5;

if (isNil _magazineClassOptional) then {
    private _configTime = configFile >> "CfgMagazines" >> _magazineClassOptional >> QGVAR(timeToLoad);
    // Default to 5 seconds if the magazine doesn't have a time to load
    if (isNumber(_configTime)) then {
        _timeToLoad = getNumber(_configTime);
    };
};


private _progressBarString = LSTRING(prepRound);

if (GVAR(useChargeSystem)) then {
    _progressBarString = LSTRING(loadingMortar);
    _timeToLoad = 1;
};

[_timeToLoad, [_static,_unit,_magazineClassOptional], {(_this select 0) call FUNC(loadMagazine); ((_this select 0) select 0) setVariable [QGVAR(inUse), nil, true]}, {((_this select 0) select 0) setVariable [QGVAR(inUse), nil, true]}, localize _progressBarString] call EFUNC(common,progressBar);
