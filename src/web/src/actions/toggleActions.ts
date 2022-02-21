import { Dispatch } from "react";
import { ActionTypes } from "./common";
import { createPayloadAction, PayloadAction } from "./actionCreators";
import { GroupStates } from "../models";
import { ApplicationState, getDefaultState } from "../models/applicationState";

export interface ToggleActions {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    change(group:any):GroupStates
}
// eslint-disable-next-line
export const change = (group:any) => (dispatch: Dispatch<ToggleAction>) => {
    const currentRes = localStorage.getItem("groupStates")
    const cres = currentRes?JSON.parse(currentRes):null;
    const defaultState: ApplicationState = getDefaultState();
    const key = group.key;
    const currentState = cres||defaultState.groupStates;
    switch (key) {
        case 'todo':
            currentState.todo = !group.isCollapsed;
            break;
        case 'inprogress':
            currentState.inprogress = !group.isCollapsed;
            break;
        case 'done':
            currentState.done = !group.isCollapsed;
            break;
        default:
            break;
      }
    localStorage.setItem('groupStates',JSON.stringify(currentState))
    dispatch(toggleAction(currentState));

    return currentState;
}

export interface ToggleAction extends PayloadAction<string, GroupStates> {
    type: ActionTypes.CHANGE_STATES
}

const toggleAction = createPayloadAction<ToggleAction>(ActionTypes.CHANGE_STATES);