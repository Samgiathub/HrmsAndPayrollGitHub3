CREATE TABLE [dbo].[T0040_Tasks_Type_Master] (
    [Task_Type_Id]    INT           IDENTITY (1, 1) NOT NULL,
    [ttm_Code]        VARCHAR (50)  NULL,
    [ttm_Title]       VARCHAR (200) NULL,
    [ttm_Status]      INT           CONSTRAINT [DF_tbl_TaskTypeMaster_ttm_Status] DEFAULT ((1)) NULL,
    [ttm_CreatedDate] SMALLDATETIME CONSTRAINT [DF_tbl_TaskTypeMaster_ttm_CreatedDate] DEFAULT (getdate()) NULL,
    [ttm_UpdatedDate] SMALLDATETIME NULL,
    CONSTRAINT [PK_tbl_TaskTypeMaster] PRIMARY KEY CLUSTERED ([Task_Type_Id] ASC)
);

