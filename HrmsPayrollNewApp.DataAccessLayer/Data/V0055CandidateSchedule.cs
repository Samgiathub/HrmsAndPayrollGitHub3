using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0055CandidateSchedule
{
    public decimal ResumeId { get; set; }

    public decimal Status { get; set; }

    public decimal RecPostId { get; set; }

    public decimal? ProcessDisNo { get; set; }

    public string? Schedule { get; set; }

    public string? SchedulePrev { get; set; }

    public string? Status1 { get; set; }

    public decimal CmpId { get; set; }

    public string? AppFullName { get; set; }

    public string EmpFirstName { get; set; } = null!;

    public decimal? ExpCtc { get; set; }

    public decimal TotalExperience { get; set; }

    public string JobTitle { get; set; } = null!;

    public string? FileName { get; set; }

    public DateTime? ResumePostedDate { get; set; }

    public string? ResumeName { get; set; }

    public string? PrimaryEmail { get; set; }

    public string LocName { get; set; } = null!;

    public byte? ResumeStatus { get; set; }

    public DateTime DateOfBirth { get; set; }

    public string? MobileNo { get; set; }
}
