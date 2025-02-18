using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0055HrmsInterviewScheduleProcess
{
    public decimal? Expr1 { get; set; }

    public decimal? ProcessId { get; set; }

    public decimal? SEmpId { get; set; }

    public decimal? DisNo { get; set; }

    public decimal? CmpId { get; set; }

    public string? EmpFullName { get; set; }

    public decimal? RecPostId { get; set; }

    public string? ProcessName { get; set; }

    public decimal InterviewScheduleId { get; set; }

    public decimal? InterviewProcessDetailId { get; set; }

    public decimal? Rating { get; set; }

    public DateTime? ScheduleDate { get; set; }

    public string? ScheduleTime { get; set; }

    public decimal? ProcessDisNo { get; set; }

    public decimal Status { get; set; }

    public decimal ResumeId { get; set; }

    public string Comments { get; set; } = null!;
}
