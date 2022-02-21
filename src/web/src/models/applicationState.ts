import { Dispatch } from "react";
import { TodoActions } from "../actions/common";
import { GroupStates } from "./groupStates";
import { TodoItem } from "./todoItem";
import { TodoList } from "./todoList";

export interface AppContext {
    state: ApplicationState
    dispatch: Dispatch<TodoActions>
}

export interface ApplicationState {
    lists?: TodoList[]
    selectedList?: TodoList
    selectedItem?: TodoItem
    groupStates:GroupStates
}

export const getDefaultState = (): ApplicationState => {
    return {
        lists: undefined,
        selectedList: undefined,
        selectedItem: undefined,
        groupStates:{
            todo:false,
            inprogress:false,
            done:true
        }
    }
}

