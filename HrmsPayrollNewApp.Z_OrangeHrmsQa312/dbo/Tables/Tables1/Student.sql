CREATE TABLE [dbo].[Student] (
    [IId]   INT            NOT NULL,
    [Name]  NVARCHAR (MAX) NOT NULL,
    [Age]   INT            NOT NULL,
    [Class] INT            NOT NULL,
    PRIMARY KEY CLUSTERED ([IId] ASC) WITH (FILLFACTOR = 95)
);


GO
Create Trigger My_Trigger On Student 
  
AFTER Insert  
AS  
Declare @IId int ;  
Declare @Name Nvarchar(50) ;  
Declare @Age Int;  
Declare @Class int;  
  
Select @IId= Tab.IId From inserted Tab;  
Select @Name= Tab.Name From inserted Tab;  
Select @Age= Tab.Age From inserted Tab;  
Select @Class= Tab.Class From inserted Tab;  
  
Set @IId=@IId+1;  
Insert Into Student(IId,Name , Age ,Class) Values (@IId,@Name,@Age,@Class)  
Print 'Inserted Successfully'