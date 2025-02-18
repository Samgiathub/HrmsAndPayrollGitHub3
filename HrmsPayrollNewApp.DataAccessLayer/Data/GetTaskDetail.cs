using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class GetTaskDetail
{
    public decimal TaskId { get; set; }

    public string? TaskName { get; set; }

    public string? TaskCode { get; set; }

    public string? TaskDescription { get; set; }

    public string TaskPriority { get; set; } = null!;

    public decimal? CmpId { get; set; }

    public decimal TaskTypeId { get; set; }

    public decimal? ProjectId { get; set; }

    public string? DueDate { get; set; }

    public string? DeadlineDate { get; set; }

    public string? Duration { get; set; }

    public int? Completed { get; set; }

    public int? IsReOpen { get; set; }

    public decimal ProjectStatusId { get; set; }

    public decimal MilestoneId { get; set; }

    public decimal? AssignTo { get; set; }

    public int? AllEmployeeTask { get; set; }

    public int? AllProjectTask { get; set; }

    public decimal EstimateCost { get; set; }

    public string EstimateDuration { get; set; } = null!;

    public string TaskAttachment { get; set; } = null!;

    public decimal? TaskDetailId { get; set; }

    public decimal? EmpId { get; set; }

    public string EmployeeName { get; set; } = null!;

    public string? DesigName { get; set; }

    public string? BranchName { get; set; }
}
