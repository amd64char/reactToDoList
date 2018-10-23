
// TodoList

var todoItems = [];

// Todo App    
class TodoApp extends React.Component {
    constructor (props) {
      super(props);
        this.state = {
            //todoItems: todoItems,
            //todoCount: this.activeCount(todoItems),
            todoItems: [],
            todoCount: 0,
            submissionStatus: '',
            error: '',
            isLoading: false
        };
        this.addItem = this.addItem.bind(this);
        this.removeItem = this.removeItem.bind(this);
        this.markItemDone = this.markItemDone.bind(this);
        this.activeCount = this.activeCount.bind(this);
    }

    componentDidMount() {
        //obtain our todo list from web api
        fetch('http://bigvoltage.com/handlers/GetTodos.ashx').then(response => {
            if (response.ok) {
                return response.json();
            } else {
                this.setState({ 
                    submissionStatus: 'Could not obtain todo list.' 
                });
            }
            }).then(data => {
                console.log('todos', data);
                this.setState({  
                    todoItems: data,
                    todoCount: this.activeCount(data),
                    submissionStatus: 'OK',
                    isLoading: false
                })
            }).catch(error => this.setState({ 
                error, isLoading: false 
            }));
    }

    activeCount(todoItems) {
        var active = 0;
        //iterate over each todo in the array
        for (var i = 0; i < todoItems.length; i++) {
            //look for only active entries
            if (todoItems[i].done == false) {
                active++;
            }
        }
        return active;
    }

    addItem(todoItem) {
        //obtain items from state
        var todoItems = this.state.todoItems;

        //add new item to 1st index array
        todoItems.unshift({
            index: todoItems.length + 1, 
            value: todoItem.newItemValue, 
            done: false
        });

        //TODO: Send data to our todo web api

        //update state
        this.setState({
            todoItems: todoItems,
            todoCount: this.activeCount(todoItems)
        });

    }

    removeItem(itemIndex) {
        //obtain items from state
        var todoItems = this.state.todoItems;

        //remove item in array
        todoItems.splice(itemIndex, 1);

        //TODO: Send data to our todo web api

        //update state
        this.setState({
            todoItems: todoItems,
            todoCount: this.activeCount(todoItems)
        });
    }

    markItemDone(itemIndex) {
        //obtain items from state
        var todoItems = this.state.todoItems;

        //obtain item in array
        var todo = todoItems[itemIndex];
        //console.log(todo, 'todo item');
        
        //update done field
        todo.done = !todo.done;
        //console.log(todoItems, 'todoItems');
        
        //TODO: Send data to our todo web api

        //update state
        this.setState({
            todoItems: todoItems,
            todoCount: this.activeCount(todoItems)
        });  
    }

    //render app
    render() {
        return (
          <div id="main">
            <h1>My TODO List - {this.state.todoCount} Items</h1>
            <TodoList items={this.state.todoItems} removeItem={this.removeItem} markItemDone={this.markItemDone} />
            <TodoForm addItem={this.addItem} />
          </div>
      );
    }
}


// Display Todo List
class TodoList extends React.Component {
   
    render() {
        //map the items within the array to a todo list item
        var items = this.props.items.map((item, index) => {
            return (
              <TodoListItem key={index} item={item} index={index} removeItem={this.props.removeItem} markItemDone={this.props.markItemDone} />
            );
        });
        
        //display
        return (
            <ul className="list-group">{items}</ul>
        );
    }
}
 
// Individual Todo Item
class TodoListItem extends React.Component {
    constructor(props) {
        super(props);
        this.onClickRemove = this.onClickRemove.bind(this);
        this.onClickDone = this.onClickDone.bind(this);
    }
    
    onClickRemove() {
        var index = parseInt(this.props.index);
        this.props.removeItem(index);
    }
    
    onClickDone() {
        var index = parseInt(this.props.index);
        this.props.markItemDone(index);
    }

    render() {
        //determine item status
        var todoClass = this.props.item.done ? "done" : "undone";
        var todoClassRow = this.props.item.done ? "completed" : "active";
        return(
            <li title={todoClassRow} className="list-group-item">
                <div className={todoClass}>
                    <span className="glyphicon glyphicon-ok icon" onClick={this.onClickDone}></span>
                    {this.props.item.value}
                    <span className="glyphicon glyphicon-trash close" onClick={this.onClickRemove}></span>
                </div>
            </li>     
        );
    }
}

class TodoForm extends React.Component {
    constructor(props) {
      super(props);
      this.onSubmit = this.onSubmit.bind(this);
      this.showFilter = this.showFilter.bind(this);
    }

    componentDidMount() {
        this.refs.itemName.focus();
    }

    onSubmit(event) {
        event.preventDefault();

        var newItemValue = this.refs.itemName.value;
        //console.log(newItemValue, 'new item');

        if(newItemValue) {
            this.props.addItem({
                newItemValue
            });
            this.refs.form.reset();
        }
    }

    showFilter(event) {
        event.preventDefault();
        
        //reset active filter
        var filters = document.querySelectorAll('.filters .filter');
        //console.log(filters, 'filters');
        for (var filter of filters) {
          filter.className = 'filter';
        }
        
        //set active filter
        var clickedId = event.target.id; 
        event.target.className = 'active-filter filter';

        //show only selections
        var todoItems = document.querySelectorAll('.list-group-item');
        //console.log(todoItems, 'todoItems');
        for (var item of todoItems) {
            //console.log(item.title, 'item title');
            if(clickedId == 'all') { 
                item.style.display = 'inherit'; 
            } else {
                if(clickedId == item.title) {
                    item.style.display = 'inherit';
                } else {
                    item.style.display = 'none';
                }
            }
        }
    }

    render() {
        return (
          <form ref="form" onSubmit={this.onSubmit} className="form-inline">
            <input type="text" ref="itemName" className="form-control" placeholder="add a new todo item..."/>
            <button type="submit" className="btn btn-default">Add</button>
            <div className="text-center filters">
                <span id="all" className="active-filter filter" onClick={this.showFilter}>Show All</span>
                <span id="active" className="filter" onClick={this.showFilter}>Show Active</span>
                <span id="completed" className="filter" onClick={this.showFilter}>Show Completed</span>
            </div>
          </form>
        );   
    }
}

ReactDOM.render(
    <TodoApp initItems={todoItems}/>, 
    document.getElementById('todoListApp')
);