# Getting Started

ReactiveLists provides a React-like API for `UITableView` and `UICollectionView`.  This goal is to provide a more
declarative interface on top of your normal list and collection code.  To get started with ReactiveLists, we encourage you to play around with the examples included in the repository, but here we will also discuss the main components of the library.

To get set up, you first need to add a `Driver` (either a `TableViewDriver` or `CollectionViewDriver`) to your view controller.

```swift

struct Person {
  name: String
  uuid = UUID()
}

final class PersonViewController: UITableViewController {
    var people: [Person]
    var tableViewDriver: TableViewDriver?
```

This `Driver` will be responsible for updating your view when new data is available.

Next, you'll need to bind your new data to the `Driver` as it comes in.

```swift
let newTableViewModel: TableViewModel = ...
self.tableViewDriver?.tableViewModel = newTableViewModel
```

Great!  But how do you make that `TableViewModel`?  We recommend having a static function that
takes in new data and generates the `TableViewModel`.  It might look something like this:

```swift
static func viewModel(forState people: [Person]) -> TableViewModel { }

```

Then any time your data (in this case the `people` property), you can generate your new `TableViewModel`

```swift
var people: [Person] = [] {
    didSet {
        self.tableViewDriver?.tableViewModel = PersonViewController.viewModel(
            forState: people
        )
    }
}

```

Okay now lets go back and fill in our `viewModel()` function:

```swift
let sections: [TableViewSectionViewModel] = people.map { person in
    let personCellViewModels = people.tools.map { PersonCellModel(tool: $0) }
    return TableViewSectionViewModel(
        headerTitle: "People",
        headerHeight: 44,
        cellViewModels: personCellViewModels,
        diffingKey: "People" // a unique string for automatically diffing
    )
}
return TableViewModel(sectionModels: sections)
```

This is now called whenever we get an updated to our `people` variable.  This function takes the Latest
`people` data and for each person generates a `PersonCellModel` to display in our table view.  It wraps
all those models into a single section and then creates a `TableViewModel` from that section.

Now all we have to do is to define `PersonCellModel`:

```swift
struct PersonCellModel: TableViewCellViewModel, DiffableViewModel {
    var accessibilityFormat: CellAccessibilityFormat = "PersonUserCell"
    let cellIdentifier = "PersonUserCell"
    let commitEditingStyle: CommitEditingStyleClosure?
    let editingStyle: UITableViewCellEditingStyle = .delete
    let person: Person

    init(person: Person) {
        self.person = person
    }

    func applyViewModelToCell(_ cell: UITableViewCell) {
        cell.textLabel?.text = "\(self.person.name)""
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

And there you have it!  You now have an automatically refreshing table view which you defined in a clear
declarative manner.


### Glossary of types



#### `*SectionViewModel`

This is either a `CollectionViewSectionViewModel` or a `TableViewSectionViewModel`.  This type describes
the title and contents of a given section within your `UICollectionView` or `UITableView`

#### `*CellViewModel`

This is type you make that conforms to either `CollectionViewCellViewModel` or `TableViewCellViewModel`.  This is the type that describes the data that is used to configure a given cell in your `UITableView` or `UICollectionView`.


#### `*ViewModel`

This is either a `TableViewModel` or a `CollectionViewModel`. These are types that describe what your `UITableView` or `UICollectionView` should look like.  You initialize such a `ViewModel` with a set of `SectionModel`s, which
in turn are initialized with a set of `CellViewModel`s.  After doing this, your `ViewModel`
contains all the data required to render your `UITableView` or `UICollectionView`

#### `*ViewDriver`

This is either a `TableViewDriver` or a `CollectionViewDriver`.  These types are responsible for calling all the methods to update your view when new data is available.  You initialize your `Driver` with a `UITableView` or `UICollectionView` and then
as new data becomes available, you construct a new `ViewModel` and set the `Driver`'s `tableViewModel` or `collectionViewModel` property to the new `ViewModel`  From there the `Driver` will figure out the differences in the data and re-render your `UITableView` or `UICollectionView` automatically for you.
