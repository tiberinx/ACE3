// by commy2
#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

GVAR(syncedEvents) = [] call CBA_fnc_hashCreate;
GVAR(showHudHash) = [] call CBA_fnc_hashCreate;

GVAR(settingsInitFinished) = false;
GVAR(runAtSettingsInitialized) = [];

// @todo: Generic local-managed global-synced objects (createVehicleLocal)

//Debug
ACE_COUNTERS = [];

// Load settings on the server and broadcast them
if (isServer) then {
    call FUNC(loadSettingsOnServer);
};

GVAR(statusEffect_Names) = [];
GVAR(statusEffect_isGlobal) = [];

GVAR(setHearingCapabilityMap) = [];

//////////////////////////////////////////////////
// Set up PlayerChanged eventhandler for pre init (EH is installed in postInit)
//////////////////////////////////////////////////

ACE_player = objNull;
uiNamespace setVariable ["ACE_player", objNull];

// Init toHex
[0] call FUNC(toHex);

isHC = !hasInterface && !isDedicated; // deprecated because no tag
missionNamespace setVariable ["ACE_isHC", ACE_isHC];
uiNamespace setVariable ["ACE_isHC", ACE_isHC];

if (hasInterface) then {
    [
    missionnamespace,
    "arsenalOpened",
    {
        INFO("arsenalOpened EH");

        params ["_display","_toggleSpace"];

        diag_log text format ["A bis_fnc_arsenal_data: %1", count bis_fnc_arsenal_data];
        diag_log text format ["A bis_fnc_arsenal_data[24]: %1", bis_fnc_arsenal_data select 24];

        
        if ("ACE_Banana" in (bis_fnc_arsenal_data select 24)) exitWith {};
        
        _fullVersion = missionnamespace getvariable ["BIS_fnc_arsenal_fullArsenal",false];
        _center = (missionnamespace getvariable ["BIS_fnc_arsenal_center",player]);
        _cargo = (missionnamespace getvariable ["BIS_fnc_arsenal_cargo",objnull]);
        _virtualItemCargo =
        (missionnamespace call bis_fnc_getVirtualItemCargo) +
        (_cargo call bis_fnc_getVirtualItemCargo) +
        items _center +
        assigneditems _center +
        primaryweaponitems _center +
        secondaryweaponitems _center +
        handgunitems _center +
        [uniform _center,vest _center,headgear _center,goggles _center];


#define IDC_RSCDISPLAYARSENAL_LIST			960
#define IDC_RSCDISPLAYARSENAL_TAB_CARGOMISC		24
#define IDC_RSCDISPLAYARSENAL_SORT			800

        _ctrlList = _display displayctrl (IDC_RSCDISPLAYARSENAL_LIST + IDC_RSCDISPLAYARSENAL_TAB_CARGOMISC);


        _virtualCargo = _virtualItemCargo;
        _virtualAll = _fullVersion || {"%ALL" in _virtualCargo};
        _columns = count lnbGetColumnsPosition _ctrlList;
        {
            if (_virtualAll || {_x in _virtualCargo}) then {
                _xCfg = configfile >> "cfgweapons" >> _x;
                _lbAdd = _ctrlList lnbaddrow ["",gettext (_xCfg >> "displayName"),str 0];
                _ctrlList lnbsetdata [[_lbAdd,0],_x];
                _ctrlList lnbsetpicture [[_lbAdd,0],gettext (_xCfg >> "picture")];
                _ctrlList lnbsetvalue [[_lbAdd,0],getnumber (_xCfg >> "itemInfo" >> "mass")];
                _ctrlList lbsettooltip [_lbAdd * _columns,format ["%1\n%2",gettext (_xCfg >> "displayName"),_x]];
            };

            diag_log text format ["Adding the thing %1", _x];

            (bis_fnc_arsenal_data select IDC_RSCDISPLAYARSENAL_TAB_CARGOMISC) pushBack _x;

        } foreach ["ACE_Banana", "ACE_fieldDressing"];

        _ctrlSort = _display displayctrl (IDC_RSCDISPLAYARSENAL_SORT + IDC_RSCDISPLAYARSENAL_TAB_CARGOMISC);
        _sortValues = uinamespace getvariable ["bis_fnc_arsenal_sort",[]];
        ["lbSort",[[_ctrlSort,_sortValues param [IDC_RSCDISPLAYARSENAL_TAB_CARGOMISC,0]],IDC_RSCDISPLAYARSENAL_TAB_CARGOMISC]] call bis_fnc_arsenal;
    }
    ] call bis_fnc_addscriptedeventhandler;
};

ADDON = true;
