using System;
using Xunit;
using SimpleTodo.Api;

public class TodoListTests
{
	[Fact]
	public void Constructor_Initializes_Name()
	{
		// Arrange
		var name = "Test TodoList";

		// Act
		var todoList = new TodoList(name);

		// Assert
		Assert.Equal(name, todoList.Name);
	}

	[Fact]
	public void Properties_CanBeSet_AndRetrieved()
	{
		// Arrange
		var todoList = new TodoList("Initial Name");
		var id = Guid.NewGuid();
		var name = "Updated Name";
		var description = "A description";
		var updatedDate = DateTimeOffset.UtcNow.AddDays(1);

		// Act
		todoList.Id = id;
		todoList.Name = name;
		todoList.Description = description;
		todoList.UpdatedDate = updatedDate;

		// Assert
		Assert.Equal(id, todoList.Id);
		Assert.Equal(name, todoList.Name);
		Assert.Equal(description, todoList.Description);
		Assert.True((DateTimeOffset.UtcNow - todoList.CreatedDate).TotalSeconds < 1);
		Assert.Equal(updatedDate, todoList.UpdatedDate);
	}

	[Fact]
	public void CreatedDate_HasDefaultValue()
	{
		// Arrange & Act
		var todoList = new TodoList("Test TodoList");

		// Assert
		Assert.True((DateTimeOffset.UtcNow - todoList.CreatedDate).TotalSeconds < 1);
	}
}