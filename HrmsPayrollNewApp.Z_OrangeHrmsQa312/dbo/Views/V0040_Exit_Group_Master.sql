


CREATE VIEW [dbo].[V0040_Exit_Group_Master]
AS
SELECT DISTINCT G.Group_Id, G.Group_Name,G.Cmp_Id,G.Is_Active,EI.Is_Active As Q_Active,EI.emp_id
FROM         dbo.T0040_Exit_Group_Master AS G WITH (NOLOCK) INNER JOIN
             dbo.T0200_Question_Exit_Analysis_Master AS QE WITH (NOLOCK)  ON G.Group_Id = QE.Group_Id INNER JOIN 
             T0200_EXIT_INTERVIEW EI WITH (NOLOCK)  ON EI.Question_Id = QE.Quest_ID INNER JOIN
             T0080_EMP_MASTER E  WITH (NOLOCK) on E.Emp_ID = EI.emp_id
WHERE     (G.Is_Active = 1)



