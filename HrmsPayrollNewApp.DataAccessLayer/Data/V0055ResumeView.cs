using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0055ResumeView
{
    public string JobTitle { get; set; } = null!;

    public decimal? SEmpId { get; set; }

    public string AppFullName { get; set; } = null!;

    public decimal TotalExperience { get; set; }

    public decimal ResumeId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? RecPostId { get; set; }

    public DateTime? ResumePostedDate { get; set; }

    public string? Initial { get; set; }

    public string EmpFirstName { get; set; } = null!;

    public string? EmpSecondName { get; set; }

    public string EmpLastName { get; set; } = null!;

    public DateTime DateOfBirth { get; set; }

    public string? MaritalStatus { get; set; }

    public string? Gender { get; set; }

    public string? PresentStreet { get; set; }

    public string? PresentCity { get; set; }

    public string? PresentState { get; set; }

    public string? PresentPostBox { get; set; }

    public string? PermanentStreet { get; set; }

    public string? PermanentCity { get; set; }

    public string? PermanentState { get; set; }

    public string? PermanenttPostBox { get; set; }

    public string? HomeTelNo { get; set; }

    public string MobileNo { get; set; } = null!;

    public string? PrimaryEmail { get; set; }

    public string? OtherEmail { get; set; }

    public decimal? CurCtc { get; set; }

    public decimal? ExpCtc { get; set; }

    public string? ResumeName { get; set; }

    public string? FileName { get; set; }

    public byte? ResumeStatus { get; set; }

    public decimal? FinalCtc { get; set; }

    public DateTime? DateOfJoin { get; set; }

    public decimal? BasicSalary { get; set; }

    public decimal? EmpFullPf { get; set; }

    public decimal? EmpFixSalary { get; set; }

    public decimal? PresentLoc { get; set; }

    public decimal? PermanentLocId { get; set; }

    public string LocName { get; set; } = null!;

    public string? EmpFullName { get; set; }

    public decimal? CatId { get; set; }

    public decimal? GrdId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? TypeId { get; set; }

    public decimal? ShiftId { get; set; }

    public decimal? BankId { get; set; }

    public string? NonTechnicalSkill { get; set; }

    public string? RecPostCode { get; set; }

    public string? ResumeCode { get; set; }

    public DateTime? SystemDate { get; set; }

    public decimal? BranchId { get; set; }
}
