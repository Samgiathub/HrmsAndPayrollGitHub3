CREATE TABLE [dbo].[T0100_Task_Assign] (
    [Task_Id]            INT            IDENTITY (1, 1) NOT NULL,
    [Task_ParentId]      INT            NULL,
    [Status_Id]          INT            NULL,
    [Priority_Id]        INT            NULL,
    [Project_Id]         INT            NULL,
    [Task_Type_Id]       INT            NULL,
    [Task_Cat_Id]        INT            NULL,
    [Created_Emp_Id]     INT            NULL,
    [Assigned_Emp_Id]    INT            NULL,
    [Task_Title]         VARCHAR (5000) NULL,
    [Task_Description]   VARCHAR (MAX)  NULL,
    [Task_DueDate]       SMALLDATETIME  NULL,
    [Task_TargetDate]    SMALLDATETIME  NULL,
    [Task_EstimatedTime] VARCHAR (50)   NULL,
    [Task_CreatedDate]   SMALLDATETIME  CONSTRAINT [DF_T0100_Task_Assign_Task_CreatedDate] DEFAULT (getdate()) NULL,
    [Task_Attachment]    VARCHAR (300)  NULL,
    [Task_IsMulti]       INT            NULL,
    CONSTRAINT [PK_T0100_Task_Assign] PRIMARY KEY CLUSTERED ([Task_Id] ASC)
);

