import { GroupStates } from "../models";
import { ApplicationState, getDefaultState } from "../models/applicationState";

export interface OperateLocalStorageActions
 {
    getCurrentLocalStoage(): GroupStates,
    setCurrentLocalStorage(groupStates: GroupStates): GroupStates
}

export const getCurrentLocalStoage = (): GroupStates =>  {
    const isLocalStorage = localStorage.getItem("groupStates");
    const defaultState: ApplicationState = getDefaultState();
    const currentState = isLocalStorage ? JSON.parse(isLocalStorage) : defaultState.groupStates;
    return currentState;
}
export const setCurrentLocalStorage = (groupStates: GroupStates): GroupStates => {
    localStorage.setItem('groupStates',JSON.stringify(groupStates));
    return getCurrentLocalStoage();
}