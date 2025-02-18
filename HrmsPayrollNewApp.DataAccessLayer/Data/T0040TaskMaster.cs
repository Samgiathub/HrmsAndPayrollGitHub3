using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040TaskMaster
{
    public decimal TaskId { get; set; }

    public string? TaskName { get; set; }

    public string? TaskCode { get; set; }

    public string? TaskDescription { get; set; }

    public string? TaskPriority { get; set; }

    public decimal? TaskTypeId { get; set; }

    public decimal? ProjectId { get; set; }

    public DateTime? DueDate { get; set; }

    public string? Duration { get; set; }

    public int? Completed { get; set; }

    public int? IsReOpen { get; set; }

    public decimal? ProjectStatusId { get; set; }

    public decimal? MilestoneId { get; set; }

    public DateTime? DeadlineDate { get; set; }

    public int? AllEmployeeTask { get; set; }

    public int? AllProjectTask { get; set; }

    public decimal? EstimateCost { get; set; }

    public string? EstimateDuration { get; set; }

    public string? TaskAttachment { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? CreatedBy { get; set; }

    public DateTime? CreatedDate { get; set; }

    public decimal? ModifyBy { get; set; }

    public DateTime? ModifyDate { get; set; }

    public virtual T0010CompanyMaster? Cmp { get; set; }

    public virtual T0011Login? CreatedByNavigation { get; set; }

    public virtual T0040MilestoneMaster? Milestone { get; set; }

    public virtual T0040TsProjectMaster? Project { get; set; }

    public virtual T0040ProjectStatus? ProjectStatus { get; set; }

    public virtual ICollection<T0050TaskDetail> T0050TaskDetails { get; set; } = new List<T0050TaskDetail>();

    public virtual ICollection<T0110TsApplicationDetail> T0110TsApplicationDetails { get; set; } = new List<T0110TsApplicationDetail>();

    public virtual ICollection<T0130TsApprovalDetail> T0130TsApprovalDetails { get; set; } = new List<T0130TsApprovalDetail>();

    public virtual T0040TaskTypeMaster? TaskType { get; set; }
}
