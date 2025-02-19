CREATE TABLE [dbo].[T0040_Task_Role_Master] (
    [Role_Id]       INT           IDENTITY (1, 1) NOT NULL,
    [r_Code]        VARCHAR (50)  NULL,
    [r_Title]       VARCHAR (200) NULL,
    [r_Status]      INT           CONSTRAINT [DF_tbl_RoleMaster_r_Status] DEFAULT ((1)) NULL,
    [r_CreatedDate] SMALLDATETIME CONSTRAINT [DF_tbl_RoleMaster_r_CreatedDate] DEFAULT (getdate()) NULL,
    [r_UpdatedDate] SMALLDATETIME NULL,
    CONSTRAINT [PK_tbl_RoleMaster] PRIMARY KEY CLUSTERED ([Role_Id] ASC)
);

