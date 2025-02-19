






CREATE  VIEW [dbo].[V0000_MONTHLY_EMP_BANK_PAYMENT_BACKUP_MHL_20122021]
AS
SELECT    MEBP.Emp_ID, MEBP.Cmp_ID, MEBP.For_Date, MEBP.Payment_Date, MEBP.Emp_Bank_ID, MEBP.Payment_Mode, MEBP.Net_Amount, MEBP.Emp_Bank_AC_No,
		  MEBP.Cmp_Bank_ID,MEBP.Emp_Cheque_No, MEBP.Cmp_Bank_Cheque_No, MEBP.Cmp_Bank_AC_No, MEBP.Emp_Left, MEBP.Status, EMP.Alpha_Emp_Code,
		  EMP.Emp_Full_Name, ISNULL(BKM.Bank_Name, '-') AS Bank_Name,I.Branch_ID,BRM.Branch_Name,
		  CASE WHEN isnull(Am.AD_ID,0) = 0 THEN MEBP.Process_type ELSE Am.Ad_Name END as Process_Type,ISNULL(AM.AD_ID,0) as Ad_Id,I.Vertical_ID,
		  I.SubVertical_ID,I.Dept_ID,ISNULL(process_type_id,0) as process_type_id,ISNULL(MEBP.payment_process_id,0) as payment_process_id,I.Desig_Id,
		  I.Grd_ID,I.Cat_ID,I.Type_ID,I.subBranch_ID , BOND.Bond_Id , BOND.Bond_Apr_Id ,cad.Claim_ID,cad.Claim_Apr_ID,cm.Claim_Name--added by jimit 28072017
FROM    dbo.MONTHLY_EMP_BANK_PAYMENT MEBP WITH (NOLOCK)
		INNER JOIN		dbo.T0080_EMP_MASTER EMP WITH (NOLOCK) ON MEBP.Emp_ID = EMP.Emp_ID
		LEFT OUTER JOIN	dbo.T0040_BANK_MASTER BKM WITH (NOLOCK) ON MEBP.Emp_Bank_ID = BKM.Bank_ID AND MEBP.Cmp_Bank_ID = BKM.Bank_ID AND EMP.Bank_ID = BKM.Bank_ID
        INNER JOIN
				  (	SELECT Branch_ID,I.Increment_Id, I.Emp_Id,I.Grd_ID,I.Desig_Id,I.Dept_ID,I.Vertical_ID,I.SubVertical_ID,I.Segment_ID,I.Cat_ID,I.Type_ID,I.subBranch_ID 
					FROM T0095_INCREMENT I WITH (NOLOCK)
						INNER JOIN
							(SELECT Max(TI.Increment_ID) Increment_Id,ti.Emp_ID 
							 FROM T0095_INCREMENT TI WITH (NOLOCK)
								INNER JOIN
								(SELECT Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID
								 FROM T0095_Increment WITH (NOLOCK)
								 WHERE Increment_effective_Date <= GETDATE()
								 GROUP BY emp_ID
								) new_inc on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
							WHERE TI.Increment_effective_Date <= GETDATE()
							GROUP BY ti.emp_id
							) Qry on I.Increment_Id = Qry.Increment_Id 
				  ) I ON EMP.EMP_ID=I.EMP_ID
		LEFT OUTER JOIN T0050_AD_MASTER AM WITH (NOLOCK)			ON CASE WHEN Process_Type <> 'Bond' THEN MEBP.AD_ID else 0 end = AM.AD_ID
		LEFT OUTER JOIN T0030_BRANCH_MASTER BRM WITH (NOLOCK)		ON I.Branch_id = BRM.Branch_ID
		LEFT OUTER JOIN T0120_BOND_APPROVAL BOND WITH (NOLOCK)	ON BOND.Payment_Process_ID = MEBP.payment_process_id
		LEFT OUTER JOIN T0130_CLAIM_APPROVAL_DETAIL cad WITH (NOLOCK)	ON cad.Payment_Process_ID = MEBP.payment_process_id
		LEFT OUTER JOIN T0040_CLAIM_MASTER CM WITH (NOLOCK) ON cm.Claim_ID = cad.Claim_ID



