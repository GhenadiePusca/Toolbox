//
//  PropertyGetter.swift
//  ToolBox
//
//  Created by Pusca, Ghenadie on 25/03/2019.
//

func getProperty<E, T>(instance: E, property: (E) -> T) -> T {
    return property(instance)
}
