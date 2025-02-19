CREATE TABLE [dbo].[T0040_Mood_Activity_Master] (
    [Mood_Activity_Id]     INT           IDENTITY (1, 1) NOT NULL,
    [Activity]             VARCHAR (100) NULL,
    [System_Date]          DATETIME      NULL,
    [Selected_ImageName]   VARCHAR (50)  NULL,
    [Unselected_ImageName] VARCHAR (50)  NULL
);

