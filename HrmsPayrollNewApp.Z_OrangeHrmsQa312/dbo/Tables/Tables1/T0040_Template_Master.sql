CREATE TABLE [dbo].[T0040_Template_Master] (
    [T_ID]                 INT            NOT NULL,
    [Cmp_ID]               INT            NOT NULL,
    [Template_Title]       NVARCHAR (100) NULL,
    [Template_Instruction] NVARCHAR (500) NULL,
    [Branch_ID]            NUMERIC (18)   NULL,
    [EmpId]                VARCHAR (MAX)  NULL,
    [CreatedBy]            INT            NULL,
    [CreatedDate]          DATETIME       NULL,
    [UpdateBy]             INT            NULL,
    [UpdateDate]           DATETIME       NULL,
    [Is_Active]            INT            NULL,
    [Desig_ID]             VARCHAR (MAX)  NULL,
    CONSTRAINT [PK_T0040_Template_Master] PRIMARY KEY CLUSTERED ([T_ID] ASC) WITH (FILLFACTOR = 80)
);

