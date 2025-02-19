CREATE TABLE [dbo].[T0053_HRMS_Recruitment_Form] (
    [Rec_form_id] NUMERIC (18)  NOT NULL,
    [cmp_id]      NUMERIC (18)  NOT NULL,
    [Rec_Post_Id] NUMERIC (18)  NOT NULL,
    [form_id]     NUMERIC (18)  NULL,
    [Form_name]   VARCHAR (150) NULL,
    [status]      INT           NULL,
    CONSTRAINT [PK_T0053_HRMS_Recruitment_Form] PRIMARY KEY CLUSTERED ([Rec_form_id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0053_HRMS_Recruitment_Form_T0010_COMPANY_MASTER] FOREIGN KEY ([cmp_id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0053_HRMS_Recruitment_Form_T0052_HRMS_Posted_Recruitment] FOREIGN KEY ([Rec_Post_Id]) REFERENCES [dbo].[T0052_HRMS_Posted_Recruitment] ([Rec_Post_Id])
);

