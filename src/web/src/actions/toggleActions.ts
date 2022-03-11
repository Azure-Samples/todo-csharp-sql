import { Dispatch } from "react";
import { ActionTypes } from "./common";
import { createPayloadAction, PayloadAction } from "./actionCreators";
import { GroupStates,TodoItemState } from "../models";
import { getCurrentLocalStoage, setCurrentLocalStorage } from "./operateLocalStorageAction";
import { IGroup } from "@fluentui/react";

export interface ToggleActions {
    expandOrCollapseGroup(group: IGroup): GroupStates
}
// eslint-disable-next-line
export const expandOrCollapseGroup = (group: IGroup) => (dispatch: Dispatch<ToggleAction>) => {
    const key = group.key;
    const currentState = getCurrentLocalStoage();
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

    setCurrentLocalStorage(currentState);

    dispatch(toggleAction(currentState));

    return currentState;
}

export interface ToggleAction extends PayloadAction<string, GroupStates> {
    type: ActionTypes.CHANGE_GROUP_STATES
}

const toggleAction = createPayloadAction<ToggleAction>(ActionTypes.CHANGE_GROUP_STATES);