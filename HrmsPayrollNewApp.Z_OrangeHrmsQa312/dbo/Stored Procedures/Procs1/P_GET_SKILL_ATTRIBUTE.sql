

-- =============================================
-- Author:		Mukti Chauhan
-- Create date: 14-11-2018
-- Description:	to get skill/attribute details for Probation
---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P_GET_SKILL_ATTRIBUTE]
	 @Cmp_ID int,
     @flag  varchar(5),    
     @Type varchar(15),
     @Emp_ID int,
     @Tran_ID int,
     @Desig_ID int,
     @Dept_ID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	IF @Type='Skill'
		BEGIN
			IF @flag = 'Add' 
				BEGIN
					SELECT DISTINCT SM.Skill_Name,SM.[Description],SM.Skill_ID,SW.Weightage,0 AS Wages_Value 
						   FROM T0100_EMP_Skill_Attr_Assign ES WITH (NOLOCK)
					INNER JOIN (SELECT MAX(Tran_ID) AS Tran_ID,T0100_EMP_Skill_Attr_Assign.Desig_Id 
								FROM T0100_EMP_Skill_Attr_Assign WITH (NOLOCK)
									Inner Join(SELECT MAX(Effect_Date) AS Effect_Date , Desig_Id 
									FROM T0100_EMP_Skill_Attr_Assign WITH (NOLOCK)
									WHERE CMP_ID = @Cmp_ID AND ((isnull(Desig_Id,0) <> 0 and Desig_Id = @Desig_ID) or (isnull(Dept_Id,0) <> 0 and Dept_Id=@Dept_ID))
									and [TYPE]=0 
									GROUP BY Desig_Id) inqry on inqry.Desig_Id = T0100_EMP_Skill_Attr_Assign.Desig_Id and inqry.Effect_Date=T0100_EMP_Skill_Attr_Assign.Effect_Date
								WHERE CMP_ID = @Cmp_ID GROUP BY T0100_EMP_Skill_Attr_Assign.Desig_Id) QRY 
					ON ES.Desig_Id = QRY.Desig_Id AND ES.Tran_ID = QRY.Tran_ID 
					INNER JOIN T0110_SKILL_WEIGHTAGE SW WITH (NOLOCK) ON ES.Tran_ID = SW.Tran_Id 
					INNER JOIN T0040_SKILL_MASTER SM WITH (NOLOCK) ON SM.Skill_ID = SW.Skill_ID AND SM.Cmp_ID=SW.Cmp_ID 
					Where SM.cmp_Id = @Cmp_ID
				END
			ELSE
				BEGIN	
					SELECT DISTINCT SM.Skill_Name,SM.[Description],SM.Skill_ID,SW.Weightage,ep.Skill_Rating AS Wages_Value 
						   FROM T0100_EMP_Skill_Attr_Assign ES WITH (NOLOCK)
					INNER JOIN (SELECT MAX(Tran_ID) AS Tran_ID,T0100_EMP_Skill_Attr_Assign.Desig_Id 
								FROM T0100_EMP_Skill_Attr_Assign WITH (NOLOCK)
									Inner Join(SELECT MAX(Effect_Date) AS Effect_Date , Desig_Id 
									FROM T0100_EMP_Skill_Attr_Assign WITH (NOLOCK)
									WHERE CMP_ID = @Cmp_ID AND ((isnull(Desig_Id,0) <> 0 and Desig_Id = @Desig_ID) or (isnull(Dept_Id,0) <> 0 and Dept_Id=@Dept_ID)) and [TYPE]=0 
									GROUP BY Desig_Id) inqry on inqry.Desig_Id = T0100_EMP_Skill_Attr_Assign.Desig_Id and inqry.Effect_Date=T0100_EMP_Skill_Attr_Assign.Effect_Date
								WHERE CMP_ID = @Cmp_ID GROUP BY T0100_EMP_Skill_Attr_Assign.Desig_Id) QRY 
					ON ES.Desig_Id = QRY.Desig_Id AND ES.Tran_ID = QRY.Tran_ID 
					INNER JOIN T0110_SKILL_WEIGHTAGE SW WITH (NOLOCK) ON ES.Tran_ID = SW.Tran_Id 
					INNER JOIN T0040_SKILL_MASTER SM WITH (NOLOCK) ON SM.Skill_ID = SW.Skill_ID AND SM.Cmp_ID=SW.Cmp_ID 
					LEFT JOIN T0115_EMP_PROBATION_SKILL_DETAIL_LEVEL EP WITH (NOLOCK) ON EP.Skill_ID=SW.Skill_ID AND 
					EP.Emp_Id=@Emp_ID and EP.Tran_ID=@Tran_ID 
					Where SM.cmp_Id = @Cmp_ID
				END	
		END
	ELSE  --for Attributes
		IF @flag = 'Add' 
			BEGIN
				select DISTINCT AM.Attribute_Name,AM.[Description],AM.Attribute_ID,AW.Weightage,
				0 as Attri_Wages_Value from T0100_EMP_Skill_Attr_Assign ES  WITH (NOLOCK)
				INNER JOIN 
				--(SELECT MAX(Effect_Date) As Effect_date FROM T0100_EMP_Skill_Attr_Assign 
				--WHERE Cmp_ID = @Cmp_ID AND Desig_Id = @Desig_ID and [TYPE]=0)
				-- Qry ON Es.Effect_Date = Qry.Effect_date 
				(SELECT MAX(Tran_ID) AS Tran_ID,T0100_EMP_Skill_Attr_Assign.Desig_Id 
								FROM T0100_EMP_Skill_Attr_Assign WITH (NOLOCK)
									Inner Join(SELECT MAX(Effect_Date) AS Effect_Date , Desig_Id 
									FROM T0100_EMP_Skill_Attr_Assign WITH (NOLOCK)
									WHERE CMP_ID = @Cmp_ID AND ((isnull(Desig_Id,0) <> 0 and Desig_Id = @Desig_ID) or (isnull(Dept_Id,0) <> 0 and Dept_Id=@Dept_ID)) and [TYPE]=1
									GROUP BY Desig_Id) inqry on inqry.Desig_Id = T0100_EMP_Skill_Attr_Assign.Desig_Id and inqry.Effect_Date=T0100_EMP_Skill_Attr_Assign.Effect_Date
								WHERE CMP_ID = @Cmp_ID GROUP BY T0100_EMP_Skill_Attr_Assign.Desig_Id) QRY 
					ON ES.Desig_Id = QRY.Desig_Id AND ES.Tran_ID = QRY.Tran_ID  
				 INNER JOIN T0110_ATTRIBUTE_WEIGHTAGE AW WITH (NOLOCK) ON ES.Tran_Id=AW.Tran_Id 
				 inner join T0040_ATTRIBUTE_MASTER AM WITH (NOLOCK) on AM.Attribute_ID = AW.Attr_Id 
				 Where AM.cmp_Id = @Cmp_ID
			END	
		ELSE
			BEGIN
				select DISTINCT AM.Attribute_Name,AM.[Description],AM.Attribute_ID,AW.Weightage,EP.Attr_Rating as 
				Attri_Wages_Value from T0100_EMP_Skill_Attr_Assign ES WITH (NOLOCK)
				INNER JOIN (SELECT MAX(Tran_ID) AS Tran_ID,T0100_EMP_Skill_Attr_Assign.Desig_Id 
								FROM T0100_EMP_Skill_Attr_Assign WITH (NOLOCK)
									Inner Join(SELECT MAX(Effect_Date) AS Effect_Date , Desig_Id 
									FROM T0100_EMP_Skill_Attr_Assign WITH (NOLOCK)
									WHERE CMP_ID = @Cmp_ID AND ((isnull(Desig_Id,0) <> 0 and Desig_Id = @Desig_ID) or (isnull(Dept_Id,0) <> 0 and Dept_Id=@Dept_ID)) and [TYPE]=1 
									GROUP BY Desig_Id) inqry on inqry.Desig_Id = T0100_EMP_Skill_Attr_Assign.Desig_Id and inqry.Effect_Date=T0100_EMP_Skill_Attr_Assign.Effect_Date
								WHERE CMP_ID = @Cmp_ID GROUP BY T0100_EMP_Skill_Attr_Assign.Desig_Id) QRY 
					ON ES.Desig_Id = QRY.Desig_Id AND ES.Tran_ID = QRY.Tran_ID  
				INNER JOIN T0110_ATTRIBUTE_WEIGHTAGE AW WITH (NOLOCK) ON ES.Tran_Id=AW.Tran_Id 
				INNER JOIN T0040_ATTRIBUTE_MASTER AM WITH (NOLOCK) on AM.Attribute_ID = AW.Attr_Id 
				LEFT JOIN T0115_EMP_PROBATION_ATTRIBUTE_DETAIL_LEVEL EP WITH (NOLOCK) ON EP.Attribute_ID=AW.Attr_Id 
				AND EP.Emp_Id=@Emp_ID and EP.Tran_ID=@Tran_ID
				Where AM.cmp_Id = @Cmp_ID
			END
END

