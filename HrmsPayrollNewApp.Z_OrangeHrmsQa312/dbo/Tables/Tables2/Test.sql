CREATE TABLE [dbo].[Test] (
    [ID]         INT            IDENTITY (1, 1) NOT NULL,
    [First_Name] NVARCHAR (100) NULL,
    [Last_Name]  NVARCHAR (100) NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_Test_First_Name]
    ON [dbo].[Test]([First_Name] ASC) WITH (FILLFACTOR = 80);

