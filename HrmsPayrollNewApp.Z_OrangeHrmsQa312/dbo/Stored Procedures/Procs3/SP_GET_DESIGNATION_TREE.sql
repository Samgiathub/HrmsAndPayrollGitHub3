




CREATE PROCEDURE [dbo].[SP_GET_DESIGNATION_TREE]  
@Cmp_Id numeric(18,0),  
@Desig_id_Main numeric(18,0),  
@Emp_ID numeric(18,0) =0  ,
@Branch_ID  numeric(18,0) =0  
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

  
if @Desig_id_Main = 0  
 set @Desig_id_Main = null  
if @Emp_ID = 0  
 set @Emp_ID = null   
 
 if @Branch_ID =0
   set @Branch_ID =NULL
 
if @Desig_id_Main is null And @Emp_ID is null   
 Begin  
   
Declare @Desig_Main table  
(  
Desig_ID numeric(18,0),  
Cmp_ID numeric(18,0),  
Desig_Name varchar(50),  
Desig_Dis_No numeric(18,0),  
Def_Id   numeric(18,0),  
Parent_ID  numeric(18,0),  
Is_MAin numeric(18,0),  
Desig_Level numeric(18,0),  
DEsig_Sub   numeric(18,0),  
Sys_Date datetime,  
Count numeric(18,0),  
Max_Level numeric(18,0)  
)  
  
Declare @Row_Id numeric(18,0)  
Declare @Desig_Level numeric(18,0)  
Declare @Desig_Dis_No numeric(18,0)  
Declare @Desig_ID numeric(18,0)  
Declare @Desig_Name varchar(50)  
declare @Parent_ID numeric(18,0)  
Declare @Level numeric(18,0)  
  
DEclare @New_ID numeric(18,0)  
set @Level=1  
set @Row_Id=0  
set @Desig_level=0  
  
insert into @Desig_Main   
select Desig_ID,Cmp_ID,Desig_Name,Desig_Dis_No,Def_Id,Parent_ID,Is_MAin,0,0,Getdate(),0,0 from t0040_designation_master WITH (NOLOCK) where cmp_id=@Cmp_ID  
  
  select * from Desig_Main
  
Declare curDesgi cursor for  
  select Desig_Id,Parent_ID,Desig_Level from @Desig_Main order by Parent_ID  
   open curDesgi  
    fetch next from curDesgi into  @Desig_ID,@Parent_ID,@Desig_Level  
     while @@fetch_status = 0  
     Begin  
     if isnull(@Parent_ID,0) = 0  
      Begin  
        Update @Desig_Main set Desig_Level=@Level where Parent_ID=@Desig_ID  
      End  
      Declare @Desig_ID_sub numeric(18,0)  
      Declare @Desig_Level_sub numeric(18,0)  
      Declare @Level_sub numeric(18,0)  
       Declare curDesgi_sub cursor for  
       select Desig_Id,Desig_Level from @Desig_Main where Desig_Level=@Level  
        open curDesgi_sub  
         fetch next from curDesgi_sub into  @Desig_ID_sub,@Desig_Level_sub  
          while @@fetch_status = 0  
           Begin  
            set @Level_sub=@Level+1  
            update @Desig_Main set Desig_Level=@Level_sub where Parent_ID=@Desig_ID_sub  
           fetch next from curDesgi_sub into  @Desig_ID_sub,@Desig_Level_sub  
          end   
        close curDesgi_sub  
        deallocate curDesgi_sub  
        set @Level=@Level+1  
     fetch next from curDesgi into  @Desig_ID,@Parent_ID,@Desig_Level  
     end   
  close curDesgi  
deallocate curDesgi  



Declare @Desig_ID_sub1 numeric(18,0)  
Declare @Desig_Level_sub1 numeric(18,0)  
Declare curDesgi_sub1 cursor for  
       select Desig_Id,Desig_Level from @Desig_Main order by Desig_Level,Parent_ID  
        open curDesgi_sub1  
         fetch next from curDesgi_sub1 into  @Desig_ID_sub1,@Desig_Level_sub1  
          while @@fetch_status = 0  
           Begin  
            Declare @Desig_ID_sub2 numeric(18,0)  
            Declare @Desig_Level_sub2 numeric(18,0)  
            Declare @Set_SubLevel numeric(18,0)  
            set @Set_SubLevel=1  
              
            Declare curDesgi_sub2 cursor for  
            select Desig_Id,Desig_Level from @Desig_Main Where PArent_ID=@Desig_ID_sub1 order by Desig_Level,Parent_ID  
            open curDesgi_sub2  
              fetch next from curDesgi_sub2 into  @Desig_ID_sub2,@Desig_Level_sub2  
               while @@fetch_status = 0  
                Begin  
                update @Desig_Main set Desig_Sub=@Set_SubLevel where Desig_Id=@Desig_ID_sub2  
                set @Set_SubLevel=@Set_SubLevel+1  
            fetch next from curDesgi_sub2 into  @Desig_ID_sub2,@Desig_Level_sub2  
            end   
            close curDesgi_sub2  
            deallocate curDesgi_sub2  
              
          fetch next from curDesgi_sub1 into  @Desig_ID_sub1,@Desig_Level_sub1  
          end   
        close curDesgi_sub1  
        deallocate curDesgi_sub1  
          
         
