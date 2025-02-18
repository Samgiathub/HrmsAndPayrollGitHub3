﻿



CREATE VIEW [dbo].[V0110_EMP_EARN_DEDUCTION_REVISED]
AS

SELECT    b.Branch_ID,EED.AD_ID, EED.FOR_DATE, AD.AD_NAME, EED.TRAN_ID, EED.CMP_ID, EED.EMP_ID, EM.Alpha_Emp_Code,EM.Emp_Full_Name,EM.Emp_First_Name,
		  EED.E_AD_FLAG, EED.E_AD_MODE, EED.E_AD_PERCENTAGE, Case When Isnull(EED.Is_Calculate_Zero,0) =0 Then dbo.F_Show_Decimal(EED.E_AD_AMOUNT,EM.Cmp_ID) Else dbo.F_Show_Decimal(-1,EM.Cmp_ID) End as E_AD_AMOUNT , EED.E_AD_MAX_LIMIT, AD.AD_LEVEL, 
          AD.AD_NOT_EFFECT_SALARY, AD.AD_PART_OF_CTC, AD.AD_ACTIVE, AD.AD_NOT_EFFECT_ON_PT, AD.FOR_FNF, 
          AD.NOT_EFFECT_ON_MONTHLY_CTC, AD.Is_Yearly, AD.Not_Effect_on_Basic_Calculation, AD.AD_CALCULATE_ON, 
          AD.Effect_Net_Salary, AD.AD_EFFECT_MONTH, AD.AD_DEF_ID, EED.ENTRY_TYPE,
          CASE WHEN E_AD_Flag = 'D' THEN '-' ELSE '+' END AS E_AD_Flag1, AD.Add_in_sal_amt,
          B.Vertical_ID,B.SubVertical_ID,B.Dept_ID  --Added By Jaina 23-09-2015
		  ,ad.hide_in_Reports  
		  ,EM.Type_ID,EM.Cat_ID  --added by chetan 27112017
FROM      dbo.T0110_EMP_EARN_DEDUCTION_REVISED AS EED WITH (NOLOCK) INNER JOIN
		  dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK)  ON EED.EMP_ID= EM.Emp_ID INNER JOIN
		  dbo.T0050_AD_MASTER AS AD WITH (NOLOCK)  ON EED.AD_ID = AD.AD_ID INNER JOIN
		  --Added By Jaina 03-09-2015 Start
		  (
			SELECT	EMP_ID, Branch_ID, CMP_ID,I.Vertical_ID,I.SubVertical_ID,I.Dept_ID
			FROM	T0095_INCREMENT I WITH (NOLOCK) 
			WHERE	I.INCREMENT_ID = (
										SELECT	TOP 1 INCREMENT_ID
										FROM	T0095_INCREMENT I1 WITH (NOLOCK) 
										WHERE	I1.EMP_ID=I.EMP_ID AND I1.CMP_ID=I.CMP_ID
										ORDER BY	INCREMENT_EFFECTIVE_DATE DESC, INCREMENT_ID DESC
									)
		  ) AS B ON B.EMP_ID = EM.EMP_ID AND B.CMP_ID=EM.CMP_ID --Added By Jaina 02-09-2015 End




