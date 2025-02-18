using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0090HrmsRecruitmentFinalScore
{
    public string? Initial { get; set; }

    public string? EmpFirstName { get; set; }

    public string? EmpLastName { get; set; }

    public string? AppFullName { get; set; }

    public string? Gender { get; set; }

    public string? PresentStreet { get; set; }

    public string? PresentCity { get; set; }

    public string? PresentState { get; set; }

    public string? PresentPostBox { get; set; }

    public string? PermanentStreet { get; set; }

    public string? PermanentCity { get; set; }

    public string? PermanentState { get; set; }

    public string? PermanenttPostBox { get; set; }

    public string? MobileNo { get; set; }

    public string? PrimaryEmail { get; set; }

    public decimal? PresentLoc { get; set; }

    public string? MaritalStatus { get; set; }

    public string? HomeTelNo { get; set; }

    public string? OtherEmail { get; set; }

    public DateTime? DateOfBirth { get; set; }

    public string? EmpSecondName { get; set; }

    public decimal? PermanentLocId { get; set; }

    public decimal TransId { get; set; }

    public decimal ResumeId { get; set; }

    public decimal? CmpId { get; set; }

    public string? RecJobCode { get; set; }

    public decimal? ProcessId { get; set; }

    public decimal? RecPostId { get; set; }

    public decimal? ActualRate { get; set; }

    public decimal? GivenRate { get; set; }

    public string? Notes { get; set; }

    public decimal? Status1 { get; set; }

    public decimal RecReqId { get; set; }

    public string JobTitle { get; set; } = null!;

    public DateTime? DateOfJoin { get; set; }

    public decimal? RStatus { get; set; }
}
