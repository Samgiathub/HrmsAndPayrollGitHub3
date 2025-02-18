using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0110TaskDetail
{
    public int TaskDetailId { get; set; }

    public int? TaskId { get; set; }

    public int? TaskParentId { get; set; }

    public int? StatusId { get; set; }

    public int? PriorityId { get; set; }

    public int? ProjectId { get; set; }

    public int? TaskTypeId { get; set; }

    public int? TaskCatId { get; set; }

    public int? CreatedEmpId { get; set; }

    public int? AssignedEmpId { get; set; }

    public int? ActivityId { get; set; }

    public string? TaskTitle { get; set; }

    public string? TaskDescription { get; set; }

    public DateTime? TaskDueDate { get; set; }

    public DateTime? TaskTargetDate { get; set; }

    public string? TaskEstimatedTime { get; set; }

    public DateTime? TaskUpdatedDate { get; set; }

    public int? TaskUpdatedEmpId { get; set; }

    public TimeOnly? TaskLogHours { get; set; }

    public string? TaskLogComments { get; set; }

    public string? TaskLogNotes { get; set; }

    public bool? TaskIsActive { get; set; }
}
