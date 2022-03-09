import { Dispatch } from "react";
import { ActionTypes } from "./common";
import { createPayloadAction, PayloadAction } from "./actionCreators";
import { Group,GroupStates,TodoItemState } from "../models";
import { ApplicationState, getDefaultState } from "../models/applicationState";

export interface ToggleActions {
    expandOrCollapseGroup(group:Group):GroupStates
}
// eslint-disable-next-line
export const expandOrCollapseGroup = (group:Group) => (dispatch: Dispatch<ToggleAction>) => {
    const currentRes = localStorage.getItem("groupStates");
    const cres = currentRes ? JSON.parse(currentRes) : null;
    const defaultState: ApplicationState = getDefaultState();
    const key = group.key;
    const currentState = cres || defaultState.groupStates;
    switch (key) {
        case TodoItemState.Todo:
            currentState.todo = !group.isCollapsed;
            break;
        case TodoItemState.InProgress:
            currentState.inprogress = !group.isCollapsed;
            break;
        case TodoItemState.Done:
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
    type: ActionTypes.CHANGE_GROUP_STATES
}

const toggleAction = createPayloadAction<ToggleAction>(ActionTypes.CHANGE_GROUP_STATES);