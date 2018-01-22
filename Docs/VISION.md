# Vision

The goal of ReactiveLists  is to provide a [React](https://reactjs.org/)-like API for `UITableView` and `UICollectionView`. It is currently in use across large parts of the [PlanGrid](https://www.plangrid.com/) iOS app.

The APIs provided by ReactiveLists aim to be declarative, therefore they are significantly different from the UIKit APIs that favor providing data via the delegate pattern. From the [React](https://github.com/facebook/react) repo:

> React is a JavaScript library for building user interfaces.
>
> [...]
>
> - **Declarative:** React makes it painless to create interactive UIs. Design simple views for each state in your application, and React will efficiently update and render just the right components when your data changes. Declarative views make your code more predictable, simpler to understand, and easier to debug.

ReactiveLists provides automated diffing. This means that whenever your application data changes, you only need to map that new data to a new view model to update the UI.

Anything other than providing declarative APIs on top of existing `UITableView` and `UICollectionView` APIs is currently considered out of scope.