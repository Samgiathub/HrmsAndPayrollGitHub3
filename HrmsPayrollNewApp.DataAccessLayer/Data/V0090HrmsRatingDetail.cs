using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0090HrmsRatingDetail
{
    public decimal InterviewProcessDetailId { get; set; }

    public decimal CmpId { get; set; }

    public decimal RecPostId { get; set; }

    public decimal? ProcessId { get; set; }

    public decimal? SEmpId { get; set; }

    public decimal? DisNo { get; set; }

    public string ProcessName { get; set; } = null!;

    public decimal InterviewScheduleId { get; set; }

    public decimal? Expr3 { get; set; }

    public decimal ResumeId { get; set; }

    public decimal? Rating { get; set; }

    public DateTime? ScheduleDate { get; set; }

    public string? ScheduleTime { get; set; }

    public decimal? ProcessDisNo { get; set; }

    public string EmpFirstName { get; set; } = null!;

    public string? EmpSecondName { get; set; }

    public string EmpLastName { get; set; } = null!;

    public string? PrimaryEmail { get; set; }

    public string? OtherEmail { get; set; }

    public string RecPostCode { get; set; } = null!;

    public string? AppFullName { get; set; }

    public decimal? ActualRate { get; set; }

    public decimal? BasicSalary { get; set; }

    public DateTime? DateOfJoin { get; set; }

    public string JobTitle { get; set; } = null!;

    public string Comments { get; set; } = null!;
}
