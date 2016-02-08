/*
 * Author: Glowbal
 * Handle the UI data display.
 *
 * Arguments:
 * 0: Display <DISPLAY>
 *
 * Return value:
 * None
 *
 * Example:
 * [display] call ace_cargo_fnc_onMenuOpen
 *
 * Public: No
 */
#include "script_component.hpp"

disableSerialization;

params ["_display"];

uiNamespace setVariable [QGVAR(menuDisplay), _display];

[{
    disableSerialization;
    private _display = uiNamespace getVariable QGVAR(menuDisplay);
    if (isnil "_display") exitWith {
        [_this select 1] call CBA_fnc_removePerFrameHandler;
    };

    if (isNull GVAR(interactionVehicle) || {ACE_player distance GVAR(interactionVehicle) >= 10}) exitWith {
        closeDialog 0;
        [_this select 1] call CBA_fnc_removePerFrameHandler;
    };

    private _loaded = GVAR(interactionVehicle) getVariable [QGVAR(loaded), []];
    private _ctrl = _display displayCtrl 100;
    private _label = _display displayCtrl 2;

    lbClear _ctrl;
    {
        private _class = if (_x isEqualType "") then {_x} else {typeOf _x};
        _ctrl lbAdd (getText(configfile >> "CfgVehicles" >> _class >> "displayName"));
        true
    } count _loaded;

    _label ctrlSetText format[localize LSTRING(labelSpace), [GVAR(interactionVehicle)] call DFUNC(getCargoSpaceLeft)];
}, 0, []] call CBA_fnc_addPerFrameHandler;
