CREATE Procedure [dbo].[P0040_Get_Grievance_CommitteeMembers_Details]
@CommitteID nvarchar(10),
@CmpID int,
@AppID int = 0
As
Begin

				Declare @CommiteeMembers as Table
				(
				  EmpID int ,
				  EmpAlphaCode Varchar(Max),
				  EmpName Varchar(Max),
				  MemType Varchar(Max),
				  MemEmail Varchar(Max)
				)


				--Declare @CommitteID as int  = 1 
				--declare @CmpID as int =120

				declare @ChairParson as Nvarchar(500)
				declare @NodelHR as Nvarchar(500)
				declare @ComMem as Nvarchar(500)


				select @ChairParson=COALESCE(@ChairParson + ', ' + cast(Chairperson_id as nvarchar),cast(Chairperson_id as nvarchar)),
				@NodelHR=COALESCE(@NodelHR + ', ' + cast(NodelHR_id as nvarchar),cast(NodelHR_id as nvarchar)),
				@ComMem=COALESCE(@ComMem + ', ' + cast(CommitteeMem_ID as nvarchar),cast(CommitteeMem_ID as nvarchar)) 
				from  T0040_Griev_Committee_Master
				where GC_ID in (Select Cast(Data As Numeric) As ID FROM dbo.Split(@CommitteID,',') T Where T.Data <> '')
				and Cmp_id=@CmpID



				
				--select @ChairParson=Chairperson_id,@NodelHR=NodelHR_id,@ComMem=CommitteeMem_ID 
				--from  T0040_Griev_Committee_Master where GC_ID=@CommitteID and Cmp_id=@CmpID
				
				
				
				print @ChairParson
				print @NodelHR
				print @ComMem
				
				--For Chairperson
				insert into @CommiteeMembers (EmpID,EmpAlphaCode,EmpName,MemType,MemEmail)
				select Emp_ID,Alpha_Emp_Code,Emp_Full_Name,'Chairperson',Work_Email from T0080_EMP_MASTER 
				where Cmp_ID=@CmpID and Emp_ID in (select cast(data  as numeric) from dbo.Split (@ChairParson,',')  T Where T.Data <> '' )
			
				
				--For NodelHR
				insert into @CommiteeMembers (EmpID,EmpAlphaCode,EmpName,MemType,MemEmail)
				select Emp_ID,Alpha_Emp_Code,Emp_Full_Name,'Nodel HR',Work_Email from T0080_EMP_MASTER 
				where Cmp_ID=@CmpID and Emp_ID in (select cast(data  as numeric) from dbo.Split (@NodelHR,',')  T Where T.Data <> '' )
	
				
				--For Committee Member
				insert into @CommiteeMembers (EmpID,EmpAlphaCode,EmpName,MemType,MemEmail)
				select Emp_ID,Alpha_Emp_Code,Emp_Full_Name,'Committee Member',Work_Email 
				from T0080_EMP_MASTER where Cmp_ID=@CmpID and 
				Emp_ID in (select cast(data  as numeric) from dbo.Split (@ComMem,',')  T Where T.Data <> '' )


				If @AppID <>0 
				Begin

						--For Application Person
						insert into @CommiteeMembers (EmpID,EmpAlphaCode,EmpName,MemType,MemEmail)
						Select isnull(EM.Emp_ID,0) ,
								isnull(EM.Alpha_Emp_Code,''),
								isnull(EM.Emp_Full_Name,GA.NameF),
								'Applicant',
								isnull(EM.Work_Email,GA.EmailF)
						from T0080_Griev_Application GA
						left join T0080_EMP_MASTER EM on EM.Emp_ID = GA.Emp_IDF
						where GA.GA_ID = @AppID



						--For Againts Person
						insert into @CommiteeMembers (EmpID,EmpAlphaCode,EmpName,MemType,MemEmail)
						Select isnull(EM.Emp_ID,0),
							   isnull(EM.Alpha_Emp_Code,''),
							   isnull(EM.Emp_Full_Name,GA.NameT),
							   'Againts',
							   isnull(EM.Work_Email,GA.EmailT) 
						from T0080_Griev_Application GA
						left join T0080_EMP_MASTER EM on EM.Emp_ID = GA.Emp_IDT
						where GA.GA_ID = @AppID

				End

				
				select EmpID,EmpAlphaCode,EmpName,MemType,MemEmail from @CommiteeMembers

End