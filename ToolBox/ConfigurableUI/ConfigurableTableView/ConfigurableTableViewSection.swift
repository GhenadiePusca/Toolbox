//
//  ConfigurableTableViewSection.swift
//  ToolBox
//
//  Created by Pusca, Ghenadie on 25/03/2019.
//

/// The Configurable Table View Section
final class ConfigurableTableViewSection {

    /// The table view header configurator
    var headerViewConfigurator: ConfigurableHeaderFooterViewType?

    /// The table footer view configurator
    var footerViewConfigurator: ConfigurableHeaderFooterViewType?

    /// The header title of the section
    var headerTitle: String?

    /// The footer title of the section
    var footerTitle: String?

    /// The rows in the section
    var rows: [ConfigurableTableViewRowType] = []
}

