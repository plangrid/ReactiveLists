# Getting Started

`ReactiveLists` provides a React-like API for `UITableView` and `UICollectionView`.  The goal is to provide a more
declarative interface on top of your normal table and collection code.  To get started with `ReactiveLists`, in addition to reading this document, we encourage you to play around with the [example app included](https://github.com/plangrid/ReactiveLists/tree/master/Example) in the repository.

#### Checking out the code

```bash
$ git clone https://github.com/plangrid/ReactiveLists.git
$ cd ReactiveLists/
$ open ReactiveLists.xcworkspace
```

## Primary Components

#### `SectionViewModel`

This is either a `CollectionSectionViewModel` or a `TableSectionViewModel`.  This type describes
the title and contents of a given section within your `UICollectionView` or `UITableView`

#### `CellViewModel`

This either `CollectionCellViewModel` protocol or `TableCellViewModel` protocol.  You create types that conform to these protocols, which are used to configure a given cell in your `UITableView` or `UICollectionView`.


#### `ViewModel`

This is either a `TableViewModel` or a `CollectionViewModel`. These are types that describe what your `UITableView` or `UICollectionView` should look like.  You initialize such a `ViewModel` with a set of `SectionModel`s, which
in turn are initialized with a set of `CellViewModel`s.  After doing this, your `ViewModel`
contains all the data required to render your `UITableView` or `UICollectionView`

#### `ViewDriver`

This is either a `TableViewDriver` or a `CollectionViewDriver`.  These types are responsible for calling all the methods to update your view when new data is available.  You initialize your `Driver` with a `UITableView` or `UICollectionView` and then
as new data becomes available, you construct a new `ViewModel` and set the `Driver`'s `tableViewModel` or `collectionViewModel` property to the new `ViewModel`.  From there the `Driver` will figure out the differences in the data and re-render your `UITableView` or `UICollectionView` automatically for you.

## Example

```swift
// Given a view controller with a table view

// 1. create cell models
let cell0 = ExampleTableCellModel(...)
let cell1 = ExampleTableCellModel(...)
let cell2 = ExampleTableCellModel(...)

// 2. create section models
let section0 = ExampleTableSectionViewModel(cellViewModels: [cell0, cell1, cell2])

// 3. create table model
let tableModel = TableViewModel(sectionModels: [section0])

// 4. create driver
self.driver = TableViewDriver(tableView: self.tableView, tableViewModel: tableModel)

// 5. update driver with new table model as it changes
let updatedTableModel = self.doSomethingToChangeModels()
self.driver.tableViewModel = updatedTableModel

// self.tableView will update automatically
```


## Detailed Example

The following is a more detailed example, to see how this is all integrated into your
code.  To get set up, you first need to add a `Driver` (either a `TableViewDriver`
or `CollectionViewDriver`) to your view controller:

```swift
struct Person {
  let name: String
  let uuid = UUID()
}

final class PersonViewController: UITableViewController {
    var people: [Person]
    var tableViewDriver: TableViewDriver?
                  .
                  .
                  .
    override func viewDidLoad() {
        super.viewDidLoad()
        // Initialize our `TableViewDriver` with our tableView
        self.tableViewDriver = TableViewDriver(tableView: self.tableView)
        self.people = [Person(name: "Tom")]
    }
}
```

`tableViewDriver` will be responsible for updating your view when new data is available.

Next, you'll need to bind your new data to the `Driver` as it comes in.

```swift
let newTableViewModel: TableViewModel = ...
self.tableViewDriver?.tableViewModel = newTableViewModel
```

Great!  But how do you make that `TableViewModel`?  We recommend having a static function that
takes in new data and generates the `TableViewModel`.  It might look something like this:

```swift
/// Given a new set of [Person], generates the `TableViewModel` representing that new data
static func viewModel(forState people: [Person]) -> TableViewModel { ... }

```

Then any time your data (in this case the `people` property) changes, you can generate your new `TableViewModel`

```swift
var people: [Person] = [] {
    didSet {
        self.tableViewDriver?.tableViewModel = PersonViewController.viewModel(
            forState: people
        )
    }
}

```

Okay now lets go back and fill in our `viewModel(forState:)` function:

```swift
/// Given a new set of [Person], generates the `TableViewModel` representing that new data
extension PersonViewController {
    static func viewModel(forState people: [Person]) -> TableViewModel {
            let personCellViewModels = people.map { PersonCellModel(person: $0) }
            let section = TableSectionViewModel(
              headerTitle: "People",
              headerHeight: 44,
              cellViewModels: personCellViewModels,
              diffingKey: "People" // a unique string for automatically diffing
            )
        return TableViewModel(sectionModels: [section])
    }
}

```

This is now called whenever we get an update to our `people` variable.  This function takes the latest
`people` data and for each person generates a `PersonCellModel` to display in our table view.  It wraps
all those models into a single section and then creates a `TableViewModel` from that section.

Now all we have to do is to define `PersonCellModel`:

```swift

final class PersonCell: UITableViewCell { }

struct PersonCellModel: TableCellViewModel, DiffableViewModel {
    var registrationInfo = ViewRegistrationInfo(classType: PersonCell.self)
    var accessibilityFormat: CellAccessibilityFormat = "PersonUserCell"
    let cellIdentifier = "PersonUserCell"
    let editingStyle: UITableViewCellEditingStyle = .delete
    let person: Person

    init(person: Person) {
        self.person = person
    }

    func applyViewModelToCell(_ cell: UITableViewCell) {
        cell.textLabel?.text = "\(self.person.name)"
    }

    // If we want the library to automatically reload when new data is available
    // each cell model needs to have a unique key for the diffing algorithm to work.
    // In this case we just use the person's uuid
    var diffingKey: String {
        return self.person.uuid.uuidString
    }
}
```

A `CellViewModel` just needs to conform to `TableViewCellViewModel` or `CollectionViewCellViewModel`.  The
most important function is `applyViewModelToCell`.  This is where you define how your view model will get
mapped onto a `UITableViewCell` or `UICollectionViewCell`.  In this case we are just setting the `textLabel`'s
`text` property to the person's `name`.

And there you have it!  You now have an automatically refreshing table view which you have defined in a clear,
declarative manner.
