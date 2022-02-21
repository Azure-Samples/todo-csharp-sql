import { Reducer } from "react";
import { ActionTypes, TodoActions } from "../actions/common";
import { GroupStates } from "../models"

export const changeReducer: Reducer<GroupStates, TodoActions> = (state: GroupStates, action: TodoActions): GroupStates => {
    switch (action.type) {
        case ActionTypes.CHANGE_STATES:
            state = action.payload;
            break;
    }

    return state;
}