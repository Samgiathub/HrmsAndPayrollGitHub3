CREATE TABLE [dbo].[T0040_Clearance_Attribute] (
    [Clearance_id]   NUMERIC (18)  CONSTRAINT [DF_T0030_Clearance_Attribute_Clearance_id] DEFAULT ((0)) NOT NULL,
    [Cmp_id]         NUMERIC (18)  CONSTRAINT [DF_T0030_Clearance_Attribute_Cmp_id] DEFAULT ((0)) NOT NULL,
    [Dept_id]        NUMERIC (18)  CONSTRAINT [DF_T0030_Clearance_Attribute_Dept_id] DEFAULT ((0)) NULL,
    [Item_code]      VARCHAR (50)  NULL,
    [Item_name]      VARCHAR (500) NOT NULL,
    [Active]         TINYINT       CONSTRAINT [DF_T0030_Clearance_Attribute_Active] DEFAULT ((0)) NOT NULL,
    [Cost_Center_ID] VARCHAR (MAX) NULL,
    CONSTRAINT [PK_T0040_Clearance_Attribute] PRIMARY KEY CLUSTERED ([Clearance_id] ASC)
);

