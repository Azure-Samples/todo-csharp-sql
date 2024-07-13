using System;
using Xunit;
using SimpleTodo.Api;

public class TodoItemTests
{
	[Fact]
	public void Constructor_Initializes_RequiredProperties()
	{
		// Arrange
		var listId = Guid.NewGuid();
		var name = "Test Todo";

		// Act
		var todoItem = new TodoItem(listId, name);

		// Assert
		Assert.Equal(listId, todoItem.ListId);
		Assert.Equal(name, todoItem.Name);
		Assert.Equal("todo", todoItem.State);
		Assert.True((DateTimeOffset.UtcNow - todoItem.CreatedDate.Value).TotalSeconds < 1);
	}

	[Fact]
	public void Properties_CanBeSet_AndRetrieved()
	{
		// Arrange
		var todoItem = new TodoItem(Guid.NewGuid(), "Test Todo");
		var id = Guid.NewGuid();
		var description = "Test Description";
		var dueDate = DateTimeOffset.UtcNow.AddDays(1);
		var completedDate = DateTimeOffset.UtcNow.AddDays(2);
		var updatedDate = DateTimeOffset.UtcNow.AddDays(3);

		// Act
		todoItem.Id = id;
		todoItem.Description = description;
		todoItem.DueDate = dueDate;
		todoItem.CompletedDate = completedDate;
		todoItem.UpdatedDate = updatedDate;

		// Assert
		Assert.Equal(id, todoItem.Id);
		Assert.Equal(description, todoItem.Description);
		Assert.Equal(dueDate, todoItem.DueDate);
		Assert.Equal(completedDate, todoItem.CompletedDate);
		Assert.Equal(updatedDate, todoItem.UpdatedDate);
	}
}