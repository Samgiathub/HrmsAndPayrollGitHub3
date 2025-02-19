


CREATE VIEW [dbo].[V0200_Question_Exit_Analysis_Master]
AS
SELECT     Q.Cmp_ID, Q.Quest_ID, Q.Question, 
                      CASE WHEN Question_Type = 1 THEN 'Title' ELSE CASE WHEN Question_Type = 2 THEN 'Text' ELSE CASE WHEN Question_Type = 3 THEN 'Group Title' ELSE CASE WHEN
                       Question_Type = 4 THEN 'RadioButtonList' ELSE CASE WHEN Question_Type = 5 THEN 'CheckBoxList' ELSE CASE WHEN Question_Type = 6 THEN 'DropDownList' ELSE
                       '''' END END END END END END AS Question_Type, Q.Question_Options, Q.strDesig_ID, Q.Sorting_No, Q.AutoAssign, G.Group_Name
FROM         dbo.T0200_Question_Exit_Analysis_Master AS Q WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.T0040_Exit_Group_Master AS G WITH (NOLOCK)  ON Q.Group_Id = G.Group_Id


