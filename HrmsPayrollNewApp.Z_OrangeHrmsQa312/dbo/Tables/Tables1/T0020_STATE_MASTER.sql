CREATE TABLE [dbo].[T0020_STATE_MASTER] (
    [State_ID]                  NUMERIC (18)  NOT NULL,
    [Cmp_ID]                    NUMERIC (18)  NOT NULL,
    [State_Name]                VARCHAR (100) NOT NULL,
    [Loc_ID]                    NUMERIC (18)  NULL,
    [PT_Deduction_Type]         VARCHAR (100) CONSTRAINT [DF__T0020_STA__PT_De__48006DE0] DEFAULT ('Monthly') NULL,
    [PT_Deduction_Month]        VARCHAR (100) NULL,
    [PT_Enroll_Cert_NO]         VARCHAR (50)  NULL,
    [Applicable_PT_Male_Female] TINYINT       CONSTRAINT [DF_T0020_STATE_MASTER_Applicable_PT_Male_Female] DEFAULT ((0)) NOT NULL,
    [Esic_State_Code]           VARCHAR (100) NULL,
    [Esic_Reg_Addr]             VARCHAR (MAX) NULL,
    CONSTRAINT [PK_T0020_STATE_MASTER] PRIMARY KEY CLUSTERED ([State_ID] ASC) WITH (FILLFACTOR = 80)
);