Declare @L_Count numeric(18,0)  
Declare @Number numeric(18,0)  
set @Number=0  
Declare curCount cursor for  
 select Desig_Level from @Desig_Main   order by Desig_Level  
  open curCount  
   fetch next from curCount into  @L_Count  
   while @@fetch_status = 0  
   Begin  
   select @Number = Count(DEsig_Level) from @Desig_Main where Desig_Level = @L_Count  
   update @Desig_Main set Count=@Number where Desig_Level = @L_Count  
  fetch next from curCount into  @L_Count  
end   
close curCount  
deallocate curCount  
   Declare @MAx_Level numeric(18,0)  
   select @MAx_Level  = Max(Desig_Level) from @Desig_Main  
   update @Desig_Main set MAx_LEvel=@MAx_Level   
   select D.*,Dm.Desig_Name as Parent_Name from @Desig_Main D Left Outer join t0040_designation_master Dm WITH (NOLOCK) on D.Parent_ID=Dm.DEsig_ID  order by D.Desig_Level,D.Parent_ID,D.Desig_Sub  
 End  
else  
		Begin  
				Declare @Emp_Main table  
				(  
				Emp_ID numeric(18,0),  
				Cmp_ID numeric(18,0),  
				Emp_Full_Name varchar(50),  
				Emp_Code numeric(18,0),  
				Gender varchar(2),  
				Parent_ID  numeric(18,0),  
				Emp_Level numeric(18,0),  
				Count   numeric(18,0),  
				Max_Level numeric(18,0),  
				 Basic_Salary numeric(22,2),  
				 Gross_Salary numeric(22,2)  
    )  
      if @Emp_ID is null   
      BEgin  
       insert into @Emp_Main  
       select E.Emp_ID,@Cmp_ID,E.Emp_Full_Name,E.Emp_Code,E.Gender,E.Emp_Superior,0,0,0,I.Basic_Salary,I.Gross_Salary From t0080_Emp_Master E WITH (NOLOCK) Inner join t0095_increment I WITH (NOLOCK) on E.Increment_ID=I.Increment_ID where Isnull(E.Emp_ID,0) = isnull(@Emp_ID ,Isnull(E.Emp_ID,0)) and E.Desig_ID=@Desig_id_Main And E.Emp_LEft <> 'Y' and Isnull(E.Branch_ID,0) = isnull(@Branch_ID ,Isnull(E.Branch_ID,0)) 
         
         
       insert into @Emp_Main  
       select E.Emp_ID,@Cmp_ID,E.Emp_Full_Name,E.Emp_Code,E.Gender,E.Emp_Superior,1,0,0, I.Basic_Salary,I.Gross_Salary From t0080_Emp_Master E WITH (NOLOCK) Inner join t0095_increment I WITH (NOLOCK) on E.Increment_ID=I.Increment_ID where Isnull(E.Emp_ID,0) = isnull(@Emp_ID ,Isnull(E.Emp_ID,0)) and E.Emp_LEft <> 'Y'  and  Isnull(E.Branch_ID,0) = isnull(@Branch_ID ,Isnull(E.Branch_ID,0)) 
       And E.Emp_Superior in (select Emp_ID From t0080_Emp_Master WITH (NOLOCK) where Desig_ID=@Desig_id_Main And Emp_LEft <> 'Y'  and Isnull(E.Branch_ID,0) = isnull(@Branch_ID ,Isnull(E.Branch_ID,0)) )  
         
        -- select * from @Emp_Main
      End  
     else  
      Begin  
      
       insert into @Emp_Main  
       select E.Emp_ID,@Cmp_ID,E.Emp_Full_Name,E.Emp_Code,E.Gender,E.Emp_Superior,0,0,0,I.Basic_Salary,I.Gross_Salary From t0080_Emp_Master E WITH (NOLOCK) Inner join t0095_increment I WITH (NOLOCK) on E.Increment_ID=I.Increment_ID where E.Emp_ID=@Emp_ID And E.Emp_LEft <> 'Y' and Isnull(E.Branch_ID,0) = isnull(@Branch_ID ,Isnull(E.Branch_ID,0))     
         
       insert into @Emp_Main  
       select E.Emp_ID,@Cmp_ID,E.Emp_Full_Name,E.Emp_Code,E.Gender,E.Emp_Superior,1,0,0,I.Basic_Salary,I.Gross_Salary From t0080_Emp_Master E WITH (NOLOCK) Inner join t0095_increment I WITH (NOLOCK) on E.Increment_ID=I.Increment_ID  where  Emp_LEft <> 'Y'  and Isnull(E.Branch_ID,0) = isnull(@Branch_ID ,Isnull(E.Branch_ID,0)) 
       And E.Emp_Superior in (select Emp_ID From t0080_Emp_Master WITH (NOLOCK) where Emp_ID=@Emp_ID And Emp_LEft <> 'Y' and Isnull(E.Branch_ID,0) = isnull(@Branch_ID ,Isnull(E.Branch_ID,0)) )  
      End   
      
      
         
       insert into @Emp_Main  
       select E.Emp_ID,@Cmp_ID,E.Emp_Full_Name,E.Emp_Code,E.Gender,E.Emp_Superior,2,0,0,I.Basic_Salary,I.Gross_Salary From t0080_Emp_Master E WITH (NOLOCK) Inner join t0095_increment I WITH (NOLOCK) on E.Increment_ID=I.Increment_ID  where  E.Emp_LEft <> 'Y'  
      And E.Emp_Superior in (select Emp_ID From @Emp_Main where Emp_Level=1)  
         
       
       insert into @Emp_Main  
       select E.Emp_ID,@Cmp_ID,E.Emp_Full_Name,E.Emp_Code,E.Gender,E.Emp_Superior,3,0,0, I.Basic_Salary,I.Gross_Salary From t0080_Emp_Master E WITH (NOLOCK) Inner join t0095_increment I WITH (NOLOCK) on E.Increment_ID=I.Increment_ID  where  E.Emp_LEft <> 'Y'  
      And E.Emp_Superior in (select Emp_ID From @Emp_Main where Emp_Level=2)  
      
       insert into @Emp_Main  
       select E.Emp_ID,@Cmp_ID,E.Emp_Full_Name,E.Emp_Code,E.Gender,E.Emp_Superior,4,0,0, I.Basic_Salary,I.Gross_Salary From t0080_Emp_Master E WITH (NOLOCK) Inner join t0095_increment I WITH (NOLOCK) on E.Increment_ID=I.Increment_ID  where  E.Emp_LEft <> 'Y'  
      And E.Emp_Superior in (select Emp_ID From @Emp_Main where Emp_Level=3) 
      
   
	   insert into @Emp_Main  
       select E.Emp_ID,@Cmp_ID,E.Emp_Full_Name,E.Emp_Code,E.Gender,E.Emp_Superior,5,0,0, I.Basic_Salary,I.Gross_Salary From t0080_Emp_Master E WITH (NOLOCK) Inner join t0095_increment I WITH (NOLOCK) on E.Increment_ID=I.Increment_ID  where  E.Emp_LEft <> 'Y'  
      And E.Emp_Superior in (select Emp_ID From @Emp_Main where Emp_Level=4)
   
     declare @E_Count numeric(18,0)  
     Declare @E_Number numeric(18,0)  
     set @E_Number=0  
  
      
     select @E_Count=Count(Emp_Level) from @Emp_Main where Emp_Level=0  
     update @Emp_Main set Count=@E_Count where Emp_Level=0  
     set @E_Count=0  
       
     select @E_Count=Count(Emp_Level) from @Emp_Main where Emp_Level=1  
     update @Emp_Main set Count=@E_Count where Emp_Level=1  
     set @E_Count=0  
       
     select @E_Count=Count(Emp_Level) from @Emp_Main where Emp_Level=2  
     update @Emp_Main set Count=@E_Count where Emp_Level=2  
     set @E_Count=0  
       
     select @E_Count=Count(Emp_Level) from @Emp_Main where Emp_Level=3  
     update @Emp_Main set Count=@E_Count where Emp_Level=3  
     set @E_Count=0  
       
     DEclare @E_MAx_Level numeric(18,0)  
     select @E_MAx_Level  = Max(Emp_Level) from @Emp_Main  
     update @Emp_Main set MAx_LEvel=@E_MAx_Level   
    
     select E.*,isnull(Em.Emp_Code,0) as Parent_Code from @Emp_Main E Left outer join t0080_Emp_Master EM WITH (NOLOCK) on E.Parent_ID = Em.Emp_ID and Isnull(EM.Branch_ID,0) = isnull(@Branch_ID ,Isnull(EM.Branch_ID,0)) -- where Isnull(E.Emp_ID,0) != isnull(@Emp_ID ,Isnull(E.Emp_ID,0))   --where emp_level<2  
     
     --select * from @Desig_Main
   
    End  
  
RETURN  




