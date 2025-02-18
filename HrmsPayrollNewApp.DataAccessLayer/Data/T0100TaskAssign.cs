using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100TaskAssign
{
    public int TaskId { get; set; }

    public int? TaskParentId { get; set; }

    public int? StatusId { get; set; }

    public int? PriorityId { get; set; }

    public int? ProjectId { get; set; }

    public int? TaskTypeId { get; set; }

    public int? TaskCatId { get; set; }

    public int? CreatedEmpId { get; set; }

    public int? AssignedEmpId { get; set; }

    public string? TaskTitle { get; set; }

    public string? TaskDescription { get; set; }

    public DateTime? TaskDueDate { get; set; }

    public DateTime? TaskTargetDate { get; set; }

    public string? TaskEstimatedTime { get; set; }

    public DateTime? TaskCreatedDate { get; set; }

    public string? TaskAttachment { get; set; }

    public int? TaskIsMulti { get; set; }
}
