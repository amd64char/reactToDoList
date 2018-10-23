


/****** Object: Table [dbo].[ToDoList] ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ToDoList] (
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NULL,
	[Completed] [bit] NOT NULL DEFAULT 0,
	[DateCreated] [datetime] NOT NULL DEFAULT GETDATE(),
	[DateModified] [datetime] NULL
 CONSTRAINT [PK_ToDoList] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)
) ON [PRIMARY]
GO




/****** Object: StoredProcedure [dbo].[GetToDoListItems] ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
/*
	Exec [dbo].[GetToDoListItems]
*/
CREATE PROCEDURE [dbo].[GetToDoListItems]

AS
BEGIN
	
	--Return all Todo items based on session id
	Select
		[ID] 
		, [Name]
		, [Completed]
	From [dbo].[ToDoList]
	--FOR JSON PATH, ROOT('TodoItems')

END
GO


/****** Object: Table Based Type [dbo].[TodoListItems] ******/
CREATE TYPE [dbo].[TodoListItems] AS TABLE (
	[ID] [int] NOT NULL, 
	[Name] [nvarchar](255) NULL,
	[Completed] [bit] NOT NULL DEFAULT 0
);  
GO  


/****** Object:  StoredProcedure [dbo].[GetToDoListItems] ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
/*
	Declare @TVPTodoItems AS [dbo].[TodoListItems]

	Insert Into @TVPTodoItems (Name, Completed, ID)
		Select [Name], [Completed], [ID] From (
			values('Go grocery shopping', 0, 1)
				, ('Wash the car', 0, 2)
				, ('Pay all the bills', 1, 3)
				, ('Sell the house', 1, 4)
			 ) as list ([Name], [Completed], [ID])

	--select * From @TVPTodoItems

	Exec [dbo].[SaveToDoListItems] @TVPTodoItems

	select * from [dbo].[ToDoList]

*/
ALTER PROCEDURE [dbo].[SaveToDoListItems]
	@TVPTodoItems TodoListItems READONLY
AS
BEGIN
	
	MERGE [dbo].[ToDoList] AS Target
	USING (
		Select [Name], [Completed], [ID] From @TVPTodoItems 
	) AS Source ON Target.[ID] = Source.[ID]
	WHEN MATCHED AND (Target.[Name] <> Source.[Name] OR Target.[Completed] <> Source.[Completed]) THEN
		UPDATE SET
			Target.[Name] = Source.[Name]
			, Target.[Completed] = Source.[Completed]
			, Target.[DateModified] = GETDATE()
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (
			[Name], [Completed], [DateCreated]
		) VALUES (
			Source.[Name], Source.[Completed], GETDATE()
		)
	WHEN NOT MATCHED BY SOURCE THEN DELETE;

END

GO




